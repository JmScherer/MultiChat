//
//  AppDelegate.h
//  SeniorDesignProject2
//
//  Created by James Scherer on 10/20/17.
//  Copyright © 2017 James Scherer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

