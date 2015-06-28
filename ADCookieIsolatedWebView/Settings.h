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

#ifndef ADCookieIsolatedWebView_Settings_h
#define ADCookieIsolatedWebView_Settings_h

#import "BSHTTPCookieStorage.h"

@interface Settings : NSObject

- (void) saveCookieStorage: (BSHTTPCookieStorage *) cookieStorage;

- (BSHTTPCookieStorage *) retrieveCookieStorage;

- (void) deleteCookieStorage;

@end

#endif
