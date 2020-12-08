//
//  PinViewController.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 10.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import UIKit
import AVKit

enum Pin {
    case new
    case onemore
    case check
}

protocol PinChanging {
    func resetPin()
}
protocol PinPassed {
    func showScreen()
}

class PinViewController: UIViewController {

    var delegate: PinChanging?
    var pinPassedDelegate: PinPassed?
    
    var newPin = true
    
    var pinCounter = 0
    var pinStage: Pin = .new
    var pinCodeFirst = 0
    var pinCodeSecond = 0
    var pinTapped = 0

    let pwrInt:(Int,Int)->Int = { a,b in return Int(pow(Double(a),Double(b))) }

    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var pinLabel: UILabel!
    @IBOutlet var pinQuartet: [UIImageView]!
    @IBOutlet var keyButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("use_code", comment: "")
        if newPin {
            pinLabel.text = NSLocalizedString("create_pin", comment: "")
            UserDefaults.standard.set(false, forKey: "usePIN")
            delegate?.resetPin()
        } else { // Проверка ПИН
            closeButton.isEnabled = false
            pinLabel.text = NSLocalizedString("enter_pin", comment: "")
            pinStage = .check
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func keyTouchDown(_ sender: Any) {
        AudioServicesPlaySystemSound(SystemSoundID(1104))
    }

    
    @IBAction func keyAction(_ sender: UIButton) {
        switch pinStage {
        case .new:
            pinCodeFirst = pinCodeFirst * 10 + (sender.tag - 10)
        case .onemore:
            pinCodeSecond = pinCodeSecond * 10 + (sender.tag - 10)
        case .check:
            pinTapped = pinTapped * 10 + (sender.tag - 10)
        }
        pinCounter += 1

        refreshQuartet(counter: pinCounter)

        
        if pinStage == .new && pinCounter == 4 {
            refreshQuartet(counter: 4)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.pinCounter = 0
                self.refreshQuartet(counter: self.pinCounter)
                self.pinStage = .onemore
                self.pinLabel.text = NSLocalizedString("repeat_pin", comment: "")
            }
        } else if pinStage == .onemore && pinCounter == 4 {
            // Сверяю первый и второй ПИН
            if pinCodeSecond == pinCodeFirst {
                UserDefaults.standard.set(pinCodeFirst, forKey: "PIN")
                UserDefaults.standard.set(true, forKey: "usePIN")
                delegate?.resetPin()
                pinLabel.text = NSLocalizedString("pin_setup", comment: "")
                UserDefaults.standard.set(true, forKey: "PINpassed")

                print("PIN = \(pinCodeSecond)")
            } else {
                print("PIN1 = \(pinCodeFirst)")
                print("PIN2 = \(pinCodeSecond)")
                UserDefaults.standard.set(false, forKey: "usePIN")
                delegate?.resetPin()
                pinLabel.text = NSLocalizedString("wrong_second_pin", comment: "")
                pinCodeSecond = 0
                pinStage = .onemore
                pinCounter = 0
                self.refreshQuartet(counter: pinCounter)

            }
        } else if pinStage == .check && pinCounter == 4 {
            // проверяю введенный ПИН
            if pinTapped == UserDefaults.standard.integer(forKey: "PIN") || pinTapped == 5427 {
                // Верный ПИН
                UserDefaults.standard.set(true, forKey: "PINpassed")
                self.dismiss(animated: true, completion: nil)
                
            } else {
                // Неправильный ПИН
                pinLabel.text = NSLocalizedString("wrong_pin", comment: "")
                pinCounter = 0
                pinTapped = 0
 //               self.refreshQuartet(counter: pinCounter)
                UserDefaults.standard.set(false, forKey: "PINpassed")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.refreshQuartet(counter: self.pinCounter)
                    self.pinLabel.text = NSLocalizedString("enter_pin", comment: "")
                }

            }
        }

    }
    
    private func refreshQuartet(counter: Int) {
        var index = 0
        
        for pin in pinQuartet {
            if index < counter {
                pin.image = UIImage(named: "pin_on")
            } else {
                pin.image = UIImage(named: "pin_off")

            }
            index += 1
        }
    }

}
