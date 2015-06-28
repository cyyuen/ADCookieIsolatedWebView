# ADCookieIsotatedWebView
A true cookie isolated webview for cocoa (Mac osx). It handles both request-level cookie and JS-level cookie

### Implementation

Web cookies in the Mac OSX are stored in the common cookie jar. That is your app are sharing cookies with others which could be a big issue for hybird app.
Thanks to SASMITO ADIBOWO and @jjconti, their excellent work archieve the Request-level cookie isolation. See:

* https://github.com/jjconti/swift-webview-isolated (swift-webview-isolated)
* http://cutecoder.org/programming/implementing-cookie-storage/ (how to handle HTTP cookies)
* http://cutecoder.org/programming/handling-cookies-javascript-custom-jar/ (how to handle JavaScript document.cookie cookies)

In short, by using ResourceLoadDelegate, we can inject our own cookies from our own cookie jar to a NSURLRequst before it sent and retrieve the cookies from NSURLResponse after it return. It works very well for most of the site. However, some sites would like to use the cookie in its JS environment and this make problem because the cookies we intercepted don't push back to the JS environment. Also, the native implementation of "document.cookie" access the shared cookie jar. Therefore, we need JS-level cookie isolation.
To implement this, I use Object.__defineSetter__ and Object.__defineGetter__ to override document.cookie's setter and getter, and make them point to our own cookie jar. See the following:

```objc
#define JS_API_NAME @"ADCIWEBVIEW"

- (void) webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    WebScriptObject *wobj = sender.windowScriptObject;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [wobj evaluateWebScript:[NSString stringWithFormat:@"document.__defineGetter__('cookie', function(){ return %@.getCookie();})", JS_API_NAME]];
        
        [wobj evaluateWebScript:[NSString stringWithFormat:@"document.__defineSetter__('cookie', function(v) { return %@.setCookie(v);})", JS_API_NAME]];
    });
}
```

We inject the cookie interception code before the webview start loading anything to make sure every code would use our own cookie implementation.

### Status

This project is created for proof of concept and there are some functionality missed.
Currently, I only implemented JS cookie getter. JS cookie setter is not implemented.
In addition, the cookie management is not complete. It haven't handle cookie expiration, session cookie.
Contirbution are welcome.

