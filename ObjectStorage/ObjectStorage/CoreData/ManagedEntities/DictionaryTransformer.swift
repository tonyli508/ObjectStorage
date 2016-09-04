//
//  DictionaryTransformer.swift
//  ObjectStorage
//
//  Created by Li Jiantang on 12/06/2015.
//  Copyright (c) 2015 Carma. All rights reserved.
//

import Foundation

class DictionaryTransformer: NSValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSDictionary.classForCoder()
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