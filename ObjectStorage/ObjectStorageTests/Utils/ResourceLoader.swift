//
//  ResourceLoader.swift
//  ObjectStorage
//
//  Created by Li Jiantang on 04/09/2016.
//  Copyright © 2016 Carma. All rights reserved.
//

import Foundation

/**
 @class ResourceLoader
 
 @abstract Load txt files from test bundle
 
 */
class ResourceLoader {
    
    /**
     Load resource with file name in bundle
     
     - parameter name:     file name
     - parameter inBundle: NSBundle
     
     - returns: Resource
     */
    static func load(name: String, inBundle: NSBundle) -> Resource {
        
        guard let path = filePath(forName: name, inBundle: inBundle),
            let data = NSData(contentsOfFile: path) else {
            fatalError("Can't load resource, name: \(name).")
        }
        
        return Resource(data: data)
    }
    
    // get file path from name, return nil if not found
    static func filePath(forName name: String, inBundle: NSBundle) -> String? {
        let nsString = name as NSString
        return inBundle.pathForResource(nsString.stringByDeletingPathExtension, ofType: nsString.pathExtension)
    }
}

/**
 *  Resource represent NSData, can derive string or json object
 */
struct Resource {
    
    let data: NSData
    
    var string: String {
        get {
            return String(data: data, encoding: NSUTF8StringEncoding)!
        }
    }
    
    var json: AnyObject? {
        let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        return json
    }
}