//
//  Constants.swift
//  SymbioteSpike
//
//  Created by Konrad Leszczyński on 14/07/2017.
//  Copyright © 2017 PSNC. All rights reserved.
//

import Foundation


public class Constants {
    public static let defaultSspRestApiUrl: String  = "http://217.72.97.9:8080"
    public static let defaultCoreInterfaceApiUrl: String = "https://symbiote-open.man.poznan.pl/coreInterface"
    
    //this is used during demo
    public static var defaultCoreClientRequest: String = "https://symbiote-open.man.poznan.pl:8777/query?homePlatformId=SymbIoTe_Core_AAM"
    public static var defaultCoreRapSensorAdressTamplate: String = "https://symbiote.tel.fer.hr"
}

public final class GlobalSettings {
    public static let isDebug: Bool                                        = _isDebugAssertConfiguration()
    public static let isVerboseLogging: Bool                               = true  //TODO: zrobić zaawansowaną konfigurację jak w loggerze microsoftowym
    
    public static var restApiUrl: String  = Constants.defaultSspRestApiUrl
    public static var coreInterfaceApiUrl: String = Constants.defaultCoreInterfaceApiUrl
    
    //this is used during demo
    public static var coreClientRequest: String = Constants.defaultCoreClientRequest
    public static var coreRapSensorAdressTamplate: String = Constants.defaultCoreRapSensorAdressTamplate
}


