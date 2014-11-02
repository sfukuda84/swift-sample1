//
//  NSManagedObject.swift
//  SwiftRssSample
//
//  Created by fukudas on 2014/10/30.
//  Copyright (c) 2014年 fukudas. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    class var entityName: String {
        get {
            return NSStringFromClass(self).componentsSeparatedByString(".").last!
        }
    }
}
