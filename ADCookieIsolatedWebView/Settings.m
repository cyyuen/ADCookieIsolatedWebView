//
//  Settings.h
//  ADCookieIsolatedWebView
//
//  Created by cyyuen on 28/5/15.
//  Copyright (c) 2015 cyyuen. All rights reserved.
//
//  Note: This Class, Settings is originally created by @jjconti in project,
//  swift-webview-isolated(https://github.com/jjconti/swift-webview-isolated) with
//  Swift lang. I convert the Swift version to Objective-C.
//

#import <Foundation/Foundation.h>

#import "Settings.h"

#define COOKIE_STORAGE_KEY @"CookieStorageKey"

@interface Settings()

@property (strong, nonatomic) NSUserDefaults *defaults;

@end

@implementation Settings

- (id) init
{
    if ((self = [super init])) {
        self.defaults = [[NSUserDefaults alloc] init];
        [self registerDefaults];
    }
    
    return self;
}

- (void) deleteCookieStorage
{
    [self.defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[[BSHTTPCookieStorage alloc] init]] forKey:COOKIE_STORAGE_KEY];
    [self.defaults synchronize];
}

- (BSHTTPCookieStorage *) retrieveCookieStorage
{
    NSData *cookieStorageData = [self.defaults objectForKey:COOKIE_STORAGE_KEY];
    return [NSKeyedUnarchiver unarchiveObjectWithData:cookieStorageData];
}

- (void) saveCookieStorage:(BSHTTPCookieStorage *)cookieStorage
{
    [self.defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:cookieStorage] forKey:COOKIE_STORAGE_KEY];
    [self.defaults synchronize];
}

- (void) registerDefaults
{
    [self.defaults registerDefaults:@{
        COOKIE_STORAGE_KEY: [NSKeyedArchiver archivedDataWithRootObject:[[BSHTTPCookieStorage alloc] init]]
    }];
}

@end

#undef COOKIE_STORAGE_KEY