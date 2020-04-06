//
//  SWRunHistoryViewController.m
//  SXRBand
//
//  Created by qf on 15/11/17.
//  Copyright © 2015年 SXR. All rights reserved.
//

#import "SWRunHistoryViewController.h"
#import "RunRecord+CoreDataClass.h"
#import "SWTextAttachment.h"
#import "SWRunHistoryMapViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MainLoop.h"
#import "CommonDefine.h"
#import "IRKCommonData.h"

@interface SWRunHistoryViewController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate>
@property(nonatomic,strong)UITableView* tableview;
@property(nonatomic,strong)NSManagedObjectContext* context;
@property(nonatomic,strong)NSFetchedResultsController* fetchedResultsController;
@property(nonatomic,strong)IRKCommonData* commondata;
@property(nonatomic,strong)RunRecord* currentrecord;
@property(nonatomic,strong) NSMutableArray *recordarray;
@property(nonatomic,strong) NSMutableArray *modelAry;
@property(nonatomic,assign) int sections;
@end

@implementation SWRunHistoryViewController
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];//self.commondata.colorHSKNav;
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setHidden:NO];
    NSError* error;
    if (![self.fetchedResultsController performFetch:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.tableview reloadData];

    //[self.tableview reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
//    self.fetchedResultsController = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.commondata = [IRKCommonData SharedInstance];
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.context = delegate.managedObjectContext;
    
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    UIImageView * backimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 7, 22, 15)];
    backimg.image = [UIImage imageNamed:@"icon_back.png"];
    backimg.contentMode = UIViewContentModeScaleAspectFit;
    [btn addSubview:backimg];
    [btn addTarget:self action:@selector(onClickBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    NSMutableParagraphStyle* p = [NSMutableParagraphStyle new];
    p.alignment = NSTextAlignmentCenter;
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"History", nil) attributes:@{NSFontAttributeName: [UIFont fontWithName:@"STHeitiSC-Medium" size:14], NSParagraphStyleAttributeName: p}];
    UILabel* titleview = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, str.size.width, str.size.height)];
    titleview.attributedText = str;
    self.navigationItem.titleView = titleview;
    
//    self.modelAry=[[NSMutableArray alloc]init];
//    self.recordarray=[NSMutableArray arrayWithArray:[self getRundata]];
//    for (int i=0; i<self.recordarray.count; i++) {
//        NSString *str=self.recordarray[i][@"sectionIdentifier"];
//        NSArray *ary=[self getSectionRunData:str];
//        [self.modelAry addObject:ary];
//    }
    
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-64) style:UITableViewStyleGrouped];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    //self.tableview.backgroundColor=[UIColor clearColor];
    [self.view addSubview:self.tableview];
    
}

-(void)onClickBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[self.fetchedResultsController sections] count];
    return count;

//    return self.recordarray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    NSInteger count = [sectionInfo numberOfObjects];
    return count;

