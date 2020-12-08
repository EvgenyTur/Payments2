//
//  DataModel.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 08.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import Foundation

struct Payment: Codable {
    var uuid: UUID
    var title: String
    // true - в этом периоде отмечен как завершён
    var checked: Bool
    // 1..11 - advance for 1-12 months
    // 0 - current and normal value
    // -1..-12 - debt for 1-12 months
    var month: Int
    // 1 - разовый 30 - ежемесячно 90 - ежеквартально 360 - ежегодно
    var interval: Int
    // сумма за период
    var value: Double
    // сумма за период - та, которая была изначально записана и не меняется при частичном платеже
    var originalValue: Double
    // дата платежа
    var date: Date
    // день месяца платежа
    var day: Int
    // дата реального изменения - не использую пока
    var realDate: Date
    
    init(withTitle: String) {
        self.title = withTitle
        self.checked = false
        self.month = 0
        self.interval = 30
        self.value = 0.0
        self.originalValue = 0.0
        self.date = Today.date
        self.day = 0
        self.realDate = Today.date
        self.uuid = UUID()
    }
}

// Данные для вывода чарт-графика платежей за месяц
struct DayPayment {
    let dayDate: Int
    let regularPlus: Double
    let singlePlus: Double
    let regularMinus: Double
    let singleMinus: Double
}

// Данные для расшифровки долгов порегулярным платежам
struct DebetRegular {
    let name: String
    let periodsQty: Int
    let sum: Double
}
