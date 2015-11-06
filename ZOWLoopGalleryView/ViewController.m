//
//  ViewController.m
//  ZOWLoopGalleryView
//
//  Created by stoncle on 11/6/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import "ViewController.h"
#import "ZOWLoopGalleryView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    ZOWLoopGalleryView *galleryView = [[ZOWLoopGalleryView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:galleryView];
    
    UIImage *image1 = [UIImage imageNamed:@"lufy1.jpg"];
    UIImage *image2 = [UIImage imageNamed:@"lufy2.jpg"];
    NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"]];
    
    [galleryView insertImage:image1];
    [galleryView insertImage:image2];
    [galleryView insertVideo:videoURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
