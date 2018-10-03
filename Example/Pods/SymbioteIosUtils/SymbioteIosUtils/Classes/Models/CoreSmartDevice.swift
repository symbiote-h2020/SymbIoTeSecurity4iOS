//
//  Device.swift
//  SymbioteSpike
//
//  Created by Konrad Leszczyński on 13/07/2017.
//  Copyright © 2017 Konrad Leszczyński. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 Smart device/resources for core's has slightly different JSON structure
 */
public class CoreSmartDevice : SmartDevice {

    
    public convenience init(_ j: JSON)  {
        self.init()
        
        type = .core
        
        if j["platformId"].exists()     { platformId = j["platformId"].stringValue }
        if j["platformName"].exists()   { platformName = j["platformName"].stringValue }
        if j["owner"].exists()          { owner = j["owner"].stringValue }
        if j["name"].exists()           { name = j["name"].stringValue
            //debug
//            if self.name == "A23" {
//                log("json=\(j)")
//            }
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
    }
}
