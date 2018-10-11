//
//  SecurityHandler.swift
//  SecuritySSP
//
//  Created by Konrad Leszczyński
//  Copyright © 2018 PSNC. All rights reserved.
//

import Foundation
import SwiftyJSON
import SymbioteIosUtils
// CertificateSigningRequestSwift
import iOSCSRSwift


public let homeAamConstant = "https://symbiote-open.man.poznan.pl/coreInterface" //dev tests "https://symbiote-dev.man.poznan.pl/coreInterface"

/**
  SecurityHandler class is designe to work exactly as its counterpart on android /java code
 see https://github.com/symbiote-h2020/SymbIoTeSecurity/blob/master-android/src/main/java/eu/h2020/symbiote/security/handler/SecurityHandler.java
 names of methods are the same
 */
public class SecurityHandler {
    private var homeAAMAddress: String
    private var platformId: String
    
    public var coreAAM: Aam?
    public var availableAams = [String:Aam]()
    
    //both getCertificate and login methods must share the same credentials
    let homeCredentials = HomeCredentials()
    
    struct KeyPair {
        static let manager: EllipticCurveKeyPair.Manager = {
            let publicAccessControl = EllipticCurveKeyPair.AccessControl(protection: kSecAttrAccessibleAlwaysThisDeviceOnly, flags: [])
            let privateAccessControl = EllipticCurveKeyPair.AccessControl(protection: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, flags: {
                return EllipticCurveKeyPair.Device.hasSecureEnclave ? [.userPresence, .privateKeyUsage] : [.userPresence]
            }())
            let config = EllipticCurveKeyPair.Config(
                publicLabel: "n.sign.public",
                privateLabel: "n.sign.private",
                operationPrompt: "n Ident",
                publicKeyAccessControl: publicAccessControl,
                privateKeyAccessControl: privateAccessControl,
                token: .secureEnclaveIfAvailable)
            return EllipticCurveKeyPair.Manager(config: config)
        }()
    }
    
    public init(homeAAMAddress: String, platformId: String = "") {
        self.homeAAMAddress = homeAAMAddress
        self.platformId = platformId
    }
    
    public func getCoreAAMInstance() -> Aam? {
        if self.availableAams.count == 0 {
            _ = getAvailableAams()
        }
        if let val = self.availableAams[SecurityConstants.CORE_AAM_INSTANCE_ID] {
            return val
        }
        else {
            return nil
        }
    }
    
    public func getAvailableAams() -> [String:Aam] {
        var aams = [String:Aam]()
        let semaphore = DispatchSemaphore(value: 0)  //1. create a counting semaphore
        getAvailableAams(self.homeAAMAddress) {dictOfAams in
            aams = dictOfAams
            semaphore.signal()  //3. count it up
        }
        semaphore.wait()  //2. wait for finished counting
        return aams
    }
    
    public func getAvailableAams(homeAam: Aam) -> [String:Aam] {
        var aams = [String:Aam]()
        let semaphore = DispatchSemaphore(value: 0)  //1. create a counting semaphore
        getAvailableAams(homeAam.aamAddress) {dictOfAams in
            aams = dictOfAams
            semaphore.signal()  //3. count it up
        }
        semaphore.wait()  //2. wait for finished counting
        return aams
    }
    
    /**
     - Parameter aamAddress:  Address where the user can reach REST endpoints used in security layer of SymbIoTe
     */
    public func getAvailableAams(_ aamAddress: String, finished: @escaping ((_ dictOfAams: [String:Aam])->Void))   {
        let url = URL(string: aamAddress + SecurityConstants.AAM_GET_AVAILABLE_AAMS)!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data,response,error in
            if let err = error {
                logError(error.debugDescription)
                
                let notiInfoObj  = NotificationInfo(type: ErrorType.connection, info: err.localizedDescription)
                NotificationCenter.default.postNotificationName(SymNotificationName.CoreCommunictation, object: notiInfoObj)
            }
            else {
                if let httpResponse = response as? HTTPURLResponse
                {
                    let status = httpResponse.statusCode
                    if (status >= 400) {
                        logWarn("response status: \(status)")
                        logError("getAvailableAams json")
                        let notiInfoObj  = NotificationInfo(type: ErrorType.connection, info: "wrong http status code")
                        NotificationCenter.default.postNotificationName(SymNotificationName.CoreCommunictation, object: notiInfoObj)
                    }

                    if let jsonData = data {
                        do {
                            let json = try JSON(data: jsonData)
                            self.availableAams = self.parseAamsJson(json)
                            NotificationCenter.default.postNotificationName(SymNotificationName.CoreCommunictation)
                            finished(self.availableAams)
                        } catch {
                            logError("getAvailableAams json")
                            let notiInfoObj  = NotificationInfo(type: ErrorType.connection, info: "wrong data json")
                            NotificationCenter.default.postNotificationName(SymNotificationName.CoreCommunictation, object: notiInfoObj)
                        }
                    }
                }
            }
        }
        
