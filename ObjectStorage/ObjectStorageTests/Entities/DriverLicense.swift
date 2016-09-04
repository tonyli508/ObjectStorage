//
//  DriverLicense.swift
//  ObjectStorage
//
//  Created by Li Jiantang on 12/05/2015.
//  Copyright (c) 2015 Carma. All rights reserved.
//

import Foundation
import ObjectMapper
@testable import ObjectStorage

class DriverLicense: MappableModel {
    
    var firstName: String?
    var middleName: String?
    var lastName: String?
    var licenseNumber: String?
    var licenseState: String?
    var dateOfBirth: NSDate?
    var dateOfExpiry: NSDate?
    var country: String = "USA"
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    required init(MappingRule rule: MappingRules) {
        super.init(MappingRule: rule)
    }
    
    override func mapping(map: Map) {
        
        switch mappingRule {
        case .PropertiesJSON:
            
            firstName <- map["firstName"]
            middleName <- map["middleName"]
            lastName <- map["lastName"]
            licenseState <- map["licenseState"]
            licenseNumber <- map["licenseNumber"]
            dateOfBirth <- (map["dateOfBirth"], CustomDateFormatTransform(formatString: "MMddyyyy"))
            dateOfExpiry <- (map["dateOfExpiry"], CustomDateFormatTransform(formatString: "MMddyyyy"))
            
        case .ServerResponseJSON:
            
            firstName <- map["firstName"]
            lastName <- map["lastName"]
            middleName <- map["middleName"]
            dateOfBirth <- (map["dateOfBirth"], CustomDateFormatTransform(formatString: "yyyy-MM-dd"))
            licenseNumber <- map["number"]
            licenseState <- map["region"]
            country <- map["country"]
        }
        
    }
    
    override var identifier: ModelIdentifier {
        get {
            return (modelName: "DriverLicense", keys: ["licenseNumber"], values: [licenseNumber])
        }
        set {
            
        }
    }
    
    override var description: String {
        get {
            return "fristName: \(firstName), middleName: \(middleName), lastName: \(lastName), licenseNumber: \(licenseNumber), licenseState: \(licenseState), dateOfBirth: \(dateOfBirth), dateOfExpiry: \(dateOfExpiry)"
        }
    }
}
