//
//  ResourceLoaderTest.swift
//  ObjectStorage
//
//  Created by Li Jiantang on 04/09/2016.
//  Copyright © 2016 Carma. All rights reserved.
//

import XCTest

/**
 RsourceLoad is quite handy for tests
 
 Just make sure it works from time to time
 */
class ResourceLoaderTest: XCTestCase {
    
    // Loading json resource test
    func testLoadingJSONResource() {
        
        let JSONResource = ResourceLoader.load("test_json.txt", inBundle: NSBundle(forClass: self.classForCoder))
        
        XCTAssertGreaterThan(JSONResource.string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding), 0)
        XCTAssertNotNil(JSONResource.json, "Should be a json file")

    }
}
