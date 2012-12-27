//
//  MLDesktop.m
//  MLDesktop
//
//  Created by Zakk on 8/2/12.
//  Copyright (c) 2012 Zakk. All rights reserved.
//

#import "MLDesktop.h"
#import "CTUtil.h"
@class CTEffectProxy;



@implementation MLDesktop




+ (BOOL) isSource
{
    return YES;
}

+ (NSString *) name
{
    return @"MLDesktop";
}


- (void) setSelectedDisplay:(NSScreen *)selectedDisplay
{
    
    _selectedDisplay = selectedDisplay;
    
}

-(NSScreen *)selectedDisplay
{
    return _selectedDisplay;
}


- (void) initCGStream
{
    CGDirectDisplayID display = CGMainDisplayID();
    CGRect bounds = CGDisplayBounds(display);
    
    camtwist_queue = dispatch_get_current_queue();
    displayStreamQueue = dispatch_queue_create("MLDESKTOP_QUEUE", DISPATCH_QUEUE_SERIAL);
    
    
    NSOpenGLPixelFormatAttribute attributes[] =
	{
		NSOpenGLPFAPixelBuffer,
		NSOpenGLPFANoRecovery,
		NSOpenGLPFAAccelerated,
		NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute) 24,
		(NSOpenGLPixelFormatAttribute) 0
	};
	
    NSOpenGLPixelFormat *fmt = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
    oglctx = [[NSOpenGLContext alloc] initWithFormat:fmt shareContext:[[CamTwist instance] sharedGLContext]];
    
    CGLContextObj cgl_ctx = (CGLContextObj) [oglctx CGLContextObj];
    CGLSetCurrentContext(cgl_ctx);
    
    glViewport (0, 0, bounds.size.width, bounds.size.height);
    glMatrixMode (GL_PROJECTION);
    glLoadIdentity ();
    glOrtho (0, bounds.size.width, 0, bounds.size.height, -1, 1);
    glMatrixMode (GL_MODELVIEW);
    glLoadIdentity ();
    
    CVOpenGLBufferCreate (nil, bounds.size.width, bounds.size.height, nil, &backingBuffer);
    CVOpenGLBufferAttach (backingBuffer, cgl_ctx, 0, 0, 0);
    
    [CTContext clearContext:oglctx toRed:0 green:0 blue:0 alpha:1];
        displayStreamRef = CGDisplayStreamCreateWithDispatchQueue(display, bounds.size.width, bounds.size.height, 'BGRA', nil,  displayStreamQueue, Block_copy(^(CGDisplayStreamFrameStatus status, uint64_t displayTime, IOSurfaceRef frameSurface, CGDisplayStreamUpdateRef updateRef)
        {
          if (frameSurface)
            
          {
              dispatch_sync(camtwist_queue, ^{
              IOSurfaceIncrementUseCount(frameSurface);
                  
                  
              CGLContextObj cgl_ctx = (CGLContextObj) [[[self context] oglCtx] CGLContextObj];
              CGLSetCurrentContext(cgl_ctx);
              NSUInteger width = IOSurfaceGetWidth(frameSurface);
              NSUInteger height = IOSurfaceGetHeight(frameSurface);
              GLuint newTextureForSurface;
              glPushAttrib(GL_TEXTURE_BIT);
              glGenTextures(1, &newTextureForSurface);
              glBindTexture(GL_TEXTURE_RECTANGLE_ARB, newTextureForSurface);
              
              CGLTexImageIOSurface2D(cgl_ctx, GL_TEXTURE_RECTANGLE_ARB, GL_RGBA, width, height, GL_BGRA, GL_UNSIGNED_BYTE, frameSurface, 0);
              
              [CTContext drawTexture:newTextureForSurface fromRect:CGRectMake(0,0,width,height) toContext:oglctx inRect:CGRectMake(0,0,width,height) flipped:YES mirrored:NO];
                  IOSurfaceDecrementUseCount(frameSurface);
              glPopAttrib();
              });
              
          }
        })
                                                              
                                                              
                                                              
                                                              
                                                              );
    CGDisplayStreamStart(displayStreamRef);
    
}


- (void) doit
{
    if (!displayStreamRef)
    {
        [self initCGStream];
    }
    
    [CTContext drawPBuffer:backingBuffer toContext:[[self context] oglCtx] flipped:NO mirrored:NO];
}

- (NSView *) inspectorView
{
	return [viewController view];
}



- (void) initConfig
{
    
}


- (id) initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    flipped = YES;
    [self  initConfig];
    return [[CTEffectProxy proxyWithRealMcCoy:self] retain];
    
    
}
    
- (id) initWithContext:(CTContext *)ctContext
{
    self = [super initWithContext:ctContext];
    flipped = YES;
    [self initConfig];
    
    return [[CTEffectProxy proxyWithRealMcCoy:self] retain];
}


@end
