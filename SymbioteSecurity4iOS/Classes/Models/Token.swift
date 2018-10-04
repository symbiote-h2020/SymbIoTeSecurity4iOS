//
//  Token.swift
//  SecuritySSP
//
//  Created by Konrad Leszczyński
//  Copyright © 2018 PSNC. All rights reserved.
//

import Foundation


public enum TokenType {
    case HOME
    case FOREIGN
    case GUEST
    case NULL
}

public class Token {
    
    public var id: String = "";
    public var token: String = "";
    public var tokenType = TokenType.NULL;
    public var authenticationChallenge: String = ""
}
