#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
@import Cocoa;
#import "BPGDecoder.h"

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{    
    BPGDecoder *bpgDecoder = [[BPGDecoder alloc] initWithURL:(__bridge NSURL*)url];
    if (!bpgDecoder) {
        return kUnknownType;
    }
    CGSize imageSize = CGSizeMake(bpgDecoder.width, bpgDecoder.height);
    
    CGContextRef ctx = QLThumbnailRequestCreateContext(thumbnail, imageSize, true, options);
    if (!ctx) {
        NSLog(@"%s unable to QLThumbnailRequestCreateContext for %dx%d", __FUNCTION__,
              (int)bpgDecoder.width, (int)bpgDecoder.height);
        return kUnknownType;
    }
    [bpgDecoder decodeInContext:ctx];
     
    QLThumbnailRequestFlushContext(thumbnail, ctx);
    CFRelease(ctx);
    
    return noErr;
}

void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail)
{
    // Implement only if supported
}
