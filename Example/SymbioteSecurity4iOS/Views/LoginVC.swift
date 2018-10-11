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



public class LoginVC: UIViewController {
    
    @IBOutlet weak var usrnameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var homeAamTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var infoTextView: UITextView!
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        if  let username = usrnameTextField.text, let pass = passwordTextField.text {  //let coreUrl = homeAamTextField.text,
            //clientSH = SecurityHandler(homeAAMAddress: coreUrl)
            let coreAam = clientSH.getCoreAAMInstance()
            if let homeAam = coreAam {
                let certStr = clientSH.getCertificate(aam: homeAam, username: username, password: pass, clientId: "zupa_konrri_zupa")
                let loginToken = clientSH.login(homeAam)
                
                infoTextView.text = "Certyficate = \n\(certStr) \n\nToken=\n\(loginToken?.token ?? "error")"
            }
        }
    }
    
    
    @IBAction func testButtonTapped(_ sender: Any) {
        let obsMan = ObservationsManager()
        obsMan.getResourcesUrl("5b67ea6c8199a065667cc409")
        ////resource of user icom id    String    "5b67ea6c8199a065667cc409"
        //let url = URL(string: "https://symbiote-dev.man.poznan.pl/coreInterface/resourceUrls?id=")  //id=5a9d2e024a234e4b02e97c41")
    }
}
