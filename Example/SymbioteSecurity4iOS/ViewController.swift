//
//  ViewController.swift
//  SymbioteSecurity4iOS
//
//  Created by konrri on 08/30/2018.
//  Copyright (c) 2018 konrri. All rights reserved.
//

import UIKit
import SymbioteIosUtils
import SymbioteSecurity4iOS

class ViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationNameTextField: UITextField!
    @IBOutlet weak var platformNameTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var waitingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginStatusLabel: UILabel!
    
    let srm = SearchResourcesManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.getListNotyficationReceived(_:)),
                                               name: SymNotificationName.DeviceListLoaded,
                                               object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if clientSH.isLoggedIn() {
            loginStatusLabel.text = "You are logged in"
            loginStatusLabel.textColor = UIColor.green
            var expDate = Date()
            if clientSH.hasTokenExpired(expirationDate: &expDate) {
                loginStatusLabel.textColor = UIColor.orange
                loginStatusLabel.text = "Login Token has expired at \(expDate)"
            }
        }
        else {
            loginStatusLabel.text = "You are not logged in - you can access only public resources"
            loginStatusLabel.textColor = UIColor.red
        }
    }
    
    //MARK - data management
    @objc func getListNotyficationReceived(_ notification: Notification) {
        let notInfo = NotificationInfo(object: notification.object as AnyObject?)
        if notInfo.errorType == .noErrorSuccessfulFinish {
            let vc = DevicesListVC.getViewController()
            vc.deviceObjects = srm.devicesList
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            notInfo.showProblemAlert()
        }
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    
    private func buildParamsFromTextBoxes() -> [String:String] {
        var dict = [String:String]()
        let nameParam = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if nameParam?.isEmpty == false {
            dict["name"] = nameParam
        }
        
        let locationName = locationNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if locationName?.isEmpty == false {
            dict["location_name"] = locationName
        }
        
        let platformName = platformNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if platformName?.isEmpty == false {
            dict["platform_name"] = platformName
        }
        return dict
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        waitingActivityIndicator.isHidden = false
        
        srm.getCoreResourcesList(buildParamsFromTextBoxes())
    }
}

