//
//  SearchResourcesManager.swift
//  SymbioteSpike
//
//  Created by Konrad Leszczyński on 10/07/2017.
//  Copyright © 2017 PSNC. All rights reserved.
//

import Foundation
import SwiftyJSON
import SymbioteIosUtils

public class SearchResourcesManager {
    
    public var devicesList: [SmartDevice] = []

    public init() {}
    
    func getTestDataFromCloud() {
        let url = URL(string: "https://symbiote-dev.man.poznan.pl:8100/coreInterface/v1/query") //debug - data from
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("", forHTTPHeaderField: "X-Auth-Token")  //TODO: proper secure token
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data,response,error in
            if let err = error {
                logError(error.debugDescription)

                let notiInfoObj  = NotificationInfo(type: ErrorType.connection, info: err.localizedDescription)
                NotificationCenter.default.postNotificationName(SymNotificationName.DeviceListLoaded, object: notiInfoObj)

                self.getBackupTestData()
            }
            else {
                //debug
//                let dataString = String(data: data!, encoding: String.Encoding.utf8)
//                logVerbose(dataString)
                
                if let jsonData = data {
                    do {
                        let json = try JSON(data: jsonData)
                        self.parseDevicesFromCoreJson(json)
                    } catch {
                        logError("getTestDataFromCloud json")
                    }
                }

            }
        }
        
        task.resume()
    }
    
    public func getCoreResourceList() {
        //let url = URL(string: "https://symbiote-open.man.poznan.pl/coreInterface/query?id=5ae314283a6fd805304869ca") //if using direct request  -needs security tokens in heade
        let url = URL(string: GlobalSettings.coreClientRequest) //requesting via client proxy
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        

        let task = URLSession.shared.dataTask(with: request as URLRequest) { data,response,error in
            if let err = error {
                logError(error.debugDescription)
                
                let notiInfoObj  = NotificationInfo(type: ErrorType.connection, info: err.localizedDescription)
                NotificationCenter.default.postNotificationName(SymNotificationName.DeviceListLoaded, object: notiInfoObj)
                
                self.getBackupTestData()
            }
            else {
                let status = (response as! HTTPURLResponse).statusCode
                if (status >= 400) {
                    logError("response status: \(status)  \(response.debugDescription)")
                    let notiInfoObj  = NotificationInfo(type: ErrorType.connection, info: "response status: \(status)")
                    NotificationCenter.default.postNotificationName(SymNotificationName.DeviceListLoaded, object: notiInfoObj)
                }
                //debug
//                let dataString = String(data: data!, encoding: String.Encoding.utf8)
//                logVerbose(dataString)
                
                
                if let jsonData = data {
                    do {
                        let json = try JSON(data: jsonData)
                        self.parseDevicesFromCoreJson(json)
                    } catch {
                        logError("getResourceList json")
                    }
                }
                
            }
        }
        
        task.resume()
    }
    
    public func getSSPResourceList() {
        let url = URL(string: GlobalSettings.restApiUrl + "/innkeeper/public_resources/")
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data,response,error in
            if let err = error {
                logError(error.debugDescription)
                
                let notiInfoObj  = NotificationInfo(type: ErrorType.connection, info: err.localizedDescription)
                NotificationCenter.default.postNotificationName(SymNotificationName.DeviceListLoaded, object: notiInfoObj)
                
                self.getBackupTestData()
            }
            else {
                let status = (response as! HTTPURLResponse).statusCode
                if (status >= 400) {
                    logError("response status: \(status)  \(response.debugDescription)")
                    let notiInfoObj  = NotificationInfo(type: ErrorType.connection, info: "response status: \(status)")
                    NotificationCenter.default.postNotificationName(SymNotificationName.DeviceListLoaded, object: notiInfoObj)
                }
                //debug
//                let dataString = String(data: data!, encoding: String.Encoding.utf8)
//                logVerbose(dataString)
                
                
                if let jsonData = data {
                    do {
                        let json = try JSON(data: jsonData)
                        self.parseDevicesFromSSPJson(json)
                    } catch {
                        logError("getResourceList json")
                    }
                }
                
            }
        }
        
        task.resume()
    }
    
    
    public func parseDevicesFromCoreJson(_ dataJson: JSON) {
        if dataJson["body"].exists() == false {
            logWarn("+++++++ wrong json +++++  SearchDevicesManager dataJson = \(dataJson)")
            
            let notiInfoObj  = NotificationInfo(type: ErrorType.wrongResult, info: "wrong json from API")
            NotificationCenter.default.postNotificationName(SymNotificationName.DeviceListLoaded, object: notiInfoObj)
            self.getBackupTestData()
            return
        }
        
        let jsonArr:[JSON] = dataJson["body"].arrayValue
        for childJson in jsonArr {
            
            let dev = CoreSmartDevice(childJson)
            devicesList.append(dev)
        }
        
        if devicesList.count == 0 {
            getBackupTestData()
            let notiInfoObj  = NotificationInfo(type: ErrorType.emptySet, info: "No devices found in core")
            NotificationCenter.default.postNotificationName(SymNotificationName.DeviceListLoaded, object: notiInfoObj)
        }
        else {
            NotificationCenter.default.postNotificationName(SymNotificationName.DeviceListLoaded)
        }
    }
    
    
    public func parseDevicesFromSSPJson(_ dataJson: JSON) {
        let jsonArr:[JSON] = dataJson.arrayValue
        for childJson in jsonArr {
            
            let dev = SSPSmartDevice(childJson)
            devicesList.append(dev)
        }
        
        if devicesList.count == 0 {
            getBackupTestData()
            let notiInfoObj  = NotificationInfo(type: ErrorType.emptySet, info: "No devices in SSP")
            NotificationCenter.default.postNotificationName(SymNotificationName.DeviceListLoaded, object: notiInfoObj)
        }
        else {
            NotificationCenter.default.postNotificationName(SymNotificationName.DeviceListLoaded)
        }
    }
    
    public func getBackupTestData() {
        logWarn("+++  no devices found getting debug test data +++")
        
        let dev = SmartDevice.makeDebugTestDevice()
        devicesList.append(dev)
        
        NotificationCenter.default.postNotificationName(SymNotificationName.DeviceListLoaded)
    }
    
    
    
}
