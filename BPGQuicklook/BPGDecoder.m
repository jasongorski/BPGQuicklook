//
//  BPGDecoder.m
//  BPGQuicklook
//
//  Created by Jason Gorski on 2014-12-22.
//  Copyright (c) 2014 Bad Dream. All rights reserved.
//

#import "BPGDecoder.h"
#import "libbpg.h"

@interface BPGDecoder ()
@property (strong) NSURL *url;
@property NSInteger width;
@property NSInteger height;
@property NSData *bpgData;
@end

@implementation BPGDecoder {
    BPGImageInfo _img_info;
    BPGDecoderContext *_img;
}

- (void)dealloc {
    if (_img) {
        bpg_decoder_close(_img);
        _img = NULL;
    }
}

- (instancetype)initWithURL:(NSURL*)url {
    self = [super init];
    if (self) {
        self.url = url;
        BOOL success = [self _init];
        if (!success)
            return nil;
    }
    return self;
}

- (BOOL)_init {
    _img = NULL;
    _width = -1;
    _height = -1;
    
    NSString *bpgPath = [_url path];
    self.bpgData = [NSData dataWithContentsOfFile:bpgPath];
 
    _img = bpg_decoder_open();
    
    if (_img == NULL || bpg_decoder_decode(_img, [_bpgData bytes], (int)[_bpgData length]) == -1)
    {
        NSLog(@"%s Could not decode image %p %p %p %lu {%@}", __FUNCTION__, _bpgData, _img, [_bpgData bytes], (unsigned long)[_bpgData length], bpgPath);
        return NO;
    }
    
    BPGImageInfo *img_info_p = &_img_info;
    bpg_decoder_get_info(_img, img_info_p);

    if (img_info_p->width <= 0 || img_info_p->height <= 0)
        return NO;

    _width = img_info_p->width;
    _height = img_info_p->height;

    return YES;
}

- (BOOL)decodeInContext:(CGContextRef)ctx {
    BPGImageInfo *img_info_p = &_img_info;
    bpg_decoder_get_info(_img, img_info_p);
    
    bpg_decoder_start(_img, BPG_OUTPUT_FORMAT_RGBA32);
    
    unsigned int rowWidth = img_info_p->width * 4;
    NSMutableData *pixData = [[NSMutableData alloc] initWithCapacity:rowWidth * img_info_p->height];
    
    unsigned char *pixbuf = [pixData mutableBytes];
    unsigned char *row = pixbuf;
    for (int y = 0; y < img_info_p->height; y++)
    {
        bpg_decoder_get_line(_img, row);
        row += rowWidth;
    }

    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, pixbuf, _width * _height * 4, NULL);
    
    CGImageRef image =  CGImageCreate(_width, _height,
                                      8, 8 * 4, _width * 4, CGColorSpaceCreateDeviceRGB(), img_info_p->has_alpha ? (CGBitmapInfo)kCGImageAlphaLast : (CGBitmapInfo)kCGImageAlphaNoneSkipLast, provider, NULL, false, kCGRenderingIntentDefault);
    
    
    CGContextDrawImage(ctx, CGRectMake(0, 0, _width, _height), image);
    
    CGContextFlush(ctx);
    
    CGImageRelease(image);
    
    return YES;
}
@end
