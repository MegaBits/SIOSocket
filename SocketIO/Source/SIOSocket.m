//
//  Socket.m
//  SocketIO
//
//  Created by Patrick Perini on 6/13/14.
//
//

#import "SIOSocket.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "socket.io.js.h"

#ifdef __IPHONE_8_0
#import <WebKit/WebKit.h>
#endif

@interface SIOSocket ()

@property UIWebView *javascriptWebView;
@property (readonly) JSContext *javascriptContext;

@end

@implementation SIOSocket

// Generators
+ (void)socketWithHost:(NSString *)hostURL response:(void (^)(SIOSocket *))response
{
    // Defaults documented with socket.io-client: https://github.com/Automattic/socket.io-client
    return [self socketWithHost: hostURL
         reconnectAutomatically: YES
                   attemptLimit: -1
                      withDelay: 1
                   maximumDelay: 5
                        timeout: 20
                       response: response];
}

+ (void)socketWithHost:(NSString *)hostURL reconnectAutomatically:(BOOL)reconnectAutomatically attemptLimit:(NSInteger)attempts withDelay:(NSTimeInterval)reconnectionDelay maximumDelay:(NSTimeInterval)maximumDelay timeout:(NSTimeInterval)timeout response:(void (^)(SIOSocket *))response
{
    SIOSocket *socket = [[SIOSocket alloc] init];
    if (!socket)
    {
        response(nil);
        return;
    }

    socket.javascriptWebView = [[UIWebView alloc] init];
    [socket.javascriptContext setExceptionHandler: ^(JSContext *context, JSValue *errorValue)
    {
        NSLog(@"JSError: %@", errorValue);
    }];

    socket.javascriptContext[@"window"][@"onload"] = ^()
    {
        [socket.javascriptContext evaluateScript: socket_io_js];
        NSString *socketConstructor = socket_io_js_constructor(hostURL,
            reconnectAutomatically,
            attempts,
            reconnectionDelay,
            maximumDelay,
            timeout
        );

        socket.javascriptContext[@"objc_socket"] = [socket.javascriptContext evaluateScript: socketConstructor];
        if (![socket.javascriptContext[@"objc_socket"] toObject])
        {
            response(nil);
        }

        // Responders
        __weak typeof(socket) weakSocket = socket;
        
        socket.javascriptContext[@"objc_onConnect"] = ^()
        {
            if (weakSocket.onConnect)
                weakSocket.onConnect();
        };

        socket.javascriptContext[@"objc_onDisconnect"] = ^()
        {
            if (weakSocket.onDisconnect)
                weakSocket.onDisconnect();
        };

        socket.javascriptContext[@"objc_onError"] = ^(NSDictionary *errorDictionary)
        {
            if (weakSocket.onError)
                weakSocket.onError(errorDictionary);
        };

        socket.javascriptContext[@"objc_onReconnect"] = ^(NSInteger numberOfAttempts)
        {
            if (weakSocket.onReconnect)
                weakSocket.onReconnect(numberOfAttempts);
        };

        socket.javascriptContext[@"objc_onReconnectionAttempt"] = ^(NSInteger numberOfAttempts)
        {
            if (weakSocket.onReconnectionAttempt)
                weakSocket.onReconnectionAttempt(numberOfAttempts);
        };

        socket.javascriptContext[@"objc_onReconnectionError"] = ^(NSDictionary *errorDictionary)
        {
            if (weakSocket.onReconnectionError)
                weakSocket.onReconnectionError(errorDictionary);
        };

        [socket.javascriptContext evaluateScript: @"objc_socket.on('connect', objc_onConnect);"];
        [socket.javascriptContext evaluateScript: @"objc_socket.on('error', objc_onError);"];
        [socket.javascriptContext evaluateScript: @"objc_socket.on('disconnect', objc_onDisconnect);"];
        [socket.javascriptContext evaluateScript: @"objc_socket.on('reconnect', objc_onReconnect);"];
        [socket.javascriptContext evaluateScript: @"objc_socket.on('reconnecting', objc_onReconnectionAttempt);"];
        [socket.javascriptContext evaluateScript: @"objc_socket.on('reconnect_error', objc_onReconnectionError);"];

        response(socket);
    };
        
    [socket.javascriptWebView loadHTMLString: @"<html/>" baseURL: nil];
}

// Accessors
- (JSContext *)javascriptContext
{
    return [self.javascriptWebView valueForKeyPath: @"documentView.webView.mainFrame.javaScriptContext"];
}

// Event listeners
- (void)on:(NSString *)event callback:(void (^)(id))function
{
    self.javascriptContext[[NSString stringWithFormat: @"objc_%@", event]] = function;
    [self.javascriptContext evaluateScript: [NSString stringWithFormat: @"objc_socket.on('%@', objc_%@);", event, event]];
}

// Emitters
- (void)emit:(NSString *)event, ...
{
    NSMutableArray *arguments = [NSMutableArray array];

    va_list args;
    va_start(args, event);

    for (id argument = event; argument != nil; argument = va_arg(args, id))
    {
        [arguments addObject: [NSString stringWithFormat: @"'%@'", argument]];
    }

    va_end(args);

    [self.javascriptContext evaluateScript: [NSString stringWithFormat: @"objc_socket.emit(%@);", [arguments componentsJoinedByString: @", "]]];
}

- (void)close
{
    [self.javascriptWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    [self.javascriptWebView reload];
    self.javascriptWebView = nil;
}

@end