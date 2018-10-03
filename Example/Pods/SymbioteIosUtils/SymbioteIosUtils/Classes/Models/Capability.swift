//
//  Capabilities.swift
//  SymAgent
//
//  Created by Konrad Leszczyński on 28/05/2018.
//  Copyright © 2018 PSNC. All rights reserved.
//

import Foundation
import SwiftyJSON


public class Capability {

    public var name: String = ""
    public var parameters: [CapabilitiesParameters] = [CapabilitiesParameters]()
    
    public convenience init(_ cJson: JSON)  {
        self.init()
        
        if cJson["name"].exists() { name = cJson["name"].stringValue  }
        
        if cJson["parameters"].exists() {
            for cP in cJson["parameters"].arrayValue {
                parameters.append(CapabilitiesParameters(cP))
            }
        }
    }
    
    func findParameterWithName(name: String) -> CapabilitiesParameters? {
        for p in parameters {
            if p.name == name {
                return p
            }
        }
        return nil //did not find
    }
    
    
    
}


