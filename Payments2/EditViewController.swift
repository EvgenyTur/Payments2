//
//  EditViewController.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 09.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import UIKit
import AVKit

class EditViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var valueLabel: SumLabel!
    
    @IBOutlet weak var lockKeys: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            let rightView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 46.0))
            nameTextField.rightView = rightView
            nameTextField.rightViewMode = .always
        }
    }
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateTextLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    
    @IBOutlet weak var keysView: UIView!
    
    @IBOutlet var digits: [UIButton]!
    @IBOutlet weak var acKey: UIButton!
    @IBOutlet weak var commaKey: UIButton!
    @IBOutlet weak var cKey: UIButton!
    @IBOutlet weak var signPlusKey: UIButton!
    @IBOutlet weak var signMinusKey: UIButton!
    @IBOutlet weak var numbersKeysBottom: NSLayoutConstraint!
//    @IBOutlet weak var numbersHintLabel: UILabel!

    @IBOutlet weak var datesView: UIView!
    
    @IBOutlet var dates: [UIButton]!
    @IBOutlet weak var datesKeysBottom: NSLayoutConstraint!
//    @IBOutlet weak var datesHintLabel: UILabel!

    @IBOutlet weak var oneDateView: UIView!
    @IBOutlet weak var oneDatePicker: UIDatePicker!
    @IBOutlet weak var oneDateBottom: NSLayoutConstraint!
//    @IBOutlet weak var oneDateHintLabel: UILabel!

    
    var delegate: DataDelegate?
    var currentPeriod: Int?
    
    // Входящий item
    var item: Payment?
    
    // Dohod + 1  Rashod - 1
    var valueSign = 1.0
    // Dohod = 0  Rashod = 1
    private var paymentType = 0

    
    
    var incomeColor: UIColor?
    var outcomeColor: UIColor?
    var buttonColor: UIColor?
    
    enum Focused {
        case value, text, periodic, single
    }
    
    var currentFocus: Focused = .value
    
    var valueTotal = 0.00
    
    var decimalMode = false
    var decimalDigits = 0
    var mantissDigits = 0
    let maximumDigits = 9
    
    // Дата однократного платежа
    var selectedDate = Today.date
    // День регулярных платежей
    var periodicDay = 0
    // Насколько вниз уходят клавиатуры
    let digitsKeyboardConstant: CGFloat = -324.0 - 64.0
    let datesKeyboardConstant: CGFloat = -324.0 - 64.0
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
        
        sumLabel.text = NSLocalizedString("sum", comment: "")
        dateLabel.text = NSLocalizedString("payment_date", comment: "")
        
        nameTextField.delegate = self
        numbersKeysBottom.constant = digitsKeyboardConstant
        datesKeysBottom.constant = datesKeyboardConstant
        oneDateBottom.constant = datesKeyboardConstant
        
        
        nameTextField.placeholder = NSLocalizedString("entername", comment: "")

        nameTextField.text = item?.title
        if let existDate = item?.date {
            selectedDate = existDate
        }
                
        
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
            setupPaymentType()
        }
        
        
        // Определяю сколько знаков в мантиссе и после запятой
        let strValue = String(valueTotal)
        if valueTotal * 100 == Double(100 * Int(valueTotal)) {
            decimalMode = false
            decimalDigits = 0
            if let range: Range<String.Index> = strValue.range(of: ".") {
                mantissDigits = strValue.distance(from: strValue.startIndex, to: range.lowerBound)
            }
        } else {
            decimalMode = true
            if let range: Range<String.Index> = strValue.range(of: ".") {
                mantissDigits = strValue.distance(from: strValue.startIndex, to: range.lowerBound)
                decimalDigits = strValue.distance(from: range.lowerBound, to: strValue.endIndex) - 1
            }
        }
        
        if let paymentDay = item?.day {
            periodicDay = paymentDay
        }
        displayDate()

        // Create Picker
        oneDatePicker.datePickerMode = .date
