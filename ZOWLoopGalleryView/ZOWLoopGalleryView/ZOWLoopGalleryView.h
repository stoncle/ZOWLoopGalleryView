//
//  ZOWLoopGalleryView.h
//  ZOWLoopGalleryView
//
//  Created by stoncle on 11/6/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZOWLoopGalleryView : UIView

- (instancetype)initWithImages:(NSArray<UIImage *> *)imageArray;

- (void)insertImage:(UIImage *)image;
- (void)insertVideo:(NSURL *)videoPath;

- (id)currentDisplayedMedia;

@end

@interface ZOWLoopGalleryViewImageCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@end

@interface ZOWLoopGalleryViewVideoCell : UICollectionViewCell

// local file url, fill this property with [NSURL fileURLWithPath:]
@property (nonatomic, copy) NSURL *videoURL;

@property (nonatomic, strong) UIImageView *previewImageView;

@end
