//
//  SSPSmartDevice.swift
//  SymAgent
//
//  Created by Konrad Leszczyński on 15/05/2018.
//  Copyright © 2018 PSNC. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
   Do not mix with cores SmartDevice - it has different JSON
 */
public class SSPSmartDevice : SmartDevice {
    
    
    public convenience init(_ resourceJson: JSON)  {
        self.init()
        
        type = .ssp
        
        var j: JSON = JSON()
        if resourceJson["resource"].exists()  {
            j = resourceJson["resource"]
        }
        else {
            name = "Error - unexpected JSON"
            return
        }
        
        
        if j["platformId"].exists()     { platformId = j["platformId"].stringValue }
        if j["platformName"].exists()   { platformName = j["platformName"].stringValue }
        if j["owner"].exists()          { owner = j["owner"].stringValue }
        if j["name"].exists()           { name = j["name"].stringValue
        }
        if j["id"].exists()             { id = j["id"].stringValue }
        if j["description"].exists()    { deviceDescription = j["description"].stringValue }
        if j["status"].exists()         { status = j["status"].stringValue }
        
        //location
        if j["locationName"].exists()           { locationName = j["locationName"].stringValue }
        if j["locationLatitude"].exists()       { locationLatitude = j["locationLatitude"].stringValue }
        if j["locationLongitude"].exists()      { locationLongitude = j["locationLongitude"].stringValue }
        if j["locationAltitude"].exists()       { locationAltitude = j["locationAltitude"].stringValue }
        
        if j["observedProperties"].exists() {
            for oP in j["observedProperties"].arrayValue {
                observedProperties.append(oP.stringValue)
            }
        } else if j["observesProperty"].exists() {              //I'm not sure about the naming convention so I'll parse both
            for oP in j["observesProperty"].arrayValue {
                observedProperties.append(oP.stringValue)
            }
        }
        
        
        if j["resourceType"].exists() {
            for r in j["resourceType"].arrayValue {
                resourceType.append(r.stringValue)
            }
        }
        
        if j["capabilities"].exists() {
            for c in j["capabilities"].arrayValue {
                self.capabilities.append(Capability(c))
            }
        }
    }
}
