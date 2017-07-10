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
        
        NotificationCenter.default.addObserver(self, selector: #selector(APFeedDemoTableViewController.timelineStatusChanged(_:)), name: NSNotification.Name(rawValue: kTimeFeedTimeLineStatusChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(APFeedDemoTableViewController.episodeStatusChanged(_:)), name: NSNotification.Name(rawValue: kFeedEpisodeStatusChanged), object: nil)
        
        updateTimelines()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Private methods
    
    dynamic fileprivate func timelineStatusChanged(_ notification: Notification) {
        updateTimelines()
    }
    
    dynamic fileprivate func episodeStatusChanged(_ notification: Notification) {
        updateTimelines()
    }
    
    
    fileprivate func updateTimelines() {
        self.timelinesArray = APTimelinesManager.shared().liveFeedTimelines() as! NSArray
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.timelinesArray != nil) {
            return self.timelinesArray.count
        }
        else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timelineCellIdentifier", for: indexPath) 

        let timeline: APFeedTimeline = self.timelinesArray.object(at: indexPath.row) as! APFeedTimeline
        if (timeline.isLive) {
            cell.textLabel?.text = timeline.name
            cell.detailTextLabel?.text = "Not Available"
            APTimelinesManager.shared().episodes(forTimelineID: timeline.timelineID, completion: { (episodes) -> Void in
                let episodesArr: NSArray! = episodes as! NSArray
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Set the APFeedTimeline object
        let timeline: APFeedTimeline = self.timelinesArray.object(at: indexPath.row) as! APFeedTimeline
        // Present the selected Feed
        APTimelinesManager.shared().presentFeed(withTimelineID: timeline.timelineID, completionHandler: { (success) -> Void in
            if (!success) {
                let alertView: UIAlertView = UIAlertView(title: "Missing Live Episode", message: "Could not open the feed because no live Episode set at the moment.", delegate: nil, cancelButtonTitle: "Close")
                alertView.show()
            }
        })
    }
}
