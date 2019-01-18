//
//  MWXDefocusView.m
//  DefocusDemo
//
//  Created by Chris Webb on 2/24/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "MWXDefocusView.h"
#import "MWXBlurTool.h"

@implementation UIView (MWXPinToEdge)

- (NSLayoutConstraint *)mwx_constraintPinnedToSuperviewEdge:(NSLayoutAttribute)edge {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:edge relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:edge multiplier:1.0 constant:0];
    [self.superview addConstraint:constraint];
    return constraint;
}

- (NSArray<NSLayoutConstraint *> *)mwx_pinToSuperviewEdges {
    NSMutableArray<NSLayoutConstraint *> *constraints = [[NSMutableArray alloc] init];
    [constraints addObject:[self mwx_constraintPinnedToSuperviewEdge:NSLayoutAttributeTop]];
    [constraints addObject:[self mwx_constraintPinnedToSuperviewEdge:NSLayoutAttributeLeft]];
    [constraints addObject:[self mwx_constraintPinnedToSuperviewEdge:NSLayoutAttributeBottom]];
    [constraints addObject:[self mwx_constraintPinnedToSuperviewEdge:NSLayoutAttributeRight]];
    return [constraints copy];
}

@end

@interface MWXDefocusView ()

@property (nonatomic, assign) BOOL hasSetConstraints;
@property (nonatomic, strong, readwrite) MWXDrawingPaintView *paintView;
@property (nonatomic, strong, readwrite) UIImageView *normalImageView;
@property (nonatomic, strong, readwrite) UIImageView *blurredImageView;

@property (nonatomic, strong) MWXBlurTool *blurTool;

@end

@interface MWXDrawingPaintView (MWXDefocusViewExposure)

@property (nonatomic, strong) UIImage *drawnImage;

@end

@implementation MWXDefocusView

- (void)setMode:(MWXDrawingMode)newMode {
    if (newMode == MWXDrawingModeNone) {
        self.userInteractionEnabled = NO;
    } else {
        self.userInteractionEnabled = YES;
    }
    _mode = newMode;
}

- (void)setBrushSize:(CGFloat)brushSize {
    _brushSize = brushSize;
    self.paintView.brushRadius = _brushSize;
}

- (void)setDefocusImage:(UIImage *)defocusImage {
    self.paintView.drawnImage = defocusImage;
    [self setNeedsUpdateMask:YES];
    [self setNeedsLayout];
}

#pragma mark - Lazy inits

- (MWXDrawingPaintView *)paintView {
    if (_paintView == nil) {
        _paintView = [[MWXDrawingPaintView alloc] init];
//        _paintView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _paintView;
}

- (UIImageView *)normalImageView {
    if (_normalImageView == nil) {
        _normalImageView = [[UIImageView alloc] init];
        _normalImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _normalImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _normalImageView;
}

- (UIImageView *)blurredImageView {
    if (_blurredImageView == nil) {
        _blurredImageView = [[UIImageView alloc] init];
        _blurredImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _blurredImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _blurredImageView;
}

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = YES;
        self.needsUpdateMask = YES;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    _mode = MWXDrawingModeDraw;
    _blurRadius = 4.0;
    
    _intensityWithoutForceCapability = 0.1;
    _intensityAtMinimumForce = 0.01;
    _intensityAtMaximumForce = 0.4;
    
    self.brushSize = 50.0;
    
    _blurTool = [[MWXBlurTool alloc] init];
    
//
    
    [self addSubview:self.normalImageView];
    [self addSubview:self.blurredImageView];
    [self addSubview:self.paintView];
}

- (void)updateConstraints {
    if (!_hasSetConstraints) {
        [self.normalImageView mwx_pinToSuperviewEdges];
        [self.blurredImageView mwx_pinToSuperviewEdges];
        
        _hasSetConstraints = YES;
    }
    
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!CGRectIsEmpty(self.blurredImageView.bounds) && !self.blurredImageView.maskView) {
        self.blurredImageView.maskView = self.paintView;
    }
    
    if (self.needsUpdateMask && self.blurredImageView.maskView) {
        self.needsUpdateMask = NO;
    }
    
    self.paintView.frame = self.blurredImageView.bounds;
}

#pragma mark - Public

- (void)setImageForPreview:(UIImage *)image completionHandler:(void (^)())completionHandler {
    [self setImageForPreview:image postBlurHandler:nil completionHandler:completionHandler];
}

- (void)setImageForPreview:(UIImage *)image postBlurHandler:(UIImage *(^)(UIImage *))postBlurHandler completionHandler:(void (^)())completionHandler {
    [self.blurTool blurImage:image radius:self.blurRadius completionHandler:^(UIImage *blurredImage, NSError *error) {
        UIImage *finalNormalImage = nil;
        UIImage *finalBlurredImage = nil;
        if (postBlurHandler) {
            finalNormalImage = postBlurHandler(image);
            finalBlurredImage = postBlurHandler(blurredImage);
        } else {
            finalNormalImage = image;
            finalBlurredImage = blurredImage;
        }
        
        if (!error) {
            self.normalImageView.image = finalNormalImage;
            self.blurredImageView.image = finalBlurredImage;
            self.paintView.canvasSize = self.bounds.size;
        }
        
        if (completionHandler) {
            completionHandler();
        }
    }];
}

- (UIImage *)renderComposedImage:(UIImage *)sourceImage {
    __block UIImage *finalImage = sourceImage;
    
    if (self.paintView.drawnImage != nil) {
        NSLog(@"%@", self.paintView.drawnImage);
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [self.blurTool blurImage:sourceImage radius:self.blurRadius imageMask:self.paintView.drawnImage completionHandler:^(UIImage *blurredImage, NSError *error) {
            finalImage = blurredImage;
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    return finalImage;
}

#pragma mark - Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];

    self.paintView.eraseMode = (self.mode == MWXDrawingModeErase);
    [self.paintView startAtPoint:point];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        CGFloat relativeForce = touch.force / touch.maximumPossibleForce;
        CGFloat intensity = self.intensityAtMinimumForce + (self.intensityAtMaximumForce - self.intensityAtMinimumForce) * relativeForce;
        
        self.paintView.intensity = intensity;
    } else {
        self.paintView.intensity = self.intensityWithoutForceCapability;
    }
    
    [self.paintView drawToPoint:point];
    [self setNeedsLayout];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    [self.paintView drawToPoint:point];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

@end
