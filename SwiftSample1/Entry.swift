//
//  Entry.swift
//  SwiftRssSample
//
//  Created by fukudas on 2014/10/30.
//  Copyright (c) 2014年 fukudas. All rights reserved.
//

import Foundation
import CoreData

class Entry: NSManagedObject {
    @NSManaged var title: String
    @NSManaged var author: String
    @NSManaged var contentSnippet: String
    @NSManaged var content: String
    @NSManaged var link: String
    @NSManaged var publishedDate: String
    @NSManaged var isUnread: Bool
    @NSManaged var isMark: Bool
}
