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


public class QueryParameters {
    public var platform_id:           String?
    public var platform_name:         String?
    public var owner:                 String?
    public var name:                  String?
    public var id:                    String?
    public var description:           String?
    public var location_name:         String?
    public var location_lat:          Double?
    public var location_long:         Double?
    public var max_distance:          Int?
    public var observed_property:     [String]?
    public var resource_type:         String?
    public var should_rank:           Bool?
}




///global instance of SecurityHandler client
public var clientSH: SecurityHandler = SecurityHandler(homeAAMAddress: homeAamConstant)

public class SearchResourcesManager {
    
    public var devicesList: [SmartDevice] = []
    public var coreInterfaceUrl = ""
    public var aamClient: AAMClient
    
    
    public init(_ coreUrl: String = homeAamConstant) {
        self.coreInterfaceUrl = coreUrl
        aamClient = AAMClient(coreUrl)
    }
    

    public func buildQueryUrl(_ params: [String:String]) -> URL? {
        var urlComp = URLComponents(string: "\(coreInterfaceUrl)/query")!
        urlComp.queryItems = [URLQueryItem]()
        for p in params.keys {
            let qItem = URLQueryItem(name: p, value: params[p])
            urlComp.queryItems?.append(qItem)
        }
        
        return urlComp.url
    }
    
    public func getCoreResourcesList(_ params: [String:String]) {
        guard let url = buildQueryUrl(params) else {
            let notiInfoObj  = NotificationInfo(type: ErrorType.connection, info: "empty query url")
            NotificationCenter.default.postNotificationName(SymNotificationName.DeviceListLoaded, object: notiInfoObj)
            return
        }
        
        let request = NSMutableURLRequest(url: url)
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
                
                self.getBackupTestData()
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
                        self.parseDevicesFromCoreJson(json)
                    } catch {
                        logError("getResourceList json")
                    }
                }
            }
        }
        
        task.resume()
    }
    
    
    /// example urlSearchStr format: "https://symbiote-open.man.poznan.pl/coreInterface/query?id=5ae314283a6fd805304869ca"
    public func getCoreResourcesList___test(_ urlSearchStr: String = GlobalSettings.coreClientRequest) {
        let url = URL(string: urlSearchStr) //requesting via client proxy
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
    
    private func parseDevicesFromCoreJson(_ dataJson: JSON) {
        devicesList = [SmartDevice]()
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
            NotificationCenter.default//.post(Notification.Name(SymNotificationName.DeviceListLoaded.rawValue))
            .postNotificationName(SymNotificationName.DeviceListLoaded)
        }
    }
    
    
    private func parseDevicesFromSSPJson(_ dataJson: JSON) {
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
    
    private func getBackupTestData() {
        logWarn("+++  no devices found getting debug test data +++")
        
        let dev = SmartDevice.makeDebugTestDevice()
        devicesList.append(dev)
        
        NotificationCenter.default.postNotificationName(SymNotificationName.DeviceListLoaded)
    }
    
    
    
}
