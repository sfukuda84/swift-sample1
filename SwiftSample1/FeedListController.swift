//
//  SubscriptionListController.swift
//  SwiftRssSample
//
//  Created by fukudas on 2014/10/30.
//  Copyright (c) 2014年 fukudas. All rights reserved.
//

import UIKit
import CoreData


class FeedListController: UITableViewController {
    var context: NSManagedObjectContext?
    var feeds: NSMutableArray = NSMutableArray()
    
    enum CellTags: Int {
        case Title = 1
    }
    
    @IBAction func serchData(sender: AnyObject) {
        loadData()
        self.navigationItem.title = "RSS一覧"
    }
    
    @IBAction func filterTrash(sender: AnyObject) {
        var predicate = NSPredicate(format: "isActive != 1")
        loadData(predicate: predicate)
        self.navigationItem.title = "ゴミ箱"
    }
    
    @IBAction func returnFeedList(segue: UIStoryboardSegue) {
        loadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        context = appDelegate.managedObjectContext
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier(Identifiers.Cells.FeedList) as UITableViewCell
        var feed = feeds[indexPath.row] as Feed
        var lbTitle = cell.viewWithTag(CellTags.Title.rawValue) as UILabel
        lbTitle.text = feed.title as String
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var feed = feeds[indexPath.row] as Feed
        if (feed.isActive) {
            performSegueWithIdentifier(Identifiers.Segues.EntryList, sender: feed)
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var feed = feeds[indexPath.row] as Feed
        if !feed.isActive {
            let activate = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "戻す") { (action, indexPath) in
                var feed = self.feeds[indexPath.row] as Feed
                feed.isActive = true
                var error: NSError? = nil
                if self.context!.save(&error) {
                    self.feeds.removeObjectAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                } else {
                    println(error)
                }
            }
            activate.backgroundColor = UIColor.blueColor()
            let delete = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "削除") { (action, indexPath) in
                if self.deleteData(indexPath) {
                    self.feeds.removeObjectAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
            }
            delete.backgroundColor = UIColor.redColor()
            return [activate, delete]
        } else {
            let delete = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "ゴミ箱") { (action, indexPath) in
                var feed = self.feeds[indexPath.row] as Feed
                feed.isActive = false
                var error: NSError? = nil
                if self.context!.save(&error) {
                    self.feeds.removeObjectAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                } else {
                    println(error)
                }
            }
            delete.backgroundColor = UIColor.redColor()
            return [delete]
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Identifiers.Segues.EntryList {
            var controller = segue.destinationViewController as EntryListController
            controller.feed = sender as? Feed
        }
    }
    
    // 変数としての仮引数を説明
    func loadData(var predicate: NSPredicate? = nil) {
        var request = NSFetchRequest(entityName: Feed.entityName)
        if predicate == nil {
            predicate = NSPredicate(format: "isActive = 1")
        }
        var err: NSError? = nil
        request.returnsObjectsAsFaults = false
        request.predicate = predicate
        var results = context!.executeFetchRequest(request, error: &err)
        if err == nil {
            feeds = NSMutableArray(array: results!)
            self.tableView.reloadData()
        } else {
            feeds = NSMutableArray()
        }
    }

    func deleteData(indexPath: NSIndexPath) -> Bool {
        var object = self.feeds[indexPath.row] as NSManagedObject
        context!.deleteObject(object)
        var error: NSError? = nil
        var ret = context!.save(&error)
        if !ret {
            println(error)
        }
        return ret
    }
}
