Pod::Spec.new do |s|

	# The name of the Pod
	s.name = "APFeed"

	# The version of the Pod
	s.version = "__version__"

	# The minimum deployment targets of the supported platforms
	s.ios.platform = :ios
	s.ios.deployment_target = "7.0"

	# A short (maximum 140 characters) description of the Pod
	s.summary = "APFeed SDK"

	# The description of the Pod
	s.description = "Podspec of APFeed library"

	# The URL of the homepage of the Pod
	s.homepage = "https://github.com"

	# The license of the Pod
	s.license = {
		:type => 'Commercial',
		:text => <<-LICENSE
		Copyright 2015
		LICENSE
	}

	s.author = {
		"Miri Vecselboim" => "m.vecselboim@applicaster.com",
		"Simon Borkin" => "s.borkin@applicaster.com"
	}

	# The location from where the library should be retrieved
	s.source = {
    	"http" => "__source_url__"
	}

	# A list of system frameworks that the user’s target needs to link against.
	s.frameworks = 'Foundation' , 'AdSupport' , 'Accounts' , 'AudioToolbox' , 'AVFoundation' , 'CoreTelephony' , 'CoreMotion' , 'CoreMedia' , 'CoreLocation' , 'CoreData' , 'CoreText' , 'CFNetwork' , 'iAd' , 'Twitter' , 'QuartzCore' , 'MobileCoreServices' , 'MessageUI' , 'StoreKit' , 'SystemConfiguration' , 'Social' , 'Accelerate' , 'MediaPlayer' , 'AddressBook' , 'QuickLook'

	# Allows you to specify which source_files use ARC. This can either be the files which support ARC, or true to indicate all of the source_files use ARC
	s.requires_arc = true

	# A list of system libraries that the user’s target needs to link against
	s.ios.libraries = 'iconv' , 'resolv' , 'xml2' , 'sqlite3.0' , 'z'

	# Will add the framework to the project once the installation completes
	s.preserve_paths = 'APFeed.framework'
	s.vendored_frameworks = 'APFeed.framework'
 	s.resources = ["APFeed.framework/Resources/*"]

	s.dependency 'Applicaster', '~> 2.18.183'

end
