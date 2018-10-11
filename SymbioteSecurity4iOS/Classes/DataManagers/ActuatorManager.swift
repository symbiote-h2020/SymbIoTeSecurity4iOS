//
//  ActuatorManager.swift
//  SSPApp
//
//  Created by Konrad Leszczyński on 15/09/2017.
//  Copyright © 2017 PSNC. All rights reserved.
//

import Foundation
import SwiftyJSON
import SymbioteIosUtils

public class ActuatorManager {
    public var aamClient: AAMClient
    public var coreInterfaceUrl = ""
    
    public init(coreUrl: String = homeAamConstant) {
        self.coreInterfaceUrl = coreUrl
        aamClient = AAMClient(coreUrl)
    }
    
    public func sendRequest(_ smartDeviceId: String, capability: Capability, valuesList: [ActuatorsValue]) {
        let strUrl = GlobalSettings.restApiUrl + "/rap/Actuator/" + smartDeviceId
        //let strUrl = "\(GlobalSettings.restApiUrl)/rap/Actuator('\(smartDeviceId)')"
        
        log(strUrl)
        let url = URL(string: strUrl)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("\(DateTime.Now.unixEpochTime()*1000)", forHTTPHeaderField: "x-auth-timestamp")
        request.setValue("1", forHTTPHeaderField: "x-auth-size")
        request.setValue(aamClient.buildXauth1HeaderWithGuestToken(), forHTTPHeaderField: "x-auth-1")
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonStr = buildRequestBody(valuesList: valuesList, capabilityName: capability.name).rawString()
        request.httpBody = jsonStr?.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data,response,error in
            if let err = error {
                logError(error.debugDescription)
                
                let notiInfoObj  = NotificationInfo(type: ErrorType.connection, info: err.localizedDescription)
                NotificationCenter.default.postNotificationName(SymNotificationName.ActuatorAction, object: notiInfoObj)
            }
            else {
                let status = (response as! HTTPURLResponse).statusCode
                if (status >= 400) {
                    logError("response status: \(status) \(response.debugDescription)")
                    let notiInfoObj  = NotificationInfo(type: ErrorType.connection, info: "response status: \(status)")
                    NotificationCenter.default.postNotificationName(SymNotificationName.ActuatorAction, object: notiInfoObj)
                }
                //debug
                let dataString = String(data: data!, encoding: String.Encoding.utf8)
                logVerbose(dataString)
                
                
                let notiInfoObj  = NotificationInfo(type: ErrorType.noErrorSuccessfulFinish, info: "OK - action send")
                NotificationCenter.default.postNotificationName(SymNotificationName.ActuatorAction, object: notiInfoObj)
                
            }
        }
        
        task.resume()
    }
    
    private func buildActionsDict(_ valuesList: [ActuatorsValue]) -> [[String: Int]] {
        var retDict = [[String: Int]]()
        
        for v in valuesList {
            let dict = [v.name : v.value]
            retDict.append(dict)
        }
        
        return retDict
    
    }
    
    private func buidFakeDebugTestRequest() -> JSON {
        let json = JSON(
        ["RGBCapability":[
            ["r":5],
            ["g":5],
            ["b":5]
            ]]
        )
        
        log(json.rawString(options: []))
        return json
    }
    
    
    
    private func buildRequestBody(valuesList: [ActuatorsValue], capabilityName: String) -> JSON {
        let arrOfDict = buildActionsDict(valuesList)
        
        
        //let jArr = JSON(valuesList)
        let json = JSON(
            [capabilityName:arrOfDict]
            )
        log(json.rawString(options: []))
        return json
    }
 
}
