//
//  AbstractSmartDevice.swift
//  SymAgent
//
//  Created by Konrad Leszczyński on 23/05/2018.
//  Copyright © 2018 PSNC. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum DeviceType{
    case ssp
    case core
}

public enum DeviceFunctionType {
    case actuator
    case sensor
    case both //is this posible
    case none
}

public class SmartDevice {
    public var platformId: String = ""
    public var platformName: String = ""
    public var owner: String =  ""
    public var name: String = ""
    public var id: String = ""
    public var deviceDescription: String = ""
    public var status: String = ""
    
    //location
    public var locationName: String = ""
    public var locationLatitude: String = ""
    public var locationLongitude: String = ""
    public var locationAltitude: String = ""
    
    //array
    public var observedProperties: [String] = [String]()
    public var resourceType: [String] = [String]()

    public var type: DeviceType = .ssp
    public var capabilities: [Capability] = [Capability]()
    
    public var functionType: DeviceFunctionType {
        get {
            if capabilities.count > 0 {
                if observedProperties.count > 0 {
                    return .both
                }
                else {
                    return .actuator
                }
            }
            else if observedProperties.count > 0 {
                return .sensor
            }
            else {
                return .none
            }
        }
    }
    
    public static func makeDebugTestDevice() -> SmartDevice {
        let dev = SmartDevice()
        dev.id="0"
        dev.name="No smart devices in this SmartSpace"
        dev.locationName="Not found"
        dev.platformName="No devices"
        dev.deviceDescription="Debug test device in case of error"
        dev.status = "NOT FOUND"
        dev.observedProperties.append("debug data")
        return dev
    }
    
    public func findCapabilityByname(name: String) -> Capability? {
        for c in capabilities {
            if c.name == name {
                return c
            }
        }
        return nil
    }
}
