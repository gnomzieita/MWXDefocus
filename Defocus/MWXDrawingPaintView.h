//
//  MWXDrawingPaintView.h
//  DefocusDemo
//
//  Created by Chris Webb on 2/24/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MWXDrawingPaintView : UIView

@property (nonatomic, assign) CGSize canvasSize;
@property (nonatomic, assign) BOOL eraseMode;
@property (nonatomic, assign) CGFloat brushRadius;
@property (nonatomic, assign) CGFloat intensity;
@property (nonatomic, strong, readonly) UIImage *drawnImage;

- (void)startAtPoint:(CGPoint)point;
- (void)drawToPoint:(CGPoint)point;

@end
