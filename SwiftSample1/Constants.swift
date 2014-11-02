//
//  Constants.swift
//  SwiftRssSample
//
//  Created by fukudas on 2014/10/30.
//  Copyright (c) 2014年 fukudas. All rights reserved.
//

import Foundation

class Identifiers: NSObject {
    struct Segues {
        static let FeedList: String = "showFeedList"
        static let FeedForm: String = "showFeedForm"
        static let FeedConfirm: String = "showFeedConfirm"
        static let EntryList: String = "showEntryList"
        static let EntryView: String = "showEntryView"
    }
    
    struct Cells {
        static let FeedList: String = "FeedListCell"
        static let EntryList: String = "EntryListCell"
    }
}
