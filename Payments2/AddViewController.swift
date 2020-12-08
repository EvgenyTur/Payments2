//
//  AddViewController.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 09.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import UIKit
import AVKit

protocol DataDelegate {
    func saveChanges(item: Payment, new: Bool)
}

class SumLabel: UILabel {
    override func drawText(in rect: CGRect) {
        let newRect = rect.offsetBy(dx: -10, dy: 0) // move text 10 points to the right
        super.drawText(in: newRect)
    }
}

class AddViewController: UIViewController, UITextFieldDelegate, SetPeriodicDateDelegate {
    
    @IBOutlet weak var saveButton: UIButton!
    //    @IBOutlet weak var signView: UIImageView!
    
    @IBOutlet weak var paymentSegmentControl: UISegmentedControl!
    //    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var valueLabel: SumLabel!
    @IBOutlet weak var lockKeys: UIImageView!
    
    //    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            let rightView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 46.0))
            nameTextField.rightView = rightView
            nameTextField.rightViewMode = .always
        }
    }
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateTextLabel: UILabel!
    
    @IBOutlet weak var periodSegmentControl: UISegmentedControl!
    @IBOutlet weak var keysView: UIView!
    
    @IBOutlet var digits: [UIButton]!
    @IBOutlet weak var commaKey: UIButton!
    @IBOutlet weak var acKey: UIButton!
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
    //    var currentPeriod: Int = Today.date.yearMonths
    var currentPeriod: Int?
    // Это сдвиг периодов относительно текущего Июль - Май = 2
    var dateShift: Int = 0
    var item: Payment?
    
    var isNew = true
    
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
    
    
    //  MARK: - View Lifecircle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("to_add", comment: "")
        dateTextLabel.text = NSLocalizedString("no_date", comment: "")
        //        numbersHintLabel.text = NSLocalizedString("numbers_hint", comment: "")
        //        datesHintLabel.text = NSLocalizedString("dates_hint", comment: "")
        //        oneDateHintLabel.text = NSLocalizedString("one_date_hint", comment: "")
        
        incomeColor = UIColor(named: "positiveColor")
        outcomeColor = UIColor(named: "negativeColor")
        
        //        if #available(iOS 13.0, *) {
        //            signView.tintColor = .systemBackground
        //        } else {
        //            signView.tintColor = .white
        //        }
        saveButton.setTitle(NSLocalizedString("save_button", comment: ""), for: .normal)
        saveButton.isEnabled = false
        drawDatesButtons()
        paymentSegmentControl.setTitle(NSLocalizedString("income", comment: ""), forSegmentAt: 0)
        paymentSegmentControl.setTitle(NSLocalizedString("expense", comment: ""), forSegmentAt: 1)
        
        paymentSegmentControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "CurrentPaymentType")

        
//        let segActiveAttributes: NSDictionary = [
//            NSAttributedString.Key.foregroundColor: UIColor.white,
//        ]
//        let segPassiveAttributes: NSDictionary = [
//            NSAttributedString.Key.foregroundColor: UIColor.blue,
//        ]
        
        //        paymentSegmentControl.setTitleTextAttributes(segActiveAttributes as? [NSAttributedString.Key : Any], for: UIControl.State.selected)
        //        paymentSegmentControl.setTitleTextAttributes(segPassiveAttributes as? [NSAttributedString.Key : Any], for: .normal)
        
        periodSegmentControl.setTitle(NSLocalizedString("regular", comment: ""), forSegmentAt: 0)
        periodSegmentControl.setTitle(NSLocalizedString("single", comment: "").localizedCapitalized, forSegmentAt: 1)
        
//        periodSegmentControl.setTitleTextAttributes(segActiveAttributes as? [NSAttributedString.Key : Any], for: UIControl.State.selected)
//        periodSegmentControl.setTitleTextAttributes(segPassiveAttributes as? [NSAttributedString.Key : Any], for: .normal)
        
        //        sumLabel.text = NSLocalizedString("sum", comment: "")
        dateLabel.text = NSLocalizedString("payment_date", comment: "")
        
        nameTextField.delegate = self
        numbersKeysBottom.constant = digitsKeyboardConstant
        datesKeysBottom.constant = datesKeyboardConstant
        oneDateBottom.constant = datesKeyboardConstant
        
        
        nameTextField.placeholder = NSLocalizedString("entername", comment: "")
        
        if isNew {
            selectedDate = Today.date
            reset()
            
        } else {
            getExistData()
        }
        
