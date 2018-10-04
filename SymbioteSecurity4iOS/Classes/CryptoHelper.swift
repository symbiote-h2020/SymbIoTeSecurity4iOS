//
//  CryptoHelper.swift
//  SecuritySSP
//
//  Created by Konrad Leszczyński
//  Copyright © 2018 PSNC. All rights reserved.
//

import Foundation
//import CertificateSigningRequestSwift

public class CryptoHelper {
    
    
    
    public static func buildHomeTokenAcquisitionRequest(_ homeCredentials: HomeCredentials ) -> String{
        let manager = SecurityHandler.KeyPair.manager
        //try? manager.deleteKeyPair()
        
        
        let expirationTime: TimeInterval = 60000
        let jwt = JWT(issuer: homeCredentials.username, subject: homeCredentials.clientIdentifier, keysManager: manager)
        let token = jwt.createToken(expiresAfter: expirationTime)
        
//        let pk = try! manager.publicKey()
//        let pkdata = try! pk.data()
//        print(pkdata.PEM)
        
        
        return token
    }
}
