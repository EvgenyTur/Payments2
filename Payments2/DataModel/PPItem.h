//
//  PPItem.h
//  payments
//
//  Created by Евгений Турчанинов on 08.12.13.
//  Copyright (c) 2013 Evgeny Turchaninov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPItem : NSObject <NSCoding>

- (id)initWithItemName:(NSString *)name
              itemSign:(NSNumber *)sign
           itemChecked:(NSNumber *)checked
          monthsPeriod:(NSNumber *)period
             itemValue:(double)value
        repeatInterval:(NSInteger)interval
           paymentDate:(NSDate *)dateToPay
       realPaymentDate:(NSDate *)realDate;


@property (nonatomic, strong) PPItem *containedItem;
@property (nonatomic, weak) PPItem *container;

@property (nonatomic, copy) NSString *itemName;

// 1 - income, -1 - outcome
@property (nonatomic) NSNumber *itemSign;

// F - unchecked, T - checked
@property (nonatomic) NSNumber *itemChecked;

// starting v3:
// 1..11 - advance for 1-12 months
// 0 - current and normal value
// -1..-12 - debt for 1-12 months
@property (nonatomic) NSNumber *monthsPeriod;


// income/outcome sum
@property (nonatomic) double itemValue;

// 1 - once, 2 - debet, 30 - monthly, 3 - monthly debet
@property (nonatomic) NSInteger repeatInterval;

// payment date when payment is planned
@property (nonatomic) NSDate *paymentDate;

// real payment date when payment was done
@property (nonatomic) NSDate *realPaymentDate;

@end
