//
//  SymbolsTableViewController.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 10.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import UIKit

class SymbolsTableViewController: UITableViewController {

    // Регулярные платежи
    @IBOutlet weak var regularOpenLabel: UILabel!
    @IBOutlet weak var regularOpenHintLabel: UILabel!

    @IBOutlet weak var regularDoneLabel: UILabel!
    @IBOutlet weak var regularDoneHintLabel: UILabel!

    @IBOutlet weak var regularAvansLabel: UILabel!
    @IBOutlet weak var regularAvansHintLabel: UILabel!

    @IBOutlet weak var regularOverLabel: UILabel!
    @IBOutlet weak var regularOverHintLabel: UILabel!

    @IBOutlet weak var regularDebtLabel: UILabel!
    @IBOutlet weak var regularDebtHintLabel: UILabel!

    // Разовые платежи
    @IBOutlet weak var onceOpenLabel: UILabel!
    @IBOutlet weak var onceOpenHintLabel: UILabel!

    @IBOutlet weak var onceDoneLabel: UILabel!
    @IBOutlet weak var onceDoneHintLabel: UILabel!

    @IBOutlet weak var onceOverLabel: UILabel!
    @IBOutlet weak var onceOverHintLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("symbols", comment: "")
        regularOpenLabel.text = NSLocalizedString("payment_open", comment: "")
        regularOpenHintLabel.text = NSLocalizedString("note_open", comment: "")
        
        regularDoneLabel.text = NSLocalizedString("payment_done", comment: "")
        regularDoneHintLabel.text = NSLocalizedString("note_done", comment: "")
        
//        regularAvansLabel.text = NSLocalizedString("payment_advance", comment: "")
//        regularAvansHintLabel.text = NSLocalizedString("note_advance", comment: "")
        
        regularOverLabel.text = NSLocalizedString("payment_overtime", comment: "")
        regularOverHintLabel.text = NSLocalizedString("note_overtime", comment: "")
        
//        regularDebtLabel.text = NSLocalizedString("payment_debt", comment: "")
//        regularDebtHintLabel.text = NSLocalizedString("note_debt", comment: "")

        onceOpenLabel.text = NSLocalizedString("single_open", comment: "")
        onceOpenHintLabel.text = NSLocalizedString("note_s_open", comment: "")

        onceDoneLabel.text = NSLocalizedString("single_done", comment: "")
        onceDoneHintLabel.text = NSLocalizedString("note_s_done", comment: "")

        onceOverLabel.text = NSLocalizedString("single_overtime", comment: "")
        onceOverHintLabel.text = NSLocalizedString("note_s_overtime", comment: "")

        tableView.tableFooterView = UIView()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        switch section {
        case 0:
            rows = 3
        case 1:
            rows = 3
        default:
            print("Wrong section")
        }
        return rows
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionTitle = ""

        if section == 0 {
            sectionTitle = NSLocalizedString("regular_payments", comment: "")
        } else if section == 1 {
            sectionTitle = NSLocalizedString("single_payments", comment: "")
        }
        return sectionTitle.localizedUppercase
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let sectionView = UILabel()
//
//        if section == 0 {
//            sectionView.text = NSLocalizedString("regular_payments", comment: "")
//
//        } else if section == 1 {
//            sectionView.text = NSLocalizedString("single_payments", comment: "")
//        }
//        sectionView.frame = CGRect(x: 20, y: 0, width: 300, height: 52)
//
//        sectionView.backgroundColor = .green
//
//        print("sec: \(section)")
//        return sectionView
//    }
//    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        guard let header = view as? UITableViewHeaderFooterView else { return }
//        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
//        header.textLabel?.frame = CGRect(x: 0, y: 0, width: 320, height: 52)
//        header.textLabel?.textAlignment = .left
//    }

    
}
