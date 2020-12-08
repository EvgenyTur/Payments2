//
//  OldPayment.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 08.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import Foundation
class OldPayment: NSObject  {
    var itemName: String = ""
    var itemSign: Int = 0
    var itemChecked: Bool  = false
    var monthsPeriod: Int = 1
    var itemValue: Double = 0
    var repeatInterval: Int = 30
    var paymentDate: Date = Date()
    var realPaymentDate: Date = Date()
    
    
    init(itemName: String, itemSign: Int, itemChecked: Bool, monthsPeriod: Int, itemValue: Double, repeatInterval: Int, paymentDate: Date, realPaymentDate: Date) {
        self.itemName = itemName
        self.itemSign = itemSign
        self.itemChecked = itemChecked
        self.monthsPeriod = monthsPeriod
        self.itemValue = itemValue
        self.repeatInterval = repeatInterval
        self.paymentDate = paymentDate
        self.realPaymentDate = realPaymentDate
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encode(itemName, forKey: "itemName")
        aCoder.encode(itemSign, forKey: "itemSign")
        aCoder.encode(itemChecked, forKey: "itemChecked")
        aCoder.encode(monthsPeriod, forKey: "monthsPeriod")
        aCoder.encode(itemValue, forKey: "itemValue")
        aCoder.encode(repeatInterval, forKey: "repeatInterval")
        aCoder.encode(paymentDate, forKey: "paymentDate")
        aCoder.encode(realPaymentDate, forKey: "realPaymentDate")
    }
    
    func initWithCoder(aDecoder: NSCoder) -> OldPayment {
        self.itemName = aDecoder.decodeObject(forKey: "itemName") as! String
        self.itemSign = aDecoder.decodeObject(forKey: "itemSign") as! Int
        self.itemChecked = aDecoder.decodeObject(forKey: "itemChecked") as! Bool
        self.monthsPeriod = aDecoder.decodeObject(forKey: "monthsPeriod") as! Int
        self.itemValue = aDecoder.decodeObject(forKey: "itemValue") as! Double
        self.repeatInterval = aDecoder.decodeObject(forKey: "repeatInterval") as! Int
        self.paymentDate = aDecoder.decodeObject(forKey: "paymentDate") as! Date
        self.realPaymentDate = aDecoder.decodeObject(forKey: "realPaymentDate") as! Date
        return self
    }
}

//class PPItem: NSObject  {
//    var itemName: NSString = ""
//    var itemSign: NSNumber = 0
//    var itemChecked: NSNumber = 0
//    var monthsPeriod: NSNumber = 0
//    var itemValue: Double = 0.0
//    var repeatInterval: NSInteger = 0
//    var paymentDate: NSDate = NSDate()
//    var realPaymentDate: NSDate = NSDate()
    
    
//    init(itemName: String, itemSign: Int, itemChecked: Bool, monthsPeriod: Int, itemValue: Double, repeatInterval: Int, paymentDate: Date, realPaymentDate: Date) {
//        self.itemName = ""
//        self.itemSign = 1
//        self.itemChecked = false
//        self.monthsPeriod = monthsPeriod
//        self.itemValue = 0.0
//        self.repeatInterval = repeatInterval
//        self.paymentDate = Today.date
//        self.realPaymentDate = realPaymentDate
//    }
//
//    func encodeWithCoder(aCoder: NSCoder) {
//        aCoder.encode(itemName, forKey: "itemName")
//        aCoder.encode(itemSign, forKey: "itemSign")
//        aCoder.encode(itemChecked, forKey: "itemChecked")
//        aCoder.encode(monthsPeriod, forKey: "monthsPeriod")
//        aCoder.encode(itemValue, forKey: "itemValue")
//        aCoder.encode(repeatInterval, forKey: "repeatInterval")
//        aCoder.encode(paymentDate, forKey: "paymentDate")
//        aCoder.encode(realPaymentDate, forKey: "realPaymentDate")
//    }
    
//    func initWithCoder(aDecoder: NSCoder) -> OldPayment {
//        self.itemName = aDecoder.decodeObject(forKey: "itemName") as! String
//        self.itemSign = aDecoder.decodeObject(forKey: "itemSign") as! Int
//        self.itemChecked = aDecoder.decodeObject(forKey: "itemChecked") as! Bool
//        self.monthsPeriod = aDecoder.decodeObject(forKey: "monthsPeriod") as! Int
//        self.itemValue = aDecoder.decodeObject(forKey: "itemValue") as! Double
//        self.repeatInterval = aDecoder.decodeObject(forKey: "repeatInterval") as! Int
//        self.paymentDate = aDecoder.decodeObject(forKey: "paymentDate") as! Date
//        self.realPaymentDate = aDecoder.decodeObject(forKey: "realPaymentDate") as! Date
//        return self
//    }
//}
