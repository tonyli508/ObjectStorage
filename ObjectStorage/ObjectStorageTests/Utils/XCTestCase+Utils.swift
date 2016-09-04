//
//  XCTestCase+Utils.swift
//  ObjectStorage
//
//  Created by Li Jiantang on 04/09/2016.
//  Copyright © 2016 Carma. All rights reserved.
//

import XCTest

// MARK: - WaitForExpectationsAssertion
extension XCTestCase {
    
    /**
     Wait for expectations with assertion (no errors, no timeout)
     
     - parameter timeout: NSTimeInterval, default to TestConfigs.API_TIMEOUT_TIMER if not passing in
     */
    func waitForExpectationsAssertion(timeout: NSTimeInterval = 60) {
        self.waitForExpectationsWithTimeout(timeout) { (error) -> Void in
            XCTAssertNil(error, "Should be no error: \(error)")
        }
    }
}