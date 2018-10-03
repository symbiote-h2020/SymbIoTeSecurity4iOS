//
//  CapabilitiesParameters.swift
//  SymAgent
//
//  Created by Konrad Leszczyński on 28/05/2018.
//  Copyright © 2018 PSNC. All rights reserved.
//

import Foundation
import SwiftyJSON

public class CapabilitiesParameters {
    public var name: String = ""
    public var mandatory: Bool = false
    public var restricitons: [Restriction] = [Restriction]()
    
    public convenience init(_ cpj: JSON)  {
        self.init()
        
        if cpj["name"].exists() { name = cpj["name"].stringValue  }
        if cpj["mandatory"].exists() { mandatory = cpj["mandatory"].boolValue}
        if cpj["restrictions"].exists() {
            for r in cpj["restrictions"].arrayValue {
                restricitons.append(Restriction(r))
            }
        }
    }
    
    public func findRestrictionByName(_ naem: String) -> Restriction? {
        for r in restricitons {
            if r.cName == name {
                return r
            }
        }
        return nil
    }
}

public class Restriction {
    var cName: String = ""
    var min: Int = 0
    var max: Int = 1
    
    public convenience init(_ cpj: JSON)  {
        self.init()
        
        if cpj["@c"].exists() { cName = cpj["@c"].stringValue }
        if cpj["min"].exists() { min = cpj["min"].intValue }
        if cpj["max"].exists() { max = cpj["max"].intValue }
    }
}

public class DataType {
    //TODO if this information is needed - make a parser
}
