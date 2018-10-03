//
//  ObservationValue.swift
//  SSPApp
//
//  Created by Konrad Leszczyński on 23/08/2017.
//  Copyright © 2017 PSNC. All rights reserved.
//

import Foundation
import SwiftyJSON

public class ObservationValue {
    public var valueString: String = ""
    public var valueDouble: Double = 0.0
    
    public var unitLabel: String = ""
    public var unitSymbol: String = ""
    public var propertyLabel: String = ""

    
    public convenience init(j: JSON)  {
        self.init()
        
        if j["value"].exists()     {
            valueString = j["value"].stringValue
            if let dVal = Double(valueString) {
                self.valueDouble = dVal
            }
            else {  //in case value is with unit like "30.5 %" we must remove leters first
                let text2 = valueString.replacingOccurrences(of: ",", with: ".")   //decimal point has different formats
                let decimals = Set("0123456789.".characters)
                let filtered = String( text2.characters.filter{decimals.contains($0)} )
                if filtered != "" {
                    if let dVal = Double(filtered) {
                        self.valueDouble = dVal
                    }
                }
            }
        }
        
        if j["uom"].exists() {
            if j["uom"]["symbol"].exists() {
                unitSymbol = j["uom"]["symbol"].stringValue
            }
            if j["uom"]["label"].exists() {
                unitLabel = j["uom"]["label"].stringValue
            }
        }
        
        if j["obsProperty"]["label"].exists() {
            propertyLabel = j["obsProperty"]["label"].stringValue
        }       
    }
}
