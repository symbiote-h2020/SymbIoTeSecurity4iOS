//
//  AAMClient.swift
//  SecuritySSP
//
//  Created by Konrad Leszczyński
//  Copyright © 2018 PSNC  All rights reserved.
//

import Foundation
import SymbioteIosUtils

public class AAMClient {
    public var serverAddress: String
    
    public init(_ baseUrl: String) {
        self .serverAddress = baseUrl
    }
    
    public func getGuestToken() -> String {
        let url = URL(string: self.serverAddress + SecurityConstants.AAM_GET_GUEST_TOKEN)!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        
        var guestToken: String = ""
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data,response,error in
            if let err = error {
                logError(error.debugDescription)
                
                let notiInfoObj  = NotificationInfo(type: ErrorType.connection, info: err.localizedDescription)
                NotificationCenter.default.postNotificationName(SymNotificationName.SecurityTokenCore, object: notiInfoObj)
            }
            else {
                if let httpResponse = response as? HTTPURLResponse
                {
                    //logVerbose("response header for guest_token request:  \(httpResponse.allHeaderFields)")
                    if let xAuthToken = httpResponse.allHeaderFields[SecurityConstants.TOKEN_HEADER_NAME] as? String { //"x-auth-token"
                        //logVerbose("core gouest_token = \(xAuthToken)")
                        guestToken = xAuthToken
                        NotificationCenter.default.postNotificationName(SymNotificationName.SecurityTokenCore)
                    }
                }
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        return guestToken
    }
    
    public func getHomeToken(_ loginRequest: String) -> String {
        return "TODO"
    }
}
