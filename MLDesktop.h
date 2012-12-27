//
//  MLDesktop.h
//  MLDesktop
//
//  Created by Zakk on 8/2/12.
//  Copyright (c) 2012 Zakk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CTEffect.h"

@interface MLDesktop : CTEffect
{
    BOOL flipped;
    CGDisplayStreamRef displayStreamRef;
    dispatch_queue_t displayStreamQueue;
    CVOpenGLBufferRef backingBuffer;
    NSOpenGLContext *oglctx;
    dispatch_queue_t camtwist_queue;
    
    NSViewController *viewController;
    
    
}




@end
