//
//  LoginVC.swift
//  SymbioteSecurity4iOS_Example
//
//  Created by Konrad Leszczyński on 25/09/2018.
//  Copyright © 2018 PSNC. All rights reserved.
//

import Foundation
import UIKit
import SymbioteIosUtils
import SymbioteSecurity4iOS

public var clientSH: SecurityHandler = SecurityHandler(homeAAMAddress: Constants.defaultCoreInterfaceApiUrl)

public class LoginVC: UIViewController {
    
    @IBOutlet weak var usrnameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var homeAamTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var infoTextView: UITextView!
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        if let coreUrl = homeAamTextField.text, let username = usrnameTextField.text, let pass = passwordTextField.text {
            clientSH = SecurityHandler(homeAAMAddress: coreUrl)
            let coreAam = clientSH.getCoreAAMInstance()
            if let homeAam = coreAam {
                let certStr = clientSH.getCertificate(aam: homeAam, username: username, password: pass, clientId: "clientId")
                let loginToken = clientSH.login(homeAam)
                
                infoTextView.text = "Certyficate = \n\(certStr) \n\nToken=\n\(loginToken?.token ?? "error")"
            }
        }
    }
}
