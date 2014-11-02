//
//  FeedListController.swift
//  SwiftRssSample
//
//  Created by fukudas on 2014/10/30.
//  Copyright (c) 2014年 fukudas. All rights reserved.
//

import UIKit
import CoreData

class EntryListController: UITableViewController {
    var feed: Feed?
    var indicator = UIActivityIndicatorView()
    var entries: NSArray? = NSArray()
    var context: NSManagedObjectContext?
    var ctRefresh = UIRefreshControl()
    var refreshed = false
    
    @IBAction func searchData(sender: AnyObject) {
        self.navigationItem.title = "記事一覧"

        loadData()
    }
    
    @IBAction func filterByMarked(sender: AnyObject) {
        self.navigationItem.title = "注目一覧"
        
        var predicate = NSPredicate(format: "isMark = 1")
        loadData(predicate: predicate)
    }
    
    @IBAction func fiterByUnread(sender: AnyObject) {
        self.navigationItem.title = "未読一覧"

        var predicate = NSPredicate(format: "isUnread = 1")
        loadData(predicate: predicate)
    }
    
    private enum CellTags: Int {
        case Title = 1
        case Catch
        case Date
        case Reading
        case Mark
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        context = appDelegate.managedObjectContext
        
        ctRefresh = UIRefreshControl()
        ctRefresh.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)

        self.tableView.addSubview(ctRefresh)
    }
    
    override func viewWillAppear(animated: Bool) {
        if (!refreshed) {
            refreshData()
            refreshed = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier(Identifiers.Cells.EntryList) as UITableViewCell
        var entry = entries![indexPath.row] as Entry
        var labelTitle = cell.viewWithTag(CellTags.Title.rawValue) as UILabel
        var labelContentSnippet = cell.viewWithTag(CellTags.Catch.rawValue) as UILabel
        var labelDate = cell.viewWithTag(CellTags.Date.rawValue) as UILabel
        var ivReading = cell.viewWithTag(CellTags.Reading.rawValue) as UIImageView
        var ivMark = cell.viewWithTag(CellTags.Mark.rawValue) as UIImageView
        
        labelTitle.text = entry.title
        labelContentSnippet.text = entry.contentSnippet
        labelDate.text = entry.publishedDate
        ivReading.hidden = !entry.isUnread
        ivMark.hidden = !entry.isMark
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var entry = self.entries![indexPath.row] as Entry
        entry.isUnread = false
        var error: NSError? = nil
        if self.context!.save(&error) {
            var cell = tableView.cellForRowAtIndexPath(indexPath)
            var isReading = cell?.viewWithTag(CellTags.Reading.rawValue) as? UIImageView
            isReading?.hidden = true
            performSegueWithIdentifier(Identifiers.Segues.EntryView, sender: entry)
        } else {
            println(error)
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let unread = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "未読") { (action, indexPath) in
            var entry = self.entries![indexPath.row] as Entry
            entry.isUnread = true
            var error: NSError? = nil
            if self.context!.save(&error) {
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            } else {
                println(error)
            }
        }
        unread.backgroundColor = UIColor.darkGrayColor()
        
        let bookmark = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "注目") { (action, indexPath) in
            var entry = self.entries![indexPath.row] as Entry
            entry.isMark = true
            var error: NSError? = nil
            if self.context!.save(&error) {
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            } else {
                println(error)
            }
        }
        bookmark.backgroundColor = UIColor.orangeColor()
        
        return [unread, bookmark]
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Identifiers.Segues.EntryView {
            var controller = segue.destinationViewController as EntryViewController
            controller.entry = sender as? Entry
        }
    }
    
    func onRefresh() {
        ctRefresh.beginRefreshing()
        refreshData()
        ctRefresh.endRefreshing()
        refreshed = true
    }
        
    func refreshData() {
        if var endpoint = feed?.feedUrl {
            var request = FeedUtil.Request()
            request.endPoint = endpoint
            FeedUtil.getEntries(request, completionHander: { (status, detail, data) -> Void in
                if (status == FeedUtil.Response.Status.Ok) {
                    self.deleteData()
                    
                    var entries = data!
                    var err: NSError? = nil
                    for var i = 0; i < entries.count; i++ {
                        var entry = entries[i] as NSDictionary
                        
                        var newEntry = NSEntityDescription.insertNewObjectForEntityForName(Entry.entityName, inManagedObjectContext: self.context!) as Entry

                        newEntry.title = entry[FeedUtil.Response.Keys.Entry.Title] as String
                        newEntry.author = entry[FeedUtil.Response.Keys.Entry.Author] as String
                        newEntry.contentSnippet = entry[FeedUtil.Response.Keys.Entry.ContentSnippet] as String
                        newEntry.content = entry[FeedUtil.Response.Keys.Entry.Content] as String
                        newEntry.link = entry[FeedUtil.Response.Keys.Entry.Link] as String
                        newEntry.publishedDate = entry[FeedUtil.Response.Keys.Entry.PublishedDate] as String
                        newEntry.isUnread = true
                        newEntry.isMark = false

                        if !self.context!.save(&err) {
                            return
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.loadData()
                    })
                }
            })
        }
    }
    
    func loadData(predicate: NSPredicate? = nil) {
        var request = NSFetchRequest(entityName: Entry.entityName)
        var error: NSError? = nil
        request.returnsObjectsAsFaults = false
        request.predicate = predicate
        
        self.entries = context!.executeFetchRequest(request, error: &error)
        if error != nil {
            self.entries = NSArray()
        } else {
            self.tableView.reloadData()
        }
    }
    
    func deleteData() {
        var request = NSFetchRequest(entityName: Entry.entityName)
        var error: NSError? = nil
        var objects = context!.executeFetchRequest(request, error: &error) as? [NSManagedObject]
        if (objects != nil) {
            for object in objects! {
                context?.deleteObject(object)
            }
            if !context!.save(&error) {
                println(error)
            }
        }

    }
}
