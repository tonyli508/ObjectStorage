//
//  CoreDataService.swift
//  ObjectStorage
//
//  Created by Li Jiantang on 12/05/2015.
//  Copyright (c) 2015 Carma. All rights reserved.
//

import Foundation
import CoreData

/// United protocol for append object to NSOrderedSet and NSSet
protocol AppendableSet: class {
    func addObject(object: AnyObject)
}
// make NSmutableOrderedSet appendable, will be very useful for ordered CoreData objects
extension NSMutableOrderedSet: AppendableSet {
    
}
// make NSMutableSet appendable
extension NSMutableSet: AppendableSet {
    
}

/**
 @class StorageProviderService
 
 @abstract Storage Privder using CoreData to store all the datas
 
 */
class StorageProviderService: ObjectStorageProviderService, DataConverter {
    
    // Core data store
    private var coreDataStore: CoreDataStore
    private let coreDataModelFileName: String
    private let bundle: NSBundle
    
    /// core data helper
    private lazy var coreDataHelper: CoreDataHelper = {
        var coreDataHelper = CoreDataHelper(cdstore: self.coreDataStore)
        return coreDataHelper
    }()
    
    /**
     Init StoreProviderService with CoreData model file name and NSBundle
     
     - parameter coreDataModelFileName: CoreData model file name (without extention name)
     - parameter inBundle:              NSBundle, indicate where the file in
     */
    init(coreDataModelFileName: String, inBundle: NSBundle = NSBundle.mainBundle()) {
        self.coreDataModelFileName = coreDataModelFileName
        self.bundle = inBundle
        self.coreDataStore = CoreDataStore(storeName: coreDataModelFileName, inBundle: inBundle)
    }
    
    typealias T = NSManagedObject
    
    // MARK: - helper functions
    
    /**
     Convert Model to json dictionary
     
     - parameter model: Model
     
     - returns: json dictionary
     */
    func convert(model: NSManagedObject) -> [String : AnyObject] {
        
        let entity = model.entity
        
        var dict = [String: AnyObject]()
        
        for (name, _) in entity.attributesByName {
            dict[name] = model.valueForKey(name)
        }
        
        for (name, _) in entity.relationshipsByName {
            
            if let submodel = model.valueForKey(name) as? NSManagedObject {
                dict[name] = self.convert(submodel)
            } else if let array = model.valueForKey(name) as? NSSet {
                convertSet(array, forDictionary: &dict, usingName: name)
            } else if let array = model.valueForKey(name) as? NSOrderedSet {
                convertSet(array, forDictionary: &dict, usingName: name)
            }
        }
        
        return dict
    }
    
    /**
     Convert SequenceType to Array, and add array to dictionary using give name
     
     - parameter array:         SequenceType
     - parameter forDictionary: dictionary that will add array to
     - parameter usingName:     key name for the array in dictionary
     */
    private func convertSet<T: SequenceType>(array: T, inout forDictionary: [String: AnyObject], usingName: String) {
        
        var newArray = [AnyObject]()
        
        for obj in array {
            
            if let obj = obj as? NSManagedObject {
                newArray.append(self.convert(obj))
            }
        }
        
        forDictionary[usingName] = newArray
    }
    
    /**
     Verify current model if structure is good for storage service
     
     - parameter model: Model
     
     - returns: Bool, is valid or not
     */
    private func verify(model: Model) -> Bool {
        
        if coreDataHelper.backgroundContext == nil || coreDataHelper.managedObjectContext == nil || model.isDataValid() == false {
            return false
        }
        
        return true
    }
    
    /**
     Set attributes from json to NSManagedObject
     
     - parameter json:        json dictionary
     - parameter destination: NSManagedObject
     */
    private func setAttributesFrom(json: [String: AnyObject], To destination: NSManagedObject) {
        
        for (name, _) in destination.entity.attributesByName {
            let key = name 
            
            if let value: AnyObject = json[key] {
                
                destination.setValue(value, forKey: key)
            }
        }
    }
    
