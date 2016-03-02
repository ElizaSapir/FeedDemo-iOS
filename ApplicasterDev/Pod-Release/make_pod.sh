#!/bin/sh

selected_product="APFeed"

selected_workspace="FeedDemo-Swift/FeedDemo-Swift.xcworkspace"
selected_scheme="APFeed2"
selected_bundle="APFeed2Bundle.bundle" # the bundles to copy into the distributed framework, separated by ;
selected_pods_dir="APFeed" # the name of the remote folder on the CocoaPods repository in which the relevant podspecs located
bintray_api_key=$1 # required to securely upload the product to bintray

# start with a clean output folder
selected_output_dir="$(mktemp -d -t feed2-release)/build"
mkdir -p "${selected_output_dir}/compile"
mkdir -p "${selected_output_dir}/product"

current_device_build_dir="${selected_output_dir}/compile/Release-iphoneos"
xcodebuild clean build \
					 -workspace ${selected_workspace} \
					 -scheme ${selected_scheme} \
					 -sdk iphoneos \
					 -configuration Release \
					 CONFIGURATION_BUILD_DIR=${current_device_build_dir}

current_simulator_build_dir="${selected_output_dir}/compile/Release-iphonesimulator"
xcodebuild clean build \
					 -workspace ${selected_workspace} \
					 -scheme APFeed2 \
					 -sdk iphonesimulator9.2 \
					 -destination 'platform=iOS Simulator,name=iPhone 6' \
					 -configuration Release \
					 CONFIGURATION_BUILD_DIR=${current_simulator_build_dir}

current_device_product_lib_path="${current_device_build_dir}/libAPFeed2.a"
current_simulator_product_lib_path="${current_simulator_build_dir}/libAPFeed2.a"

# prepare the folders required to create the .framework

current_product_dir="${selected_output_dir}/product"

current_product_framework_name="${selected_product}.framework"
current_product_framework_base_dir="${current_product_dir}/${current_product_framework_name}"
current_product_framework_data_dir="${current_product_framework_base_dir}/Versions/A"
current_product_headers_dir="${current_product_framework_data_dir}/Headers"
current_product_resources_dir="${current_product_framework_data_dir}/Resources"

mkdir -p "${current_product_framework_data_dir}"
mkdir -p "${current_product_headers_dir}"
mkdir -p "${current_product_resources_dir}"

current_compiled_files_source_dir=${current_device_build_dir}

# copy the headers into the framework dir
rsync -r --prune-empty-dirs --filter="-s_*.*/" --include "*/" --include "*.h" --exclude "*" "${current_compiled_files_source_dir}/" "${current_product_headers_dir}/"

# copy the resources into the framework dir
# each directory with resources must flatten
if [[ ! ${selected_bundle} =~ \.bundle ]]
then
	find "${current_compiled_files_source_dir}/${selected_bundle}" -maxdepth 1 -iname '*.*' -exec cp -R \{\} /"${current_product_resources_dir}"/ \;
else
	cp -R "${current_compiled_files_source_dir}/${selected_bundle}" "${current_product_resources_dir}"
fi

# gather the symbols into one library file
lipo -create -output "${current_product_framework_data_dir}/${selected_product}" \
 											$current_device_product_lib_path \
											$current_simulator_product_lib_path

# create symbolic links which are required by the .framework structure
ln -sfh "A" "${current_product_framework_base_dir}/Versions/Current"
ln -sfh "Versions/Current/Headers" "${current_product_framework_base_dir}/Headers"
ln -sfh "Versions/Current/Resources" "${current_product_framework_base_dir}/Resources"
ln -sfh "Versions/Current/${selected_product}" "${current_product_framework_base_dir}/${selected_product}"

# get the latest tag from the specified git repository, this will be used as the version number
pushd ApplicasterDev/Feed-2.0-iOS
selected_version=$(git describe --abbrev=0 --tags)
popd

# compress the framework
current_product_file_name="${selected_product}Framework_${selected_version}.zip"
current_product_file_path="${current_product_dir}/${current_product_file_name}"

	# currently CocoaPods doesn't properly support tar.gz (which reduces the framework size by 100MB)
# tar -zcf "${current_product_file_path}" -C "${current_product_dir}" "${current_product_framework_name}"

# using zip
echo; echo
echo "Compressing using zip..."
pushd "${current_product_dir}"
zip -rq "${current_product_file_name}" "${current_product_framework_name}"
popd

# upload the compressed file to the BinTray host
bintray_username="applicasterapps"
bintray_organization="applicaster-ltd"
bintray_api_key="${bintray_api_key}"
bintray_repo="Stars-Team-iOS"
bintray_package="${selected_product}"
bintray_file_path="${bintray_organization}/${bintray_repo}/${bintray_package}/${selected_version}"

bintray_upload_url="https://api.bintray.com/content/${bintray_file_path}/${current_product_file_name}?publish=1&override=1"

echo; echo
echo "Uploading to: ${bintray_upload_url}"
echo; echo

curl --progress-bar -sST "${current_product_file_path}" -u"${bintray_username}":"${bintray_api_key}" "${bintray_upload_url}"
if test $? -ne 0
then
	exit 505
fi

echo; echo

bintary_download_url="https://dl.bintray.com/${bintray_organization}/${bintray_repo}/${current_product_file_name}"
echo "Uploaded ${bintary_download_url}"

# load the template podspec and replace the version and source link
podspec_template=$(<"ApplicasterDev/Pod-Release/${selected_pods_dir}_Template.podspec")
podspec_template="${podspec_template/__version__/${selected_version}}"
podspec_filled="${podspec_template/__source_url__/${bintary_download_url}}"

podspec_tmp_file_name="${selected_pods_dir}.podspec"
echo "${podspec_filled}" > "${selected_output_dir}/${podspec_tmp_file_name}"

# push the new podspec to the CocoaPods repository
pushd "${selected_output_dir}"
pod repo add master https://github.com/CocoaPods/Specs.git
pod repo add applicaster git@github.com:applicaster/CocoaPods.git
pod repo push --verbose --no-private --allow-warnings applicaster "${podspec_tmp_file_name}"
popd
