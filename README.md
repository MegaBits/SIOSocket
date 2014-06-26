
# SIOSocket

## How to use

SIOSocket can be added as a CocodaPod, submodule, or standalone dependency to any iOS 7.0 (or greater) project. To access the Cocoapod, point to the podspec file directly.

```ruby
pod 'SIOSocket', :podspec => 'https://raw.githubusercontent.com/MegaBits/SIOSocket/master/SIOSocket.podspec'
```

then...

```objc
#import <SIOSocket/SIOSocket.h>

// ...
[SIOSocket socketWithHost: @"http://localhost:3000" response: ^(SIOSocket *socket)
{
    self.socket = socket;
}];
```

A full demo can be found over at [MegaBits/WorldPin](https://github.com/MegaBits/WorldPin)

## Generators

#### + (void)socketWithHost:response:

Generates a new `SIOSocket` object, begins its connection to the given host, and returns it as the sole parameter of the response block.

The host reachable at the given URL string should be running a valid instance of a socket.io server.

#### + (void)socketWithHost:reconnectAutomatically:attemptLimit:withDelay:maximumDelay:timeout:response:

- `reconnectAutomatically` whether to reconnect automatically (`YES`)
- `attemptLimit` number of times to attempt a reconnect (Infinite)
- `reconnectionDelay` how long to wait before attempting a new
reconnection (`1`)
- `maximumDelay` maximum amount of time to wait between
reconnections (`5`). Each attempt increases the reconnection by
the amount specified by `reconnectionDelay`.
- `timeout` connection timeout before an `onReconnectionError` event is emitted (`20`)

## Properties

#### void (^onConnect)()

Called upon connecting.

#### void (^onDisconnect)()

Called upon a disconnection.

#### void (^onError)(NSDictionary *errorInfo)

Called upon a connection error.

#### void (^onReconnect)(NSInteger numberOfAttempts)

Called upon a successful reconnection.

#### void (^onReconnectionAttempt)(NSInteger numberOfAttempts)

Called upon an attempt to reconnect.

#### void (^onReconnectionError)(NSDictionary *errorInfo)

Called upon a reconnection attempt error.

## Responders

#### -(void)on:do:

Binds the given `void (^)(id)` block, `function`, to the given `event`.

`function` is called upon a firing of `event`.

## Emitters

#### -(void)emit:...

Fires the given `event` with then given variadic arguments as arguments.

## License

MIT