//        dateShift = currentPeriod! - Today.date.yearMonths
        
        
        // Create Picker
        oneDatePicker.datePickerMode = .date
        let monthNumber = month(fromPeriodId: currentPeriod!)
        let yearNumber = (currentPeriod! - monthNumber ) / 12
        
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Today.date)
        components.month = monthNumber
        components.year = yearNumber
//        let thisMonthDate = Calendar.current.date(from: components)!
//        
//        oneDatePicker.minimumDate = thisMonthDate.startOfMonth()
//        oneDatePicker.maximumDate = thisMonthDate.endOfMonth()
        oneDatePicker.addTarget(self, action: #selector(onDateChanged), for: UIControl.Event.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isNew {
            setupPaymentType()
        } else {
            if valueSign > 0 {
                showColors(tintColor: incomeColor ?? .label)
            } else {
                showColors(tintColor: outcomeColor ?? .label)
            }
        }
        
        displayValue()
    }
    
    private func getExistData() {
        nameTextField.text = item?.title
        if let existDate = item?.date {
            selectedDate = existDate
        }
//        print("VAlue:  \(item?.value)")
        if let realValue = item?.value {
            if realValue > 0 {
                valueTotal = realValue
                valueSign = 1.0
                
                           print(" Dohod!")
            } else {
                valueTotal = fabs(realValue)
                valueSign = -1.0
                
                            print("Rashod")
            }
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

        
    }
    
    //    override func viewDidAppear(_ animated: Bool) {
    //        let keysColor = UserDefaults.standard.integer(forKey: "CurrentPaymentType") == 0 ? incomeColor : outcomeColor
    //        showDigitKeyboard(color: keysColor!)
    //    }
    
    //  MARK: - Actions
    @IBAction func paymentTypeAction(_ sender: UISegmentedControl) {
        valueSign = -1 * valueSign
        changePaymentSign()

//        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "CurrentPaymentType")
//        //     setupPaymentType()
//        if sender.selectedSegmentIndex == 0 {
//            valueSign = 1.0
//            //            signView.image = UIImage(named: "plus")
//            valueLabel.textColor = incomeColor
//            drawButtons(shadowColor: incomeColor ?? .black)
//
//            //            keysView.backgroundColor = incomeColor
//            nameTextField.placeholder = NSLocalizedString("title_from", comment: "name label")
//        } else {
//            valueSign = -1.0
//            //            signView.image = UIImage(named: "minus")
//            valueLabel.textColor = outcomeColor
//            drawButtons(shadowColor: outcomeColor ?? .black)
//
//            //            keysView.backgroundColor = outcomeColor
//            nameTextField.placeholder = NSLocalizedString("title_to", comment: "name label")
//        }
//        displayValue()
    }
    
    private func changePaymentSign() {
        paymentType = valueSign > 0 ? 0 : 1
        UserDefaults.standard.set(paymentType, forKey: "CurrentPaymentType")
        if paymentType == 0 {
            valueSign = 1.0
            showColors(tintColor: incomeColor ?? .label)
            nameTextField.placeholder = NSLocalizedString("title_from", comment: "name label")
        } else {
            valueSign = -1.0
            showColors(tintColor: outcomeColor ?? .label)
            nameTextField.placeholder = NSLocalizedString("title_to", comment: "name label")
        }
        displayValue()
    }
    
    private func showColors(tintColor: UIColor) {
        let titleFont = UIFont.systemFont(ofSize: 18, weight: .bold)
        let titleDict: NSDictionary = [NSAttributedString.Key.foregroundColor: tintColor, NSAttributedString.Key.font : titleFont]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [NSAttributedString.Key : Any]
        
        valueLabel.textColor = tintColor
        drawButtons(shadowColor: tintColor)

    }

    
    @IBAction func titleChanged(_ sender: UITextField) {
        saveButton(enabled: true)
    }
    @IBAction func titleBeginEditAction(_ sender: Any) {
        print("edit detected")
        hideCurrentKeyboard (sender: .text) {
            self.currentFocus = .text
        }
    }
    
    //    @IBAction func titleTouchAction(_ sender: UITextField) {
    //        print("touch detected")
    //        hideCurrentKeyboard {
    //            self.currentFocus = .text
    //        }
    //    }
    
    private func setupPaymentType() {
        if UserDefaults.standard.integer(forKey: "CurrentPaymentType") == 0 {
            nameTextField.placeholder = NSLocalizedString("title_from", comment: "name label")
            //            paymentSegmentControl.selectedSegmentIndex = 0
            valueSign = 1.0
            showColors(tintColor: incomeColor ?? .label)
        } else {
            nameTextField.placeholder = NSLocalizedString("title_to", comment: "name label")
            //            paymentSegmentControl.selectedSegmentIndex = 1
            valueSign = -1.0
            showColors(tintColor: outcomeColor ?? .label)
        }
    }
    
    
    @IBAction func valueBtnAction(_ sender: Any) {
        let keysColor = UserDefaults.standard.integer(forKey: "CurrentPaymentType") == 0 ? incomeColor : outcomeColor
        reset()
        showDigitKeyboard(color: keysColor!)
    }
    
    @IBAction func dateButtonAction(_ sender: Any) {
        if !((periodSegmentControl.selectedSegmentIndex == 0 && currentFocus == .periodic) || (periodSegmentControl.selectedSegmentIndex == 1 && currentFocus == .single)) {
            // Periodic payment
//            performSegue(withIdentifier: "ShowPeriodics", sender: self)
            showDateKeyboard()
        }
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Save
    @IBAction func saveBtnAction(_ sender: Any) {
        valueTotal = valueSign * (100 * valueTotal).rounded() / 100
        let intervalIndex = periodSegmentControl.selectedSegmentIndex
        var item = Payment(withTitle: nameTextField.text!)
        item.value = valueTotal
        item.originalValue = valueTotal
        item.title = nameTextField.text ?? ".."
        item.day = periodicDay
        if intervalIndex == 0 {
            item.interval = 30
            item.date = dateFromDay(day: item.day)
            
            print("date: \(item.date)")
            print("day: \(item.day)")
            
        } else {
            // Single day
            item.interval = 1
            item.date = selectedDate.justDate
            print("date: \(item.date)")
            print("day: \(item.day)")

        }
        item.realDate = Today.date
        delegate?.saveChanges(item: item, new: true)
        
        UserDefaults.standard.set(true, forKey: "WasChanges")
        self.dismiss(animated: true, completion: nil)
        
    }
    
    private func dateFromDay(day: Int) -> Date {
        var dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: Today.date)
        dateComponents.day = day
        let someDate = Calendar.current.date(from: dateComponents)!
        return Calendar.current.date(byAdding: .month, value: dateShift, to: someDate)!
    }
    
    @IBAction func periodSegmentAction(_ sender: Any) {
        // Показываю выбранную дату на label
        displayDate()
        showDateKeyboard()
        saveButton(enabled: true)
    }
    
    // MARK: - Private functions
    private func month(fromPeriodId period: Int) -> Int {
        var currentYear = period / 12
        if period % 12 == 0 {
            currentYear -= 1
        }
        return period  - 12 * currentYear
    }
    
    
    // MARK: - Delegate functions
    func setPeriodicDate(period: Int, day: Int) {
        print("period: \(period) day: \(day)")
        
        var dateTextPrefix = ""
        switch period {
        case 30:
            dateTextPrefix = NSLocalizedString("monthly", comment: "")
        case 91...92:
            dateTextPrefix = NSLocalizedString("quartely", comment: "")
        case 360:
            dateTextPrefix = NSLocalizedString("annually", comment: "")
            
        default:
            print("wrong case")
        }
        let dateTextSuffix = NSLocalizedString("day_of_month", comment: "")
        let dateTextLastDaySuffix = NSLocalizedString("last_day_of_month", comment: "")
        
        if day > 0 && day < 28 {
            dateTextLabel.text = dateTextPrefix + "\(day)" + dateTextSuffix
        } else if day >= 28 {
            dateTextLabel.text = dateTextPrefix + dateTextLastDaySuffix
        } else { // day == 0
            dateTextLabel.text = NSLocalizedString("no_date", comment: "")
        }
        
//        hideCurrentKeyboard(sender: .single) {
            
//        }
        
        periodicDay = day
        saveButton(enabled: true)
        
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
        displayValue()
        saveButton(enabled: true)
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
        paymentSegmentControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "CurrentPaymentType")
    }
    
    @IBAction func signMinusTepped(_ sender: Any) {
        valueSign = -1
        changePaymentSign()
        paymentSegmentControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "CurrentPaymentType")
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
        for button in dates {
            button.backgroundColor = .systemBackground
            button.setTitleColor(UIColor(named: "dateFontColor"), for: .normal)
        }
