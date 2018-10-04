//
//  Certificate.swift
//  SecuritySSP
//
//  Created by Konrad Leszczyński on 27/08/2018.
//  Copyright © 2018 Konrad. All rights reserved.
//

import Foundation

/**
 * SymbIoTe certificate with stored PEM value
 *
 * Only to keep coherent with android/java version
 */
public class Certificate {
    
    //@Id
    public var certificateString: String = "";
    
    public init() {}
    
    public init(_ str: String) {
        certificateString = str
    }
}
