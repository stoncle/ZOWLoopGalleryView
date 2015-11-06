# ZOWLoopGalleryView
a loop gallery view to display image and video with easy access to add media in.

In many cases we want a gallery view that can display both image and video in. And also **Loop Scrolling**.

##Installation
Drag **ZOWLoopGalleryView.h** and **ZOWLoopGallleryView.m** to your project. And import.
```Objective-C
#import "ZOWLoopGalleryView.h"
```

##Usage
* Init a galleryView then add it.
```Objective-C
    ZOWLoopGalleryView *galleryView = [[ZOWLoopGalleryView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:galleryView];
```
* Insert media in.
It is easy to insert photo and video in a galleryView
```Objective-C
    UIImage *image1 = [UIImage imageNamed:@"lufy1.jpg"];
    [galleryView insertImage:image1];
    
    NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"]];
    [galleryView insertVideo:videoURL];
```
