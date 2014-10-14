//
//  socket.io.js.h
//  SocketIO
//
//  Created by Patrick Perini on 6/13/14.
//
//

#import <Foundation/Foundation.h>
#define MSEC_PER_SEC 1000

/*!
 *  Complete socket.io-1.1.0.js, minified.
 */
static NSString *socket_io_js = nil;

/*!
 *  socket.io client constructor format.
 */
static NSString *socket_io_js_constructor(NSString *hostURL, BOOL reconnection, NSInteger attemptLimit, NSTimeInterval reconnectionDelay, NSTimeInterval reconnectionDelayMax, NSTimeInterval timeout)
{
    NSString *constructorFormat = @"io('%@', {  \
        'reconnection': %@,                     \
        'reconnectionAttempts': %@,             \
        'reconnectionDelay': %d,                \
        'reconnectionDelayMax': %d,             \
        'timeout': %d                           \
    });";

    return [NSString stringWithFormat: constructorFormat,
        hostURL,
        reconnection? @"true" : @"false",
        (attemptLimit == -1)? @"Infinity" : @(attemptLimit),
        (int)(reconnectionDelay * MSEC_PER_SEC),
        (int)(reconnectionDelayMax * MSEC_PER_SEC),
        (int)(timeout * MSEC_PER_SEC)
    ];
}
