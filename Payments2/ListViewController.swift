//
//  ViewController.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 08.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DataDelegate, SettingUpdatedDelegate, PinPassed {
    
    
    @IBOutlet weak var allHiddenLabel: UILabel!
    
    @IBOutlet weak var incomeTitleLabel: UILabel!
    @IBOutlet weak var outcomeTitleLabel: UILabel!
    @IBOutlet weak var totalTitleLabel: UILabel!
    
    @IBOutlet weak var topIncomeAllValue: UILabel!
    @IBOutlet weak var topIncomeDoneValue: UILabel!
    @IBOutlet weak var topIncomeRestValue: UILabel!
    
    @IBOutlet weak var topOutcomeAllValue: UILabel!
    @IBOutlet weak var topOutcomeDoneValue: UILabel!
    @IBOutlet weak var topOutcomeRestValue: UILabel!
    
    @IBOutlet weak var topTotalAllValue: UILabel!
    @IBOutlet weak var topAllDoneValue: UILabel!
    @IBOutlet weak var topAllRestValue: UILabel!
    
    @IBOutlet weak var topAllLabel: UILabel!
    @IBOutlet weak var topDoneLabel: UILabel!
    @IBOutlet weak var topRestLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!
    
    // это платежи
    var payments = [Payment]()
    // записи, которые сейчас на экране
    var shownPayments = [Payment]()
    
    var currentPeriodId = 0
    var previousPeriodId = 0

    var currentRow: Int = 0
    var currentIndexPath = IndexPath()
    var initFirst = false
    var makeDuplicate = false
    
    var incomeColor: UIColor?
    var outcomeColor: UIColor?
    var buttonColor: UIColor?
    
    var showPenny = UserDefaults.standard.bool(forKey: "ShowPenny")
        
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        allHiddenLabel.text = NSLocalizedString("items_hidden", comment: "")

        incomeColor = UIColor(named: "positiveColor")
        outcomeColor = UIColor(named: "negativeColor")

        // определяю именно текущий период years * 12 + months
        currentPeriodId = Today.date.yearMonths

