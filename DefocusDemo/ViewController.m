//
//  ViewController.m
//  DefocusDemo
//
//  Created by Chris Webb on 2/23/16.
//  Copyright © 2016 MuseWorks. All rights reserved.
//

#import "ViewController.h"
#import "MWXDefocusView.h"

@interface ViewController ()

@property (nonatomic, assign) BOOL hasSetImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.hasSetImage) {
        [self.defocusView setImage:[UIImage imageNamed:@"chess-original"]];
        self.hasSetImage = YES;
    }
    self.brushSizeSlider.value = self.defocusView.brushSize;
}


- (IBAction)didChangeMode:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.defocusView.mode = MWXDrawingModeDraw;
    } else {
        self.defocusView.mode = MWXDrawingModeErase;
    }
}
- (IBAction)didChangeBrushSize:(UISlider *)sender {
    self.defocusView.brushSize = sender.value;
}

@end
