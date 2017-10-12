//
//  TCHomeListView.m
//  TC168
//
//  Created by Sam on 17/03/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//
#import <MapKit/MapKit.h>
#import "TCHomeListView.h"

#import <React/RCTViewManager.h>
#import "JXTableView.h"
#import "JXHomeViewModel.h"
#import "JXMarkSixHomeLottery.h"
#import "JXBannerView.h"
#import "JXHomeViewModel.h"
#import "JXHomeSudokuView.h"
#import "JXRollTextCell.h"
#import "JXLotteryResultsCell.h"
#import "JXMarkSixHomeLottery.h"
#import "JXAudioPlayHelper.h"
#import "JXCurrentUserManager.h"
#import <UShareUI/UShareUI.h>
#import "JXHTTPSessionManager.h"
#import "UIScrollView+JXRefresh.h"
#import "JXNavigationBar.h"
#import "JXHUD.h"

@interface RNTHomeListManager : RCTViewManager
@end

@implementation RNTHomeListManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
  return [[TCHomeListView alloc] initWithFrame:CGRectMake(0, 0, JXScreenWidth, JXScreenHeight - 64-49)];
}

@end


@interface TCHomeListView ()<UITableViewDelegate,UITableViewDataSource,JXLotteryResultsCellDelegate>
@property (nonatomic,strong) JXTableView *tableView;
@property (nonatomic,strong) JXHomeViewModel *model;
@property (nonatomic,strong) JXMarkSixHomeLottery *tempModel;
@property (nonatomic,assign) BOOL openVoice;
@property (nonatomic,assign) BOOL isBegining;
@property (nonatomic, strong) dispatch_source_t timer;
@end

@implementation TCHomeListView

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self initData];
    [self addSubview:self.tableView];
    self.hidden = YES;
    [self requestHomeData];
  }
  return self;
}

- (void)initData
{
  self.openVoice = YES;
  self.model = [[JXHomeViewModel alloc] init];
  [self requestHomeData];
  [self startwithTime:40];
  
  NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
  //添加当前类对象为一个观察者，name和object设置为nil，表示接收一切通知
  [center addObserver:self selector:@selector(requestNextTime) name:@"requestNextTime" object:nil];
}


- (void)startwithTime:(NSTimeInterval)time
{
  if (self.timer) {
    dispatch_cancel(self.timer);
  }
  self.timer = nil;
  dispatch_queue_t queue = dispatch_get_main_queue();
  self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
  dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC));
  uint64_t interval = (uint64_t)(time * NSEC_PER_SEC);
  dispatch_source_set_timer(self.timer, start, interval, 0);
  dispatch_source_set_event_handler(self.timer, ^{
    [self requestNextTime];
  });
  dispatch_resume(self.timer);
}

- (void)requestHomeData
{
  [self requestNextTime];
  [self requestBannerAndNoticData];
}

- (void)requestNextTime
{
  WS(weakSelf);
  [[JXHTTPSessionManager sharedManager] POST:@"markSix/nextTime.json" parameters:nil onComplete:^(id responseObject) {
    [weakSelf.tableView endRequest];
    BOOL success =  [[responseObject objectForKey:@"rs"] objectForKey:@"success"];
    if (success) {
      JXMarkSixHomeLottery *homeLottery = [JXMarkSixHomeLottery yy_modelWithDictionary:[responseObject objectForKey:@"content"]];
      if (homeLottery.beginLottery) {
        [weakSelf startwithTime:5];
      }
      if (weakSelf.model.homeLottery.beginLottery && !homeLottery.beginLottery) {
        [weakSelf startwithTime:40];
      }
      weakSelf.model.homeLottery = homeLottery;
      [weakSelf playVoice:homeLottery];
      dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableView reloadData];
      });
      [[JXCurrentUserManager sharedInstance] setCurrentYYYControlNo:homeLottery.markSixDO.controlNo];
      if (homeLottery.beginLottery) {
        weakSelf.tempModel = homeLottery;
      }else{
        weakSelf.tempModel = nil;
      }
    }}];
}

- (void)requestBannerAndNoticData
{
  WS(weakSelf);
  NSDictionary *requestDic = [NSDictionary dictionaryWithObject:@"INDEX" forKey:@"type"];
  [[JXHTTPSessionManager sharedManager] POST:@"banner/list.json" parameters:requestDic onComplete:^(id responseObject) {
    [weakSelf.tableView endRequest];
    BOOL success =  [[responseObject objectForKey:@"rs"] objectForKey:@"success"];
    if (success) {
      NSMutableArray *tempArr = [NSMutableArray array];
      for (NSDictionary *dic in [responseObject objectForKey:@"content"]) {
        JXBannerModel *model = [JXBannerModel yy_modelWithDictionary:dic];
        [tempArr addObject:model];
      }
      weakSelf.model.bannerArray = tempArr;
    }
    [weakSelf.tableView reloadData];
  }];
  
  [[JXHTTPSessionManager sharedManager] POST:@"notice/list.json" parameters:nil onComplete:^(id responseObject) {
    [weakSelf.tableView endRequest];
    BOOL success =  [[responseObject objectForKey:@"rs"] objectForKey:@"success"];
    if (success) {
      int i = 0;
      for (NSDictionary *dic in [responseObject objectForKey:@"content"]) {
        if (i ==0) {
          JXNoticeModel *model = [JXNoticeModel yy_modelWithDictionary:dic];
          if (model) {
            weakSelf.model.notice = model;
            [weakSelf.tableView reloadData];
          }
        }
        i++;
      }
    }
  }];
}

