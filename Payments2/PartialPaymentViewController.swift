//
//  PartialPaymentViewController.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 15.07.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import UIKit
import AVKit

class PartialPaymentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var valueLabel: SumLabel!
    @IBOutlet weak var partialMaxValue: UILabel!
    
    @IBOutlet weak var lockKeys: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var keysView: UIView!
    
    @IBOutlet var digits: [UIButton]!
    @IBOutlet weak var acKey: UIButton!
    @IBOutlet weak var commaKey: UIButton!
    @IBOutlet weak var cKey: UIButton!
    @IBOutlet weak var numbersKeysBottom: NSLayoutConstraint!
    
    var delegate: DataDelegate?
    var currentPeriod: Int?
    
    // Входящий item
    var item: Payment!
    // Новые item-ы которые получатся в результате частичной оплаты
    var addedItem: Payment!
    var originalValue = 0.00
    
    
    var twoItems = [Payment]()
    // Dohod + 1  Rashod - 1
    var valueSign = 1.0
    // Dohod = 0  Rashod = 1
    private var paymentType = 0
    
    
    
    var incomeColor: UIColor?
    var outcomeColor: UIColor?
    var buttonColor: UIColor?
    
    
    var valueTotal = 0.00
    var valueMax = 0.00
    
    var decimalMode = false
    var decimalDigits = 0
    var mantissDigits = 0
    let maximumDigits = 9
    
//    // Дата однократного платежа
//    var selectedDate = Today.date
//    // День регулярных платежей
//    var periodicDay = 0
    // Насколько вниз уходят клавиатуры
    let digitsKeyboardConstant: CGFloat = -324.0 - 64.0
    let showingConstant: CGFloat = -64.0
    
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("edit_item", comment: "")
        
        incomeColor = UIColor(named: "positiveColor")
        outcomeColor = UIColor(named: "negativeColor")
        
        saveButton.setTitle(NSLocalizedString("save_button", comment: ""), for: .normal)
        saveButton.isEnabled = true
        lockKeys.isHidden = true
        
        numbersKeysBottom.constant = digitsKeyboardConstant
        
        partialMaxValue.isHidden = true
        valueMax = item!.value
        partialPaymentSetup()
        
        if let realValue = item?.value {
            if realValue > 0 {
                valueTotal = realValue
                valueSign = 1.0
                //                           print(" Dohod!")
            } else {
                valueTotal = fabs(realValue)
                valueSign = -1.0
                //                            print("Rashod")
            }
        }
        
        reset()
        showDigitKeyboard()
        
//        if let paymentDay = item?.day {
//            periodicDay = paymentDay
//        }
        addedItem = Payment(withTitle: item.title)
        addedItem.checked = true
        addedItem.date = item.date
        addedItem.realDate = Today.date
        addedItem.day = item.day
        addedItem.interval = 1
        addedItem.value = 0
        originalValue = item.value
        twoItems.append(item)
        saveButton(enabled: false)
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showDigitKeyboard()
        
        if valueSign > 0 {
            showColors(tintColor: incomeColor ?? .label)
        } else {
            showColors(tintColor: outcomeColor ?? .label)
        }
        