    /**
     Set relationships from json to NSManagedObject
     
     - parameter json:        json dictionary
     - parameter destination: NSManagedObject
     */
    private func setRelationshipsFrom(json: [String: AnyObject], To destination: NSManagedObject) {
        
        for (name, relationshipDesc) in destination.entity.relationshipsByName {
            let key = name 
            
            if let relateJson = json[key] as? [String: AnyObject] {
                if let entityDesc = relationshipDesc.destinationEntity {
                    var managedObject = destination.valueForKey(key) as? NSManagedObject
                    
                    if managedObject == nil {
                        managedObject = NSManagedObject(entity: entityDesc, insertIntoManagedObjectContext: coreDataHelper.backgroundContext!)
                    }
                    
                    setAllPropertiesFrom(relateJson, To: managedObject!)
                    
                    destination.setValue(managedObject!, forKey: key)
                }
            } else if let relateJson = json[key] as? [AnyObject] {
                
                if let entityDesc = relationshipDesc.destinationEntity {
                    
                    var array: AppendableSet
                    if relationshipDesc.ordered {
                        array = destination.mutableOrderedSetValueForKey(key)
                    } else {
                        array = destination.mutableSetValueForKey(key)
                    }
                    
                    for subJson in relateJson {
                        if let subJson = subJson as? [String: AnyObject] {
                            
                            let managedObject = NSManagedObject(entity: entityDesc, insertIntoManagedObjectContext: coreDataHelper.backgroundContext!)
                            
                            setAllPropertiesFrom(subJson, To: managedObject)
                            
                            array.addObject(managedObject)
                        }
                    }
                    
                    destination.setValue(array, forKey: key)
                }
            }
        }
    }
    
    // set all properties from json to managedObject, include attributes and relationships
    private func setAllPropertiesFrom(json: [String: AnyObject], To destination: NSManagedObject) {
        
        setAttributesFrom(json, To: destination)
        
        setRelationshipsFrom(json, To: destination)
    }
    
    // MARK: - CURD functions
    
    /**
     create new model data
     
     - parameter model: Model
     
     - returns: Bool, if model created or not
     */
    func create(model: Model) -> Bool {
        
        if !verify(model) {
            return false
        }
        
        let newData: NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName(model.identifier.modelName, inManagedObjectContext: coreDataHelper.backgroundContext!) 
        
        let json = model.toJSON()
        
        self.setAllPropertiesFrom(json, To: newData)
        
        coreDataHelper.saveContext(coreDataHelper.backgroundContext!)
        print("Inserted new data for \(model) ")
        return true
    }
    
    /**
     read model data
     
     - parameter model: Model
     
     - returns: Model with original type
     */
    func read<T: Model>(model: T) -> T? {
        
        if !verify(model) {
            return nil
        }
        
        let fReq = NSFetchRequest(entityName: model.identifier.modelName)
        
        let query = model.getQuery()
        if !query.isEmpty {
            fReq.predicate = NSPredicate(format: query)
        }
        print("identifier: \(model.identifier.modelName), query: \(query)")
        
        fReq.returnsObjectsAsFaults = false
        
        if let result = try? coreDataHelper.managedObjectContext!.executeFetchRequest(fReq) {
            for resultItem in result {
                let resData = resultItem as! NSManagedObject
                print("Fetched core data for \(model.identifier.modelName) with query \(query) sucess, model: \(resData)")
                
                return model.fromJSON(self.convert(resData)) as? T
            }
        }
        
        return nil
    }
    
    /**
     udapte existing model data
     
     - parameter model: Model
     
     - returns: Bool, whether updated or not
     */
    func update(model: Model) -> Bool {
        return update(model, ignoreEmptyValues: false)
    }
    