//        print("curr: \(245.monthName)")
        self.title = currentPeriodId.monthName.localizedUppercase
        tableView.tableFooterView = UIView()

        incomeTitleLabel.text = NSLocalizedString("incomes_title", comment: "").uppercased()
        outcomeTitleLabel.text = NSLocalizedString("outcomes_title", comment: "").uppercased()
        totalTitleLabel.text = NSLocalizedString("summary_title", comment: "").uppercased()

        topAllLabel.text = NSLocalizedString("top_all_payments", comment: "")
        topDoneLabel.text = NSLocalizedString("top_done_payments", comment: "")
        topRestLabel.text = NSLocalizedString("top_rest_payments", comment: "")

        
        let keyStore = NSUbiquitousKeyValueStore()
        NotificationCenter.default.addObserver(self, selector: #selector(keyValueStoreDidChange),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: keyStore)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: "RELOAD_DATA"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideScreen), name: NSNotification.Name(rawValue: "HIDE_VIEW"), object: nil)

        
//        #warning("Change to false before publishing")
//        initFirst = false
//        if initFirst {
//            initItems()
//        }

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("use pin: \(UserDefaults.standard.bool(forKey: "usePIN"))")
        print("pin passed: \(UserDefaults.standard.bool(forKey: "PINpassed"))")

        
        // Буду проверять, не изменился ли период с последнего запуска
        previousPeriodId = UserDefaults.standard.integer(forKey: "CurrentPeriodId")
        //       print("Previous start period: \(previousStartPeriodId)")
        
        if UserDefaults.standard.bool(forKey: "VeryFirstTime") {
            previousPeriodId = currentPeriodId
            UserDefaults.standard.set(currentPeriodId, forKey: "CurrentPeriodId")
            UserDefaults.standard.set(false, forKey: "VeryFirstTime")
        }
        
        print("Current period: \(currentPeriodId) previous: \(previousPeriodId)")
        
//        self.reloadData()
        
                
//        if !(UserDefaults.standard.bool(forKey: "usePIN") && !UserDefaults.standard.bool(forKey: "PINpassed"))  {
//            print("pass pins")
//            if currentPeriodId > previousPeriodId {
//                print("!!! Start next period !!!")
//                showNextPeriod()
//            }

//        } else {
//            print("cant pass pins")
//        }
        
        if UserDefaults.standard.bool(forKey: "usePIN") && !UserDefaults.standard.bool(forKey: "PINpassed")  {
            print("Show PIN access")
            performSegue(withIdentifier: "ShowPin", sender: self)
        } else {
            showScreen()
        }

    }
        
    // MARK: - Password Delegate method

    func showScreen() {
        if currentPeriodId > previousPeriodId {
            print("!!! Start next period !!!")
            showNextPeriod()
        }

        self.loadData()
    }

    
    // MARK: - Change period to NEXT
    private func showNextPeriod() {
        let alertMessage = NSLocalizedString("start_new_period", comment: "")
        let hintAlert = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
        
        let okTitle = randomLuck()
        let okButton = UIAlertAction(title: okTitle, style: .default) {_ in
            // Пересчет на следующий период
            self.setupNextPeriod()
        }
        hintAlert.addAction(okButton)
        present(hintAlert, animated: true, completion: nil)
    }
    
    // Next period
    private func setupNextPeriod() {
        print("next period setup... period: \(currentPeriodId)")
        UserDefaults.standard.set(currentPeriodId, forKey: "CurrentPeriodId")
        
        let countDebts = UserDefaults.standard.bool(forKey: "CountDebts") // true by default
        
        if let currentPayments = DataManager.getPayments() {
            payments = currentPayments
        }

        // Сначала оставляем только все разовые неотмеченные и все регулярные,
        payments = payments.filter({ (payment) -> Bool in
            payment.interval == 30 || (payment.interval == 1 && !payment.checked)
        })
        // плюс оставляем все отмеченные с day == 0 - долги
        payments = payments.filter({ (payment) -> Bool in
            !(payment.interval == 30 && payment.day == 0 && payment.checked) || payment.interval == 1
        })

        
        // Создаём временные массивы для долгов
        let oldDebts = payments.filter { (payment) -> Bool in
            payment.interval == 30 && payment.day == 0
        }
        let newDebts = payments.filter { (payment) -> Bool in
            payment.interval == 30 && payment.day != 0 && !payment.checked
        }
        //  print("old debts count = \(oldDebts.count)   new debts count = \(newDebts.count)")
        
        // Теперь оставляем только регулярные и разовые - без всех долгов
        payments = payments.filter({ (payment) -> Bool in
            payment.day != 0 || payment.interval == 1
        })

        // Теперь у них меняем дату на актуальную, кроме разовых
        payments = payments.map({ (payment) -> Payment in
            var newPayment = payment
            if newPayment.interval > 1 {
                
                newPayment.checked = false
                newPayment.value = payment.originalValue

                if payment.day < 29 {
                    newPayment.date = dateFromDay(day: payment.day).justDate
                } else {
                    newPayment.date = dateFromDay(day: 28).justDate
                }
            }
            return newPayment
        })
        
        if countDebts {
            // Добавляю все старые долги
            payments.append(contentsOf: oldDebts)
            
            // Добавляю новые долги
            for debt in newDebts {
                var newDebt = Payment(withTitle: debt.title)
                newDebt.checked = false
                newDebt.date = debt.date
                newDebt.day = 0
                newDebt.interval = debt.interval // 30
                newDebt.originalValue = debt.originalValue
                newDebt.month = debt.month
                newDebt.value = debt.value
                newDebt.realDate = debt.realDate
                
                payments.append(newDebt)
            }
        }
                
        DataManager.savePayments(payments: payments)

        self.loadData()
    }
    
    private func dateFromDay(day: Int) -> Date {
        var dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: Today.date)
        dateComponents.day = day
        return Calendar.current.date(from: dateComponents)!
    }

    // MARK: - Actions
    @IBAction func addNewBtnAction(_ sender: Any) {
        makeDuplicate = false
        performSegue(withIdentifier: "ShowAddNew", sender: self)
    }
    
    @IBAction func supportBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "ShowSupport", sender: self)
    }
    
    @objc
    func keyValueStoreDidChange() {
        print("got cloud changes...")
        UserDefaults.standard.set(false, forKey: "VeryFirstTime")
        if UserDefaults.standard.bool(forKey: "AutomaticSync") {
            print("Automatic ON")
            DataManager.updatePaymentsFromCloud { success in
                if success {
                    print("reload from cloud changes")
                    self.loadData()
                }
            }
        } else {
            print("Automatic OFF")
        }
    }
        
    // Close app: will resign active
    @objc func hideScreen() {
        print("hide screen")
        performSegue(withIdentifier: "ShowPin", sender: self)
    }
    
    // App Will Enter Foreground - does not call
    @objc
    func reloadData() {
        print("RELOAD calling")
        currentPeriodId = Today.date.yearMonths
        
        
        if currentPeriodId > previousPeriodId {
            print("!!! Start next period !!!")
            showNextPeriod()
        }

        loadData()
    }
    
    private func loadData() {
        if let currentPayments = DataManager.getPayments() {
            payments = currentPayments
            reloadTableView()
            if !UserDefaults.standard.bool(forKey: "WasChanges") {
                DataManager.savePayments(payments: payments)
            }
        }

    }

    
    // Это для создания скриншотов
    private func initItems() {
        var payments = [Payment]()
        payments.removeAll()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        for index in 1...6 {
            let newTitle = NSLocalizedString("initName\(index)", comment: "")
            var newItem = Payment(withTitle: newTitle)
            let day = Int(NSLocalizedString("initDay\(index)", comment: ""))
            newItem.date = dateFromDay(day: day!)
            newItem.value = Double(NSLocalizedString("initSum\(index)", comment: ""))!
            newItem.day = day ?? 1
            payments.append(newItem)
        }
         DataManager.savePayments(payments: payments)
    }
    
    // MARK: - Functions
    func saveEdits(withPayment thePayment: Payment) {
        let newPayments = payments.map { (iPayment) -> Payment in
            if iPayment.uuid == thePayment.uuid {
                var newPayment = iPayment
                newPayment.checked = !thePayment.checked
                return newPayment
            }
            return iPayment
        }
        payments = newPayments
        DataManager.savePayments(payments: newPayments)
        calculateTotal()
    }

    func applySettingsChanged() {
        print("Settings changed:")
        if UserDefaults.standard.bool(forKey: "HideChecked") {
            print("Hide checked")
        }
        showPenny = UserDefaults.standard.bool(forKey: "ShowPenny")
        // Сохраняю циферку на бейджик
        UserDefaults.standard.set(DataManager.overduedCount(items: payments), forKey: "Overdued")
        reloadTableView()
    }
    
    private func updateShownItems() {
//        print("payments exist: \(payments.count)")
        // Если в Настройках Скрыть отмеченные
        if UserDefaults.standard.bool(forKey: "HideChecked") {
            shownPayments = payments.filter{ !$0.checked }
            allHiddenLabel.isHidden = shownPayments.count != 0 || payments.count == 0
        } else {
            shownPayments = payments
            allHiddenLabel.isHidden = true
        }
        
        //      print("items count: \(items.count)")
        shownPayments = shownPayments.sorted(by: {
            var order = false
//            if $0.date.dayFromDate == $1.date.dayFromDate {
//                order = $0.value > $1.value
//            } else {
//                order = $0.date.dayFromDate < $1.date.dayFromDate
//            }
            
            if $0.date == $1.date {
                order = $0.value > $1.value
            } else {
                order = $0.date < $1.date
            }
            return order
        })
        calculateTotal()
    }
    
    private func randomLuck() -> String{
        var answers = [String]()
        for i in 0...4 {
            let answer = NSLocalizedString("ok\(i)", comment: "")
            answers.append(answer)
        }
        let lucky = answers.randomElement()
        return lucky ?? "Ok"
    }

    private func calculateTotal() {
        topTotalAllValue.text = payments.reduce(0.00, { (res, payment) -> Double in
            res + payment.value
        }).display(fraction: 2)
        topAllDoneValue.text = payments.reduce(0.00, { (res, payment) -> Double in
            if payment.checked {
                return res + payment.value
            }
            return res
        }).display(fraction: 2)
        topAllRestValue.text = payments.reduce(0.00, { (res, payment) -> Double in
            if !payment.checked {
                return res + payment.value
            }
            return res
            }).display(fraction: 2)

        
        // Incomes
        topIncomeAllValue.text = payments.reduce(0.00, { (res, payment) -> Double in
            if payment.value > 0 {
                return res + payment.value
            }
            return res
        }).display(fraction: 2)
        topIncomeDoneValue.text = payments.reduce(0.00, { (res, payment) -> Double in
            if payment.value > 0 && payment.checked {
                return res + payment.value
            }
            return res
        }).display(fraction: 2)
        topIncomeRestValue.text = payments.reduce(0.00, { (res, payment) -> Double in
            if payment.value > 0 && !payment.checked {
                return res + payment.value
            }
            return res
        }).display(fraction: 2)

        // Outcomes
        topOutcomeAllValue.text = payments.reduce(0.00, { (res, payment) -> Double in
            if payment.value < 0 {
                return res + payment.value
            }
            return res
        }).display(fraction: 2)
        topOutcomeDoneValue.text = payments.reduce(0.00, { (res, payment) -> Double in
            if payment.value < 0 && payment.checked {
                return res + payment.value
            }
            return res
        }).display(fraction: 2)
        topOutcomeRestValue.text = payments.reduce(0.00, { (res, payment) -> Double in
            if payment.value < 0 && !payment.checked {
                return res + payment.value
            }
            return res
        }).display(fraction: 2)

    }
    
    
    // MARK: - Delegate methods
    func saveChanges(item: Payment, new: Bool) {
        if new {
            payments.append(item)
            DataManager.savePayments(payments: payments)

        } else { // Edit patment
            print("Saving editts in delegate")
            
            let updatedPayments = payments.map { (existingPayment) -> Payment in
                if existingPayment.uuid == item.uuid {
                    var newPayment = existingPayment
                    newPayment.day = item.day
                    newPayment.date = item.date
                    newPayment.value = item.value
                    newPayment.originalValue = item.originalValue
                    newPayment.title = item.title
                    return newPayment
                }
                return existingPayment
            }
            payments = updatedPayments
            DataManager.savePayments(payments: updatedPayments)

            reloadTableView()
            
        }
        reloadTableView()
      }
      
    func deleteItem(item: Payment) {
//        let indexPath = IndexPath(row: currentRow, section: 0)
        
        payments = payments.filter {$0.uuid != item.uuid }
        DataManager.savePayments(payments: payments)
        
        updateShownItems()
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [currentIndexPath], with: .automatic)
        tableView.endUpdates()
    }

    
    
    // MARK: - Table reload data
    private func reloadTableView() {
        updateShownItems()
        tableView.reloadData()
    }

    
    // MARK: - Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shownPayments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ListTableViewCell
        let payment = shownPayments[indexPath.row]
        
        if payment.value > 0 {
            cell.sumLabel.textColor = incomeColor
            cell.titleLabel.textColor = incomeColor
            cell.checkView.tintColor = incomeColor
            
        } else {
            cell.sumLabel.textColor = outcomeColor
            cell.titleLabel.textColor = outcomeColor
            cell.checkView.tintColor = outcomeColor
        }
        cell.titleLabel.text = payment.title
        
        if payment.interval == 1 {
            cell.dateLabel.text = payment.date.toLongString + " (" + NSLocalizedString("single", comment: "") + ")"
            
            
        } else {
            // Periodic day
            if payment.day == 0 {
                // Это долг прошлого периода
                cell.dateLabel.text = NSLocalizedString("debt_from", comment: "") + " " + payment.date.toShortString
            } else if payment.day > 0 && payment.day < 28 {
                cell.dateLabel.text = payment.date.toShortString
            } else if payment.day >= 28 {
                cell.dateLabel.text = NSLocalizedString("until_end", comment: "") + payment.date.endOfMonth().toShortString
            }
//            cell.dateLabel.text = payment.date.toShortString
        }
        
        var sign = ""
        if payment.value > 0 {
            sign = "+"
        }
        cell.sumLabel.text = sign + payment.value.display(fraction: 2)
        
        if payment.checked {
            if payment.interval == 30 {
                cell.checkView.image = UIImage(named: "checked_30")
                //        cell.checkView.tintColor = UIColor(named: "disabledFontColor")
            } else if payment.interval == 1 {
                cell.checkView.image = UIImage(named: "checked_1")
                //           cell.checkView.tintColor = UIColor(named: "disabledFontColor")
                
            }
            cell.titleLabel.alpha = 0.4
            cell.dateLabel.alpha = 0.4
            cell.sumLabel.alpha = 0.4
            cell.backgroundColor = UIColor(named: "bkgColor")

        } else {
            if payment.interval == 30 {
                if payment.date < Today.date {
                    cell.checkView.image = UIImage(named: "overtime_30")
                } else {
                    cell.checkView.image = UIImage(named: "unchecked_30")
                }
                
            } else if payment.interval == 1 {
                if payment.date < Today.date {
                    cell.checkView.image = UIImage(named: "overtime_1")
                } else {
                    cell.checkView.image = UIImage(named: "unchecked_1")
                }
            }
            cell.titleLabel.alpha = 1.0
            cell.dateLabel.alpha = 1.0
            cell.sumLabel.alpha = 1.0
            cell.backgroundColor = UIColor(named: "lightColor")
        }
        
        cell.checkButtonFunction = {
            // Tap on check image
            self.shownPayments[indexPath.row].checked = !payment.checked
            self.saveEdits(withPayment: payment)
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentRow = indexPath.row
        currentIndexPath = indexPath
//        performSegue(withIdentifier: "ShowEditItem", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        
        showSubMenu()
    }
    
    private func showSubMenu() {
        let menuTitle = shownPayments[currentRow].title
//        let menuMessage = NSLocalizedString("choose_action", comment: "")
        let menuAlert = UIAlertController(title: menuTitle, message: nil, preferredStyle: .actionSheet)
        
        let editTitle = NSLocalizedString("edit_button", comment: "")
        let duplicateTitle = NSLocalizedString("duplicate_button", comment: "")
        let partialTitle = NSLocalizedString("partial_payment", comment: "")
        let deleteTitle = NSLocalizedString("delete_button", comment: "")
        
        let editButton = UIAlertAction(title: editTitle, style: .default) { action in
            print("Confirm edit")
            self.performSegue(withIdentifier: "ShowEditItem", sender: self)
        }
        let duplicateButton = UIAlertAction(title: duplicateTitle, style: .default) { action in
            print("Confirm duplicate")
            self.makeDuplicate = true
            self.performSegue(withIdentifier: "ShowAddNew", sender: self)
        }
        let partialButton = UIAlertAction(title: partialTitle, style: .default) { action in
            print("Confirm partial")
            self.performSegue(withIdentifier: "ShowPartialPayment", sender: self)
        }

        let deleteButton = UIAlertAction(title: deleteTitle, style: .destructive) { action in
            print("Confirm delete")
            self.deleteItem(item: self.shownPayments[self.currentRow])
        }

        let cancelTitle = NSLocalizedString("cancel", comment: "")
        let cancelButton = UIAlertAction(title: cancelTitle, style: .cancel)
        
        menuAlert.addAction(editButton)
        menuAlert.addAction(duplicateButton)
        if !shownPayments[currentRow].checked {
            menuAlert.addAction(partialButton)
        }
        menuAlert.addAction(deleteButton)
        menuAlert.addAction(cancelButton)
        
        // Чтобы работало на iPad
        menuAlert.popoverPresentationController?.sourceView = self.view
        menuAlert.popoverPresentationController?.permittedArrowDirections = .down
        menuAlert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.width / 2, y: self.view.bounds.height - 20, width: 0, height: 0)

        present(menuAlert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowEditItem" {
            let navController = segue.destination as! UINavigationController
            let detailsController = navController.topViewController as! EditViewController

            detailsController.currentPeriod = self.currentPeriodId
            detailsController.item = shownPayments[currentRow]
            print("item day sent: \(shownPayments[currentRow].day)")
            print("item date sent: \(shownPayments[currentRow].date)")
            detailsController.delegate = self
        } else if segue.identifier == "ShowPartialPayment" {
            let navController = segue.destination as! UINavigationController
            let detailsController = navController.topViewController as! PartialPaymentViewController

            detailsController.currentPeriod = self.currentPeriodId
            detailsController.item = shownPayments[currentRow]
            detailsController.delegate = self
        } else if segue.identifier == "ShowAddNew" {
            let navController = segue.destination as! UINavigationController
            let destinationVC = navController.topViewController as! AddViewController
            
            if makeDuplicate {
                destinationVC.item = shownPayments[currentRow]
            }

            destinationVC.currentPeriod = self.currentPeriodId
            destinationVC.isNew = !makeDuplicate
            destinationVC.delegate = self
        }
            else if segue.identifier == "ShowSupport" {
            let navController = segue.destination as! UINavigationController
            let supportController = navController.topViewController as! SupportTableViewController
            supportController.delegate = self
        } else if segue.identifier == "ShowPin" {
            let navController = segue.destination as! UINavigationController
            let pinController = navController.topViewController as! PinViewController
            pinController.newPin = false
        }
    }

}

