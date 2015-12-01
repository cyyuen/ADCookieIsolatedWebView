//
//  ADCookieIsolatedWebView.h
//  ADCookieIsolatedWebView
//
//  Created by cyyuen on 28/5/15.
//  Copyright (c) 2015 cyyuen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// In this header, you should import all the public headers of your framework using statements like #import <ADCookieIsolatedWebView/PublicHeader.h>

#import <WebKit/WebKit.h>
#import "Settings.h"
#import "BSHTTPCookieStorage.h"

@interface ADCookieIsolatedWebView : WebView

- (BSHTTPCookieStorage *) cookieStorage;
- (Settings *) settings;
@end
