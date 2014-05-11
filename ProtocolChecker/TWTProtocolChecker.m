//
//  TWTProtocolChecker.m
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

#import "TWTProtocolChecker.h"

@import ObjectiveC.runtime;


#pragma mark Helper Functions

/*!
 @abstract Recursively accumulates and returns the selectors in the specified protocol.
 @discussion This function recursively adds all methods in the protocol and its protocol list 
     (and their protocol lists) to the specified set of selectors.
 @param protocol The protocol whose selectors are being returned.
 @param instanceMethods Whether the function should accumulate instance methods (YES) or class
     methods (NO).
 @param accumulatedSelectorStrings The mutable set in which to return the accumulated selectors.
     Selectors are added to the set in string form. If this parameter is nil, a new empty set 
     will be used to accumulate the strings.
 @result The set of accumulated selectors in string form.
 */
static NSMutableSet *TWTProtocolAccumulateSelectorStrings(Protocol *protocol, BOOL instanceMethods, NSMutableSet *accumulatedSelectorStrings)
{
    if (!accumulatedSelectorStrings) {
        accumulatedSelectorStrings = [[NSMutableSet alloc] init];
    }

    // Add required methods
    unsigned int methodCount = 0;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, YES, instanceMethods, &methodCount);
    for (unsigned int i = 0; i < methodCount; ++i) {
        [accumulatedSelectorStrings addObject:NSStringFromSelector(methods[i].name)];
    }

    free(methods);

    // Add optional methods
    methodCount = 0;
    methods = protocol_copyMethodDescriptionList(protocol, NO, instanceMethods, &methodCount);
    for (unsigned int i = 0; i < methodCount; ++i) {
        [accumulatedSelectorStrings addObject:NSStringFromSelector(methods[i].name)];
    }

    free(methods);

    // Add protocols this protocol conforms to
    unsigned int protocolCount = 0;
    Protocol *__unsafe_unretained *protocolList = protocol_copyProtocolList(protocol, &protocolCount);
    for (unsigned int i = 0; i < protocolCount; ++i) {
        TWTProtocolAccumulateSelectorStrings(protocolList[i], instanceMethods, accumulatedSelectorStrings);
    }

    free(protocolList);

    return accumulatedSelectorStrings;
}


#pragma mark -

@interface TWTProtocolChecker ()
@property (nonatomic, copy) NSSet *protocolSelectors;
@end


#pragma mark -

@implementation TWTProtocolChecker

+ (instancetype)protocolCheckerWithTarget:(NSObject *)target protocol:(Protocol *)protocol
{
    return [[self alloc] initWithTarget:target protocol:protocol];
}


- (instancetype)initWithTarget:(NSObject *)target protocol:(Protocol *)protocol
{
    NSParameterAssert(target);
    NSParameterAssert(protocol);

    _target = target;
    _protocol = protocol;

    // Get and cache the selectors in the protocol. If the target is a class object, get class methods.
    // Otherwise, get instance methods.
    BOOL isInstance = [target isMemberOfClass:target.class];
    _protocolSelectors = [TWTProtocolAccumulateSelectorStrings(protocol, isInstance, nil) copy];

    return self;
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    return [self.protocolSelectors containsObject:NSStringFromSelector(selector)] ? [self.target methodSignatureForSelector:selector] : nil;
}


- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation invokeWithTarget:self.target];
}

@end
