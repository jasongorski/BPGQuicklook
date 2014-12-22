//
//  BPGDecoder.h
//  BPGQuicklook
//
//  Created by Jason Gorski on 2014-12-22.
//  Copyright (c) 2014 Bad Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPGDecoder : NSObject

@property (readonly) NSInteger width;
@property (readonly) NSInteger height;

- (instancetype)initWithURL:(NSURL*)url;
- (BOOL)decodeInContext:(CGContextRef)context;

@end
