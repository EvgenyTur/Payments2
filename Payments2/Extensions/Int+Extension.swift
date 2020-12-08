//
//  Int+Extension.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 09.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import Foundation
extension Int {
    var monthName: String {
        var components = Calendar.current.dateComponents([.month,], from: Today.date)
        components.month = self
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM")
        return dateFormatter.string(from: Calendar.current.date(from: components)!)
    }

    var monthDate: Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Today.date)
        components.month = self
        return Calendar.current.date(from: components)!
    }
        

}
