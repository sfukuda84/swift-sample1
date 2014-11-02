//
//  Feed.swift
//  SwiftRssSample
//
//  Created by fukudas on 2014/10/30.
//  Copyright (c) 2014年 fukudas. All rights reserved.
//

import Foundation
import CoreData

class Feed: NSManagedObject {
    @NSManaged var feedUrl: String
    @NSManaged var link: String
    @NSManaged var title: String
    @NSManaged var catch: String
    @NSManaged var author: String
    @NSManaged var isActive: Bool
}
