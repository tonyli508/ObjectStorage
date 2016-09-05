//
//  CoreDataStore.swift
//  ObjectStorage
//
//  Created by Li Jiantang on 26/03/2015.
//  Copyright (c) 2015 Carma. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStore {
    
    let storeName: String
    let storeFilename: String
    let bundle: NSBundle
    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    let managedObjectModel: NSManagedObjectModel
    
    /**
     Init with store file name and which bundle it in
     
     - parameter storeName: store file name without extension
     - parameter inBundle:  NSBundle
     
     */
    init(storeName: String, inBundle: NSBundle = NSBundle.mainBundle()) {
        self.storeName = storeName
        self.storeFilename = "\(storeName).sqlite"
        self.bundle = inBundle
        
        let modelURL = bundle.URLForResource(self.storeName, withExtension: "momd")!
        self.managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file.
        guard let url = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last else {
            fatalError("Can't found user docuemnt directory.")
        }
        return NSURL(fileURLWithPath: url)
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.storeFilename)
        
        let mOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true]
        
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: mOptions)
        } catch {
            coordinator = nil
            // TODO:: Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            // Need to delete all the core data files in the user's device
            print("Failed to initialize the application's saved data, with error \(error)")
            self.removeModelData()
            #if DEBUG
                //abort()
            #endif
        }
        
        return coordinator
    }()
    
    // remove current store file, shortcut for reset everything
    func removeModelData() {
        let modelFilesName = [ "Model.sqlite", "Model.sqlite-shm", "Model.sqlite-wal" ]
        let theFileManager = NSFileManager.defaultManager()
        for file in modelFilesName {
            let pathToDocumentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            
            if let filePath = NSURL(string: pathToDocumentsFolder)?.URLByAppendingPathComponent(file).path {
                if theFileManager.fileExistsAtPath(filePath) {
                    
                    do {
                        try theFileManager.removeItemAtPath(filePath)
                    } catch let error as NSError {
                        print("removed item with error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}