//        displayValue()
    }
    
    // MARK: - Actions
    @IBAction func cancelBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBtnAction(_ sender: Any) {
        
        // теперь item - это изменённая item
        if let editedItem = item {
            delegate?.saveChanges(item: editedItem, new: false)
        }
        
//        print("saving item with date: \(addedItem.date.justDate)")
//        addedItem.date = Today.date
        if let addedSingleItem = addedItem {
            delegate?.saveChanges(item: addedSingleItem, new: true)
        }
        
        UserDefaults.standard.set(true, forKey: "WasChanges")
        self.dismiss(animated: true)
    }
    
    // MARK: - Table Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return twoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ListTableViewCell
        let payment = twoItems[indexPath.row]
        
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
        
        var dateSuffix = ""
        if payment.interval == 1 {
            dateSuffix = " (" + NSLocalizedString("single", comment: "") + ")"
        }
        
        cell.dateLabel.text = payment.date.toShortString + dateSuffix
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
            cell.titleLabel.alpha = 0.5
            cell.dateLabel.alpha = 0.5
            cell.sumLabel.alpha = 0.5
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
        }
        
        cell.checkButtonFunction = {
            // Tap on check image
        }
        
        return cell
    }
    
    
    
    // MARK: - Private functions
    private func partialPaymentSetup() {
        self.title = NSLocalizedString("partial_payment", comment: "")
        
//        let sign = valueSign > 0 ? "+" : "-"
        partialMaxValue.text = NSLocalizedString("less_than", comment: "") + fabs(valueMax).display(fraction: 2)
        partialMaxValue.isHidden = false
                
        // скрываю Save
        saveButton(enabled: false)
        // сброс суммы
//        reset()
//        displayValue()
        
        // теперь эта item станет новой добавленной записью платежа
        // - это будет разовый платеж на сумму частиной оплаты
//        addedItem?.uuid = UUID()
//        if let existDate = item?.date {
//            selectedDate = existDate
//        }
//        if let paymentDay = item?.day {
//            periodicDay = paymentDay
//        }
        
        // поскольку это будет частичная оплата,
        // то интервал - разовый
//        addedItem?.interval = 1
        // и отмечаем её как уже исполненную
//        addedItem?.checked = true
    }
    
    
    private func showColors(tintColor: UIColor) {
        let titleFont = UIFont.systemFont(ofSize: 18, weight: .bold)
        let titleDict: NSDictionary = [NSAttributedString.Key.foregroundColor: tintColor, NSAttributedString.Key.font : titleFont]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [NSAttributedString.Key : Any]
        
        valueLabel.textColor = tintColor
        drawButtons(shadowColor: tintColor)
    }
    
    
