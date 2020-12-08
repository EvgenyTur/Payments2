//
//  SupportTableViewController.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 09.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import UIKit

class SupportTableViewController: UITableViewController {
    
    var delegate: UIViewController?
    
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var symbolsLabel: UILabel!
    @IBOutlet weak var manageDataLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsLabel.text = NSLocalizedString("settings", comment: "")
        descriptionLabel.text = NSLocalizedString("description", comment: "")
        symbolsLabel.text = NSLocalizedString("symbols", comment: "")
        manageDataLabel.text = NSLocalizedString("manage_data", comment: "")
        codeLabel.text = NSLocalizedString("use_code", comment: "")
        aboutLabel.text = NSLocalizedString("about_app", comment: "")
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(returnedFromBackground), name: NSNotification.Name(rawValue: "HIDE_VIEW"), object: nil)
        
    }
    
    @objc func returnedFromBackground() {
        if UserDefaults.standard.bool(forKey: "usePIN") {
            self.dismiss(animated: false, completion: nil)
        }
        
    }
    
    @IBAction func doneBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     switch indexPath.row {
     case 0:
     cell.textLabel?.text = NSLocalizedString("auto", comment: "")
     
     case 1:
     cell.textLabel?.text = NSLocalizedString("manual", comment: "")
     
     case 2:
     cell.textLabel?.text = NSLocalizedString("off", comment: "")
     
     case 3:
     cell.textLabel?.text = NSLocalizedString("off", comment: "")
     case 4:
     cell.textLabel?.text = NSLocalizedString("off", comment: "")
     
     default:
     print("no cells")
     }
     return cell
     }
     */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "ShowSettings", sender: self)
            
        case 1:
            performSegue(withIdentifier: "ShowDescription", sender: self)
            
        case 2:
            performSegue(withIdentifier: "ShowSymbols", sender: self)
        case 3:
            performSegue(withIdentifier: "ShowDataManagement", sender: self)
        case 4:
            performSegue(withIdentifier: "ShowCode", sender: self)
        case 5:
            performSegue(withIdentifier: "ShowAbout", sender: self)
            
        default:
            print("No items")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSettings" {
            let settingsController = segue.destination as! SettingsTableViewController
            settingsController.delegate = self.delegate as? SettingUpdatedDelegate
            
        } else if segue.identifier == "ShowAbout" {
            //   let aboutController = segue.destination as! AboutViewController
            
        }
        
    }
    
}
