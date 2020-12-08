//
//  DataManager.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 08.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import Foundation

//class PPItem: NSObject  {
//    var itemName: NSString = ""
//    var itemSign: NSNumber = 0
//    var itemChecked: NSNumber = 0
//    var monthsPeriod: NSNumber = 0
//    var itemValue: Double = 0.0
//    var repeatInterval: NSInteger = 0
//    var paymentDate: NSDate = NSDate()
//    var realPaymentDate: NSDate = NSDate()
//    
//}

public class DataManager {
    
    // get document directory
    static fileprivate func getDocumentDirectory() -> URL {
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Unable to get file directory")
        }
    }

    static let dataFilePath = getDocumentDirectory().appendingPathComponent("Payments.plist")

//    static let oldArchiveFilePath = getDocumentDirectory().appendingPathComponent("items.archive")
//
//    static let archivePathName = getDocumentDirectory().appendingPathComponent("items.archive").relativeString

    static func itemArchivePath () -> String {
        let docDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docDirectory = docDirectories[0]
        return docDirectory.appending("/items.archive")
    }

    static func getArchive() -> [OldPayment]? {
        var items = [OldPayment]()
        let arcPath = itemArchivePath()

//        print(arcPath)
        
        let data = try? Data(contentsOf: URL(fileURLWithPath: arcPath))
        
        if let archive = data {
            //            print("Got items \(archive.debugDescription)")
            //            let oldItems: [PPItem] = NSKeyedUnarchiver.unarchiveObject(with: archive) as! [PPItem]
            
            if let oldItems = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archive) as? [PPItem] {
                for item in oldItems {
                    let itemSignInt = item.itemSign.intValue
                    print("sign = \(itemSignInt) sum = \(item.itemValue)")
                    let itemSign = itemSignInt == 1 ? 1 : 0
                    let newItem = OldPayment(itemName: item.itemName, itemSign: itemSign, itemChecked: item.itemChecked.boolValue, monthsPeriod: item.monthsPeriod.intValue, itemValue: item.itemValue, repeatInterval: item.repeatInterval, paymentDate: item.paymentDate, realPaymentDate: item.realPaymentDate)
                    
                    print("\(newItem.itemName)  sum: \(newItem.itemValue) interval: \(newItem.monthsPeriod)  period: \(newItem.repeatInterval) date: \(newItem.paymentDate.toShortString)")
                    items.append(newItem)
                }
                
            } else {
                print("Error getting old archive....")
            }
            //            }
            
            
            //            let oldItems = NSKeyedUnarchiver.unarchiveObject(withFile: arcPath) as! [PPItem]
            //            print(oldItems)
        }
        
        print("found and restored: \(items.count)")

        
        
//        items = NSKeyedUnarchiver.unarchiveObject(withFile: oldArchiveFilePath.absoluteString) as? [OldPayment] ?? [OldPayment]()

