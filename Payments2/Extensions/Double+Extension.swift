//
//  Double+Extension.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 09.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import Foundation
extension Double {
    var toDecimal: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let nsSelf = NSNumber(value: self)
        return numberFormatter.string(from: nsSelf) ?? "--"
    }
    var toCurrency: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        let nsSelf = NSNumber(value: self)
        return numberFormatter.string(from: nsSelf) ?? "--"
    }
    func display(fraction: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = UserDefaults.standard.bool(forKey: "ShowPenny") ? fraction : 0
        let nsSelf = NSNumber(value: self)
        
        return numberFormatter.string(from: nsSelf)!
        
    }
    var toDisplay: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.decimalSeparator = ","
        numberFormatter.minimumFractionDigits = 1
        let nsSelf = NSNumber(value: self)
        return numberFormatter.string(from: nsSelf) ?? "--"
    }
    
    var toChart: String {
        var short = self
        var symbol = ""
        if self / 1000000 > 1 || self / 1000000 < -1 {
            symbol = "M"
            short = self / 1000000
        } else if self / 1000 > 1 || self / 1000 < -1 {
            symbol = "K"
            short = self / 1000
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        let nsSelf = NSNumber(value: short)
        var chartNumber = numberFormatter.string(from: nsSelf)! + symbol
        if self == 0.00 {
            chartNumber = ""
        }
        return chartNumber
    }
}
