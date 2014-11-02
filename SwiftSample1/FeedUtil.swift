//
//  FeedUtil.swift
//  SwiftRssSample
//
//  Created by fukudas on 2014/10/30.
//  Copyright (c) 2014年 fukudas. All rights reserved.
//

import Foundation

// クラス定数を説明
private let GOOGLE_FEED_API = "http://ajax.googleapis.com/ajax/services/feed/load"

class FeedUtil: NSObject {
    //class var GOOGLE_FEED_API_DUMMY = ""
    //class let GOOGLE_FEED_API_DUMMY2 = ""
    
    class var GOOGLE_FEED_API: String {
        get { return "http://ajax.googleapis.com/ajax/services/feed/load?v=1.0" }
    }
    
//    class let GOOGLE_FEED_API2 :String {
//        get { return "" }
//    }
    
    
    // 構造体の使い方を説明
    struct Request {
        static let version = "1.0"
        var entryNum = 10
        var endPoint = ""
        
        func getUrl() -> String {
            return "\(GOOGLE_FEED_API)?v=\(Request.version)&num=\(entryNum)&q=\(endPoint)"
        }
    }
    
    struct Response {
        struct Keys {
            static let ResponseStatus = "responseStatus"
            static let ResponseDetails = "responseDetails"
            static let ResponseData = "responseData"
            static let FeedData = "feed"
            static let Entries = "entries"
            
            struct Feed {
                static let Title = "title"
                static let Description = "description"
                static let Author = "author"
                static let Link = "link"
                static let FeedUrl = "feedUrl"
            }
            
            struct Entry {
                static let Title = "title"
                static let Author = "author"
                static let ContentSnippet = "contentSnippet"
                static let Content = "content"
                static let Link = "link"
                static let PublishedDate = "publishedDate"
            }
        }
        
        struct Status {
            static let Ok = 200
            static let ParseError = 999
        }
        
        struct Details {
            static let Ok = ""
            static let ParseError = "JSON parse error"
        }
    }
    
    // イベントハンドラを受けるメソッドの作り方＆使い方を説明
    class func getFeed(params: Request, completionHander: (status: Int?, detail: String?, data: NSDictionary?) -> Void) {
        getAllData(params, completionHander: { (status, detail, data) -> Void in
            if (status != Response.Status.Ok || data == nil) {
                completionHander(status: status, detail: detail, data: data)
            } else {
                var tStatus = Response.Status.ParseError
                var tDetails = Response.Details.ParseError
                var feed = data![Response.Keys.FeedData] as? NSDictionary
                if feed != nil {
                    tStatus = Response.Status.Ok
                    tDetails = Response.Details.Ok
                }
                completionHander(status: tStatus, detail: tDetails, data: feed)
            }
        })
    }
    
    // オーバーロード
    class func getEntries(params: Request, completionHander: (status: Int?, detail: String?, data: NSArray?) -> Void) {
        getAllData(params, completionHander: { (status, detail, data) -> Void in
            if (status != Response.Status.Ok || data == nil) {
                completionHander(status: status, detail: detail, data: NSArray())
            } else {
                var tStatus = Response.Status.ParseError
                var tDetails = Response.Details.ParseError
                var entries: NSArray? = NSArray()
                if var feed = data![Response.Keys.FeedData] as? NSDictionary {
                    entries = feed[Response.Keys.Entries] as? NSArray
                    if (entries != nil) {
                        tStatus = Response.Status.Ok
                        tDetails = Response.Details.Ok
                    }
                }
                completionHander(status: tStatus, detail: tDetails, data: entries)
            }
        })
    }

    class func getAllData(params: Request, completionHander: (status: Int?, detail: String?, data: NSDictionary?) -> Void) {
        var url = NSURL(string: params.getUrl())!
        var task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            var parsed = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            var status = parsed[Response.Keys.ResponseStatus] as? Int
            var detail = parsed[Response.Keys.ResponseDetails] as? String
            var data = parsed[Response.Keys.ResponseData] as? NSDictionary
            
            if (data == nil) {
                status = Response.Status.ParseError
                detail = Response.Details.ParseError
            }
        
            completionHander(status: status, detail: detail, data: data)
            
        })
        task.resume()
    }
}