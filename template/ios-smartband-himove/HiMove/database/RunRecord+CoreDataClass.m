//
//  RunRecord+CoreDataClass.m
//  HiMove
//
//  Created by qf on 2017/9/5.
//  Copyright © 2017年 SXR. All rights reserved.
//

#import "RunRecord+CoreDataClass.h"

@interface RunRecord ()

@property (nonatomic) NSDate *primitivestarttime;
@property (nonatomic) NSString *primitiveSectionIdentifier;

@end

@implementation RunRecord
@dynamic primitivestarttime, primitiveSectionIdentifier;
//@dynamic tempid;
// Insert code here to add functionality to your managed object subclass

- (NSString *)sectionIdentifier
{
    // Create and cache the section identifier on demand.
    
    [self willAccessValueForKey:@"sectionIdentifier"];
    NSString *tmp = [self primitiveSectionIdentifier];
    [self didAccessValueForKey:@"sectionIdentifier"];
    
    if (!tmp)
    {
        /*
         Sections are organized by month and year. Create the section identifier as a string representing the number (year * 1000) + month; this way they will be correctly ordered chronologically regardless of the actual name of the month.
         */
        //        NSCalendar *calendar = [NSCalendar currentCalendar];
        //
        //        NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth|NSCalendarUnitYearForWeekOfYear|NSCalendarUnitWeekOfYear) fromDate:[self starttime]];
        //        tmp = [NSString stringWithFormat:@"%ld-%ld", (long)[components year],(long)[components month]];
        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"yyyy-MM";
        tmp = [format stringFromDate:self.starttime];
        [self setPrimitiveSectionIdentifier:tmp];
        //        NSLog(@"RunRecord[sectionIdentifier]===>sectionIdentifier = %@",self.sectionIdentifier);
        
    }
    return tmp;
}


#pragma mark - Time stamp setter

- (void)setStarttime:(NSDate *)newDate
{
    // If the time stamp changes, the section identifier become invalid.
    [self willChangeValueForKey:@"starttime"];
    [self setPrimitivestarttime:newDate];
    [self didChangeValueForKey:@"starttime"];
    
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM";
    NSString* tmp = [format stringFromDate:newDate];
    
    [self setPrimitiveSectionIdentifier:tmp];
    //    NSLog(@"RunRecord[setStarttime]===>sectionIdentifier = %@",self.sectionIdentifier);
}

//-(NSString*)getTempid{
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//
//    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit|NSYearForWeekOfYearCalendarUnit|NSWeekOfYearCalendarUnit) fromDate:[self starttime]];
//    return [NSString stringWithFormat:@"%d-%d", [components yearForWeekOfYear],[components weekOfYear]];
//
//
//}

#pragma mark - Key path dependencies

+ (NSSet *)keyPathsForValuesAffectingSectionIdentifier
{
    // If the value of timeStamp changes, the section identifier may change as well.
    return [NSSet setWithObject:@"starttime"];
}

@end
