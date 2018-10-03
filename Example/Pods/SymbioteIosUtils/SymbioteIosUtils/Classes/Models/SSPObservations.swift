//
//  SSPObservations.swift
//  SymAgent
//
//  Created by Konrad Leszczyński on 21/05/2018.
//  Copyright © 2018 PSNC. All rights reserved.
//

import Foundation
import SwiftyJSON
import SymbioteIosUtils

/// use only in SSP bacause JSON format for observations differs
public class Observation {
    
    public var resourceId: String = ""
    public var resultTime: String = ""  //TODO parse time to DateTime
    public var samplingTime: String = ""
    public var time = DateTime()
    
    public var location: ObservationLocation?
    public var values: [ObservationValue] = [ObservationValue]()
    
    public var valuesCombined: String = ""
    
    
    public convenience init(j: JSON)  {
        self.init()
        
        
        if j["resourceId"].exists()     { resourceId = j["resourceId"].stringValue }
        if j["resultTime"].exists()     {
            resultTime = j["resultTime"].stringValue
            time = DateTime(fromString: resultTime)
        }
        if j["samplingTime"].exists()     { samplingTime = j["samplingTime"].stringValue }
        
        if j["location"].exists()     {
            let jLoc = j["location"]
            self.location = ObservationLocation(j: jLoc)
        }
        
        if j["obsValues"] .exists()     {
            let jArrObsValues = j["obsValues"].arrayValue
            for childJson in jArrObsValues {
                let obsV = ObservationValue(j: childJson)
                values.append(obsV)
            }
            combineValues()
        }
    }
    
    public func combineValues() {
        for v in values {
            valuesCombined += v.valueString + "; "
        }
    }
}
