//
//  DeviceDetailsVC.swift
//  SSPApp
//
//  Created by Konrad Leszczyński
//  Copyright © PSNC
//

import UIKit
import SymbioteIosUtils

class DeviceDetailsVC: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var platformNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var observesPropertiesLabel: UILabel!
    
    @IBOutlet weak var actuatorButton: UIButton!
    @IBOutlet weak var chartButton: UIButton!
    @IBOutlet weak var observationButton: UIButton!
    
    
    var detailItem: SmartDevice? {
        didSet {
            // Update the view.
            if UIDevice.current.userInterfaceIdiom == .pad {
                configureView()
            }
        }
    }
    
    func configureView() {
        hideButtons()
        // Update the user interface for the detail item.
        if let d = detailItem {
            if let l = nameLabel {
                l.text = d.name
            }
            if let p = platformNameLabel {
                p.text = d.platformName
            }
            if let dL = descriptionLabel {
                dL.text = d.deviceDescription
            }
            if let lL = locationLabel {
                lL.text = d.locationName
            }
            if let sL = statusLabel {
                sL.text = d.status
                if (d.status.uppercased() == "ONLINE") {
                    statusLabel.textColor = UIColor.green
                }
                else {
                    statusLabel.textColor = UIColor.red
                }
            }
            if let opL = observesPropertiesLabel {
                opL.text = d.observedProperties.flatMap({$0}).joined(separator: ",");
            }
            
//            if d.type == .ssp {
//                NotificationCenter.default.addObserver(self, selector: #selector(tokenFromSSPNotificationReceived(_:)), name: SymNotificationName.SecurityTokenSSP, object: nil)
//                GuestTokensManager.shared.getSSPGuestToken()
//            }
//            else if d.type == .core {
//                NotificationCenter.default.addObserver(self, selector: #selector(tokenFromCoreNotificationReceived(_:)), name: SymNotificationName.SecurityTokenCore, object: nil)
//                GuestTokensManager.shared.getCoreGuestToken()
//            }

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    
    //MARK Tokens
    func tokenFromSSPNotificationReceived(_ notification: Notification) {
        logVerbose("DeviceDetialsVC: gets token from ssp - shows button")
        showButtons()
    }
    
    func tokenFromCoreNotificationReceived(_ notification: Notification) {
        logVerbose("DeviceDetialsVC: gets token from core - shows button")
        showButtons()
    }
    
    func hideButtons() {
        actuatorButton.isHidden = true
        chartButton.isHidden = true
        observationButton.isHidden = true
    }
    
    func showButtons() {
        if let d = detailItem {
            if d.functionType == .actuator {
                actuatorButton.isHidden = false
                chartButton.isHidden = true
                observationButton.isHidden = true
            }
            else if d.functionType == .sensor {
                actuatorButton.isHidden = true
                chartButton.isHidden = false
                observationButton.isHidden = false
            }
            else if d.functionType == .both {
                actuatorButton.isHidden = false
                chartButton.isHidden = false
                observationButton.isHidden = false
            }
            else if d.functionType == .none {
                hideButtons()
            }
        }
    }
    
    
    //MARK - storybord management
    static func getViewController() -> DeviceDetailsVC {
        let storyboard = UIStoryboard(name: "SearchDevices", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "DeviceDetailsVC")
        return controller as! DeviceDetailsVC
    }

    
    /* TODO
    
    //MARK: - actions buttons
    @IBAction func showObservations(_ sender: Any) {
        let om = ObservationsManager()
        om.getObservations(forDevice: detailItem)
        
        let vc = ObservationsVC.getViewController()
        vc.setObservations(om)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func chartButtonTapped(_ sender: Any) {
        let om = ObservationsManager()
        om.getObservations(forDevice: detailItem)
        
        let vc = ObservationsChartVC.getViewController()
        vc.setObservations(om)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actuateButtonTapped(_ sender: Any) {
        if let sdev = detailItem {
            let vc = ActuatorVC.getViewController()
            //TODO prapare multi actuators
            if sdev.capabilities.count > 0 {
                vc.setCapability(detailItem?.capabilities[0], device: sdev)
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
 
 */
}
