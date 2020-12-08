//
//  DataManagementTableViewController.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 10.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import UIKit

class DataManagementTableViewController: UITableViewController {
    
    @IBOutlet weak var saveDataLabel: UILabel!
    @IBOutlet weak var restoreDataLabel: UILabel!
    @IBOutlet weak var autoSaveLabel: UILabel!
    
    @IBOutlet weak var autoSaveSwitch: UISwitch!
    
    @IBOutlet weak var deleteAllLabel: UILabel!
    @IBOutlet weak var resetAllLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("manage_data", comment: "")
        saveDataLabel.text = NSLocalizedString("save_data", comment: "")
        restoreDataLabel.text = NSLocalizedString("restore_data", comment: "")
        autoSaveLabel.text = NSLocalizedString("autosave_data", comment: "")
        deleteAllLabel.text = NSLocalizedString("delete_data", comment: "")
        resetAllLabel.text = NSLocalizedString("reset_data", comment: "")

        autoSaveSwitch.isOn = UserDefaults.standard.bool(forKey: "AutomaticSync")

        tableView.tableFooterView = UIView()
    }

    @IBAction func autoSaveSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "AutomaticSync")
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 3 : 2
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                // Save data to iCloud
                if DataManager.isICloudContainerAvailable() {
                    print("Available")
                    DataManager.saveToCloud {
                        let alertMessage = NSLocalizedString("saved_in_icloud", comment: "")
                        let confirmAlert = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
                        let cancelTitle = NSLocalizedString("ok", comment: "")
                        let cancelButton = UIAlertAction(title: cancelTitle, style: .cancel)
                        confirmAlert.addAction(cancelButton)
                        present(confirmAlert, animated: true, completion: nil)
                    }
                    
                } else {
                    print("Cloud closed")
                    let alertMessage = NSLocalizedString("not_available_icloud", comment: "")
                    let confirmAlert = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
                    let cancelTitle = NSLocalizedString("ok", comment: "")
                    let cancelButton = UIAlertAction(title: cancelTitle, style: .cancel)
                    confirmAlert.addAction(cancelButton)
                    present(confirmAlert, animated: true, completion: nil)

                }
                
            case 1:
                // Load data from iCloud
                if DataManager.isICloudContainerAvailable() {
                    print("Available")
                    DataManager.updatePaymentsFromCloud { success in
                        var messageKey = ""
                        if success {
                            messageKey = "syncing_done"
                        } else {
                            messageKey = "syncing_wrong"
                        }
                        
                        let alertMessage = NSLocalizedString(messageKey, comment: "")
                        let confirmAlert = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
                        let cancelTitle = NSLocalizedString("ok", comment: "")
                        let cancelButton = UIAlertAction(title: cancelTitle, style: .cancel) { _ in
                            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "RELOAD_DATA")))
                        }
                        confirmAlert.addAction(cancelButton)
                        self.present(confirmAlert, animated: true, completion: nil)
                    }

                } else {
                    print("Cloud closed")
                    let alertMessage = NSLocalizedString("not_available_icloud", comment: "")
                    let confirmAlert = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
                    let cancelTitle = NSLocalizedString("ok", comment: "")
                    let cancelButton = UIAlertAction(title: cancelTitle, style: .cancel)
                    confirmAlert.addAction(cancelButton)
                    self.present(confirmAlert, animated: true, completion: nil)
                }

            case 2:
                // Sync data automatically
                print("02 ")
                if DataManager.isICloudContainerAvailable() {
                    autoSaveSwitch.isOn = !UserDefaults.standard.bool(forKey: "AutomaticSync")
                    UserDefaults.standard.set(autoSaveSwitch.isOn, forKey: "AutomaticSync")
                } else {
                    autoSaveSwitch.isOn = false
                    UserDefaults.standard.set(autoSaveSwitch.isOn, forKey: "AutomaticSync")
                    let alertMessage = NSLocalizedString("not_available_icloud", comment: "")
                    let confirmAlert = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
                    let cancelTitle = NSLocalizedString("ok", comment: "")
                    let cancelButton = UIAlertAction(title: cancelTitle, style: .cancel)
                    confirmAlert.addAction(cancelButton)
                    self.present(confirmAlert, animated: true, completion: nil)

                }

            default:
                print("no items")
            }
        case 1:
            // Delete all
            switch indexPath.row {
            case 0:
                let alertTitle = NSLocalizedString("delete_all_title", comment: "")
                let alertMessage = NSLocalizedString("delete_all_alert_message", comment: "")
                let deleteAlert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                
                let confirmAllTitle = NSLocalizedString("confirm_reset_all", comment: "")
                let okAllButton = UIAlertAction(title: confirmAllTitle, style: .destructive) { action in
                    print("Confirm All")
                    DataManager.deleteAllData()
                }
                
                let cancelTitle = NSLocalizedString("cancel", comment: "")
                let cancelButton = UIAlertAction(title: cancelTitle, style: .cancel)
                
                deleteAlert.addAction(okAllButton)
                deleteAlert.addAction(cancelButton)
                
                present(deleteAlert, animated: true, completion: nil)

                
            case 1:
                // Reset date completely
                let alertTitle = NSLocalizedString("delete_all_title", comment: "")
                let alertMessage = NSLocalizedString("reset_all_alert_message", comment: "")
                let deleteAlert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                
                let confirmAllTitle = NSLocalizedString("confirm_reset_all", comment: "")
                let okAllButton = UIAlertAction(title: confirmAllTitle, style: .destructive) { action in
                    print("Reset All")
                    DataManager.resetData()
                }
                
                let cancelTitle = NSLocalizedString("cancel", comment: "")
                let cancelButton = UIAlertAction(title: cancelTitle, style: .cancel)
                
                deleteAlert.addAction(okAllButton)
                deleteAlert.addAction(cancelButton)
                
                present(deleteAlert, animated: true, completion: nil)
            default:
                print("no")
            }
        default:
            print("no")
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

//        if section == 0 {
//            sectionTitle = NSLocalizedString("regular_payments", comment: "")
//        } else if section == 1 {
//            sectionTitle = NSLocalizedString("single_payments", comment: "")
//        }
        return " "
    }

}
