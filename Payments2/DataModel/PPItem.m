//
//  PPItem.m
//  payments
//
//  Created by Евгений Турчанинов on 08.12.13.
//  Copyright (c) 2013 Evgeny Turchaninov. All rights reserved.
//

#import "PPItem.h"

@implementation PPItem
@synthesize container, containedItem;
@synthesize itemName, itemSign, itemChecked, monthsPeriod, itemValue, repeatInterval, paymentDate, realPaymentDate;

- (id)initWithItemName:(NSString *)name
              itemSign:(NSNumber *)sign
           itemChecked:(NSNumber *)checked
          monthsPeriod:(NSNumber *)period
             itemValue:(double)value
        repeatInterval:(NSInteger)interval
           paymentDate:(NSDate *)dateToPay
       realPaymentDate:(NSDate *)realDate
{
    // Call the superclass's designated initializer
    self = [super init];
    
    // Did the superclass's designated initializer succeed?
    if(self) {
        // Give the instance variables initial values
        [self setItemName:name];
        [self setItemChecked:checked];
        [self setMonthsPeriod:period];
        [self setItemSign:sign];
        [self setItemValue:value];
        [self setRepeatInterval:interval];
        [self setPaymentDate:dateToPay];
        [self setRealPaymentDate:realDate];
    }
    
    // Return the address of the newly initialized object
    return self;
}

- (id)init
{
    NSDateFormatter *dateFormatterForGettingDate = [[NSDateFormatter alloc] init];
    [dateFormatterForGettingDate setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *zeroDate = [dateFormatterForGettingDate dateFromString:@"2000-01-01 00:00:00"];

    return [self initWithItemName:@""
                         itemSign:[NSNumber numberWithInt:1]
                      itemChecked:[NSNumber numberWithBool:NO]
                      monthsPeriod:[NSNumber numberWithInt:0]
                        itemValue:0.00
                   repeatInterval:30
                      paymentDate:[NSDate date]
                  realPaymentDate:zeroDate];
}

- (void)setContainedItem:(PPItem *)i
{
    containedItem = i;
    [i setContainer:self];
}

- (NSString *)description
{
    NSString *descriptionString =
    [[NSString alloc] initWithFormat:@"%@ (%f): Sign $%@, interval on %ld",
     itemName,
     itemValue,
     itemSign,
     (long)repeatInterval];
    return descriptionString;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:itemName forKey:@"itemName"];
    [aCoder encodeObject:itemSign forKey:@"itemSign"];
    [aCoder encodeObject:itemChecked forKey:@"itemChecked"];
    [aCoder encodeObject:monthsPeriod forKey:@"monthsPeriod"];
    [aCoder encodeDouble:itemValue forKey:@"itemValue"];
    [aCoder encodeInteger:repeatInterval forKey:@"repeatInterval"];
    [aCoder encodeObject:paymentDate forKey:@"paymentDate"];
    [aCoder encodeObject:realPaymentDate forKey:@"realPaymentDate"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setItemName:[aDecoder decodeObjectForKey:@"itemName"]];
        [self setItemSign:[aDecoder decodeObjectForKey:@"itemSign"]];
        [self setItemChecked:[aDecoder decodeObjectForKey:@"itemChecked"]];
        [self setMonthsPeriod:[aDecoder decodeObjectForKey:@"monthsPeriod"]];
        [self setItemValue:[aDecoder decodeDoubleForKey:@"itemValue"]];
        [self setRepeatInterval:[aDecoder decodeIntegerForKey:@"repeatInterval"]];
        [self setPaymentDate:[aDecoder decodeObjectForKey:@"paymentDate"]];
        [self setRealPaymentDate:[aDecoder decodeObjectForKey:@"realPaymentDate"]];
    }
    return self;
}


@end
