//
//  CodeViewController.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 10.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import UIKit

class CodeViewController: UIViewController, PinChanging {

    @IBOutlet weak var usePinLabel: UILabel!
    @IBOutlet weak var usePinSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("use_code", comment: "")
        usePinLabel.text = NSLocalizedString("usePIN", comment: "")
        usePinSwitch.isOn = UserDefaults.standard.bool(forKey: "usePIN")
    }
    
    @IBAction func pinSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "usePIN")
        if sender.isOn {
            performSegue(withIdentifier: "ShowPin", sender: self)
        }
    }
    
    func resetPin() {
        usePinSwitch.isOn = UserDefaults.standard.bool(forKey: "usePIN")
    }

    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPin" {
            let navController = segue.destination as! UINavigationController
            let pinController = navController.topViewController as! PinViewController
            pinController.delegate = self
            pinController.newPin = true
        }
    }
    

}
