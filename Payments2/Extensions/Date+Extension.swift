//
//  Date+Extension.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 08.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import Foundation
extension Date {
    var toString: String {
        let dateFormatter = DateFormatter()
        //  dateFormatter.locale = Locale(identifier: "ru")
        //        let sysLocale = NSLocale.current
        //   print("locale: \(sysLocale)")
        
        //        dateFormatter.locale = sysLocale
        //      dateFormatter.dateStyle = .medium
        dateFormatter.dateStyle = .short
        //       dateFormatter.setLocalizedDateFormatFromTemplate("dd MMM yy")
        
        return dateFormatter.string(from: self)
    }
    var toShortString: String {
        let dateFormatter = DateFormatter()
//        dateFormatter.setLocalizedDateFormatFromTemplate("EE dd MMMM yy")
        dateFormatter.setLocalizedDateFormatFromTemplate("dd MMMM")
        return dateFormatter.string(from: self)
    }

    var toLongString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("dd MMMM yy")
        return dateFormatter.string(from: self)
    }

    var timeString: String {
        let dateFormatter = DateFormatter()
        //        dateFormatter.setLocalizedDateFormatFromTemplate("EE dd MMMM yy")
        dateFormatter.timeStyle = .short
  //      dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
        return dateFormatter.string(from: self)
    }

    var interval: Double {
//        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
//        let cleanDate = Calendar.current.date(from: components)
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Today.date)!
        let interval = self.timeIntervalSince(startDate) / 24 / 3600
//        let value = cleanDate?.timeIntervalSince(startDate) ?? 0.0
        return interval.rounded()
    }
    
    var firstOfThisMonth: Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        components.day = 1
        // fromDate - дата, у которой 1 число текущего месяца
        return Calendar.current.date(from: components)!
    }
    
    var justDate: Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: components)!
    }
    
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    var yearMonths: Int {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        if let years = components.year {
            if let months = components.month {
                return 12 * years + months
            }
        }
        return 0
    }
    
    var dayFromDate: Int {
        return Calendar.current.component(.day, from: self)
    }

    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    var firstDayOfTheMonth: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
    }
    
}
