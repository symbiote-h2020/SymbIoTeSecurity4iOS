//
//  ObservationsManager.swift
//  SSPApp
//
//  Created by Konrad Leszczyński on 23/08/2017.
//  Copyright © 2017 PSNC. All rights reserved.
//

import Foundation
import SwiftyJSON
import SymbioteIosUtils

public class ObservationsManager {
    public var aamClient: AAMClient
    public var coreInterfaceUrl = ""
    
    public init(coreUrl: String = "https://symbiote-open.man.poznan.pl/coreInterface") {
        self.coreInterfaceUrl = coreUrl
        aamClient = AAMClient(coreUrl)
    }
    
    public var currentObservations: [Observation] = [Observation]()
    public var observationsByLocation: [String: [Observation]] = [String: [Observation]]()
    
    public func getTestData() {
        if let archiveUrl = Bundle.main.URLForResource("observationsFromSSP.json") {
            if let data = try? Data(contentsOf: archiveUrl) {
                logWarn("loading test hardcoded data from test file")
                
                do {
                    let json = try JSON(data: data)
                    parseOservationsJson(json)
                } catch {
                    logError("getTestData json")
                }
            }
        }
    }
    
    
    public func getResourceId() { //TODO parameters
        //resource of user icom id    String    "5b67ea6c8199a065667cc409"
        let url = URL(string: "https://symbiote-dev.man.poznan.pl/coreInterface/resourceUrls?id=5b67ea6c8199a065667cc409")  //id=5a9d2e024a234e4b02e97c41")
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(DateTime.Now.unixEpochTime()*1000)", forHTTPHeaderField: "x-auth-timestamp")
        request.setValue("1", forHTTPHeaderField: "x-auth-size")
        if clientSH.isLoggedIn() {
            request.setValue(clientSH.buildXauth1HeaderWithHomeToken(), forHTTPHeaderField: "x-auth-1")
        }
        else {
            request.setValue(aamClient.buildXauth1HeaderWithGuestToken(), forHTTPHeaderField: "x-auth-1")
        }
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data,response,error in
            if let err = error {
                logError(error.debugDescription)
                
                let notiInfoObj  = NotificationInfo(type: ErrorType.connection, info: err.localizedDescription)
                NotificationCenter.default.postNotificationName(SymNotificationName.DeviceListLoaded, object: notiInfoObj)
                
               
            }
            else {
                let status = (response as! HTTPURLResponse).statusCode
                if (status >= 400) {
                    logError("response status: \(status)  \(response.debugDescription)")
                    let notiInfoObj  = NotificationInfo(type: ErrorType.connection, info: "response status: \(status)")
                    NotificationCenter.default.postNotificationName(SymNotificationName.DeviceListLoaded, object: notiInfoObj)
                }
                
                if let jsonData = data {
                    do {
                        let json = try JSON(data: jsonData)
                        log(json.debugDescription)
                        
                    } catch {
                        logError("getResourceList json")
                    }
                }
            }
        }
        
