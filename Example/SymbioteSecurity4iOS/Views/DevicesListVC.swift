//
//  DevicesListVC.swift
//  SSPApp
//
//  Created by Konrad Leszczyński on 01/08/2017.
//  Copyright © 2017 PSNC. All rights reserved.
//

import UIKit
import SymbioteIosUtils
import SymbioteSecurity4iOS

protocol DevicesListViewControllerDelegate {
    func childViewControllerDidPressButton(_ childViewController:DevicesListVC)
}

class DevicesListVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var deviceObjects = [SmartDevice]()
    let sdm = SearchResourcesManager()
    var devicesListDelegate: DevicesListViewControllerDelegate?
    var selectedDevice: SmartDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Resources List"

        tableView.delegate = self
        tableView.dataSource = self
    
        tableView.tableFooterView = UIView()
        

    }
    

    
    

    
    
    
    //MARK - storybord management
    static func getViewController() -> DevicesListVC {
        let storyboard = UIStoryboard(name: "SearchDevices", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "DevicesListVC")
        return controller as! DevicesListVC
    }
    
    
    static func getNavigationViewController() -> UINavigationController {
        let storyboard = UIStoryboard(name: "SearchDevices", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "DevicesListNavigationVC")
        return controller as! UINavigationController
    }
    
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension DevicesListVC: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DeviceTableViewCell
        
        let object = deviceObjects[indexPath.row]
        //cell.textLabel!.text = object.name
        cell.setCell(object)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        self.selectedDevice = deviceObjects[indexPath.row]
        
        if (self.devicesListDelegate == nil) {
            let vc = DeviceDetailsVC.getViewController()
            vc.detailItem = selectedDevice
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            // delegate not empty - list is embedded with viewController
            self.devicesListDelegate?.childViewControllerDidPressButton(self)
        }
    }
}
