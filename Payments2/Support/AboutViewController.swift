//
//  AboutViewController.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 10.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import UIKit
import MessageUI
import StoreKit

class AboutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, SKStoreProductViewControllerDelegate {
    
    // Payments app
    let appId = "820210381"

    var itemLabels = [String]()
    var itemIcons = [UIImage]()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("about_app", comment: "")
        titleLabel.text = NSLocalizedString("main_title", comment: "")
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
        let build = Bundle.main.infoDictionary!["CFBundleVersion"]!
        versionLabel.text = "v.\(version) (\(build))"
        itemLabels.append(NSLocalizedString("show_AppStore", comment: ""))
        itemLabels.append(NSLocalizedString("rate_app", comment: ""))
        itemLabels.append(NSLocalizedString("emailtodev", comment: ""))
        itemLabels.append(NSLocalizedString("other_apps", comment: ""))
        
        itemIcons.append(UIImage(named: "ico_appstore")!)
        itemIcons.append(UIImage(named: "ico_star")!)
        itemIcons.append(UIImage(named: "ico_mail")!)
        itemIcons.append(UIImage(named: "ico_apps")!)
        activityIndicator.isHidden = true

        
        let components = Calendar.current.dateComponents([.year], from: Date())
        if let currentYear = components.year {
            copyrightLabel.text = "© 2012 - \(currentYear) Avencode LLC"
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemLabels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AboutTableViewCell
        cell.titleImage.image = itemIcons[indexPath.row]
        cell.label.text = itemLabels[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            showAppInAppstore()
        case 1:
            rateApp()
        case 2:
            mailToDev()
        case 3:
            gotoOtherApps()
        default:
            print("Wrong item")
        }
    }

    func mailToDev() {
        if MFMailComposeViewController.canSendMail() {
            present(createMailComposeViewController(), animated: true, completion: nil)
        } else { // can't send email
            let noMailMessage = NSLocalizedString("no_mail", comment: "")
            let doneTitle = NSLocalizedString("done_title", comment: "")
            
            let alertController = UIAlertController(title: nil, message: noMailMessage, preferredStyle: UIAlertController.Style.alert)
            
            let cancelAction = UIAlertAction(title: doneTitle, style: UIAlertAction.Style.default, handler: nil)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    func createMailComposeViewController() -> MFMailComposeViewController {
        let appName = NSLocalizedString("main_title", comment: "")
        let mailSubject = appName + " " + versionLabel.text!
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setToRecipients(["avencode@gmail.com"])
        mailComposer.setSubject(mailSubject)
        let currentLocale: String = NSLocale.current.description
        if !currentLocale.contains("ru") {
            mailComposer.setMessageBody("Please note that our support team will better understand your message in English.\n", isHTML: false)
        }
        return mailComposer
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    private func showAppInAppstore() {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id" + appId),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
    
    private func gotoOtherApps() {
        if let url = URL(string: "itms-apps://apps.apple.com/developer/evgeny-turchaninov/id517592625"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
    
    func rateApp() {
            SKStoreReviewController.requestReview()        
    }

    // obsolete
    func gotoAppStore() {
//        guard let iTunesLink = URL(string: "https://itunes.apple.com/app/id\(appId)&action=write-review") else { return }
//        UIApplication.shared.open(iTunesLink, options: [:], completionHandler: nil)
//        SKStoreReviewController.requestReview()

//        let urlStr = "https://itunes.apple.com/app/id\(appID)" // (Option 1) Open App Page
        let urlToReview = "itma-apps://itunes.apple.com/ru/app/id\(appId)?mt=8&action=write-review" // (Option 2) Open App Review Page
//        let urlToReview = "itma-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(appId)" // (Option 3) Open App Review Page

        
        guard let url = URL(string: urlToReview), UIApplication.shared.canOpenURL(url) else { return }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
//        guard let iTunesLink:URL = URL(string: "https://itunes.apple.com/app/id"+appId) else {
//            return // be safe
//        }
//        UIApplication.shared.open(iTunesLink, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }

//    private func gotoOtherApps() {
//        if let url = URL(string: "https://appstore.com/evgenyturchaninov"),
//            UIApplication.shared.canOpenURL(url) {
//            if #available(iOS 10.0, *) {
//                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
//            } else {
//                UIApplication.shared.openURL(url)
//            }
//        }
//
//    }

//    func openStoreProductWithiTunesItemIdentifier(identifier: String) {
//        let storeViewController = SKStoreProductViewController()
//        storeViewController.delegate = self
//        activityIndicator.isHidden = false
//
//        activityIndicator.startAnimating()
//
//        let parameters = [ SKStoreProductParameterITunesItemIdentifier : identifier]
//        storeViewController.loadProduct(withParameters: parameters) { [weak self] (loaded, error) -> Void in
//            if loaded {
//                // Parent class of self is UIViewContorller
//                self?.activityIndicator.stopAnimating()
//                self?.activityIndicator.isHidden = true
//                self?.present(storeViewController, animated: true, completion: nil)
//            }
//        }
//    }
//
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
