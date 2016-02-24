//
//  APFETimelinesTableViewController.swift
//  FeedExampleApp
//
//  Created by Udi Lumitz on 2/9/15.
//  Copyright (c) 2015 Applicaster. All rights reserved.
//

import UIKit

class APFeedDemoTableViewController: UITableViewController {

    var timelinesArray: NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "timelineStatusChanged:", name: kTimeFeedTimeLineStatusChanged, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "episodeStatusChanged:", name: kFeedEpisodeStatusChanged, object: nil)
        
        updateTimelines()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Private methods
    
    dynamic private func timelineStatusChanged(notification: NSNotification) {
        updateTimelines()
    }
    
    dynamic private func episodeStatusChanged(notification: NSNotification) {
        updateTimelines()
    }
    
    
    private func updateTimelines() {
        self.timelinesArray = APTimelinesManager.sharedManager().liveFeedTimelines()
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.timelinesArray != nil) {
            return self.timelinesArray.count
        }
        else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("timelineCellIdentifier", forIndexPath: indexPath) 

        let timeline: APFeedTimeline = self.timelinesArray.objectAtIndex(indexPath.row) as! APFeedTimeline
        if (timeline.isLive) {
            cell.textLabel?.text = timeline.name
            cell.detailTextLabel?.text = "Not Available"
            APTimelinesManager.sharedManager().episodesForTimelineID(timeline.timelineID, completion: { (episodes) -> Void in
                let episodesArr: NSArray! = episodes as NSArray
                for episode in episodesArr {
                    let feedEpisode: APFeedEpisode = episode as! APFeedEpisode
                    if timeline.name == cell.textLabel?.text {
                        if feedEpisode.isEpisodePresentingNow() {
                            cell.detailTextLabel?.text = "Live Episode"
                        }
                    }
                }
            })
        }
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Set the APFeedTimeline object
        let timeline: APFeedTimeline = self.timelinesArray.objectAtIndex(indexPath.row) as! APFeedTimeline
        // Present the selected Feed
        APTimelinesManager.sharedManager().presentFeedWithTimelineID(timeline.timelineID, completionHandler: { (success) -> Void in
            if (!success) {
                let alertView: UIAlertView = UIAlertView(title: "Missing Live Episode", message: "Could not open the feed because no live Episode set at the moment.", delegate: nil, cancelButtonTitle: "Close")
                alertView.show()
            }
        })
    }
}
