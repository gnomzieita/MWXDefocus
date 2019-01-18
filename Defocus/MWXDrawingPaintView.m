//
//  MWXDrawingPaintView.m
//  DefocusDemo
//
//  Created by Chris Webb on 2/24/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "MWXDrawingPaintView.h"

@interface MWXDrawingPaintView ()

@property (nonatomic, strong, readonly) UIBezierPath *path;
@property (nonatomic, assign) CGPoint endPoint;
@property (nonatomic, assign) BOOL hasDrawnRect;

@end

@implementation MWXDrawingPaintView


#pragma mark - Overrides

- (void)setDrawnImage:(UIImage *)drawnImage {
    _drawnImage = drawnImage;
    [self setNeedsDisplay];
}

- (CGFloat)brushRadius {
    return self.path.lineWidth;
}

- (void)setBrushRadius:(CGFloat)brushRadius {
    self.path.lineWidth = brushRadius;
}

#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    _path = [UIBezierPath bezierPath];
    _path.lineCapStyle = kCGLineCapRound;
    self.intensity = 1.0;
}

#pragma mark - Public

- (void)startAtPoint:(CGPoint)point {
    CGPoint translatedPoint = [self translatePoint:point];
    
    [self.path moveToPoint:translatedPoint];
}

- (void)drawToPoint:(CGPoint)point {
    CGPoint translatedPoint = [self translatePoint:point];
    self.endPoint = translatedPoint;
    [self.path addLineToPoint:translatedPoint];
    [self setNeedsDisplay];
    [self drawBitmap];
    [self.path removeAllPoints];
    [self.path moveToPoint:translatedPoint];
    
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    [_drawnImage drawInRect:rect];
}

- (void)drawBitmap {
    UIGraphicsBeginImageContextWithOptions(self.canvasSize, NO, 0.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    if (!ctx) {
        NSLog(@"%@ tried to draw with no context", [self class]);
        return;
    }
    
    if (self.eraseMode) {
        CGContextSetBlendMode(ctx, kCGBlendModeClear);
        [_drawnImage drawAtPoint:CGPointZero];
        
        [self.path stroke];
    } else {
        CGPoint gradCenter = self.endPoint;
        CGFloat gradRadius = self.brushRadius;
        
        size_t gradLocationsNum = 2;
        CGFloat gradLocations[2] = {0.5, 1.0};
        CGFloat gradColors[8] = {0, 0, 0, self.intensity, 0, 0, 0, 0};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum);
        CGColorSpaceRelease(colorSpace);
        
        CGContextSetBlendMode(ctx, kCGBlendModeNormal);
        CGContextDrawRadialGradient (ctx, gradient, gradCenter, 0, gradCenter, gradRadius, kCGGradientDrawsBeforeStartLocation);
        CGGradientRelease(gradient);
        
        [_drawnImage drawAtPoint:CGPointZero];
    }
    
    _drawnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (CGPoint)translatePoint:(CGPoint)point {
    CGPoint newPoint = point;
    CGSize imageSize = self.canvasSize;
    CGSize scale = CGSizeMake(imageSize.width / CGRectGetWidth(self.bounds), imageSize.height / CGRectGetHeight(self.bounds));
    newPoint.x *= scale.width;
    newPoint.y *= scale.height;
    return newPoint;
}
@end
