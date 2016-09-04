//
//  ContactAddress.swift
//  ObjectStorage
//
//  Created by Li Jiantang on 04/09/2016.
//  Copyright © 2016 Carma. All rights reserved.
//

import Foundation
import ObjectMapper
@testable import ObjectStorage

class ContactAddress: MappableModel {
    
    var address1: String = ""
    var address2: String = ""
    var city: String = ""
    var state: String = ""
    var postalCode: String = ""
    var country: String = ""
    // optional
    var lat: Double? = nil
    var lon: Double? = nil
    
    override func mapping(map: Map) {
        address1 <- map["addr1"]
        address2 <- map["addr2"]
        city <- map["city"]
        state <- map["state"]
        postalCode <- map["postalCode"]
        country <- map["country"]
        lat <- map["lat"]
        lon <- map["lon"]
    }
    
    override var description: String {
        get {
            return "<ContactAddres: - address1: \(address1), address2: \(address2), city: \(city), state: \(state), zip: \(postalCode)>"
        }
    }
    
    override var identifier: ModelIdentifier {
        get {
            return (modelName: "ContactAddress", keys: ["address1", "address2", "city", "state"], values: [address1, address2, city, state])
        }
        set {
            
        }
    }
}