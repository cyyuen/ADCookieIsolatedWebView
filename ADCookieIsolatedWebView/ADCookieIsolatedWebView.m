//
//  ADCookieIsolatedWebView.m
//  ADCookieIsolatedWebView
//
//  Created by cyyuen on 28/5/15.
//  Copyright (c) 2015 cyyuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

#import "ADCookieIsolatedWebView.h"
#import "Settings.h"
#import "BSHTTPCookieStorage.h"

@interface ADCookieIsolatedWebView()

@property (weak, nonatomic) id userFrameLoadDelegate;
@property (weak, nonatomic) id userResourceLoadDelegate;
@property (strong, nonatomic) BSHTTPCookieStorage *cookieStorage;
@property (strong, nonatomic) Settings *settings;

@end

@implementation ADCookieIsolatedWebView

- (id) initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect])) {
        self.frameLoadDelegate = self;
        self.resourceLoadDelegate = self;
    }
    return self;
}

// WebScriptingDelegate methods

+ (NSDictionary *) apiMap
{
    static NSDictionary *api = nil;
    if (api == nil) {
        api = @{
                @"getCookie": @"getCookie",
                @"setCookie:": @"setCookie"
        };
    }
    return api;
}

+ (NSString *)webScriptNameForSelector:(SEL)aSelector
{
    return [[ADCookieIsolatedWebView apiMap] valueForKey:NSStringFromSelector(aSelector)];
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector
{
    return ([[ADCookieIsolatedWebView apiMap] valueForKey:NSStringFromSelector(aSelector)] == nil);
}

- (NSString *) getCookie
{
    NSArray *cookies = [self.cookieStorage cookiesForURL:[NSURL URLWithString:self.mainFrameURL]];
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    
    if (headers[@"Cookie"])
        return headers[@"Cookie"];
    else
        return @"";
}

- (void) setCookie:(NSString *) cookieEpx
{
    
}

// ResourceLoadDelegate methods

- (void) webView:(WebView *)sender resource:(id)identifier didReceiveResponse:(NSURLResponse *)response fromDataSource:(WebDataSource *)dataSource
{
    if (response != nil && [response isKindOfClass:[NSHTTPURLResponse class]]) {
        [self.cookieStorage handleCookiesInResponse:(NSHTTPURLResponse *)response];
    }
    
    if (self.userResourceLoadDelegate && [self.userResourceLoadDelegate respondsToSelector:@selector(webView:resource:didReceiveResponse:fromDataSource:)]) {
        [self.userResourceLoadDelegate webView:sender resource:identifier didReceiveResponse:response fromDataSource:dataSource];
    }
}

- (NSURLRequest *) webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource
{
    if (redirectResponse != nil && [redirectResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        [self.cookieStorage handleCookiesInResponse:(NSHTTPURLResponse *)redirectResponse];
    }
    
    NSMutableURLRequest *modifiedRequest = request.mutableCopy;
    
    [self.cookieStorage handleCookiesInRequest:modifiedRequest];
    
    if (self.userResourceLoadDelegate && [self.userResourceLoadDelegate respondsToSelector:@selector(webView:resource:willSendRequest:redirectResponse:fromDataSource:)]) {
        modifiedRequest = [self.userResourceLoadDelegate webView:sender resource:identifier willSendRequest:modifiedRequest redirectResponse:redirectResponse fromDataSource:dataSource].mutableCopy;
    }
    
    modifiedRequest.HTTPShouldHandleCookies = false;
    
    return modifiedRequest;
}

// FrameLoadDelegate methods
#define JS_API_NAME @"ADCIWEBVIEW"

- (void) webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    WebScriptObject *wobj = sender.windowScriptObject;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [wobj evaluateWebScript:[NSString stringWithFormat:@"document.__defineGetter__('cookie', function(){ return %@.getCookie();})", JS_API_NAME]];
        
        [wobj evaluateWebScript:[NSString stringWithFormat:@"document.__defineSetter__('cookie', function(v) { return %@.setCookie(v);})", JS_API_NAME]];
    });
    
    if (self.userFrameLoadDelegate && [self.userFrameLoadDelegate respondsToSelector:@selector(webView:didFinishLoadForFrame:)]) {
        [self.userFrameLoadDelegate webView:sender didFinishLoadForFrame:frame];
    }
}

- (void) webView:(WebView *)webView didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame
{
    [windowObject setValue:self forKey:JS_API_NAME];
    
    if (self.userFrameLoadDelegate && [self.userFrameLoadDelegate respondsToSelector:@selector(webView:didClearWindowObject:forFrame:)]) {
        [self.userFrameLoadDelegate webView:webView didClearWindowObject:windowObject forFrame:frame];
    }
}

- (BSHTTPCookieStorage *) cookieStorage
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cookieStorage = [self.settings retrieveCookieStorage];
    });
    return _cookieStorage;
}

- (Settings *) settings
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _settings = [[Settings alloc] init];
    });
    return _settings;
}

@end