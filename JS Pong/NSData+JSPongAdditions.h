//
//  NSData+JSPongAdditions.h
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-17.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (JSPongAdditions)

- (int)rw_int32AtOffset:(size_t)offset;
- (short)rw_int16AtOffset:(size_t)offset;
- (char)rw_int8AtOffset:(size_t)offset;
- (NSString *)rw_stringAtOffset:(size_t)offset bytesRead:(size_t *)amount;

@end

@interface NSMutableData (JSPongAdditions)

- (void)rw_appendInt32:(int)value;
- (void)rw_appendInt16:(short)value;
- (void)rw_appendInt8:(char)value;
- (void)rw_appendString:(NSString *)string;

@end