//        if let data = try? Data(contentsOf: oldArchiveFilePath) {
//            do {
////                items = try NSKeyedUnarchiver(forReadingFrom: data)
//                let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
//
//
//                items = NSKeyedUnarchiver.unarchiveObject(withFile: oldArchiveFilePath.absoluteString) as! [OldPayment]
//            } catch {
//                print("Error unarchivation \(error.localizedDescription)")
//            }
//        }
        
        return items
    }
    
    static func convertItemsToPayments() {
        let period = UserDefaults.standard.integer(forKey: "currentPeriod")
        print("was current period: \(period)")
        
        var components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        components.hour = UserDefaults.standard.integer(forKey: "fireHour")
        components.minute = UserDefaults.standard.integer(forKey: "fireMinute")
        let reminder = Calendar.current.date(from: components)
//        print("remind time: \(components.hour):\(components.minute)")
        // fromDate - дата, у которой 1 число текущего месяца
        UserDefaults.standard.set(reminder, forKey: "RemindTime")

        if UserDefaults.standard.bool(forKey: "usePIN") {
            let pin = UserDefaults.standard.integer(forKey: "currentPIN")
//            print("was pin: \(pin)")
            UserDefaults.standard.set(pin, forKey: "PIN")
        } else {
            print("was no pin..")

        }
        
        
        if let itemsArchive = getArchive() {
            var payments = [Payment]()

            for item in itemsArchive {
                var payment = Payment(withTitle: item.itemName)
                payment.checked = item.itemChecked
                payment.value = item.itemSign == 1 ? item.itemValue : -1 * item.itemValue
                payment.originalValue = payment.value
                payment.day = item.paymentDate.dayFromDate 
                
                if item.repeatInterval == 1 {
                    payment.interval = 1
                } else if item.repeatInterval == 30 {
                    payment.interval = 30
                }
                payment.date = item.paymentDate.justDate
                payment.realDate = item.realPaymentDate
                print("newPayment:")
                print(payment)
                payments.append(payment)
            }
            
            savePayments(payments: payments)
            UserDefaults.standard.set(Today.date.yearMonths, forKey: "CurrentPeriodId")
            UserDefaults.standard.set(true, forKey: "HasConvertedFrom3")

        } else {
            print("ERROR: can't restore from items archive")
        }
    }
    
    
    static func getPayments() -> [Payment]? {
//        print("get payments")
        var payments = [Payment]()
        if let data = try? Data(contentsOf: dataFilePath) {
            let decoder = PropertyListDecoder()
            do {
                payments = try decoder.decode([Payment].self, from: data)
            } catch {
                print("Error: \(error)")
            }
        }
        return payments
    }
    
    static func deleteAllData() {
        // периоды - месяцы
//        var periods = [Period]()
//        if let currentPeriods = DataManager.getPeriods() {
//            periods = currentPeriods
//        }
//        periods.removeAll()
        // New empty periods
        let emptyPayments = [Payment]()
//        var periodID = Today.date.yearMonths
//        UserDefaults.standard.set(periodID, forKey: "FirstPeriod")
//        var month = 0
//        while month <= 12 {
//            let newPeriod = Period(withId: periodID, items: emptyPayments)
//            periods.append(newPeriod)
//            periodID += 1
//            month += 1
//        }
//        UserDefaults.standard.set(periodID - 1, forKey: "LastPeriod")
        UserDefaults.standard.set(true, forKey: "WasChanges")

        self.savePayments(payments: emptyPayments)
        // Reload data
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "RELOAD_DATA")))

    }
    
    static func resetData() {
        self.deleteAllData()
        UserDefaults.standard.set(true, forKey: "VeryFirstTime")
        UserDefaults.standard.set(false, forKey: "usePIN")
        UserDefaults.standard.set(true, forKey: "PINpassed")
        UserDefaults.standard.set(false, forKey: "HideChecked")
        UserDefaults.standard.set(false, forKey: "ShowPenny")
        UserDefaults.standard.set(true, forKey: "CountToday")
        UserDefaults.standard.set(true, forKey: "CountDebts")
        UserDefaults.standard.set(DataManager.isICloudContainerAvailable(), forKey: "AutomaticSync")
        UserDefaults.standard.set(Today.date.yearMonths, forKey: "CurrentPeriodId")
        var components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        components.hour = 11
        components.minute = 00
        UserDefaults.standard.set(Calendar.current.date(from: components), forKey: "RemindTime")
        UserDefaults.standard.set(true, forKey: "WasChanges")
    }
    
    // Save periods
    static func savePayments(payments: [Payment]) {
//        print("Saved. Total payments: \(payments.count)")
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(payments)
            try data.write(to: dataFilePath)
            UserDefaults.standard.set(true, forKey: "WasChanges")
        } catch {
            print("Error \(error)")
        }
        
        // Сохраняю циферку на бейджик
        UserDefaults.standard.set(overduedCount(items: payments), forKey: "Overdued")
    }
    
    static func isICloudContainerAvailable() -> Bool {
        return !(FileManager.default.ubiquityIdentityToken == nil)
    }
    
    static func saveToCloud(completed: () -> ()) {
        let encoder = PropertyListEncoder()
        let keyStore = NSUbiquitousKeyValueStore()
        let cloudKey = "CloudPayments"
        
        let periods = getPayments()
        
        do {
            let data = try encoder.encode(periods)
            try data.write(to: dataFilePath)
            keyStore.set(data, forKey: cloudKey)
            keyStore.synchronize()
            completed()
        } catch {
            print("Error saving to Cloud \(error)")
        }
    }
    
