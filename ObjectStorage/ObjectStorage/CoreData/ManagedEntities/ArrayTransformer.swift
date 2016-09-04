//
//  ArrayTransformer.swift
//  ObjectStorage
//
//  Created by Li Jiantang on 17/05/2016.
//  Copyright © 2016 Carma. All rights reserved.
//

import Foundation

class ArrayTransformer: NSValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSArray.classForCoder()
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        return NSKeyedArchiver.archivedDataWithRootObject(value!)
    }
    
    override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        return NSKeyedUnarchiver.unarchiveObjectWithData(value! as! NSData)
    }
}