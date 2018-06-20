//
//  RSData.m
//  rs05App
//
//  Created by Karblue on 2018/6/7.
//  Copyright © 2018 Karblue. All rights reserved.
//

#import "RSData.h"

@interface RSData ()

@end

@implementation RSData

@synthesize pTitle;
@synthesize pContent;
@synthesize pDouban;
@synthesize pTime;
@synthesize pImgsrc;
@synthesize pMoviesrc;
@synthesize pImgData;

- (NSString*)description{
    return [NSString stringWithFormat:@"img:%@\nmovie:%@\ntitle:%@\ncontent:%@\ntime:%@\ndouban:%@\n",self.pImgsrc,self.pMoviesrc,self.pTitle,self.pContent,self.pTime,self.pDouban];
}


+ (NSMutableArray<RSData*>*)getRSData:(int) pageIndex{
    /*
     <li class=\"pure-g shadow\">[\s\S]*?<img.*data-original="(http:\/\/[\w\.\/]+)"[\s\S]*?<a target="_blank" title="(.*)?" href="(.*)?">[\s\S]*?<div class="brief">(.*)?<\/div>[\s\S]*?<div class="tags">(.*)? [\s\S]*?豆瓣：<b>(\d+\.\d+)<\/b>[\s\S]*?<\/li>
     
     */
    NSMutableArray<RSData*> *aRetVal = nil;
    NSString * sURL = [NSString stringWithFormat:@"http://www.rs05.com/movie/?p=%d",pageIndex]; // url with page
    NSURL * uURL = [NSURL URLWithString:sURL];
    NSError * error;
    NSString * sHTML = [NSString stringWithContentsOfURL:uURL encoding:NSUTF8StringEncoding error:&error];
    if (sHTML==nil)
        return aRetVal;
    
    NSRegularExpression *rExp = [NSRegularExpression regularExpressionWithPattern:@"<li class=\"pure-g shadow\">[\\s\\S]*?<img.*data-original=\"(http:\/\/[\\w\.\/]+)\"[\\s\\S]*?<a target=\"_blank\" title=\"(.*)?\" href=\"(.*)?\">[\\s\\S]*?<div class=\"brief\">([\\s\\S]*?)<\/div>[\\s\\S]*?<div class=\"tags\">(.*)? [<a][\\s\\S]*?豆瓣：<b>(\\d+\.\\d+)<\/b>[\\s\\S]*?<\/li>" options:NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines |NSRegularExpressionSearch error:&error];
    NSArray * aMatchData = [rExp matchesInString:sHTML options:0 range:NSMakeRange(0, sHTML.length)];
    if (aMatchData.count ==0)
        NSLog(@"rExp MATCH COUNT IS ZERO");
    else
        aRetVal = [[NSMutableArray<RSData*> alloc] init];
    
    for (NSTextCheckingResult * tResult in aMatchData) { // match
        NSUInteger iRangeCount = tResult.numberOfRanges;
        if (iRangeCount!=7)
            continue;
        
        RSData * rTmpObj = [[RSData alloc] init];
        rTmpObj.pImgsrc = [sHTML substringWithRange:[tResult rangeAtIndex:1]];
        rTmpObj.pTitle = [sHTML substringWithRange:[tResult rangeAtIndex:2]];
        rTmpObj.pMoviesrc = [sHTML substringWithRange:[tResult rangeAtIndex:3]];
        rTmpObj.pContent = [sHTML substringWithRange:[tResult rangeAtIndex:4]];
        rTmpObj.pContent = [rTmpObj.pContent stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"]; //replace <br/> to \n
        rTmpObj.pTime = [sHTML substringWithRange:[tResult rangeAtIndex:5]];
        rTmpObj.pDouban = [sHTML substringWithRange:[tResult rangeAtIndex:6]];
        rTmpObj.pImgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:rTmpObj.pImgsrc]];
        
        [aRetVal addObject:rTmpObj];
        
    }
    
    
    return aRetVal;
}


@end
