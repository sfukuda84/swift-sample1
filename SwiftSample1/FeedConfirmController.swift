//
//  SubscriptionConfirmController.swift
//  SwiftRssSample
//
//  Created by fukudas on 2014/10/30.
//  Copyright (c) 2014年 fukudas. All rights reserved.
//

import UIKit
import CoreData


class FeedConfirmController: UIViewController {
    var feed: NSDictionary = NSDictionary()
    var context: NSManagedObjectContext?
    
    @IBOutlet weak var lbCatch: UILabel!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var lbUrl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        context = appDelegate.managedObjectContext
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "saveFeed")
        tfTitle.text = feed[FeedUtil.Response.Keys.Feed.Title] as String
        lbUrl.text = feed[FeedUtil.Response.Keys.Feed.FeedUrl] as? String
        lbCatch.text = feed[FeedUtil.Response.Keys.Feed.Description] as? String
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func saveFeed() {
        if (tfTitle.text == "") {
            return
        }
        
        var newFeed = NSEntityDescription.insertNewObjectForEntityForName(Feed.entityName, inManagedObjectContext: context!) as Feed
        newFeed.title = tfTitle.text
        newFeed.feedUrl = feed[FeedUtil.Response.Keys.Feed.FeedUrl] as String
        newFeed.catch = feed[FeedUtil.Response.Keys.Feed.Description] as String
        newFeed.link = feed[FeedUtil.Response.Keys.Feed.Link] as String
        newFeed.author = feed[FeedUtil.Response.Keys.Feed.Author] as String
        newFeed.isActive = true
        
        var err: NSError? = nil
        if !context!.save(&err) {
            println(err?.description)
        } else {
            self.performSegueWithIdentifier(Identifiers.Segues.FeedList, sender: nil)
        }
    }
}
