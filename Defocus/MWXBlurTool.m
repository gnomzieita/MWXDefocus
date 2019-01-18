//
//  MWXBlurFilter.m
//  DefocusDemo
//
//  Created by Chris Webb on 2/24/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "MWXBlurTool.h"

@interface MWXBlurTool ()

@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) dispatch_queue_t blurQueue;
@property (nonatomic, assign) NSInteger lastBlurUpdateID;

@end

@implementation MWXBlurTool

- (instancetype)init {
    self = [super init];
    if (self) {
        _blurQueue = dispatch_queue_create("MWXBlurToolQueue", DISPATCH_QUEUE_SERIAL);
        
        EAGLContext *myEAGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        NSDictionary *options = @{kCIContextUseSoftwareRenderer: @NO};
        _context = [CIContext contextWithEAGLContext:myEAGLContext options:options];
    }
    return self;
}

- (void)blurImage:(UIImage *)image radius:(CGFloat)blurRadius completionHandler:(void (^)(UIImage *, NSError *))completionHandler {
    [self blurImage:image radius:blurRadius imageMask:nil completionHandler:completionHandler];
}

- (void)blurImage:(UIImage *)image radius:(CGFloat)blurRadius imageMask:(UIImage *)imageMask completionHandler:(void (^)(UIImage *, NSError *))completionHandler {
    static NSInteger updateCounter = 0;
    
//    NSInteger currentId = updateCounter;
//    self.lastBlurUpdateID = currentId;
    
    dispatch_async(self.blurQueue, ^{
//        if (currentId != self.lastBlurUpdateID) {
//            return;
//        }
        
        UIImageOrientation originalOrientation = image.imageOrientation;
        CGFloat originalScale = image.scale;
        
        CGFloat blurRadiusScaledForSize = blurRadius * (image.size.width / 1024);
    
        CIImage *workingImage = [CIImage imageWithCGImage:image.CGImage];
        
        CGAffineTransform clampTransform = CGAffineTransformMakeScale(1.0, 1.0);
        NSValue *encodedClampTransform = [NSValue valueWithBytes:&clampTransform objCType:@encode(CGAffineTransform)];
        
        CIFilter *affineClampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
        [affineClampFilter setValue:workingImage forKey:kCIInputImageKey];
        [affineClampFilter setValue:encodedClampTransform forKey:@"inputTransform"];
        
        CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
        [blurFilter setValue:[affineClampFilter outputImage] forKey:kCIInputImageKey];
        [blurFilter setValue:@(blurRadiusScaledForSize) forKey:@"inputRadius"];

        CIImage *blurredImage = [[blurFilter outputImage] imageByCroppingToRect:workingImage.extent];
        
        CIImage *outputImage = nil;

        if (imageMask) {
            
            CIImage *maskImage = [CIImage imageWithCGImage:imageMask.CGImage];
            
            CGFloat scale = CGRectGetWidth(blurredImage.extent) / CGRectGetWidth(maskImage.extent);
            
            CIFilter *maskTransformFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
            [maskTransformFilter setValue:maskImage forKey:kCIInputImageKey];
            [maskTransformFilter setValue:@(scale) forKey:@"inputScale"];
            [maskTransformFilter setValue:@(1.0) forKey:@"inputAspectRatio"];
            
            
            CIFilter *blendFilter = [CIFilter filterWithName:@"CIBlendWithAlphaMask"];
            [blendFilter setValue:blurredImage forKey:@"inputImage"];
            [blendFilter setValue:workingImage forKey:@"inputBackgroundImage"];
            [blendFilter setValue:maskTransformFilter.outputImage forKey:@"inputMaskImage"];
            outputImage = [blendFilter outputImage];
        } else {
            outputImage = blurredImage;
        }
        
        CGImageRef cgImage = [self.context createCGImage:outputImage fromRect:workingImage.extent];
        
        UIImage *filteredImage = [UIImage imageWithCGImage:cgImage scale:originalScale orientation:originalOrientation];
        CGImageRelease(cgImage);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(filteredImage, nil);
        });
    });
}

@end
