//
//  ViewController.h
//  DefocusDemo
//
//  Created by Chris Webb on 2/23/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MWXDefocusView;

@interface ViewController : UIViewController

//@property (nonatomic, weak) IBOutlet UIImageView *originalView;
//@property (nonatomic, weak) IBOutlet UIImageView *blurredView;
@property (nonatomic, weak) IBOutlet MWXDefocusView *defocusView;
@property (nonatomic, weak) IBOutlet UISlider *brushSizeSlider;

@end