//    NSArray *ary=(NSArray*)self.modelAry[section];
//
//    return ary.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"RunCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //cell.backgroundColor=[UIColor clearColor];
//    RunRecord *record = self.modelAry[indexPath.section][indexPath.row];
    @try {
        RunRecord *record = (RunRecord*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        if (record == nil) {
            return cell;
        }
        //    NSLog(@"%@",record);
        NSDateFormatter *format=[[NSDateFormatter alloc]init];
        format.dateFormat=@"yyyy-MM-dd-HH:mm";
        NSString *timeStr=[format stringFromDate:record.starttime];
        //    NSLog(@"timeStr==%@",timeStr);
        NSArray *datearray=[timeStr componentsSeparatedByString:@"-"];
        NSMutableAttributedString* strtitle;
        if ([NSLocalizedString(@"lang", nil) isEqualToString:@"chs"]) {
            strtitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@ %@",datearray[2],NSLocalizedString(@"UNIT_DAY", nil),datearray[3]] attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:13]}];
        }else{
            if ([datearray[2] isEqualToString:@"1"]||[datearray[2] isEqualToString:@"21"]||[datearray[2] isEqualToString:@"31"]) {
                strtitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@ %@",datearray[2],@"st",datearray[3]] attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:13]}];
            }else if ([datearray[2] isEqualToString:@"2"]||[datearray[2] isEqualToString:@"22"]){
                strtitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@ %@",datearray[2],@"nd",datearray[3]] attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:13]}];
            }else if ([datearray[2] isEqualToString:@"3"]||[datearray[2] isEqualToString:@"23"]){
                strtitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@ %@",datearray[2],@"rd",datearray[3]] attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:13]}];
            }else{
                strtitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@ %@",datearray[2],@"th",datearray[3]] attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:13]}];
            }
        }
//        [strtitle appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" [%@][%@]",record.running_id,record.sectionIdentifier] attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:13]}]];
        //    NSMutableAttributedString* strtitle = [[NSMutableAttributedString alloc] initWithString:[NSDateFormatter localizedStringFromDate:record.starttime dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle] attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:13]}];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.minimumScaleFactor = 0.5;
        cell.textLabel.attributedText = strtitle;
        
        
        NSMutableAttributedString* strdetail  = [[NSMutableAttributedString alloc]init];
        if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
            [strdetail appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d'%d''",(int)record.pace.doubleValue/60,(int)record.pace.doubleValue%60] attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:22]}]];
            [strdetail appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@/%@",NSLocalizedString(@"UNIT_MIN", nil),NSLocalizedString(@"UNIT_KM", nil)] attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:9]}]];
        }else{
            double pace = record.pace.doubleValue/KM2MILE;
            [strdetail appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d'%d''",(int)pace/60,(int)pace%60] attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:22]}]];
            [strdetail appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@/%@",NSLocalizedString(@"UNIT_MIN", nil),NSLocalizedString(@"UNIT_MILE", nil)] attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:9]}]];
        }
        
        [strdetail appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %.2f",record.totalcalories.doubleValue] attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:22]}]];
        [strdetail appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",NSLocalizedString(@"UNIT_KCAL", nil)] attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:9]}]];
        
        [strdetail appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %.2d:%.2d:%.2d  ",(int)(record.totaltime.doubleValue)/3600,((int)(record.totaltime.doubleValue)/60)%60,(int)(record.totaltime.doubleValue)%60] attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:22]}]];
        
        cell.detailTextLabel.attributedText = strdetail;
        
//        return cell;
    } @catch (NSException *exception) {
        NSLog(@"SWRunHistory exception:%@",exception);
    } @finally {
//        return cell;
    }
    return cell;

}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 60)];
//    UILabel* datelabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, CGRectGetWidth(self.view.frame)/2-20, 40)];
//    datelabel.textColor = [UIColor blackColor];
//    datelabel.font = [UIFont boldSystemFontOfSize:30];
//    datelabel.adjustsFontSizeToFitWidth = YES;
//    datelabel.minimumScaleFactor = 0.5;
//    [v addSubview:datelabel];
//    
//    UILabel* dis = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(datelabel.frame), 20, CGRectGetWidth(self.view.frame)/2-20, 40)];
//    dis.textAlignment = NSTextAlignmentRight;
//    dis.adjustsFontSizeToFitWidth = YES;
//    dis.minimumScaleFactor = 0.5;
//    [v addSubview:dis];
//    
//    NSString *datestr=self.recordarray[section][@"sectionIdentifier"];
//    datelabel.text=datestr;
//    NSString *disstr=self.recordarray[section][@"sumtotaldistance"];
//
//    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
//        NSMutableAttributedString* str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f",[disstr intValue]/1000.0] attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:20]}];
//        [str appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"UNIT_KM", nil) attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:11]}]];
//        dis.attributedText = str;
//    }else{
//        NSMutableAttributedString* str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f",([disstr intValue]/1000.0)*KM2MILE] attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:24]}];
//        [str appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"UNIT_MILE", nil) attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:10]}]];
//        dis.attributedText = str;
//    }
//    return v;
    
    
    
    id <NSFetchedResultsSectionInfo> theSection = [[self.fetchedResultsController sections] objectAtIndex:section];
    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 60)];
    UILabel* datelabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, CGRectGetWidth(self.view.frame)*0.5, 40)];
    datelabel.textAlignment = NSTextAlignmentLeft;
    datelabel.numberOfLines = 0;
    datelabel.textColor = [UIColor darkGrayColor];
    datelabel.font = [UIFont boldSystemFontOfSize:20];
    datelabel.adjustsFontSizeToFitWidth = YES;
    datelabel.minimumScaleFactor = 0.5;
    [v addSubview:datelabel];
    
    UILabel* dis = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(datelabel.frame), 20, CGRectGetWidth(self.view.frame)/2-20, 40)];
    dis.numberOfLines = 0;
    dis.textAlignment = NSTextAlignmentCenter;
    dis.adjustsFontSizeToFitWidth = YES;
    dis.minimumScaleFactor = 0.5;
    [v addSubview:dis];
    
    
    NSArray* tmplist = [theSection.name componentsSeparatedByString:@"-"];
    //    NSInteger numericSection = [[theSection name] integerValue];
    if ([tmplist count]< 2) {
        return v;
    }
    NSInteger year = [[tmplist objectAtIndex:0] intValue];
    NSInteger month = [[tmplist objectAtIndex:1] intValue];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = year;
    dateComponents.month = month;
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM";
    datelabel.text = [NSString stringWithFormat:@"  %@",[format stringFromDate:date]];
    
    NSArray* objs = [theSection objects];
    __block double distance = 0;
    [objs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RunRecord* record = (RunRecord*)obj;
        distance += record.totaldistance.doubleValue;
    }];
    
    if (self.commondata.measureunit == MEASURE_UNIT_METRIX) {
        NSMutableAttributedString* str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f",distance/1000.0] attributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:24]}];
        [str appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"UNIT_KM", nil) attributes:@{NSForegroundColorAttributeName:[UIColor grayColor],NSFontAttributeName:[UIFont systemFontOfSize:10]}]];
        dis.attributedText = str;
        
    }else{
        NSMutableAttributedString* str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f",(distance/1000.0)*KM2MILE] attributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:24]}];
        [str appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"UNIT_MILE", nil) attributes:@{NSForegroundColorAttributeName:[UIColor grayColor],NSFontAttributeName:[UIFont systemFontOfSize:10]}]];
        dis.attributedText = str;
        
    }
    return v;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
