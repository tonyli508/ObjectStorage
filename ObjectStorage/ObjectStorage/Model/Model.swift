//
//  ModelProtocol.swift
//  ObjectStorage
//
//  Created by Li Jiantang on 12/05/2015.
//  Copyright (c) 2015 Carma. All rights reserved.
//

/**
The mapping rules we support

- PropertiesJSON:     Flat properties, for local storage purpose
- ServerResponseJSON: Server json format, for api response and submit to server
*/
public enum MappingRules: Int {
    case PropertiesJSON = 0
    case ServerResponseJSON = 1
}

/**
*  Model meta data
*   TODO: [IMPROVEMENT] check if keys, values array is needed
*
*  @param String modelName for local storage
*  @param String key name
*  @param String value value of the key
*
*  @return ModelIdentifier
*/
public typealias ModelIdentifier = (modelName: String, keys: [String], values: [String?])

public protocol Model {
    
    /// Identifier or Meta data for Model
    var identifier: ModelIdentifier {
        get
        set
    }
    
    /// Current mapping rule
    var mappingRule: MappingRules {
        get
        set
    }
    
    /**
    Verify model is good for using at MappingRule
    
    :param: forRule MappingRules
    
    :returns: Bool
    */
    func verify(forRule: MappingRules) -> Bool

    /**
    check if model is good for local data storage actions(update, delete)
    
    :returns: Bool
    */
    func isDataValid() -> Bool
    
    /**
    Set JSON format source to model properties using current mapping rule
    
    :param: json JSON format source
    
    :returns: Model
    */
    func fromJSON(json: AnyObject) -> Model
    
    /**
    Set JSON format source to model properties using current mapping rule
     
     - parameter json: Array JSON format source
     
     - returns: Models
     */
    func fromArray(json: AnyObject) -> [Model]
    
    /**
    Convert current model to JSON dictionary format
    
    :returns: JSON dictionary
    */
    func toJSON() -> [String: AnyObject]
    
    /**
    Initializer for model
    
    :param: rule Mapping rule
    
    :returns: Model
    */
    init(MappingRule rule: MappingRules)
    
    /**
    Get Query string for model

    :returns: Query string
    */
    func getQuery() -> String
}

/**
*  Convert data source to JSON dictionary format which we support in Model
*/
public protocol DataConverter {
    associatedtype T
    /**
    *  Convert data from data source
    */
    func convert(model: T) -> [String: AnyObject]
}


