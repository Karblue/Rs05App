//
//  RSData.h
//  rs05App
//
//  Created by Karblue on 2018/6/7.
//  Copyright © 2018 Karblue. All rights reserved.
//

#ifndef RSData_h
#define RSData_h


#endif /* RSData_h */

#import <Foundation/Foundation.h>

@interface RSData: NSObject

@property(nonatomic,retain) NSString *pTitle;
@property(nonatomic,retain) NSString *pContent;
@property(nonatomic,retain) NSString *pTime;
@property(nonatomic,retain) NSString *pDouban;
@property(nonatomic,retain) NSString *pImgsrc;
@property(nonatomic,retain) NSString *pMoviesrc; 
@property(nonatomic,retain) NSData *pImgData;

+ (NSMutableArray<RSData*>*)getRSData:(int) pageIndex;
@end
