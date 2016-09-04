//
//  ObjectStorageTests.swift
//  ObjectStorageTests
//
//  Created by Li Jiantang on 04/09/2016.
//  Copyright © 2016 Carma. All rights reserved.
//

import XCTest
@testable import ObjectStorage

class ObjectStorageTests: XCTestCase {
    
    var storageProvider: StorageProviderService!
    var userJSON: Resource!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let bundle = NSBundle(forClass: self.classForCoder)
        storageProvider = StorageProviderService(coreDataModelFileName: "Model", inBundle: NSBundle(forClass: self.classForCoder))
        userJSON = ResourceLoader.load("UserMockJSON.txt", inBundle: bundle)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCURD() {
        CURDAssertions()
    }
    
    func testCURDPerformance() {
        // This is an example of a performance test case.
        self.measureBlock { [unowned self] in
            for _ in 0...100 {
                self.CURDAssertions()
            }
        }
    }
}

// MARK: - CURD assertions
extension ObjectStorageTests {
    
    /**
     Test CURD for StoragePrivoderService
     */
    func CURDAssertions() {
        
        let json = userJSON.json
        
        if let user = UserProfile(MappingRule: .PropertiesJSON).fromJSON(json!) as? UserProfile {
            
            let created = storageProvider.create(user)
            
            XCTAssert(created, "Should create a new user")
            
            let readUser = storageProvider.read(user)
            
            XCTAssertEqual("\(readUser!.toJSON()["lastName"]!)", user.lastName!, "Should get same properties")
            
            user.lastName = "123"
            user.firstName = nil // updating should ignore the nil value
            
            let updated = storageProvider.update(user)
            
            XCTAssert(updated, "Should update the user")
            
            if updated {
                let updatedUser = storageProvider.read(user)
                
                XCTAssertEqual("\(updatedUser!.toJSON()["lastName"]!)", user.lastName!, "Should get same properties")
                XCTAssertEqual("\(updatedUser!.toJSON()["firstName"]!)", "\(readUser!.toJSON()["firstName"]!)", "Updating should ignore the nil value")
            }
            
            let deleted = storageProvider.delete(user)
            
            XCTAssert(deleted, "Should delete the user")
            
            if deleted {
                let deletedUser = storageProvider.read(user)
                
                XCTAssert(deletedUser == nil, "User should be deleted")
            }
        }
    }
}
