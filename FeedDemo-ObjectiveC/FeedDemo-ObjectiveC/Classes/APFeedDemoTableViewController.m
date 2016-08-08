//
//  APFeedDemoTableViewController.m
//  FeedDemo-ObjectiveC
//
//  Created by Philip Kramarov on 2/17/16.
//  Copyright © 2016 Applicaster LTD. All rights reserved.
//

#import "APFeedDemoTableViewController.h"

@import ApplicasterSDK;
#import <APFeed/APNewFeedManager.h>

@interface APFeedDemoTableViewController ()

@property (nonatomic, strong) NSArray *timelinesArray;

@end

@implementation APFeedDemoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(timelineStatusChanged:)
                                                 name:kTimeFeedTimeLineStatusChanged
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(episodeStatusChanged:)
                                                 name:kFeedEpisodeStatusChanged
                                               object:nil];
}

- (void)timelineStatusChanged:(NSNotification *)notification {
    [self updateTimelines];
}

- (void)episodeStatusChanged:(NSNotification *)notification {
    [self updateTimelines];
}

- (void)updateTimelines {
    self.timelinesArray = [[APTimelinesManager sharedManager] liveFeedTimelines];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.timelinesArray != nil) {
        return self.timelinesArray.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timelineCellIdentifier"
                                                            forIndexPath:indexPath];
    APFeedTimeline *timeline = self.timelinesArray[indexPath.row];
    if (timeline.isLive) {
        cell.textLabel.text = timeline.name;
        cell.detailTextLabel.text = @"Not Available";
        [[APTimelinesManager sharedManager] episodesForTimelineID:timeline.timelineID completion:^(NSArray *episodes) {
            for (APFeedEpisode *episode in episodes) {
                if (timeline.name == cell.textLabel.text) {
                    if ([episode isEpisodePresentingNow]) {
                        cell.detailTextLabel.text = @"Live Episode";
                    }
                }
            }
        }];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    APFeedTimeline *timeline = self.timelinesArray[indexPath.row];
    // Present the selected Feed
    [[APTimelinesManager sharedManager] presentFeedWithTimelineID:timeline.timelineID completionHandler:^(BOOL success) {
        if (!success) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Missing Live Episode"
                                                                                      message:@"Could not open the feed because no live Episode set at the moment."
                                                                               preferredStyle:UIAlertControllerStyleAlert];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController
                                                                                         animated:YES
                                                                                       completion:nil];
            
            
        }
    }];
}

@end
