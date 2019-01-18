//
//  MWXBlurFilter.h
//  DefocusDemo
//
//  Created by Chris Webb on 2/24/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MWXBlurTool : NSObject

- (void)blurImage:(UIImage *)image radius:(CGFloat)blurRadius completionHandler:(void(^)(UIImage *blurredImage, NSError *error))completionHandler;
- (void)blurImage:(UIImage *)image radius:(CGFloat)blurRadius imageMask:(UIImage *)imageMask completionHandler:(void(^)(UIImage *blurredImage, NSError *error))completionHandler;

@end
