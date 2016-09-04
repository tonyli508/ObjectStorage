//
//  AnyObject+toString.swift
//  ObjectStorage
//
//  Created by Li Jiantang on 04/09/2016.
//  Copyright © 2016 Carma. All rights reserved.
//

import Foundation

postfix operator & {}

postfix func & <T>(s: T?) -> String {
    return (s == nil) ? "" : "\(s!)"
}

postfix func & <T>(s: T) -> String {
    return "\(s)"
}