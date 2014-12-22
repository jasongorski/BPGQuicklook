#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
@import Cocoa;
#import "BPGDecoder.h"

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    BPGDecoder *bpgDecoder = [[BPGDecoder alloc] initWithURL:(__bridge NSURL*)url];
    if (!bpgDecoder) {
        return kUnknownType;
    }
    
    CGSize imageSize = CGSizeMake(bpgDecoder.width, bpgDecoder.height);
    
    CGContextRef ctx = QLPreviewRequestCreateContext(preview, imageSize, true, options);
    if (!ctx) {
        NSLog(@"%s unable to QLPreviewRequestCreateContext for %dx%d", __FUNCTION__,
              (int)bpgDecoder.width, (int)bpgDecoder.height);
        return kUnknownType;
    }
    
    [bpgDecoder decodeInContext:ctx];
    
    QLPreviewRequestFlushContext(preview, ctx);
    
    CFRelease(ctx);
    
    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
