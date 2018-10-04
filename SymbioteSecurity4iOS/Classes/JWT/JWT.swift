//
//  JWT.swift
//  Demo-iOS
//
//  Created by Sebastian Mamczak on 30.07.2018.
//  Copyright © 2018 Agens AS. All rights reserved.
//

import Foundation
//import SymbioteIosUtils
//import EllipticCurveKeyPair

enum JWTAlgorithm: String {
    case ES256 = "ES256"
}

class Epoch {
    
    let date: Date
    
    init(date: Date) {
        self.date = date
    }
    
    convenience init() {
        self.init(date: Date())
    }
    
    convenience init(after time: TimeInterval) {
        self.init(date: Date().addingTimeInterval(time))
    }
    
    func getString() -> String {
        return "\(date.timeIntervalSince1970)".components(separatedBy: ".")[0]
    }
}

class JWT {
    
    let algorithm: JWTAlgorithm
    let issuer: String
    let subject: String
    let keysManager: EllipticCurveKeyPair.Manager
    
    init(algorithm: JWTAlgorithm = .ES256, issuer: String, subject: String, keysManager: EllipticCurveKeyPair.Manager) {
        self.algorithm = algorithm
        self.issuer = issuer
        self.subject = subject
        self.keysManager = keysManager
    }
    
    func createToken(expiresAfter: TimeInterval) -> String {
        let header = createHeader()
        let payload = createPayload(expirationTime: expiresAfter)
        let signatureInput = self.base64(header) + "." + self.base64(payload)
        let signature = createSignature(signatureInput)
        
        return signatureInput + "." + signature
    }
}

extension JWT {
    
    fileprivate func createHeader() -> String {
        return "{\"alg\":\"\(self.algorithm.rawValue)\"}"
    }
    
    fileprivate func createPayload(expirationTime: TimeInterval) -> String {
        let iat = Epoch().getString()
        let exp = Epoch(after: expirationTime).getString()
        return "{\"iss\":\"\(self.issuer)\",\"sub\":\"\(self.subject)\",\"iat\":\(iat),\"exp\":\(exp)}"
    }
    
    fileprivate func base64(_ input: String) -> String {
        guard let data = input.data(using: .utf8) else {
            fatalError("Cannot create data")
        }
        let result = data.base64EncodedString(options: .init(rawValue: 0))
        return filterBase64(result)
    }
    
    fileprivate func createSignature(_ input: String) -> String {
        guard
            let data = input.data(using: .utf8),
            let signature = try? keysManager.sign(data, hash: .sha256)
        else {
            fatalError("Cannot create signature")
        }
        let decodedSignature = DEREC256SignatureDecode(signature)
        let result = decodedSignature.base64EncodedString(options: .init(rawValue: 0))
        return filterBase64(result)
    }
    
    fileprivate func DEREC256SignatureDecode(_ signature: Data) -> Data {
        var decoded = signature
        let maxChunkSize = 32
        decoded.removeFirst() // removing sequence header
        decoded.removeFirst() // removing sequence size
        decoded.removeFirst() // removing 'r' element header
        let rLength = Int(decoded.removeFirst()) // removing 'r' element length
        let r  = decoded.prefix(rLength).suffix(maxChunkSize) // read out 'r' bytes and discard any padding
        decoded.removeFirst(Int(rLength)) // removing 'r' bytes
        decoded.removeFirst() // 's' element header
        let sLength = Int(decoded.removeFirst()) // 's' element length
        let s  = decoded.prefix(sLength).suffix(maxChunkSize) // read out 's' bytes and discard any padding
        return Data(r) + Data(s)
    }
    
    private func filterBase64(_ input: String) -> String {
        return input
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
