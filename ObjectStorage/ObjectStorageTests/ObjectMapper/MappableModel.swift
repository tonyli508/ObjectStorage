//
//  MappableModel.swift
//  ObjectStorage
//
//  Created by Li Jiantang on 22/05/2015.
//  Copyright (c) 2015 Carma. All rights reserved.
//

import Foundation
import ObjectMapper
@testable import ObjectStorage


/**
*  WARNING: Don't use this class directly, this just for reducing coding work
*  How to use: just inherit from this class, and overide identifier and mapping functions
*/
class MappableModel: NSObject, Model, Mappable {
    
    let mapper = Mapper<MappableModel>()
    
    override init() {
        
        super.init()
    }
    
    required init(MappingRule rule: MappingRules) {
        super.init()
        
        mappingRule = rule
    }
    
    required init?(_ map: Map) {
        super.init()
        
        mappingRule = .PropertiesJSON
    }
    
    convenience init(queryValues: [String?]) {
        
        self.init(MappingRule: .PropertiesJSON)
        
        self.identifier = (modelName: self.identifier.modelName, keys: self.identifier.keys, values: queryValues)
    }
    
    /// WARNING: IEMPLEMENT THIS BY SUBCLASS
    func verify(forRule: MappingRules) -> Bool {
        // if not implemented by subclass always pass
        return true
    }
    
    func isDataValid() -> Bool {
        if identifier.modelName.isEmpty || identifier.keys.count != identifier.values.count {
            return false
        }

        for i in 0..<self.identifier.values.count {
            if self.identifier.values[i] == nil {
                return false
            }
        }
        
        return true
    }
    
    /**
    WARNING: IEMPLEMENT THIS BY SUBCLASS
    */
    func mapping(map: Map) {
        fatalError("[MappableModel] This is an empty implementation, must be override by subclass")
    }
    
    func fromJSON(json: AnyObject) -> Model {
        
        // a bug in the ObjectMapping library, if passing AnyObject it will consider Dictionary first ignore JSON String
        if json is NSString || json is String {
            return mapper.map(json as! String, toObject: self)
        }
        
        return mapper.map(json, toObject: self)
    }
    
    /**
     Set JSON format source to model properties using current mapping rule
     
     - parameter json: Array JSON format source
     
     - returns: Models
     */
    func fromArray(json: AnyObject) -> [Model] {
        
        if json is Array<AnyObject> {
            return mapper.mapArray(json) ?? []
        }
        
        return []
    }
    
    func toJSON() -> [String: AnyObject] {
        return mapper.toJSON(self)
    }
    
    private var _mappingRule: MappingRules = .PropertiesJSON
    /// Current mapping rule for json convert
    var mappingRule: MappingRules {
        get {
            return _mappingRule
        }
        set(rule) {
            _mappingRule = rule
        }
    }
    
    /// WARNING: IEMPLEMENT THIS BY SUBCLASS
    var identifier: ModelIdentifier {
        get {
            print("[MappableModel] This is an empty implementation, must be override by subclass to do CoreData stuffs")
            return (modelName: "", keys: [], values: [])
        }
        // to re-define the query or restore the keys after server response mapping
        set(modelIdentifier) {
            // default do nothing, override to implement
        }
    }
    
    /// Get query string for model
    func getQuery() -> String {
        var query = ""
        
        //if model is not valid, then the model is invalid, return empty query
        if !self.isDataValid() {
            print("ModelIdentifier must have same count for keys and values")
            return query
        }
        
        for index in 0..<identifier.keys.count {
            if identifier.values[index] != nil {
                let prefix = index > 0 ? " AND " : ""
                query += prefix + "\(identifier.keys[index]) == '\(identifier.values[index]!)'"
            }
        }
        
        return query
    }
    
}



