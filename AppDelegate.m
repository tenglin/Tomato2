//
//  AppDelegate.m
//  Tomato2
//
//  Created by Teng Lin on 13-11-11.
//  Copyright (c) 2013年 Teng Lin. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "TomatoManager.h"
#import "DataManager.h"
#import "TutorialViewController.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    [self setDefaults];
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    //core data moc
    self.viewController.managedObjectContext = self.managedObjectContext;
    [TomatoManager sharedInstance].managedObjectContext = self.managedObjectContext;
    [TomatoManager sharedInstance].uiDelegate = self.viewController;
    [DataManager sharedInstance].managedObjectContext = self.managedObjectContext;
    
    // make sure we have Day and Vars's values
    [[DataManager sharedInstance] createVarsAndDayObjectNowIfNeccessary];
    [[TomatoManager sharedInstance] clearAllNotification];
    
    self.window.rootViewController = self.viewController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //Pomodoro Ready? or Restore tomato status from disk
    [[TomatoManager sharedInstance] readyOrRestoreFromDisk];

#if DEBUG_TUTORIAL
    [self showTutorialScreen];
#else
    if (![self appHasLaunchedOnce])
    {
        // This is the first launch ever
        [self showTutorialScreen];
    }
#endif

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[TomatoManager sharedInstance] willResignActive];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[TomatoManager sharedInstance] didEnterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[TomatoManager sharedInstance] willEnterForeground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[TomatoManager sharedInstance] didBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    ClawInfo(@"applicationWillTerminate............");
    [self saveContext];
    [[TomatoManager sharedInstance] clearAllNotification];
    [[TomatoManager sharedInstance] disableRestoreAllFromDisk];
}

#pragma mark - Tutorial

- (BOOL)appHasLaunchedOnce
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"];
}

- (void)showTutorialScreen
{
    // show tutorial screen
    TutorialViewController *modalViewController = [[TutorialViewController alloc] initWithNibName:@"TutorialViewController" bundle:nil];
    modalViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.viewController presentViewController:modalViewController animated:NO completion:nil];
}

#pragma mark - core data

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            ClawError(@"saveContext, Unresolved error %@, %@", error, [error userInfo]);
            [MyGlobal showClawErrorAlert:kClawErrorCoreData];
            //abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Tomato2" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Tomato2.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        ClawError(@"Unresolved error %@, %@", error, [error userInfo]);
        [MyGlobal showClawErrorAlert:kClawErrorCoreData];
#warning show info dialog to users? instead of abort?
        //abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - default settings

- (void)setDefaults
{
    // get the plist location from the settings bundle
    NSString *settingsPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"InAppSettings.bundle"];
    NSString *plistPath = [settingsPath stringByAppendingPathComponent:@"Root.plist"];
    
    // get the preference specifiers array which contains the settings
    NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSArray *preferencesArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
    
    // use the shared defaults object
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // for each preference item, set its default if there is no value set
    for (NSDictionary *item in preferencesArray)
    {
        // get the item key, if there is no key then we can skip it
        NSString *key = [item objectForKey:@"Key"];
        if (key)
        {
            // check to see if the value and default value are set
            // if a default value exists and the value is not set, use the default
            id value = [defaults objectForKey:key];
            id defaultValue = [item objectForKey:@"DefaultValue"];
            if (defaultValue && !value)
            {
                [defaults setObject:defaultValue forKey:key];
            }
        }
    }
    
    // write the changes to disk
    [defaults synchronize];
}

@end
