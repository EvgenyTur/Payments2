//
//  Today.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 08.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import Foundation
class Today {
    static var date: Date {
        return Calendar.current.date(byAdding: .month, value: 0, to: Date())!
    }
}
