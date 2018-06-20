//
//  rs05App
//
//  Created by Karblue on 2018/6/6.
//  Copyright © 2018 Karblue. All rights reserved.
//


#import "MovieListViewController.h"
#import "RSData.h"

#import <MJRefresh.h>
#import <TOWebViewController.h>

#define UIColorFromHex(s)[UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1.0]


@interface MovieListViewController ()
@end

static NSString *TVCellIdentifier = @"MovieViewCell";
static NSMutableArray<RSData*> *g_data; // global data
static int m_nowPage = 1; // current page


@implementation MovieListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self reloadMovieData:1];
    }]; //bind refresh header
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)]; //bind load more data footer
    
    [footer setTitle:@"加载中" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"加载中" forState:MJRefreshStateWillRefresh];
    [footer setTitle:@"松开加载数据" forState:MJRefreshStatePulling];
    [footer setTitle:@"加载完毕" forState:MJRefreshStateNoMoreData];
    [footer setTitle:@"上拉加载更多" forState:MJRefreshStateIdle];
    
    [header setTitle:@"刷新中" forState:MJRefreshStateRefreshing];
    [header setTitle:@"即将刷新" forState:MJRefreshStateWillRefresh];
    [header setTitle:@"松开就可以刷新啦" forState:MJRefreshStatePulling];
    [header setTitle:@"加载完毕" forState:MJRefreshStateNoMoreData];
    [header setTitle:@"下拉刷新数据" forState:MJRefreshStateIdle];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.MovieView.estimatedRowHeight = 0;
    self.MovieView.estimatedSectionFooterHeight = 0;
    self.MovieView.estimatedSectionHeaderHeight = 0;
    self.MovieView.mj_header = header;
    self.MovieView.mj_footer = footer;
    self.MovieView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.MovieView.mj_header beginRefreshing];
    
    
    
}
- (void) loadMoreData{
    [self.MovieView.mj_footer beginRefreshing];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray<RSData*> *maMoreData = [RSData getRSData:++m_nowPage];
        if (!maMoreData|| maMoreData.count==0){
            [self showError];
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [g_data addObjectsFromArray:maMoreData]; //model add data
            [self.MovieView reloadData];
            [self.MovieView.mj_footer endRefreshing];
        });
        
    });
}
- (void)showError{
    UIAlertController *alcErrorMsg = [UIAlertController alertControllerWithTitle:@"服务器错误" message:@"加载数据失败" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alOK = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    [alcErrorMsg addAction:alOK];
    [self presentViewController:alcErrorMsg animated:YES completion:nil];
}
- (void)reloadMovieData:(int) pageIndex {
    [self.MovieView.mj_header beginRefreshing];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        g_data = [RSData getRSData:pageIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.MovieView.mj_header endRefreshing];
            if (!g_data|| g_data.count == 0)
            {
                [self showError];
                return;
            }
            [self.MovieView reloadData];
            if (self.MovieView.separatorStyle != UITableViewCellSeparatorStyleSingleLine)
                self.MovieView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            
        });
        
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:TVCellIdentifier
                             forIndexPath:indexPath];
    if (cell!=nil && cell.subviews.count > 0 && cell.subviews[0].subviews.count > 4 ){
        NSArray * contentViews = cell.subviews[0].subviews; //find subviews
        UIImageView *img = contentViews[0];
        UILabel *title = contentViews[1];
        UILabel *content = contentViews[2];
        UILabel *time = contentViews[3];
        UILabel *douban = contentViews[4];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^(void){
            if (!g_data)
                return;
            
            
            RSData *rObj = [g_data objectAtIndex:indexPath.row];
            UIImage * uiImg = [[UIImage alloc] initWithData:rObj.pImgData scale:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                [img setImage:uiImg];
                [time setText:[NSString stringWithFormat:@"时间:%@",rObj.pTime]];
                [time setTextColor:UIColorFromHex(0xf2992e)];
                [content setText:rObj.pContent];
                [content sizeToFit];
                [douban setText:[NSString stringWithFormat:@"豆瓣评分:%@",rObj.pDouban]];
                [douban setTextColor:UIColorFromHex(0x56bc8a)];
                [title setText:rObj.pTitle];
            });
            
            
        });
    }
    
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 220;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return g_data!=nil ? g_data.count : 0;
}

- (NSString *)stringByMidString:(NSString*)rawStr firstStr:(NSString*)firstStr lastStr:(NSString*)lastStr needLastStr:(bool)isNeedLastStr{
    NSString * sRetVal = nil;
    NSRange rFirst = [rawStr rangeOfString:firstStr];
    NSRange rLast = [rawStr rangeOfString:lastStr];
    if (rFirst.location != NSNotFound && rLast.location != NSNotFound && rLast.location > rFirst.location)
        sRetVal = [rawStr substringWithRange:NSMakeRange(rFirst.location, rLast.location - rFirst.location + (isNeedLastStr ? rLast.length : 0))];
    return sRetVal;
    
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (g_data.count < indexPath.row)
        return;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RSData * rTmpObj = g_data[indexPath.row];
    TOWebViewController *webViewController = [[TOWebViewController alloc] init];
    webViewController.doneButtonTitle = @"返回";
    webViewController.showPageTitles = NO;
    webViewController.showActionButton = NO;
    webViewController.navigationButtonsHidden = YES;
    webViewController.showLoadingBar = NO;
    [webViewController setHtml:@"<html><div>加载中...</div></html>"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *sHTML = [NSString stringWithContentsOfURL:[NSURL URLWithString:rTmpObj.pMoviesrc] encoding:NSUTF8StringEncoding error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!sHTML || sHTML.length == 0)
            {
                [self showError];
                return;
            }
            NSString *sMovieHtml = [self stringByMidString:sHTML firstStr:@"<div class=\"movie-des shadow\">" lastStr:@"<div class=\"more-link text-center\">" needLastStr:NO];
            NSString *sHeadHtml = [self stringByMidString:sHTML firstStr:@"<head>" lastStr:@"</head>" needLastStr:YES];
            NSString *sLoadHtml = [NSString stringWithFormat:@"<html>%@<style>img {width:100%% }</style><div class=\"wrapper\"><div class=\"pure-g\"><div class=\"pure-u-1 pure-u-md-17-24\">%@</div></div></div></html>",sHeadHtml,sMovieHtml];
            
            [webViewController setHtml:sLoadHtml];
        });

    });

    
    
    
    
}
@end
