//
//  UserProfile.swift
//  ObjectStorage
//
//  Created by Li Jiantang on 26/03/2015.
//  Copyright (c) 2015 Carma. All rights reserved.
//

import Foundation
import ObjectMapper
@testable import ObjectStorage

/// User Profile
class UserProfile: MappableModel {
    
    static let VERIFICATION_LINKEDIN = "LinkedinConnected"
    static let VERIFICATION_FACEBOOK = "FacebookConnected"
    static let VERIFICATION_EMAIL = "EmailVerified"
    static let VERIFICATION_PHONE = "PhoneNumberVerified"
    
    var userId: String?
    var firstName: String?
    var lastName: String?
    var middleName: String?
    var gender: String?
    var email: String?
    var jobTitle: String?
    var company: String?
    var countryCode: String?
    var phoneNumber: String?
    var dateOfBirth: String?
    var driverLicense: DriverLicense?
    var validations: [String: Int]?
    
    override func mapping(map: Map) {
        
        userId <- (map["userId"], StringTransform())
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        gender <- map["gender"]
        email <- map["email"]
        jobTitle <- map["jobTitle"]
        company <- map["company"]
        countryCode <- map["countryCode"]
        phoneNumber <- map["phoneNumber"]
        middleName <- map["middleName"]
        dateOfBirth <- map["dateOfBirth"]
        driverLicense <- map["driverLicense"]
        validations <- map["validations"]
    }
    
    /// Override the mappingRule setter function so that we can change sub-MappableModel as well
    override var mappingRule: MappingRules {
        get {
            return super.mappingRule
        }
        set(rule) {
            super.mappingRule = rule
            driverLicense?.mappingRule = rule
        }
    }
    
    override var identifier: ModelIdentifier {
        get {
            return (modelName: "UserProfile", keys: ["userId"], values: [userId])
        }
        set {
            
        }
    }
    
    /**
     Verify user profile, at least should have userId, firstName and lastName
     
     - parameter forRule: MappingRules
     
     - returns: Bool
     */
    override func verify(forRule: MappingRules) -> Bool {
        return userId != nil && firstName != nil && lastName != nil
    }
}