//    static func saveDefaultsToCloud() {
//        let keyStore = NSUbiquitousKeyValueStore()
//        let cloudKey = "SyncedDefaults"
//
//        let syncedDefaults = ["past" : UserDefaults.standard.integer(forKey: "PastPeriods"),
//                              "future" : UserDefaults.standard.integer(forKey: "FuturePeriods")]
//        keyStore.set(syncedDefaults, forKey: cloudKey)
//        keyStore.synchronize()
//
////        do {
////            let data = try encoder.encode(syncedDefaults)
////            try data.write(to: defaultsFilePath)
////        } catch  {
////            print("Error saving to Cloud \(error)")
////        }
//
//    }
    
//    static func getDefaultsFromCloud() -> [String : Int] {
//        var cloudDefaults = [String : Int]()
//
//        let keyStore = NSUbiquitousKeyValueStore()
//        let cloudKey = "SyncedDefaults"
//
//        cloudDefaults = keyStore.dictionary(forKey: cloudKey) as! [String : Int]
//        keyStore.synchronize()
//
//        return cloudDefaults
//    }
    
    // Восстанавливаю данные из iCloud
    static func updatePaymentsFromCloud(completion: @escaping (Bool) -> ()) {
        var payments = [Payment]()
        let keyStore = NSUbiquitousKeyValueStore()
//        let encoder = PropertyListEncoder()
        let cloudKey = "CloudPayments"
        print("try to load from Cloud...")
        if let data = keyStore.data(forKey: cloudKey) {
            let decoder = PropertyListDecoder()
            do {
                payments = try decoder.decode([Payment].self, from: data)
                print("got \(payments.count) pyments from Cloud")
                if payments.count > 0 {
                    savePayments(payments: payments)
//                    do {
//                        let data = try encoder.encode(payments)
//                        try data.write(to: dataFilePath)
//                    } catch {
//                        print("Error saving after Cloud: \(error)")
//                    }
                }
            } catch {
                print("Error decoding: \(error)")
            }
        } else {
            print("Cloud data not found")
        }
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        print("Start completion")
        
        if payments.count > 0 {
            completion(true)
        } else {
            completion(false)
            
        }
//            }
    }
    
    // Считаю цифру просрочек на бейджик
    static func overduedCount(items: [Payment]) -> Int {
        var overdued = 0
        // Temporary, пока нет в Настройках
        
        let countAlsoToday = UserDefaults.standard.bool(forKey: "CountToday")
//                            print("today date: \(Today.date), interval: \(Today.date.interval)")
        // Считаю все сегодняшние тоже
        if countAlsoToday {
            overdued = items.reduce(0, { (res, iPayment) -> Int in
                if !iPayment.checked && (iPayment.date.interval <= Today.date.justDate.interval) {
//                    print("date: \(iPayment.date), interval: \(iPayment.date.interval)")
                    return res + 1
                }
                return res
            })
        } else {
            overdued = items.reduce(0, { (res, iPayment) -> Int in
                if !iPayment.checked && (iPayment.date.interval < Today.date.justDate.interval) {
//                            print("date: \(iPayment.date), interval: \(iPayment.date.interval)")
                    return res + 1
                }
                return res
            })
        }
        print("over: \(overdued)")
        return overdued
    }

    
}