//        let monthNumber = month(fromPeriodId: currentPeriod!)
//        let thisMonthDate = monthNumber.monthDate
//        oneDatePicker.minimumDate = thisMonthDate.startOfMonth()
//        oneDatePicker.maximumDate = thisMonthDate.endOfMonth()
        oneDatePicker.date = selectedDate
        oneDatePicker.addTarget(self, action: #selector(onDateChanged), for: UIControl.Event.valueChanged)

        saveButton(enabled: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        showDigitKeyboard()
//        setupPaymentType()
        
        if valueSign > 0 {
            showColors(tintColor: incomeColor ?? .label)
        } else {
            showColors(tintColor: outcomeColor ?? .label)
        }

        displayValue()
    }

    // MARK: - Actions
    @IBAction func cancelBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Save
    @IBAction func saveBtnAction(_ sender: Any) {
        
        let newValue = valueSign * (100 * valueTotal).rounded() / 100
        item?.value = newValue
        item?.originalValue = newValue
        item?.title = nameTextField.text ?? ".."
        if item?.interval == 30 {
            item?.date = dateFromDay(day: periodicDay)
            item?.day = periodicDay
        } else { // interval = 1
            item?.date = selectedDate.justDate
            item?.day = 0
        }
        
        // теперь item - это изменённая item
        if let editedItem = item {
//            print("save edited, \(item?.title)  \(item?.value)")
            delegate?.saveChanges(item: editedItem, new: false)
        }
        
        UserDefaults.standard.set(true, forKey: "WasChanges")
        self.dismiss(animated: true)
    }
    
    // MARK: - Other actions
    @IBAction func titleChanged(_ sender: UITextField) {
        saveButton(enabled: true)
    }
    @IBAction func titleBeginEditAction(_ sender: Any) {
        print("edit detected")
        hideCurrentKeyboard (sender: .text) {
            self.currentFocus = .text
        }
    }
    
    @IBAction func valueBtnAction(_ sender: Any) {
        reset()
        showDigitKeyboard()
    }
    
    @IBAction func dateButtonAction(_ sender: Any) {
        showDateKeyboard()
    }
    
    // MARK: - Private functions
    private func changePaymentSign() {
        paymentType = valueSign > 0 ? 0 : 1
        UserDefaults.standard.set(paymentType, forKey: "CurrentPaymentType")
        if paymentType == 0 {
            valueSign = 1.0
            showColors(tintColor: incomeColor ?? .label)
            nameTextField.placeholder = NSLocalizedString("title_from", comment: "name label")
            nameLabel.text = NSLocalizedString("title_from", comment: "")

        } else {
            valueSign = -1.0
            showColors(tintColor: outcomeColor ?? .label)
            nameTextField.placeholder = NSLocalizedString("title_to", comment: "name label")
            nameLabel.text = NSLocalizedString("title_to", comment: "")

        }
        displayValue()
        
    }
    
    private func setupPaymentType() {
        if valueSign == 1 {
            nameTextField.placeholder = NSLocalizedString("title_from", comment: "name label")
            nameLabel.text = NSLocalizedString("title_from", comment: "")
            showColors(tintColor: incomeColor ?? .label)
        } else {
            nameTextField.placeholder = NSLocalizedString("title_to", comment: "name label")
            nameLabel.text = NSLocalizedString("title_to", comment: "")
            showColors(tintColor: outcomeColor ?? .label)
        }
    }

    private func showColors(tintColor: UIColor) {
        let titleFont = UIFont.systemFont(ofSize: 18, weight: .bold)
        let titleDict: NSDictionary = [NSAttributedString.Key.foregroundColor: tintColor, NSAttributedString.Key.font : titleFont]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [NSAttributedString.Key : Any]
        
        valueLabel.textColor = tintColor
        drawButtons(shadowColor: tintColor)

    }

    
//    @IBAction func titleChanged(_ sender: UITextField) {
//        saveButton(enabled: true)
//    }
//    @IBAction func titleBeginEditAction(_ sender: Any) {
//        print("edit detected")
//        hideCurrentKeyboard (sender: .text) {
//            self.currentFocus = .text
//        }
//    }
    
    //    @IBAction func titleTouchAction(_ sender: UITextField) {
    //        print("touch detected")
    //        hideCurrentKeyboard {
    //            self.currentFocus = .text
    //        }
    //    }
    

    
    
    private func month(fromPeriodId period: Int) -> Int {
        var currentYear = period / 12
        if period % 12 == 0 {
            currentYear -= 1
        }
        return period  - 12 * currentYear
    }
    private func year(fromPeriodId period: Int) -> Int {
        var currentYear = period / 12
        if period % 12 == 0 {
            currentYear -= 1
        }
        return currentYear
    }

    private func dateFromDay(day: Int) -> Date {
        var dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: Today.date)
        dateComponents.day = day
        dateComponents.month = month(fromPeriodId: currentPeriod!)
        dateComponents.year = year(fromPeriodId: currentPeriod!)
        return Calendar.current.date(from: dateComponents)!
    }


    
    // MARK: - Keys processor
    @IBAction func keyTouchDown(_ sender: Any) {
        AudioServicesPlaySystemSound(SystemSoundID(1104))
    }

    @IBAction func keyTapped(_ sender: UIButton) {
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
       
        saveButton(enabled: true)
        displayValue()
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
        displayValue()
        saveButton(enabled: false)
    }
    
    @IBAction func acTapped(_ sender: Any) {
        reset()
    }
    
    @IBAction func signPlusTepped(_ sender: Any) {
        valueSign = 1
        changePaymentSign()
        saveButton(enabled: true)
    }
    
    @IBAction func signMinusTepped(_ sender: Any) {
        valueSign = -1
        changePaymentSign()
        saveButton(enabled: true)
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
        saveButton(enabled: true)
        displayValue()
    }
    
    func displayValue() {
        var sign = ""
        if valueSign > 0 {
            sign = "+"
        } else if valueSign < 0 {
            sign = "-"
        }
        if valueTotal == 0 {
            sign = ""
        }
        valueLabel.text = sign + valueTotal.display(fraction: decimalDigits)
    }
    
    // MARK: - Dates processor
    @IBAction func dateBtnAction(_ sender: UIButton) {
        let buttonColor = UIColor(named: "mainColor")
        for button in dates {
            if #available(iOS 13.0, *) {
                button.backgroundColor = .systemBackground
            } else {
                button.backgroundColor = .white
            }
            button.setTitleColor(UIColor(named: "dateFontColor"), for: .normal)
        }
        sender.backgroundColor = buttonColor
        sender.setTitleColor(.white, for: .normal)
        
        periodicDay = sender.tag - 30
        displayDate()
        saveButton(enabled: true)
    }
    
    @objc func onDateChanged() {
        // format date
        selectedDate = oneDatePicker.date
        displayDate()
        saveButton(enabled: true)
    }
    
    private func displayDate() {
        dateTextLabel.textColor = UIColor(named: "dateFontColor")
        if self.item?.interval == 30 {
            let dateTextPrefix = NSLocalizedString("monthly", comment: "")
            let dateTextSuffix = NSLocalizedString("day_of_month", comment: "")
            let dateTextLastDaySuffix = NSLocalizedString("last_day_of_month", comment: "")
            
            if periodicDay > 0 && periodicDay < 28 {
                dateTextLabel.text = dateTextPrefix + "\(periodicDay)" + dateTextSuffix
            } else if periodicDay >= 28 {
                dateTextLabel.text = dateTextPrefix + dateTextLastDaySuffix
            } else { // day == 0
                dateTextLabel.text = NSLocalizedString("no_date", comment: "")
            }

        } else { // single payment
            let dateTextPrefix = NSLocalizedString("just_once", comment: "")
            dateTextLabel.text = dateTextPrefix + selectedDate.toShortString
        }
    }
    
    
    private func showDigitKeyboard() {
        hideCurrentKeyboard (sender: .value) {
            // Показываю цифровую клавиатуру
            self.numbersKeysBottom.constant = self.showingConstant
            self.currentFocus = .value
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
        
    private func showDateKeyboard() {
        if self.item?.interval == 30 {
            hideCurrentKeyboard (sender: .periodic) {
                // В зависимости от типа показываю соответсвующую клавиатуру
                self.datesKeysBottom.constant = self.showingConstant
                self.currentFocus = .periodic
                UIView.animate(withDuration: 0.4) {
                    self.view.layoutIfNeeded()
                }
            }
        } else {
            hideCurrentKeyboard (sender: .single) {
                self.oneDateBottom.constant = self.showingConstant
                self.currentFocus = .single
                UIView.animate(withDuration: 0.4) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }

    
    
    
    private func hideCurrentKeyboard(sender: Focused, completed: @escaping ()->()) {
//        print("hide curr keyboard, \(currentFocus)")
        // Убираю текущую клавиатуру
        switch currentFocus {
        case .value:
            if sender != .value {
                numbersKeysBottom.constant = digitsKeyboardConstant
            }
        case .text:
            nameTextField.resignFirstResponder()
            if sender == .value {
                numbersKeysBottom.constant = showingConstant
                
            } else if sender == .periodic {
                datesKeysBottom.constant = showingConstant
            } else if sender == .single {
                oneDateBottom.constant = showingConstant
            } else if sender == .text {
                oneDateBottom.constant = datesKeyboardConstant
            }
            
        case .periodic:
            datesKeysBottom.constant = datesKeyboardConstant
        case .single:
            oneDateBottom.constant = datesKeyboardConstant
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        }) {_ in
            completed()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func saveButton(enabled: Bool) {
//        let titleTextAbsend = nameTextField.text?.isEmpty ?? false
        var dateSet =  false
        if self.item?.interval == 30 && periodicDay > 0 {
            dateSet = true
        } else if self.item?.interval == 1 {
            dateSet = true
        }
        var canSave = false
        
        canSave = valueTotal != 0 && dateSet && enabled
        saveButton.isEnabled = canSave
    }
    
        private func drawDatesButtons() {
            for button in dates {
                button.layer.cornerRadius = 8.0
            }

        }
        
        private func drawButtons(shadowColor: UIColor) {
    //        let radius: CGFloat = 2
            
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
            
            signPlusKey.layer.shadowOffset = CGSize(width: 0, height: 0.4)
            signPlusKey.layer.shadowRadius = 2
            signPlusKey.layer.shadowOpacity = 0.5
            signPlusKey.layer.masksToBounds = false

            signMinusKey.layer.shadowOffset = CGSize(width: 0, height: 0.4)
            signMinusKey.layer.shadowRadius = 2
            signMinusKey.layer.shadowOpacity = 0.5
            signMinusKey.layer.masksToBounds = false

        }

    
    
}