    /**
     update existing model data but ignore empty values like empty string, array or dictionary
     
     - parameter model: Model
     
     - returns: Bool, whether updated or not
     */
    func updateIgnoreEmptyValues(model: Model) -> Bool {
        return update(model, ignoreEmptyValues: true)
    }
    
    /**
     update existing model data with setting ignore empty values like empty string
     
     - parameter model:             Model
     - parameter ignoreEmptyValues: ignore empty values flag, like empty string, array or dictionary
     
     - returns: Bool, whether updated or not
     */
    private func update(model: Model, ignoreEmptyValues: Bool) -> Bool {
        if !verify(model) {
            return false
        }
        
        let fReq: NSFetchRequest = NSFetchRequest(entityName: model.identifier.modelName)
        let query = model.getQuery()
        
        if !query.isEmpty {
            fReq.predicate = NSPredicate(format: query)
        }
        
        print("identifier: \(model.identifier.modelName), query: \(query)")
        
        fReq.returnsObjectsAsFaults = false
        
        guard let result = try? coreDataHelper.backgroundContext!.executeFetchRequest(fReq) where result.count > 0 else {
            print("Update core data for \(model.identifier.modelName) with query \(query) failed")
            return false
        }
        
        let storedData : NSManagedObject = result.first as! NSManagedObject
        var json = model.toJSON()
        
        if ignoreEmptyValues {
            json = removeEmptyValues(json)
        }
        
        setAllPropertiesFrom(json, To: storedData)
        
        print("json: \(json)")
        
        coreDataHelper.saveContext(coreDataHelper.backgroundContext!)
        
        return true
    }
    
    /**
     Remove empty values from json object
     
     - parameter json: json object [String: AnyObject]
     
     - returns: [String: AnyObject]
     */
    private func removeEmptyValues(json: [String: AnyObject]) -> [String: AnyObject] {
        var jsonDict = json
        let keys = json.keys
        for key in keys {
            let jsonValue = json[key]
            if jsonValue == nil || jsonValue&.isEmpty || isEmptyArray(jsonValue) || isEmptyDictionary(jsonValue) {
                jsonDict.removeValueForKey(key)
            }
        }
        return jsonDict
    }
    
    // check if json value is an empty array
    private func isEmptyArray(jsonValue: AnyObject?) -> Bool {
        return jsonValue == nil || (jsonValue! is [AnyObject]) && (jsonValue! as! [AnyObject]).count == 0
    }
    
    // check if json value is an empty dictionary
    private func isEmptyDictionary(jsonValue: AnyObject?) -> Bool {
        return jsonValue == nil || (jsonValue! is [String: AnyObject]) && (jsonValue! as! [String: AnyObject]).count == 0
    }
    
    /**
     delete model data
     
     - parameter model: Model
     
     - returns: Bool
     */
    func delete(model: Model) -> Bool {
        
        if !verify(model) {
            return false
        }
        
        let fReq: NSFetchRequest = NSFetchRequest(entityName: model.identifier.modelName)
        
        let query = model.getQuery()
        if !query.isEmpty {
            fReq.predicate = NSPredicate(format: query)
        }
        fReq.returnsObjectsAsFaults = false
        
        if let result = try? coreDataHelper.backgroundContext!.executeFetchRequest(fReq) {
            for resultItem in result {
                let data = resultItem as! NSManagedObject
                coreDataHelper.backgroundContext!.deleteObject(data)
                print("Delete core data \(model.identifier.modelName) \(query) ")
            }
            
            coreDataHelper.saveContext(coreDataHelper.backgroundContext!)
        }
        
        return true
    }
    
    // MARK: - clean up
    
    //clear all model datas
    func clear() {
        coreDataStore.removeModelData()
        
        coreDataStore = CoreDataStore(storeName: coreDataModelFileName, inBundle: bundle)
        coreDataHelper = CoreDataHelper(cdstore: self.coreDataStore)
    }
}