- (void)openTheVoice:(BOOL)voice
{
  self.openVoice = voice;
}

- (void)refreshDataButtonCall
{
  if (!self.model.homeLottery.beginLottery) {
    [self.tableView headerBeginRefreshing];
  }
}

- (void)playVoice:(JXMarkSixHomeLottery *)model
{
  if (model != nil &&self.tempModel != nil &&model.beginLottery &&self.openVoice) {
  }else {
    if (model.markSixDO.specialNumber != nil && self.tempModel.markSixDO.specialNumber == nil&&self.tempModel.beginLottery) {
      //特码
    } else {
      return;
    }
  }
  
  JXLotteryModel *modelNew = nil;
  if (model.markSixDO.normalNumbers.count == 0) {
    return;
  }
  BOOL isSp = NO;
  if (model.beginLottery&&model.markSixDO.normalNumbers.count > self.tempModel.markSixDO.normalNumbers.count) {
    modelNew = [model.markSixDO.normalNumbers lastObject];
  }else if(model.markSixDO.specialNumber && self.tempModel.markSixDO.specialNumber == nil){
    modelNew = model.markSixDO.specialNumber;
    isSp = YES;
  } else {
    return;
  }
  
  NSString *num = [NSString stringWithFormat:@"num%lu.mp3",(unsigned long)model.markSixDO.normalNumbers.count];
  if (isSp) {
    num =  [NSString stringWithFormat:@"num7.mp3"];
  }
  NSString *sound = [NSString stringWithFormat:@"sound%@.mp3",modelNew.number];
  JXMarkSixNumberColor type = [JXGlobalMethod getColorTypeWithNumber:modelNew.number];
  NSString *bs = @"";
  switch (type) {
    case JXMarkSixNumberColorRed:{
      bs = @"hongbo.mp3";
      break;
    }
    case JXMarkSixNumberColorRedBlue:{
      bs = @"lanbo.mp3";
      break;
    }
    case JXMarkSixNumberColorRedGreen:{
      bs = @"lvbo.mp3";
      break;
    }
    default:
      break;
  }
  [[JXAudioPlayHelper sharedInstance] playMusicWithMusicName:num andInCompletionBlock:^{
    [[JXAudioPlayHelper sharedInstance] playMusicWithMusicName:sound andInCompletionBlock:^{
      [[JXAudioPlayHelper sharedInstance] playMusicWithMusicName:bs andInCompletionBlock:^{
      }];
    }];
  }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  JXHomeSectionType type = [self.model typeInSection:indexPath.section];
  switch (type) {
    case JXHomeSectionTypeBanner: {
      return [JXBannerView getBannerCellRectWithModel:[self.model.bannerArray objectAtIndexCheck:0]].height;
    }
    case JXHomeSectionTypeSudoku: {
      return [JXHomeSudokuView getHomeSudokuViewHight];
    }
    case JXHomeSectionTypeAnnouncement: {
      return [JXRollTextCell getHightWith:self.model.notice];
    }
    case JXHomeSectionTypeLotteryResult: {
      return [JXLotteryResultsCell getHight];
    }
    default:
      break;
  }
  
  return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.model numberOfItemsInSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return [self.model numberOfSectionsInModel];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  JXHomeSectionType type = [self.model typeInSection:indexPath.section];
  switch (type) {
    case JXHomeSectionTypeBanner: {
      JXBannerView *cell = [tableView dequeueReusableCellWithIdentifier:@"JXBannerView" forIndexPath:indexPath];
      [cell resetBannerCellWithArray:self.model.bannerArray];
      return cell;
    }
    case JXHomeSectionTypeSudoku: {
      JXHomeSudokuView *cell = [tableView dequeueReusableCellWithIdentifier:@"JXHomeSudokuView" forIndexPath:indexPath];
      [cell resetWith];
      return cell;
    }
    case JXHomeSectionTypeAnnouncement: {
      JXRollTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JXRollTextCell" forIndexPath:indexPath];
      [cell resetWith:self.model.notice];
      return cell;
    }
    case JXHomeSectionTypeLotteryResult: {
      JXLotteryResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JXLotteryResultsCell" forIndexPath:indexPath];
      cell.delagate = self;
      [cell resetWithModel:self.model.homeLottery];
      return cell;
    }
    default:
      break;
  }
  return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
  return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
  JXHomeSectionType type = [self.model typeInSection:section];
  if (type == JXHomeSectionTypeAnnouncement||type == JXHomeSectionTypeBanner) {
    return 5;
  }else if (type == JXHomeSectionTypeLotteryResult) {
    return 10;
  }
  return 0;
}


- (JXTableView *)tableView
{
  if (_tableView == nil) {
    _tableView = [[JXTableView alloc] initWithFrame:CGRectMake(0, JXNavigationBarHeight, JXScreenWidth, JXScreenHeight - JXNavigationBarHeight - JXBottomNavH)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [_tableView registerClass:[JXBannerView class] forCellReuseIdentifier:@"JXBannerView"];
    [_tableView registerClass:[JXHomeSudokuView class] forCellReuseIdentifier:@"JXHomeSudokuView"];
    [_tableView registerClass:[JXRollTextCell class] forCellReuseIdentifier:@"JXRollTextCell"];
    [_tableView registerClass:[JXLotteryResultsCell class] forCellReuseIdentifier:@"JXLotteryResultsCell"];
    [_tableView addHeaderWithTarget:self action:@selector(requestHomeData)];
    //        [_tableView addFooterWithTarget:self action:@selector(requestHomeData)];
  }
  return _tableView;
}


@end
