//
//  SettingsTableViewController.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 09.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import UIKit

protocol SettingUpdatedDelegate {
    func applySettingsChanged()
}

class SettingsTableViewController: UITableViewController, TimeSetup {
    
    var delegate: SettingUpdatedDelegate?

    @IBOutlet weak var hideCheckedLabel: UILabel!
    @IBOutlet weak var hideCheckedSwitch: UISwitch!
    
    @IBOutlet weak var showPennyLabel: UILabel!
    @IBOutlet weak var showPennySwitch: UISwitch!
    
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var remindTimeLabel: UILabel!
    
    @IBOutlet weak var countTodayLabel: UILabel!
    @IBOutlet weak var countTodaySwitch: UISwitch!
    
    @IBOutlet weak var countDebtsLabel: UILabel!
    @IBOutlet weak var countDebtsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("settings", comment: "")
        hideCheckedLabel.text = NSLocalizedString("hide_checked", comment: "")
        showPennyLabel.text = NSLocalizedString("show_penny", comment: "")
        reminderLabel.text = NSLocalizedString("reminder_time", comment: "")
        countTodayLabel.text = NSLocalizedString("count_today", comment: "")
        countDebtsLabel.text = NSLocalizedString("count_debts", comment: "")

        hideCheckedSwitch.isOn = UserDefaults.standard.bool(forKey: "HideChecked")
        showPennySwitch.isOn = UserDefaults.standard.bool(forKey: "ShowPenny")
        countTodaySwitch.isOn = UserDefaults.standard.bool(forKey: "CountToday")
        countDebtsSwitch.isOn = UserDefaults.standard.bool(forKey: "CountDebts")
        let remindTime =  UserDefaults.standard.object(forKey: "RemindTime") as? Date
        remindTimeLabel.text = remindTime?.timeString
        
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Actions
    @IBAction func hideSwitchAction(_ sender: UISwitch) {
        setHide(sender.isOn)
    }
    
    @IBAction func showPennyAction(_ sender: UISwitch) {
        setPenny(sender.isOn)
    }
    
    @IBAction func todaySwitchAction(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "CountToday")
    }

    @IBAction func debtsSwitchAction(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "CountDebts")
    }

    private func setHide(_ status:Bool) {
        UserDefaults.standard.set(status, forKey: "HideChecked")
        delegate?.applySettingsChanged()
    }
    
    private func setPenny (_ status:Bool) {
        UserDefaults.standard.set(status, forKey: "ShowPenny")
        delegate?.applySettingsChanged()
    }

    private func setToday (_ status:Bool) {
        UserDefaults.standard.set(status, forKey: "CountToday")
        delegate?.applySettingsChanged()
    }
    private func setDebts (_ status:Bool) {
        UserDefaults.standard.set(status, forKey: "CountDebts")
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: // Первая секция
            switch indexPath.row {
            case 0:
                hideCheckedSwitch.isOn.toggle()
                setHide(hideCheckedSwitch.isOn)
            case 1:
                showPennySwitch.isOn.toggle()
                setPenny(showPennySwitch.isOn)
            case 2:
                countTodaySwitch.isOn.toggle()
                setToday(countTodaySwitch.isOn)
            case 3:
                countDebtsSwitch.isOn.toggle()
                setDebts(countDebtsSwitch.isOn)
            case 4:
                performSegue(withIdentifier: "ShowTimeSetup", sender: self)
            default:
                print("Wrong chioce")
            }
/*
        case 1: // Вторая секция
            switch indexPath.row {
            case 0:
                onlyMonthCell.accessoryType = .none
                allPastCell.accessoryType = .checkmark
                UserDefaults.standard.set(false, forKey: "CountOnlyMonth")
            case 1:
                allPastCell.accessoryType = .none
                onlyMonthCell.accessoryType = .checkmark
                UserDefaults.standard.set(true, forKey: "CountOnlyMonth")
            case 2:
                countTodaySwitch.isOn.toggle()
                UserDefaults.standard.set(countTodaySwitch.isOn, forKey: "CountToday")

            default:
                print("Wrong chioce")
            }
 */
        default:
            print("Wrong chioce")
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
/*
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionTitle = NSLocalizedString("late_payments", comment: "")
        if section == 1 {
            return sectionTitle.localizedUppercase
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
//        header.textLabel?.textColor = UIColor.red
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        header.textLabel?.frame = header.frame
        header.textLabel?.textAlignment = .left
    }
    */

    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let sectionHeader = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
//        let title = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 32))
//        title.text = NSLocalizedString("late_payments", comment: "")
//        sectionHeader.addSubview(title)
//        if section == 1 {
//            return sectionHeader
//        }
//        return UIView()
//    }
    
    func setupTime() {
        let remindTime =  UserDefaults.standard.object(forKey: "RemindTime") as? Date
        remindTimeLabel.text = remindTime?.timeString
    }


    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTimeSetup" {
            let timerSetup = segue.destination as! SetTimeViewController
            timerSetup.delegate = self
        }
    }
    

}