        task.resume()
    }
    
    ///use only inside SSP to combine L1 and L3/L4 devices on one list
    func makeRequestForSSPObservations(_ forDeviceId: String!) -> NSMutableURLRequest? {
        if let devId = forDeviceId {
            let strUrl =  "\(GlobalSettings.restApiUrl)/rap/Sensor('\(devId)')/Observations"  ///Observations?$top=1")
            //let strTestUrl =   "http://217.72.97.9:8080/rap/Sensor('1')/Observations" //test
            log(strUrl)
            let url = URL(string: strUrl)
            let request = NSMutableURLRequest(url: url!)
            request.httpMethod = "GET"
            request.setValue("\(DateTime.Now.unixEpochTime()*1000)", forHTTPHeaderField: "x-auth-timestamp")
            request.setValue("1", forHTTPHeaderField: "x-auth-size")
            request.setValue(aamClient.buildXauth1HeaderWithGuestToken(), forHTTPHeaderField: "x-auth-1")
            
            return request
        }
        else {
            return nil
        }
    }
    
    func makeRequestForCoreObservations(_ forDeviceId: String!) -> NSMutableURLRequest? {
        if let devId = forDeviceId {
            let strUrl =  "\(GlobalSettings.coreRapSensorAdressTamplate)/rap/Sensor('\(devId)')/Observations"
           
            log(strUrl)
            let url = URL(string: strUrl)
            let request = NSMutableURLRequest(url: url!)
            request.httpMethod = "GET"
            request.setValue("\(DateTime.Now.unixEpochTime()*1000)", forHTTPHeaderField: "x-auth-timestamp")
            request.setValue("1", forHTTPHeaderField: "x-auth-size")
            request.setValue(aamClient.buildXauth1HeaderWithGuestToken(), forHTTPHeaderField: "x-auth-1")
            
            return request
        }
        else {
            return nil
        }
    }
    
    public func getObservations(forDevice: SmartDevice!) {
        var httpRequest: NSMutableURLRequest? = nil
        if forDevice.type == .ssp {
           httpRequest = makeRequestForSSPObservations(forDevice.id)
        }
        else if forDevice.type == .core {
            httpRequest = makeRequestForCoreObservations(forDevice.id)
        }
        
        if let request = httpRequest {
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data,response,error in
                if let err = error {
                    logError(error.debugDescription)
                    
                    let notiInfoObj  = NotificationInfo(type: ErrorType.connection, info: err.localizedDescription)
                    NotificationCenter.default.postNotificationName(SymNotificationName.ObservationsListLoaded, object: notiInfoObj)
                }
                else {
                    let status = (response as! HTTPURLResponse).statusCode
                    if (status >= 400) {
                        self.getTestData()
                        logError("response status: \(status) \(response.debugDescription)")
                        let notiInfoObj  = NotificationInfo(type: ErrorType.connection, info: "response status: \(status)")
                        NotificationCenter.default.postNotificationName(SymNotificationName.ObservationsListLoaded, object: notiInfoObj)
                    }
                    //debug
                    let dataString = String(data: data!, encoding: String.Encoding.utf8)
                    logVerbose(dataString)
                    
                    
                    if let jsonData = data {
                        do {
                            let json = try JSON(data: jsonData)
                            self.parseOservationsJson(json)
                        } catch {
                            logError("getObservations json")
                        }
                    }
                    
                }
            }
            
            task.resume()
        }
    }
    
    public func parseOservationsJson(_ dataJson: JSON) {
        let jsonArr:[JSON] = dataJson.arrayValue
        //for jInnerArray in jsonArr {
        for childJson in jsonArr {
            
            let obs = Observation(j: childJson)
            currentObservations.append(obs)
            
            let location = obs.location?.name ?? "[ SSP ]"
            if (observationsByLocation[location] == nil) {
                observationsByLocation[location] = [Observation]()
            }
            self.observationsByLocation[location]?.append(obs)
        }
        
        
        NotificationCenter.default.postNotificationName(SymNotificationName.ObservationsListLoaded)
    }
}

/// helpers use for reading test data from file
extension Bundle {
    
    func pathForResource(_ name: String?) -> String? {
        if let components = name?.components(separatedBy: ".") , components.count == 2 {
            return self.path(forResource: components[0], ofType: components[1])
        }
        return nil
    }
    
    func URLForResource(_ name: String?) -> URL? {
        if let components = name?.components(separatedBy: ".") , components.count == 2 {
            return self.url(forResource: components[0], withExtension: components[1])
        }
        return nil
    }
    
}

// MARK: infoDictionary
extension Bundle {
    
    var CFBundleName: String {
        return (infoDictionary?["CFBundleName"] as? String) ?? ""
    }
    
    var CFBundleShortVersionString: String {
        return (infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
    }
    
}
