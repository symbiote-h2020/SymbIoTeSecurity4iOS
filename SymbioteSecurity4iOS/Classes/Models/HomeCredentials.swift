//
//  HomeCredentials.swift
//  SecuritySSP
//
//  Created by Konrad Leszczyński
//  Copyright © 2018 PSNC. All rights reserved.
//

import Foundation

/**
 * Credentials issued for a user that has account in the given AAM
 *
 */
public class HomeCredentials {
    
    /**
     * AAM the user has account in.
     */
    public var homeAAM: Aam;
    /**
     * the username for your account in the home AAM
     */
    public var username: String;
    /**
     * user's client identifier
     */
    public var clientIdentifier: String;
    /**
     * Certificate of this client
     */
    public var certificate: Certificate;
    
    /**
     * matching the public key in the certificate
     */
    //TODO move from JWT class public final PrivateKey privateKey;
    /**
     * token acquired from your home AAM
     */
    public var homeToken: Token?
    
    init(homeAam: Aam, username: String, clientIdentifier: String, cert: Certificate) {
        self.homeAAM = homeAam
        self.username = username
        self.clientIdentifier = clientIdentifier
        self.certificate = cert
    }
    
    ///sets some default test values
    init() {
        self.homeAAM = Aam()
        self.username = ""
        self.clientIdentifier = ""
        self.certificate = Certificate()
    }
    
//    init(AAM homeAAM, String username, String clientIdentifier, Certificate certificate, PrivateKey
//    privateKey) {
//    this.homeAAM = homeAAM;
//    this.username = username;
//    this.clientIdentifier = clientIdentifier;
//    this.certificate = certificate;
//    this.privateKey = privateKey;
//    }
    
}