//    private func setupPaymentType() {
//        if UserDefaults.standard.integer(forKey: "CurrentPaymentType") == 0 {
//            valueSign = 1.0
//            showColors(tintColor: incomeColor ?? .label)
//        } else {
//            valueSign = -1.0
//            showColors(tintColor: outcomeColor ?? .label)
//        }
//    }
    
    
    // MARK: - Keys processor
    @IBAction func keyTouchDown(_ sender: Any) {
        AudioServicesPlaySystemSound(SystemSoundID(1104))
    }
    
    @IBAction func keyTapped(_ sender: UIButton) {
        if lockKeys.isHidden {
            if !decimalMode {
                mantissDigits += 1
                if mantissDigits > maximumDigits {
                    lockKeys.isHidden = false
                    mantissDigits = maximumDigits
                } else {
                    if sender.tag > 0 && sender.tag < 10 {
                        valueTotal *= 10
                        valueTotal += Double(sender.tag)
                    } else if sender.tag == 10 {
                        valueTotal *= 10
                    }
                    cKey.isEnabled = true
                }
                
            } else { // decimal digits
                decimalDigits += 1
                if decimalDigits > 2 {
                    lockKeys.isHidden = false
                    decimalDigits = 2
                } else {
                    let fraction = pow(10.0, Double(decimalDigits))
                    if sender.tag > 0 && sender.tag < 10 {
                        let add = Double(sender.tag) / fraction
                        valueTotal += add
                    } else if sender.tag == 10 { // key 0
                        
                    }
                }
                cKey.isEnabled = true
            }
            saveButton(enabled: !checkOverMax())
            displayValue()
        } else {
//            item.value = originalValue
//            tableView.reloadData()
//            tableView.reloadRows(at: [[0, 0]], with: .automatic)
        }
    }
    
    @IBAction func commaTapped(_ sender: UIButton) {
        decimalMode = true
        decimalDigits = 0
        valueLabel.text = valueTotal.display(fraction: 1)
        commaKey.isEnabled = false
    }
    
    private func reset() {
        cKey.isEnabled = false
        commaKey.isEnabled = true
        lockKeys.isHidden = true
        valueTotal = 0.0
        decimalMode = false
        decimalDigits = 0
        mantissDigits = 0
        partialMaxValue.textColor = .secondaryLabel
        saveButton(enabled: false)
    }
    
    @IBAction func acTapped(_ sender: Any) {
        reset()
        displayValue()
        correctValues()
    }
    
    @IBAction func cTapped(_ sender: Any) {
        if !decimalMode {
            let lastDigit = valueTotal.truncatingRemainder(dividingBy: 10)
            valueTotal -= lastDigit
            valueTotal = valueTotal / 10
            mantissDigits -= 1
        } else { // decimal digits
            let fraction = pow(10.0, Double(decimalDigits))
            let zeroFractValue = valueTotal * fraction
            let lastDigit = zeroFractValue.truncatingRemainder(dividingBy: 10)
            let sub = lastDigit / fraction
            valueTotal -= sub
            decimalDigits -= 1
            if decimalDigits == 0 {
                decimalMode = false
            }
        }
        lockKeys.isHidden = true
        correctValues()
        saveButton(enabled: !checkOverMax())
        
        displayValue()
    }
    
    func displayValue() {
//        var sign = ""
//        if valueSign > 0 {
//            sign = "+"
//        } else if valueSign < 0 {
//            sign = "-"
//        }
//        if valueTotal == 0 {
//            sign = ""
//        }
        valueLabel.text = valueTotal.display(fraction: decimalDigits)
        correctValues()
        showRowsExample()
    }
    
    private func correctValues() {
        if originalValue > 0 {
            let newItemValue = originalValue - valueTotal
            let resultCorrect = valueTotal < originalValue
            item.value = resultCorrect ? newItemValue : originalValue
        } else if originalValue < 0 {
            let newItemValue = originalValue + valueTotal
            let resultCorrect = valueTotal < fabs(originalValue)
            item.value = resultCorrect ? newItemValue : originalValue
        }
//        print("edited item value: \(item.value) newvalue = \(newItemValue) correct: \(resultCorrect)")

        addedItem?.value = valueSign * valueTotal
        addedItem.date = Today.date
    }
    
    private func checkOverMax() -> Bool {
        var valueIsOver = false
        if valueTotal >= fabs(valueMax) {
            valueIsOver = true
            partialMaxValue.textColor = .red
            lockKeys.isHidden = false
        } else {
            partialMaxValue.textColor = .secondaryLabel
            lockKeys.isHidden = true
        }
        return valueIsOver
    }
    
    private func showRowsExample() {
        twoItems.removeAll()
        twoItems.append(item)
        // Показываю пример строчек
//        print("\(valueTotal) original: \(originalValue)")
        if valueTotal > 0 && valueTotal < fabs(originalValue) {
            twoItems.append(addedItem!)
        }
        tableView.reloadData()
    }
    
    private func showDigitKeyboard() {
        // Показываю цифровую клавиатуру
        self.numbersKeysBottom.constant = self.showingConstant
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func saveButton(enabled: Bool) {
        var canSave = false
        
        canSave = self.valueTotal != 0 && fabs(self.valueTotal) < fabs(valueMax) && enabled
        saveButton.isEnabled = canSave
    }
    
    
    private func drawButtons(shadowColor: UIColor) {
        for button in digits {
            button.layer.shadowOffset = CGSize(width: 0, height: 0.4)
            button.layer.shadowRadius = 2
            button.layer.shadowOpacity = 0.6
            button.layer.shadowColor = shadowColor.cgColor
            button.layer.masksToBounds = false
        }
        commaKey.layer.shadowOffset = CGSize(width: 0, height: 0.4)
        commaKey.layer.shadowRadius = 2
        commaKey.layer.shadowOpacity = 0.6
        commaKey.layer.shadowColor = shadowColor.cgColor
        commaKey.layer.masksToBounds = false
        
        acKey.layer.shadowOffset = CGSize(width: 0, height: 0.4)
        acKey.layer.shadowRadius = 2
        acKey.layer.shadowOpacity = 0.5
        acKey.layer.masksToBounds = false
        
        cKey.layer.shadowOffset = CGSize(width: 0, height: 0.2)
        cKey.layer.shadowRadius = 2
        cKey.layer.shadowOpacity = 0.5
        cKey.layer.masksToBounds = false
    }
    
}
