//
//  SocketIO.m
//  SocketIO
//
//  Created by Patrick Perini on 6/13/14.
//
//

#import <XCTest/XCTest.h>
#import "SIOSocket.h"

@interface SocketIO : XCTestCase

@end

@implementation SocketIO

- (void)testConnectToLocalhost {
    XCTestExpectation *connectionExpectation = [self expectationWithDescription: @"should connect to localhost"];
    [SIOSocket socketWithHost: @"http://localhost:3000" response: ^(SIOSocket *socket) {
        XCTAssertNotNil(socket, @"socket could not connect to localhost");
        [connectionExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout: 10 handler: nil];
}

- (void)testFalse {
    XCTestExpectation *falseExpectation = [self expectationWithDescription: @"should work with false"];
    [SIOSocket socketWithHost: @"http://localhost:3000" response: ^(SIOSocket *socket) {
        XCTAssertNotNil(socket, @"socket could not connect to localhost");
        [socket on: @"false" callback: ^(SIOParameterArray *args)
        {
            XCTAssertFalse([[args firstObject] boolValue], @"response not false");
            [falseExpectation fulfill];
        }];

        [socket emit: @"false"];
    }];

    [self waitForExpectationsWithTimeout: 10 handler: nil];
}

- (void)testUTF8MultibyteCharacters
{
    XCTestExpectation *utf8MultibyteCharactersExpectation = [self expectationWithDescription: @"should work with utf8 multibyte characters"];
    NSArray *correctStrings = @[
        @"てすと",
        @"Я Б Г Д Ж Й",
        @"Ä ä Ü ü ß",
        @"utf8 — string",
        @"utf8 — string"
    ];

    [SIOSocket socketWithHost: @"http://localhost:3000" response: ^(SIOSocket *socket) {
        XCTAssertNotNil(socket, @"socket could not connect to localhost");

        __block NSInteger numberOfCorrectStrings = 0;
        [socket on: @"takeUtf8" callback: ^(SIOParameterArray *args) {
            NSString *string = [args firstObject];
            XCTAssertEqualObjects(string, correctStrings[numberOfCorrectStrings], @"%@ is not equal to %@", string, correctStrings);
            numberOfCorrectStrings++;

            if (numberOfCorrectStrings == [correctStrings count]) {
                [utf8MultibyteCharactersExpectation fulfill];
            }
        }];

        [socket emit: @"getUtf8"];
    }];

    [self waitForExpectationsWithTimeout: 10 handler: nil];
}

- (void)testEmitDateAsString {
    XCTestExpectation *stringExpectation = [self expectationWithDescription: @"should emit date as a string"];
    [SIOSocket socketWithHost: @"http://localhost:3000" response: ^(SIOSocket *socket) {
        XCTAssertNotNil(socket, @"socket could not connect to localhost");
        [socket on: @"takeDate" callback: ^(SIOParameterArray *args) {
            NSString *string = [args firstObject];
            XCTAssert([string isKindOfClass: [NSString class]], @"%@ is not a string", string);
            [stringExpectation fulfill];
        }];

        [socket emit: @"getDate"];
    }];

    [self waitForExpectationsWithTimeout: 10 handler: nil];
}

- (void)testEmitDateAsObject {
    XCTestExpectation *stringExpectation = [self expectationWithDescription: @"should emit date as a string"];
    [SIOSocket socketWithHost: @"http://localhost:3000" response: ^(SIOSocket *socket) {
        XCTAssertNotNil(socket, @"socket could not connect to localhost");
        [socket on: @"takeDateObj" callback: ^(SIOParameterArray *args) {
            NSDictionary *dictionary = [args firstObject];
            XCTAssert([dictionary isKindOfClass: [NSDictionary class]], @"%@ is not a dictionary", dictionary);
            XCTAssert([[dictionary objectForKey: @"date"] isKindOfClass: [NSString class]], @"%@['date'] is not a string", dictionary);

            [stringExpectation fulfill];
        }];

        [socket emit: @"getDateObj"];
    }];

    [self waitForExpectationsWithTimeout: 10 handler: nil];
}

- (void)testEmitMultiWord {
    XCTestExpectation *stringExpectation = [self expectationWithDescription: @"should emit multi word"];
    [SIOSocket socketWithHost: @"http://localhost:3000" response: ^(SIOSocket *socket) {
         XCTAssertNotNil(socket, @"socket could not connect to localhost");
         [socket on: @"multi word" callback: ^(SIOParameterArray *args) {
             NSString *response = [args firstObject];
             XCTAssert([response isEqualToString: @"word"], @"%@ != 'word'", response);
             
             [stringExpectation fulfill];
         }];
         
         [socket emit: @"multi word"];
     }];
    
    [self waitForExpectationsWithTimeout: 10 handler: nil];
}

- (void)testEmitMultiWordWithCharacters {
    XCTestExpectation *stringExpectation = [self expectationWithDescription: @"should emit multi word"];
    [SIOSocket socketWithHost: @"http://localhost:3000" response: ^(SIOSocket *socket) {
        XCTAssertNotNil(socket, @"socket could not connect to localhost");
        [socket on: @"multi-word" callback: ^(SIOParameterArray *args) {
            NSString *response = [args firstObject];
            XCTAssert([response isEqualToString: @"word"], @"%@ != 'word'", response);
            
            [stringExpectation fulfill];
        }];
        
        [socket emit: @"multi-word"];
    }];
    
    [self waitForExpectationsWithTimeout: 10 handler: nil];
}

- (void)testBinaryData {
    XCTestExpectation *blobExpectation = [self expectationWithDescription: @"should send binary data as Blob"];
    [SIOSocket socketWithHost: @"http://localhost:3000" response: ^(SIOSocket *socket) {
        XCTAssertNotNil(socket, @"socket could not conenct to localhost");
        [socket on: @"back" callback: ^(SIOParameterArray *args) {
            [blobExpectation fulfill];
        }];
        
        [socket emit: @"blob" args: @[[@"hello world" dataUsingEncoding: NSUTF8StringEncoding]]];
    }];
    
    [self waitForExpectationsWithTimeout: 10 handler: nil];
}

@end
