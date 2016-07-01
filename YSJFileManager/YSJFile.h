//
//  YSJFile.h
//  YSJFileManager
//
//  Created by ysj on 16/3/10.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSJFile : NSObject
/*
 FOUNDATION_EXPORT NSString * const NSFileType;
 FOUNDATION_EXPORT NSString * const NSFileTypeDirectory;
 FOUNDATION_EXPORT NSString * const NSFileTypeRegular;
 FOUNDATION_EXPORT NSString * const NSFileTypeSymbolicLink;
 FOUNDATION_EXPORT NSString * const NSFileTypeSocket;
 FOUNDATION_EXPORT NSString * const NSFileTypeCharacterSpecial;
 FOUNDATION_EXPORT NSString * const NSFileTypeBlockSpecial;
 FOUNDATION_EXPORT NSString * const NSFileTypeUnknown;
 FOUNDATION_EXPORT NSString * const NSFileSize;
 FOUNDATION_EXPORT NSString * const NSFileModificationDate;
 FOUNDATION_EXPORT NSString * const NSFileReferenceCount;
 FOUNDATION_EXPORT NSString * const NSFileDeviceIdentifier;
 FOUNDATION_EXPORT NSString * const NSFileOwnerAccountName;
 FOUNDATION_EXPORT NSString * const NSFileGroupOwnerAccountName;
 FOUNDATION_EXPORT NSString * const NSFilePosixPermissions;
 FOUNDATION_EXPORT NSString * const NSFileSystemNumber;
 FOUNDATION_EXPORT NSString * const NSFileSystemFileNumber;
 FOUNDATION_EXPORT NSString * const NSFileExtensionHidden;
 FOUNDATION_EXPORT NSString * const NSFileHFSCreatorCode;
 FOUNDATION_EXPORT NSString * const NSFileHFSTypeCode;
 FOUNDATION_EXPORT NSString * const NSFileImmutable;
 FOUNDATION_EXPORT NSString * const NSFileAppendOnly;
 FOUNDATION_EXPORT NSString * const NSFileCreationDate;
 FOUNDATION_EXPORT NSString * const NSFileOwnerAccountID;
 FOUNDATION_EXPORT NSString * const NSFileGroupOwnerAccountID;
 FOUNDATION_EXPORT NSString * const NSFileBusy;
 FOUNDATION_EXPORT NSString * const NSFileProtectionKey NS_AVAILABLE_IOS(4_0);
 FOUNDATION_EXPORT NSString * const NSFileProtectionNone NS_AVAILABLE_IOS(4_0);
 FOUNDATION_EXPORT NSString * const NSFileProtectionComplete NS_AVAILABLE_IOS(4_0);
 FOUNDATION_EXPORT NSString * const NSFileProtectionCompleteUnlessOpen NS_AVAILABLE_IOS(5_0);
 FOUNDATION_EXPORT NSString * const NSFileProtectionCompleteUntilFirstUserAuthentication NS_AVAILABLE_IOS(5_0);
 
 FOUNDATION_EXPORT NSString * const NSFileSystemSize;
 FOUNDATION_EXPORT NSString * const NSFileSystemFreeSize;
 FOUNDATION_EXPORT NSString * const NSFileSystemNodes;
 FOUNDATION_EXPORT NSString * const NSFileSystemFreeNodes;
 
 
 
 @property (nonatomic, copy) NSString *fileName;
 @property (nonatomic, strong) NSDate *updateTime;
 @property (nonatomic, strong) NSDate *createTime;
 @property (nonatomic, copy) NSString *fileSize;
 @property (nonatomic, copy) NSString *fileType;
 @property (nonatomic, copy) NSString *filePath;
 @property (nonatomic, strong) UIImage *fileTypeImg;
 @property (nonatomic, assign) BOOL isFolder;
 @property (nonatomic, assign) BOOL isFavourite;
 @property (nonatomic, strong) NSNumber *fileSizeNumber;
 */

@property (nonatomic, strong) UIImage *fileImage;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) BOOL isFolder;
@property (nonatomic, assign) BOOL isInCollect;
@property (nonatomic, copy) NSString *fileSizeByteStr;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, strong) NSDate *fileModificationDate;
@property (nonatomic, strong) NSDate *fileCreationDate;
@property (nonatomic, strong) NSNumber *fileSize;
@property (nonatomic, copy) NSString *fileType;
@property (nonatomic, strong) NSNumber *oldFileSize;
@property (nonatomic, strong) NSDate *lastModifyDate;


+ (instancetype)fileWithAttributeDic:(NSDictionary *)dic;
+ (instancetype)fileWithAttributeDic:(NSDictionary *)dic fileImage:(UIImage *)fileImage;
- (instancetype)initWithAttributeDic:(NSDictionary *)dic;
- (instancetype)initWithAttributeDic:(NSDictionary *)dic fileImage:(UIImage *)fileImage;


@end