//        if #available(iOS 13.0, *) {
//            for button in dates {
//                button.backgroundColor = .systemBackground
//                button.setTitleColor(UIColor(named: "dateFontColor"), for: .normal)
//            }
//        } else {
//            for button in dates {
//                button.backgroundColor = .white
//                button.setTitleColor(UIColor(named: "dateFontColor"), for: .normal)
//            }
//        }
//
        sender.backgroundColor = UIColor(named: "choosenBackColor")
        sender.setTitleColor(UIColor(named: "choosenInkColor"), for: .normal)
        
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
//        dateTextLabel.textColor = UIColor(named: "dateFontColor")
        if periodSegmentControl.selectedSegmentIndex == 0 {
            // Пишу значение выбранной даты
            setPeriodicDate(period: 30, day: periodicDay)
            
        } else { // single payment
            let dateTextPrefix = NSLocalizedString("just_once", comment: "")
            dateTextLabel.text = dateTextPrefix + selectedDate.toShortString
        }
    }
    
    
    private func showDigitKeyboard(color: UIColor) {
        hideCurrentKeyboard (sender: .value) {
            print("Show digits")
            // Показываю цифровую клавиатуру
            self.numbersKeysBottom.constant = self.showingConstant
            self.currentFocus = .value
            self.valueLabel.textColor = color
            
            UIView.animate(withDuration: 0.4) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func showDateKeyboard() {
        if self.periodSegmentControl.selectedSegmentIndex == 0 {
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
        print("hide curr keyboard, \(currentFocus)")
        // Убираю текущую клавиатуру
        switch currentFocus {
        case .value:
            print("sender: \(sender)")
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
        
        print("animate")
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
//            if finished {
//                print("finish")
//                completed()
//
//            }
            completed()

        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    private func saveButton(enabled: Bool) {
        //        let titleTextAbsend = nameTextField.text?.isEmpty ?? false
        var dateSet =  false
        if periodSegmentControl.selectedSegmentIndex == 0 && periodicDay > 0 {
            dateSet = true
        } else if periodSegmentControl.selectedSegmentIndex == 1 {
            dateSet = true
        }
        let canSave = valueTotal != 0 && dateSet && enabled
        saveButton.isEnabled = canSave
        
        saveButton.backgroundColor = canSave ? UIColor(named: "activeColor") : .gray
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
//        acKey.layer.shadowColor = CGColor(srgbRed: 1, green: 0.624, blue: 0.39, alpha: 1.0)
        acKey.layer.masksToBounds = false
        
        cKey.layer.shadowOffset = CGSize(width: 0, height: 0.2)
        cKey.layer.shadowRadius = 2
        cKey.layer.shadowOpacity = 0.5
//        cKey.layer.shadowColor = CGColor(srgbRed: 1, green: 0.624, blue: 0.39, alpha: 1.0)
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
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPeriodics" {
            let destinationVC = segue.destination as! PeriodicsViewController
            destinationVC.delegate = self
        }
    }
    
}
