//
//  Aam.swift
//  SecuritySSP
//
//  Created by Konrad Leszczyński on 25/07/2018.
//  Copyright © 2018 Konrad. All rights reserved.
//

import Foundation
import SwiftyJSON

public class Aam {
    var aamInstanceId: String = ""
    var aamAddress: String = ""
    var aamInstanceFriendlyName: String = ""
    //private final Certificate aamCACertificate;
    //private final Map<String, Certificate> componentCertificates;
    
    public convenience init(_ resourceJson: JSON)  {
        self.init()
        
        if resourceJson["aamInstanceId"].exists() { aamInstanceId = resourceJson["aamInstanceId"].stringValue  }
        if resourceJson["aamAddress"].exists() { aamAddress = resourceJson["aamAddress"].stringValue  }
        if resourceJson["aamInstanceFriendlyName"].exists() { aamInstanceFriendlyName = resourceJson["aamInstanceFriendlyName"].stringValue  }
    }
}
