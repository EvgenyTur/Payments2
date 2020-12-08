//
//  DescriptionViewController.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 10.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import UIKit

class DescriptionViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var descriptionTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("description", comment: "")
        updateAboutText()
    }

    private func updateAboutText() {
        let txtFilePath = Bundle.main.path(forResource: "about", ofType: "txt")
        var howToText = ""
        if let textHowTo = try? String(contentsOfFile: txtFilePath!, encoding: String.Encoding.utf8) {
            howToText = textHowTo
        } else {
            print("Error in getting how to")
        }
        
        descriptionTextView.text = howToText
    }

    override func viewDidLayoutSubviews() {
        descriptionTextView.setContentOffset(.zero, animated: false)
    }
}
