//
//  CoreDataHelper.swift
//  ObjectStorage
//
//  Created by Li Jiantang on 26/03/2015.
//  Copyright (c) 2015 Carma. All rights reserved.
//

import CoreData

class CoreDataHelper: NSObject{
    
    var store: CoreDataStore!
    
    init(cdstore: CoreDataStore) {
        super.init()
        self.store = cdstore
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CoreDataHelper.contextDidSaveContext(_:)), name: NSManagedObjectContextDidSaveNotification, object: self.backgroundContext)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CoreDataHelper.contextDidSaveContext(_:)), name: NSManagedObjectContextDidSaveNotification, object: self.managedObjectContext)
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // #pragma mark - Core Data stack
    
    // Returns the managed object context for the application.
    // Normally, you can use it to do anything.
    // But for bulk data update, acording to Florian Kugler's blog about core data performance, [Concurrent Core Data Stacks – Performance Shootout](http://floriankugler.com/blog/2013/4/29/concurrent-core-data-stack-performance-shootout) and [Backstage with Nested Managed Object Contexts](http://floriankugler.com/blog/2013/5/11/backstage-with-nested-managed-object-contexts). We should better write data in background context. and read data from main queue context.
    // If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
    
    // main thread context
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.store.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // Returns the background object context for the application.
    // You can use it to process bulk data update in background.
    // If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
    
    lazy var backgroundContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.store.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var backgroundContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        backgroundContext.persistentStoreCoordinator = coordinator
        return backgroundContext
        }()
    
    
    // save NSManagedObjectContext
    func saveContext (context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save encounter unresolved error: \(error)")
                
                /// if in debug mode, crash to notify the developer to debug this error
                #if DEBUG
                    abort()
                #endif
            }
        }
    }
    
    func saveContext() {
        if let context = self.backgroundContext {
            self.saveContext(context)
        }
    }
    
    // call back function by saveContext, support multi-thread
    func contextDidSaveContext(notification: NSNotification) {
        let sender = notification.object as! NSManagedObjectContext
        if sender === self.managedObjectContext {
            self.backgroundContext?.performBlock {
                self.backgroundContext?.mergeChangesFromContextDidSaveNotification(notification)
            }
        } else if sender === self.backgroundContext {
            self.managedObjectContext?.performBlock {
                self.managedObjectContext?.mergeChangesFromContextDidSaveNotification(notification)
            }
        } else {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.managedObjectContext?.performBlock {
                    self.managedObjectContext?.mergeChangesFromContextDidSaveNotification(notification)
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.backgroundContext?.performBlock {
                    self.backgroundContext?.mergeChangesFromContextDidSaveNotification(notification)
                }
            }
        }
    }
}
