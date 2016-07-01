//
//  YSJPlist.h
//  YSJFileManager
//
//  Created by ysj on 16/3/4.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSJPlist : NSObject

+ (NSString *)pathStringInDocumentationDirectory;
+ (void)addDictionary:(NSDictionary *)dic inFilePath:(NSString *)path;
+ (void)removeDictionary:(NSDictionary *)dic inFilePath:(NSString *)path;

@end
