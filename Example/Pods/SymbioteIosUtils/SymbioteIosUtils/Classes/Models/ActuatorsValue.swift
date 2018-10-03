//
//  ActuatorsValue.swift
//  SSPApp
//
//  Created by Konrad Leszczyński on 13/09/2017.
//  Copyright © 2017 PSNC. All rights reserved.
//

import Foundation


public class ActuatorsValue {
    public init() {}
    
    public var name: String = "no name"
    public var value: Int = 100
    public var maxValue: Int = 255
    public var minValue: Int = 0
    
    
    public convenience init(_ cParam: CapabilitiesParameters)  {
        self.init()
        
        self.name = cParam.name
        if let rangeRestriction = cParam.findRestrictionByName(".RangeRestriction") {
            //TODO
        }
    }
    
}
