//
//  NotificationInfo.swift
//  SymbioteSpike
//
//  Created by Konrad Leszczyński on 14/07/2017.
//  Copyright © 2017 PSNC. All rights reserved.
//

import Foundation
import UIKit

public enum ErrorType {
    case noErrorSuccessfulFinish
    
    case unspecyfied
    case connection
    case authentication
    case emptySet
    case wrongParameters
    case notSetYet
    case noInternet
    case serversAreDown
    case invalidState
    case tooOldAppVersion
    case wrongResult
    case expired
}

// errors are passed via notifications
public class NotificationInfo  {
    public var errorType: ErrorType = ErrorType.unspecyfied
    public var infoText: String = ""
    public var object: AnyObject?
    
    public init(type: ErrorType = .unspecyfied, info: String = "") {
        self.errorType = type
        self.infoText = info
    }
    
    public convenience init(object: AnyObject?) {
        if let obj = object as? NotificationInfo {
            self.init(type: obj.errorType, info: obj.infoText)
            self.object = obj.object
        }
        else {
            self.init(type: ErrorType.unspecyfied, info: "")
        }
    }
    
    public convenience init(notification: Notification?) {
        self.init(object: notification?.object as AnyObject?)
    }
    
}

// utils
public extension NotificationInfo {
    public func showOkAlert() {
        let alertController = UIAlertController(title: "OK", message: self.infoText, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "ok", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    public func showProblemAlert() {
        let alertController = UIAlertController(title: "error", message: self.infoText, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "ok", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    public func postAsNotification(_ name: SymNotificationName, userInfo: [AnyHashable: Any]? = nil) {
        NotificationCenter.default.postNotificationName(name, object: self, userInfo: userInfo)
    }
    
}
