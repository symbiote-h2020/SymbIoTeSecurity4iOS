//
//  GlobalSettingsContainer.swift
//  SSPApp
//
//  Created by Konrad Leszczyński on 19/09/2017.
//  Copyright © 2017 PSNC. All rights reserved.
//

import Foundation
import SymbioteIosUtils

private struct Keys {
    static let restApiUrl: String = "restApiUrl"
    static let coreInterfaceApi: String = "coreInterfaceApi"
    static let coreClientRequest: String = "coreClientRequest"
    static let coreRapSensorAdressTamplate: String = "coreRapSensorAdressTamplate"
}

public final class GlobalSettingsContainer: NSObject, NSCoding {

    public var restApiUrl: String = Constants.defaultSspRestApiUrl
    public var coreInterfaceApi: String = Constants.defaultCoreInterfaceApiUrl
    
    ///this is used during demo
    public var coreClientRequest: String = Constants.defaultCoreClientRequest
    public var coreRapSensorAdressTamplate: String = Constants.defaultCoreRapSensorAdressTamplate
    
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.restApiUrl, forKey: Keys.restApiUrl)
        aCoder.encode(self.coreInterfaceApi, forKey: Keys.coreInterfaceApi)
        aCoder.encode(self.coreClientRequest, forKey: Keys.coreClientRequest)
        aCoder.encode(self.coreRapSensorAdressTamplate, forKey: Keys.coreRapSensorAdressTamplate)
    }
    
    @objc convenience public init?(coder aDecoder: NSCoder) {
        self.init()
        if aDecoder.containsValue(forKey: Keys.restApiUrl) {
            self.restApiUrl = aDecoder.decodeObject(forKey: Keys.restApiUrl) as! String
        }
        else {
            self.restApiUrl =  Constants.defaultSspRestApiUrl
        }
        if aDecoder.containsValue(forKey: Keys.coreInterfaceApi) {
            self.coreInterfaceApi = aDecoder.decodeObject(forKey: Keys.coreInterfaceApi) as! String
        }
        else {
            self.coreInterfaceApi = Constants.defaultCoreInterfaceApiUrl
        }
        
        if aDecoder.containsValue(forKey: Keys.coreClientRequest) {
            self.coreClientRequest = aDecoder.decodeObject(forKey: Keys.coreClientRequest) as! String
        }
        else {
            self.coreClientRequest =  Constants.defaultCoreClientRequest
        }
        if aDecoder.containsValue(forKey: Keys.coreRapSensorAdressTamplate) {
            self.coreRapSensorAdressTamplate = aDecoder.decodeObject(forKey: Keys.coreRapSensorAdressTamplate) as! String
        }
        else {
            self.coreRapSensorAdressTamplate = Constants.defaultCoreRapSensorAdressTamplate
        }
    }

}
