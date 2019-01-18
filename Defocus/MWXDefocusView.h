//
//  MWXDefocusView.h
//  DefocusDemo
//
//  Created by Chris Webb on 2/24/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWXDrawingPaintView.h"

typedef NS_ENUM(NSInteger, MWXDrawingMode) {
    MWXDrawingModeDraw,
    MWXDrawingModeErase,
    MWXDrawingModeNone
};

@protocol MWXDefocusViewDelegate;

@interface MWXDefocusView : UIView

@property (nonatomic, assign) MWXDrawingMode mode;
@property (nonatomic, assign) BOOL needsUpdateMask;
@property (nonatomic, assign) CGFloat blurRadius;
@property (nonatomic, assign) CGFloat brushSize;
@property (nonatomic, assign) CGFloat intensityWithoutForceCapability;
@property (nonatomic, assign) CGFloat intensityAtMinimumForce;
@property (nonatomic, assign) CGFloat intensityAtMaximumForce;

@property (nonatomic, strong, readonly) MWXDrawingPaintView *paintView;
@property (nonatomic, strong, readonly) UIImageView *normalImageView;
@property (nonatomic, strong, readonly) UIImageView *blurredImageView;

- (void)setDefocusImage:(UIImage *)defocusImage;
- (void)setImageForPreview:(UIImage *)image completionHandler:(void (^)())completionHandler;
- (void)setImageForPreview:(UIImage *)image postBlurHandler:(UIImage * (^)(UIImage *image))postBlurHandler completionHandler:(void (^)())completionHandler;
- (UIImage *)renderComposedImage:(UIImage *)image;

@end

@protocol MWXDefocusViewDelegate <NSObject>

@end