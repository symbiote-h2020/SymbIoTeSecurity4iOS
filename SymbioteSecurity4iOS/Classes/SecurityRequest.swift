//
//  SecurityRequest.swift
//  SymbioteSecurity4iOS
//
//  Created by Konrad Leszczyński
//

import Foundation
import SwiftyJSON
import SymbioteIosUtils

public class SecurityRequest {
    public static func makeXAuth1RequestHeader(_ guestToken: String) -> String {
        let json = JSON(
            ["token":guestToken,
             "authenticationChallenge":"",
             "clientCertificate":"",
             "clientCertificateSigningAAMCertificate":"",
             "foreignTokenIssuingAAMCertificate":""
            ]
        )
        
        log(json.rawString(options: []))
        return json.rawString(options: []) ?? "couldn't build request json"
    }
    
    public static func prepareRequestWithGuestToken(_ strUrl: String, guestToken: String) -> NSMutableURLRequest{
        let url = URL(string: strUrl)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("\(DateTime.Now.unixEpochTime()*1000)", forHTTPHeaderField: "x-auth-timestamp")
        request.setValue("1", forHTTPHeaderField: "x-auth-size")
        request.setValue(SecurityRequest.makeXAuth1RequestHeader(guestToken), forHTTPHeaderField: "x-auth-1")
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
}