//    self.currentrecord = self.modelAry[indexPath.section][indexPath.row];//[self.fetchedResultsController objectAtIndexPath:indexPath];
    self.currentrecord = [self.fetchedResultsController objectAtIndexPath:indexPath];

    SWRunHistoryMapViewController *vc=[SWRunHistoryMapViewController new];
    vc.record=self.currentrecord;
    [self.navigationController pushViewController:vc animated:YES];
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//-(NSArray*)getSectionRunData:(NSString*)str{
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RunRecord" inManagedObjectContext:self.context];
//    [fetchRequest setEntity:entity];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid IN {%@,%@} and type IN {%@,%@} and sectionIdentifier IN {%@}", self.commondata.uid,@"", [NSNumber numberWithInt:SPORT_TYPE_BICYCLE], [NSNumber numberWithInt:SPORT_TYPE_RUNNING],str];
//    [fetchRequest setPredicate:predicate];
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"starttime" ascending:NO];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//    NSError *error = nil;
//    NSArray* fetchobjs = [self.context executeFetchRequest:fetchRequest error:&error];
//    return fetchobjs ;
//}
//
//-(NSArray*)getRundata{
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RunRecord" inManagedObjectContext:self.context];
//    [fetchRequest setEntity:entity];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid IN {%@,%@} and type IN {%@,%@}", self.commondata.uid,@"", [NSNumber numberWithInt:SPORT_TYPE_BICYCLE], [NSNumber numberWithInt:SPORT_TYPE_RUNNING]];
//    [fetchRequest setPredicate:predicate];
//    [fetchRequest setReturnsObjectsAsFaults:NO];
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"starttime" ascending:NO];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//    fetchRequest.returnsDistinctResults = YES;
//    fetchRequest.resultType = NSDictionaryResultType;
//    fetchRequest.propertiesToGroupBy = [NSArray arrayWithObjects:@"sectionIdentifier", nil];
//    
//    NSMutableArray* expresslist = [[NSMutableArray alloc] init];
//    [expresslist addObject:@"sectionIdentifier"];
//
//    
//    
//    
//    NSExpressionDescription* expression = [[NSExpressionDescription alloc] init];
//    expression.name = @"sumtotaldistance";
//    expression.expression = [NSExpression expressionWithFormat:@"@sum.totaldistance"];
//    expression.expressionResultType = NSInteger32AttributeType;
//    [expresslist addObject:expression];
//    
//    fetchRequest.propertiesToFetch = expresslist;
////
//    NSError * error = nil;
//    NSArray *fetchobjs = [self.context executeFetchRequest:fetchRequest error:&error];
//    
//    return fetchobjs;
//}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RunRecord" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %@ and type IN {%@,%@,%@}", self.commondata.uid,[NSNumber numberWithInt:SPORT_TYPE_BICYCLE], [NSNumber numberWithInt:SPORT_TYPE_RUNNING],[NSNumber numberWithInt:SPORT_TYPE_GPS_CLIMB]];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %@ and type IN {%@,%@,%@}", self.commondata.uid,[NSNumber numberWithInt:SPORT_TYPE_RUNNING], [NSNumber numberWithInt:SPORT_TYPE_BICYCLE],[NSNumber numberWithInt:SPORT_TYPE_GPS_CLIMB]];

    [fetchRequest setPredicate:predicate];
    // Set the batch size to a suitable number.
    //    [fetchRequest setFetchBatchSize:20];
    
    // Sort using the timeStamp property.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"starttime" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor ]];
    
    //    NSArray* result = [self.context executeFetchRequest:fetchRequest error:nil];
    //    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    //        RunRecord* record = (RunRecord*)obj;
    //        NSLog(@"%@,%f,%@,%@",record.starttime,record.totaldistance.doubleValue,record.running_id,record.sectionIdentifier);
    //    }];
    // Use the sectionIdentifier property to group into sections.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:@"sectionIdentifier" cacheName:nil];
    //    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:@"uid" cacheName:@"Root"];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}    



@end
