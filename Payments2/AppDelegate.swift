//
//  AppDelegate.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 08.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if !UserDefaults.standard.bool(forKey: "HasLaunchedOnce") {
            print("Launched first time")
            UserDefaults.standard.set(true, forKey: "VeryFirstTime")
            UserDefaults.standard.set(false, forKey: "usePIN")
            UserDefaults.standard.set(true, forKey: "PINpassed")
            UserDefaults.standard.set(false, forKey: "HideChecked")
            UserDefaults.standard.set(false, forKey: "ShowPenny")
            UserDefaults.standard.set(true, forKey: "CountOnlyMonth")
            UserDefaults.standard.set(true, forKey: "CountToday")
            UserDefaults.standard.set(true, forKey: "CountDebts")
            UserDefaults.standard.set(DataManager.isICloudContainerAvailable(), forKey: "AutomaticSync")
            UserDefaults.standard.set(Today.date.yearMonths, forKey: "CurrentPeriodId")
            var components = Calendar.current.dateComponents([.hour, .minute], from: Date())
            components.hour = 11
            components.minute = 00
            // fromDate - дата, у которой 1 число текущего месяца
            UserDefaults.standard.set(Calendar.current.date(from: components), forKey: "RemindTime")
            //
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if granted {
                    print("Authorization granted!")
                } else {
                    print("Authorization not granted!")
                }
            }
            UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
            UserDefaults.standard.set(true, forKey: "HasConvertedFrom3")

        } else {
            // Restore data from old archive
            if !UserDefaults.standard.bool(forKey: "HasConvertedFrom3") {
                print("Try to convert from old data")
                DataManager.convertItemsToPayments()
            }
        }
        
        UserDefaults.standard.set(false, forKey: "WasChanges")
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        if UserDefaults.standard.bool(forKey: "WasChanges") && UserDefaults.standard.bool(forKey: "AutomaticSync"){
            DataManager.saveToCloud {
                print("Success saved in iCloud")
            }
        }

        if UserDefaults.standard.bool(forKey: "usePIN") {
            UserDefaults.standard.set(false, forKey: "PINpassed")
            let notificationHide = Notification(name: Notification.Name(rawValue: "HIDE_VIEW"))
            NotificationCenter.default.post(notificationHide)
        } else {
            UserDefaults.standard.set(true, forKey: "PINpassed")
        }
        
        // Получаю циферку на бейджик
        UIApplication.shared.applicationIconBadgeNumber = UserDefaults.standard.integer(forKey: "Overdued")
        
        // Create the notification for upcoming fire date
        scheduleLocalNotification(seconds: fireDate())

    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        // Получаю циферку на бейджик
        UIApplication.shared.applicationIconBadgeNumber = 0

        // Reload data
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "RELOAD_DATA")))
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UserDefaults.standard.set(false, forKey: "WasChanges")
        
    }

    private func fireDate() -> Double {
        var secondsBetween = 0.0
        var allItems = [Payment]()
        
        if let currentPayments = DataManager.getPayments() {
            allItems = currentPayments
        }
        
        let items = allItems.sorted(by: { $0.date < $1.date })
        
        if items.count > 0 {
            let firstPaymentWithFireDate = items.first { (payment) -> Bool in
                !payment.checked && payment.date.justDate >= Today.date.justDate
            }
            if firstPaymentWithFireDate != nil {
                secondsBetween = realFireTime(fireDate: (firstPaymentWithFireDate?.date)!).timeIntervalSince(Today.date)
            } else { // Если в этом периоде нет уже платежей, берем следующий период
                // Собираю вместе все платежи по всем планам на следующий месяц
//                var allNextItems = [Payment]()
//                for plan in plans {
//                    allNextItems.append(contentsOf: plan.periods[nextIndex].items)
//                }
//
//                let nextItems = allNextItems.sorted(by: { $0.date < $1.date })
//                let firstPaymentWithFireDate = nextItems.first { (payment) -> Bool in
//                    !payment.checked && payment.date > Today.date
//                }
//                if firstPaymentWithFireDate != nil {
//                    secondsBetween = realFireTime(fireDate: (firstPaymentWithFireDate?.date)!).timeIntervalSince(Today.date)
//                }
            }
            //                print("Hours to alarm: \(secondsBetween / 3600)")
            //                print("seconds rounded: \(secondsBetween.rounded())")
        }
        //        }
        return 60.0 * (secondsBetween / 60.0).rounded()
    }
    
    private func realFireTime(fireDate: Date) -> Date {
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: fireDate)
        if let fireTime = UserDefaults.standard.object(forKey: "RemindTime") as? Date {
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: fireTime)
            dateComponents.hour = timeComponents.hour
            dateComponents.minute = timeComponents.minute
            
        } else {
            dateComponents.hour = 11
            dateComponents.minute = 00
        }
        let fireDt = Calendar.current.date(from: dateComponents)!
        print("FireDate: \(fireDt)")
        return fireDt
    }
    
    func scheduleLocalNotification(seconds: Double) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification_title", comment: "")
        content.body = NSLocalizedString("notification_message", comment: "")
        content.sound = UNNotificationSound.default
        //        content.badge = badgeNumber as NSNumber
        //        content.categoryIdentifier = "id"
        //        content.userInfo = ["key": "value"]
        if seconds > 0.00 {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
            
            print("set trigger for seconds: \(seconds)")
        }
        
    }

/*
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

*/
}

