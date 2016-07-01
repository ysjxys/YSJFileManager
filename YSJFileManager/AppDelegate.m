//
//  AppDelegate.m
//  YSJFileManager
//
//  Created by ysj on 16/1/26.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "AppDelegate.h"
#import "FileManagerNavigationController.h"
#import "FileManagerViewController.h"
#import "FavouriteViewController.h"
#import "SettingViewController.h"
#import "LockViewViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) UIImageView *lockImageView;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow *window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window = window;
    window.backgroundColor = [UIColor blackColor];
    self.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    FileManagerViewController *fileManagerVC = [[FileManagerViewController alloc]init];
    fileManagerVC.shouldLock = YES;
    FileManagerNavigationController *fmnv1 = [[FileManagerNavigationController alloc]initWithRootViewController:fileManagerVC];
    
    UIImage *img1 = [UIImage imageNamed:@"files-tab"];
    img1 = [img1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *selectedImg1 = [UIImage imageNamed:@"files-tab-selected"];
    selectedImg1 = [selectedImg1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *item1 = [[UITabBarItem alloc]initWithTitle:@"我的文件" image:img1 selectedImage:selectedImg1];
    [item1 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [item1 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    fmnv1.tabBarItem = item1;
    
    FavouriteViewController *favouriteVC = [[FavouriteViewController alloc]init];
    FileManagerNavigationController *fmnv2 = [[FileManagerNavigationController alloc]initWithRootViewController:favouriteVC];
    
    UIImage *img2 = [UIImage imageNamed:@"favorite-tab"];
    img2 = [img2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *selectedImg2 = [UIImage imageNamed:@"favorite-tab-selected"];
    selectedImg2 = [selectedImg2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *item2 = [[UITabBarItem alloc]initWithTitle:@"我的收藏" image:img2 selectedImage:selectedImg2];
    [item2 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    [item2 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    fmnv2.tabBarItem = item2;
    
    SettingViewController *settingVC = [[SettingViewController alloc]init];
    settingVC.view.backgroundColor = [UIColor whiteColor];
    FileManagerNavigationController *fmnv3 = [[FileManagerNavigationController alloc]initWithRootViewController:settingVC];
    
    UIImage *img3 = [UIImage imageNamed:@"more-tab"];
    img3 = [img3 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *selectedImg3 = [UIImage imageNamed:@"more-tab-selected"];
    selectedImg3 = [selectedImg3 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *item3 = [[UITabBarItem alloc]initWithTitle:@"设置" image:img3 selectedImage:selectedImg3];
    [item3 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    [item3 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    fmnv3.tabBarItem = item3;
    
    UITabBarController *tabBarController = [[UITabBarController alloc]init];
    tabBarController.viewControllers = @[fmnv1,fmnv2,fmnv3];
    tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"grey-bg"];
    window.rootViewController = tabBarController;
    
    [window makeKeyAndVisible];
    [self showLockViewController];
    return YES;
}

- (void)showLockViewController{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault boolForKey:LockScreen] && [userDefault objectForKey:UserPWD]) {
        [self.window.rootViewController presentViewController:[[LockViewViewController alloc] initWithMsg:@"请输入手势密码" startMode:startInputPWD] animated:NO completion:nil];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    YSJLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    YSJLog(@"applicationDidEnterBackground");
    self.lockImageView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.lockImageView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *image = [UIImage imageNamed:@"lockImage.jpg"];
    self.lockImageView.image = image;
    [self.window addSubview:self.lockImageView];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    YSJLog(@"applicationWillEnterForeground");
    if (self.lockImageView){
        [self.lockImageView removeFromSuperview];
        self.lockImageView = nil;
    }
    [self showLockViewController];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    YSJLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.harry.YSJFileManager" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"YSJFileManager" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"YSJFileManager.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
