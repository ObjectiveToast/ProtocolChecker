//
//  TWTProtocolCheckerTests.m
//  ProtocolChecker
//
//  Created by Prachi Gauriar on 5/11/2014.
//  Copyright (c) 2014 Two Toasters, LLC.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@import XCTest;

#import "TWTProtocolChecker.h"


@protocol TWTTestProtocol <NSObject>

@property (nonatomic, strong) id requiredProperty1;

- (void)requiredInstanceMethod1;
+ (void)requiredClassMethod1;

@optional

@property (nonatomic, strong) id optionalProperty1;

- (void)optionalInstanceMethod1;
+ (void)optionalClassMethod1;

@end


#pragma mark -

@interface TWTTestObject : NSObject <TWTTestProtocol>

@property (nonatomic, strong) id requiredProperty1;
@property (nonatomic, strong) id optionalProperty1;
@property (nonatomic, strong) id nonProtocolProperty;

- (void)nonProtocolInstanceMethod;
+ (void)nonProtocolClassMethod;

@end


@implementation TWTTestObject

- (void)requiredInstanceMethod1 { }
+ (void)requiredClassMethod1 { }
- (void)optionalInstanceMethod1 { }
+ (void)optionalClassMethod1 { }
- (void)nonProtocolInstanceMethod { }
+ (void)nonProtocolClassMethod { }

@end


#pragma mark -

@interface TWTProtocolCheckerTests : XCTestCase

@end


@implementation TWTProtocolCheckerTests

- (void)testInstanceChecking
{
    TWTTestObject *realObject = [[TWTTestObject alloc] init];
    id protocolChecker = [TWTProtocolChecker protocolCheckerWithTarget:realObject protocol:@protocol(TWTTestProtocol)];

    XCTAssertNoThrow([protocolChecker requiredInstanceMethod1], @"Does not allow required protocol instance method");
    XCTAssertNoThrow([protocolChecker optionalInstanceMethod1], @"Does not allow optional protocol instance method");

    XCTAssertNoThrow([protocolChecker requiredProperty1], @"Does not allow required protocol property getter");
    XCTAssertNoThrow([protocolChecker setRequiredProperty1:nil], @"Does not allow required protocol property setter");

    XCTAssertNoThrow([protocolChecker optionalProperty1], @"Does not allow optional protocol property getter");
    XCTAssertNoThrow([protocolChecker setOptionalProperty1:nil], @"Does not allow optional protocol property setter");

    XCTAssertThrows([protocolChecker nonProtocolInstanceMethod], @"Allows non-protocol instance method");
}


- (void)testClassChecking
{
    id protocolChecker = [TWTProtocolChecker protocolCheckerWithTarget:(id)[TWTTestObject class] protocol:@protocol(TWTTestProtocol)];

    XCTAssertNoThrow([protocolChecker requiredClassMethod1], @"Does not allow required protocol class method");
    XCTAssertNoThrow([protocolChecker optionalClassMethod1], @"Does not allow optional protocol class method");
    XCTAssertThrows([protocolChecker nonProtocolClassMethod], @"Allows non-protocol class method");
}

@end