        task.resume()
    }
    
    private func parseAamsJson(_ dataJson: JSON) -> [String:Aam] {
        var aams = [String:Aam]()
        
        if dataJson["availableAAMs"].exists() == false {
            logWarn("+++++++ wrong json +++++  parseAamsJson dataJson = \(dataJson)")
        }
        else {
            let jsonArr:JSON = dataJson["availableAAMs"]
            for (_, subJson) in jsonArr {
                //logVerbose("AAM name = \(key)")
                let a = Aam(subJson)
                aams[a.aamInstanceId] = a
            }
        }
        
        return aams
    }
    
    /**
     The methond sends CSR Certificate signing request
    /// declaration of this function in java is: public Certificate getCertificate(AAM homeAAM, String username, String password, String clientId)
    */
    public func getCertificate(aam: Aam, username: String, password: String, clientId: String) -> String {
        var certyficateString = ""
        let cn = "\(username)@\(clientId)@\(aam.aamInstanceId)"
        
        let csr = buildPlatformCertificateSigningRequestPEM(cn: cn)
        
        let json: [String: Any] = [  "username" : username,
                                     "password" : password,
                                     "clientId" : clientId,
                                     "clientCSRinPEMFormat" : "\(csr)"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string: aam.aamAddress + SecurityConstants.AAM_SIGN_CERTIFICATE_REQUEST)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data,response,error in
            if let err = error {
                logError(err.localizedDescription)
                logError(error.debugDescription)
            }
            else {
                let status = (response as! HTTPURLResponse).statusCode
                if (status >= 400) {
                    logWarn("response status: \(status)")
                    
                }
                //debug
                certyficateString = String(data: data!, encoding: String.Encoding.utf8) ?? ""
                logVerbose("datastring= \(certyficateString)")
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        
        self.homeCredentials.homeAAM = aam
        self.homeCredentials.clientIdentifier = clientId
        self.homeCredentials.username = username
        self.homeCredentials.certificate = Certificate(certyficateString)
        
        return certyficateString
    }
    
    /// - Parameters: cn eg. "icom@clientId@SymbIoTe_Core_AAM"
    private func buildPlatformCertificateSigningRequestPEM(cn: String) -> String {

        var privateKey: SecKey?
        var publicKeyBits: Data?
        
        let keyAlgorithm = KeyAlgorithm.ec(signatureType: .sha256)
        
        do {
            privateKey = try SecurityHandler.KeyPair.manager.privateKey().underlying
        }
        catch {
            logError("Error: \(error)")
        }
        
        publicKeyBits = try! SecurityHandler.KeyPair.manager.publicKey().data().raw
        
        //Initiale CSR
        let csr = CertificateSigningRequest(commonName: cn, organizationName: nil, organizationUnitName: nil, countryName: nil, stateOrProvinceName: nil, localityName: nil, keyAlgorithm: keyAlgorithm)
        
        guard let csrBuild2 = csr.buildCSRAndReturnString(publicKeyBits!, privateKey: privateKey!) else {
            return ""
        }
        print("CSR string with header and footer")
        print(csrBuild2)
        
        return csrBuild2
        
    }
    
    private func csrDataToEncodedString(_ buildData: Data) -> String{
        guard let csrString = buildData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return "error"
        }
        let head = "-----BEGIN CERTIFICATE REQUEST-----\n";
        let foot = "-----END CERTIFICATE REQUEST-----\n";
        var isMultiple = false;
        var newCSRString = head;
    
        //Check if string size is a multiple of 64
        if (csrString.count % 64 == 0){
            isMultiple = true;
        }
    
        for (i, char) in csrString.enumerated() {
            newCSRString.append(char)
    
            if ((i != 0) && ((i+1) % 64 == 0)){
                newCSRString.append("\n")
            }
            if ((i == csrString.count-1) && !isMultiple){
                newCSRString.append("\n")
            }
        }
    
        newCSRString = newCSRString+foot
    
        return newCSRString
    }
    
    public func loginAsGuest(_ aam: Aam) -> String {
        let aamClient = AAMClient(aam.aamAddress)
        return aamClient.getGuestToken()
    }
    

    

 
    public func login(_ aam: Aam) -> Token? {
        let aamClient = AAMClient(aam.aamAddress)
        
        let loginRequest = CryptoHelper.buildHomeTokenAcquisitionRequest(homeCredentials)
        logVerbose("======= login reguest = \(loginRequest)")
        let homeToken = aamClient.getHomeToken(loginRequest)
        homeCredentials.homeToken = Token(homeToken)
        
        return homeCredentials.homeToken
    }
    
    public func isLoggedIn() -> Bool {
        if self.homeCredentials.certificate.certificateString.isEmpty == false &&
            self.homeCredentials.homeToken?.token.isEmpty == false {
            return true
        }
        else {
            return false
        }
    }

 
    public func buildXauth1HeaderWithHomeToken() -> String {
        let json = JSON(
            ["token":homeCredentials.homeToken?.token,
             "authenticationChallenge":homeCredentials.homeToken?.authenticationChallenge,
             "clientCertificate":"",
             "clientCertificateSigningAAMCertificate":"",
             "foreignTokenIssuingAAMCertificate":""
            ]
        )
        
        log("\n        ========   buildXauth1HeaderWithHomeToken")
        log(json.rawString(options: []))
        return json.rawString(options: []) ?? "couldn't build request json"
    }
}
