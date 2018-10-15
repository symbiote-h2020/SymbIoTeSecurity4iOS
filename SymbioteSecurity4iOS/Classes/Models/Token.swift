//
//  Token.swift
//  SecuritySSP
//
//  Created by Konrad Leszczyński
//  Copyright © 2018 PSNC. All rights reserved.
//

import Foundation
import SwiftyJSON
import SymbioteIosUtils
import iOSCSRSwift

public enum TokenType {
    case HOME
    case FOREIGN
    case GUEST
    case NULL
}

public class Token {
    
    public var id: String = "";  //jti
    public var token: String = "";
    public var tokenType = TokenType.NULL;
    public var authenticationChallenge: String = ""
    public var spk: String = ""
    public var sub: String = ""
    public var iat: String = ""
    public var exp: String = ""
    
    public var rawAuthenticationChalange: AuthenticationChallenge?
    
    public init(_ homeToken: String) {
        tokenType = TokenType.HOME
        
        self.token = homeToken
        if let json: JSON = JWT.decode(token: homeToken) {
        
            if json["jti"].exists() { id = json["jti"].stringValue  }
            if json["spk"].exists() { spk = json["spk"].stringValue  }
            if json["sub"].exists() { sub = json["sub"].stringValue  }
            if json["iat"].exists() { iat = json["iat"].stringValue  }
            if json["exp"].exists() { exp = json["exp"].stringValue  }
        }       
    }
    
    ///authentication chalenge is only valid 1 minute, so it must be regenertated every request
    public func renewAuthenticationChallenge() {
        let ac = buildAuthenticationChallenge()
        rawAuthenticationChalange = ac
        self.authenticationChallenge = CryptoHelper.jwt?.createAuthenticationChallenge(ac) ?? "error AuthenticationChallenge "
    }
    
    /*
     in java:
     String hexHash = hashSHA256(credentials.authorizationToken.toString() + timestampMilliseconds);
     
     JwtBuilder jwtBuilder = Jwts.builder();
     jwtBuilder.setId(String.valueOf(random.nextInt())); // random -> jti
     jwtBuilder.setSubject(credentials.authorizationToken.getClaims().getId()); // token jti -> sub
     jwtBuilder.setIssuer(credentials.authorizationToken.getClaims().getSubject()); // token sub -> iss
     jwtBuilder.claim("ipk", credentials.authorizationToken.getClaims().get("spk")); // token spk -> ipk
     jwtBuilder.claim("hash", hexHash); // SHA256(token+timestamp)
     jwtBuilder.setIssuedAt(timestampDate); // iat
     jwtBuilder.setExpiration(expiryDate);  // exp
     jwtBuilder.signWith(SignatureAlgorithm.ES256, credentials.homeCredentials.privateKey);
     String authenticationChallenge = jwtBuilder.compact();

 */
    private func buildAuthenticationChallenge() -> AuthenticationChallenge {
        let ac = AuthenticationChallenge()
        ac.sub = String(self.id)
        ac.iss = self.sub
        ac.ipk = self.spk
        ac.iat = Epoch().getString()
        ac.exp = Epoch(after: 60).getString()
        let strToHash = self.token + ac.iat + "000"
        ac.hash = sha256(strToHash) ?? ""
        
        logVerbose("           ======================   sting to hash = ")
        logVerbose(strToHash)
        
        return ac
    }
}

public class AuthenticationChallenge {
    public var ttyp: String = "HOME"
    public var sub: String = ""
    public var ipk: String = ""
    public var iss: String = ""
    public var iat: String = ""
    public var exp: String = ""
    public var jit: Int = 42
    public var spk: String = ""
    public var hash: String = ""
    
    func createPayload() -> String {
        return "{\"iss\":\"\(iss)\",\"sub\":\"\(sub)\",\"iat\":\(iat),\"exp\":\(exp),\"ipk\":\"\(ipk)\",\"jti\":\"\(jit)\",\"hash\":\"\(hash)\"}"
    }

}

func sha256(_ data: Data) -> Data? {
    guard let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH)) else { return nil }
    CC_SHA256((data as NSData).bytes, CC_LONG(data.count), res.mutableBytes.assumingMemoryBound(to: UInt8.self))
    return res as Data
}

func sha256_toString(_ str: String) -> String? {
    guard
        let data = str.data(using: String.Encoding.utf8),
        let shaData = sha256(data)
        else { return nil }
    let rc = shaData.base64EncodedString(options: [])
    return rc
}

public func sha256(_ str: String) -> String? {
    guard
        let data = str.data(using: String.Encoding.utf8),
        let shaData = sha256(data)
        else { return nil }
    let format = "%02hhx"
    return shaData.map { String(format: format, $0) }.joined()
}

