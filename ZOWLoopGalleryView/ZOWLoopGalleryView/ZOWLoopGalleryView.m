//
//  ZOWLoopGalleryView.m
//  ZOWLoopGalleryView
//
//  Created by stoncle on 11/6/15.
//  Copyright © 2015 stoncle. All rights reserved.
//

#import "ZOWLoopGalleryView.h"
#import <AVFoundation/AVFoundation.h>

#define kImageCellIdentifier @"imageCell"
#define kVideoCellIdentifier @"videoCell"

@interface ZOWLoopGalleryView() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *galleryContent;
@property (nonatomic, strong) NSMutableArray<UIImage *> *galleryPlaceholer;

@property (nonatomic, assign) NSInteger prevPage;
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, strong) AVPlayerItem *playerItem;

@end

@implementation ZOWLoopGalleryView

- (instancetype)initWithImages:(NSArray<UIImage *> *)imageArray
{
    if(self = [super init])
    {
        _galleryContent = [imageArray mutableCopy];
        _galleryPlaceholer = [[NSMutableArray alloc] init];
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        _galleryContent = [[NSMutableArray alloc] init];
        _galleryPlaceholer = [[NSMutableArray alloc] init];
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.decelerationRate = 0.8;
    _collectionView.bounces = NO;
    _collectionView.alwaysBounceHorizontal = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    
    [_collectionView registerClass:[ZOWLoopGalleryViewImageCell class] forCellWithReuseIdentifier:kImageCellIdentifier];
    [_collectionView registerClass:[ZOWLoopGalleryViewVideoCell class] forCellWithReuseIdentifier:kVideoCellIdentifier];
    
    _collectionView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    [self addSubview:_collectionView];
    
    if(!_galleryContent)
    {
        _galleryContent = [[NSMutableArray alloc] init];
    }
    
    [self configureConstraints];
    
    [self addVideoReachToEndNotification];
}

- (void)configureConstraints
{
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|[_collectionView]|"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(_collectionView)]];
    [self addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|[_collectionView]|"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(_collectionView)]];
}

#pragma mark - Public
- (id)currentDisplayedMedia
{
    NSInteger realPage = [self getRealPage:_currentPage];
    
    if(realPage >= _galleryContent.count)
    {
        return nil;
    }
    return _galleryContent[realPage];
}

#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _galleryContent.count + 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    UIImage *displayedImage = nil;
    NSURL *displayedVideoURL = nil;
    id content = nil;
    if(indexPath.row == 0)
    {
        content = _galleryContent.lastObject;
    }
    else if(indexPath.row == _galleryContent.count+1)
    {
        content = _galleryContent.firstObject;
    }
    else
    {
        content = _galleryContent[indexPath.row-1];
    }
    if(!content)
    {
        content = [UIImage imageNamed:@"icon40.png"];
    }
    
    if([content isKindOfClass:[UIImage class]])
    {
        displayedImage = (UIImage *)content;
        ZOWLoopGalleryViewImageCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:kImageCellIdentifier forIndexPath:indexPath];
        imageCell.imageView.image = displayedImage;
        cell = imageCell;
    }
    else if([content isKindOfClass:[NSURL class]])
    {
        displayedVideoURL = (NSURL *)content;
        ZOWLoopGalleryViewVideoCell *videoCell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoCellIdentifier forIndexPath:indexPath];
        NSInteger realRow = [self getRealPage:indexPath.row];
        if(realRow < _galleryPlaceholer.count)
        {
            videoCell.previewImageView.image = _galleryPlaceholer[realRow];
        }
        videoCell.videoURL = displayedVideoURL;
        cell = videoCell;
    }
    if(!cell)
    {
        cell = (ZOWLoopGalleryViewImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kImageCellIdentifier forIndexPath:indexPath];
    }
    return cell;
}

#pragma mark UICollectionViewDelegate
#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.frame.size;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat fakeFirstOffsetX = self.bounds.size.width * ((CGFloat)_galleryContent.count+1);
    CGFloat offsetX = scrollView.contentOffset.x;
    _currentPage = scrollView.contentOffset.x/self.bounds.size.width + 0.5;
    NSLog(@"stoncle debug:loop gallery current page : %ld", _currentPage);
    if(offsetX == 0)
    {
        scrollView.contentOffset = CGPointMake(self.bounds.size.width * ((CGFloat)_galleryContent.count), scrollView.contentOffset.y);
    }
    else if(offsetX == fakeFirstOffsetX)
    {
        scrollView.contentOffset = CGPointMake(self.bounds.size.width, scrollView.contentOffset.y);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(_currentPage == _prevPage)
    {
        return;
    }
    
    NSInteger realPage = [self getRealPage:_currentPage];
    if(realPage < _galleryContent.count)
    {
        if([_galleryContent[realPage] isKindOfClass:[NSURL class]])
        {
            NSURL *videoURL = (NSURL *)_galleryContent[realPage];
            [self autoPlayVideo:videoURL];
        }
        else
        {
            if(_player)
            {
                [_player pause];
            }
            if(_playerLayer && _playerLayer.superlayer)
            {
                [_playerLayer removeFromSuperlayer];
            }
        }
    }
    
    _prevPage = _currentPage;
}

- (NSInteger)getRealPage:(NSInteger)page
{
    NSInteger realPage = 0;
    if(page == 0)
    {
        realPage = _galleryContent.count-1;
    }
    else if(page == _galleryContent.count+1)
    {
        realPage = 0;
    }
    else
    {
        realPage = page - 1;
    }
    return realPage;
}

- (void)autoPlayVideo:(NSURL *)url
{
    ZOWLoopGalleryViewVideoCell *videoCell = (ZOWLoopGalleryViewVideoCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentPage inSection:0]];
    NSURL *videoURL = url;
    if(!videoCell)
    {
        return;
    }
    
    _asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    _playerItem = [AVPlayerItem playerItemWithAsset:_asset];
    
    if(_playerLayer && _playerLayer.superlayer)
    {
        [_playerLayer removeFromSuperlayer];
    }
    
    if(_player)
    {
        [_player replaceCurrentItemWithPlayerItem:_playerItem];
    }
    else
    {
        _player = [AVPlayer playerWithPlayerItem:_playerItem];
        _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [_player setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    }
    
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = videoCell.bounds;
    _playerLayer.videoGravity = AVLayerVideoGravityResize;
    [videoCell.layer insertSublayer:_playerLayer above:videoCell.previewImageView.layer];
    [_player play];
}

#pragma mark Public
-(void)insertImage:(UIImage *)image
{
    if(!image)
    {
        NSLog(@"attempt to insert a nil image.");
        return;
    }
    [_galleryContent addObject:image];
    [_galleryPlaceholer addObject:image];
    [self refresh];
}

- (void)insertVideo:(NSURL *)videoPath
{
    if(!videoPath)
    {
        NSLog(@"attempt to insert a nil video url");
        return;
    }
    _asset = [AVURLAsset URLAssetWithURL:videoPath options:nil];
    if(_asset)
    {
        [_galleryContent addObject:videoPath];
    }
    AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:_asset];
    UIImage* image = [UIImage imageWithCGImage:[imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil]];
    if(!image)
    {
        [_galleryPlaceholer addObject:[UIImage imageNamed:@"icon40.png"]];
    }
    else
    {
        [_galleryPlaceholer addObject:image];
    }
    
    [self refresh];
    
    // auto play
    if(_galleryContent.count==1 && _asset)
    {
        [self autoPlayVideo:videoPath];
    }
}

#pragma mark - Private
- (void)refresh
{
    _collectionView.contentSize = CGSizeMake(self.frame.size.width*(_galleryContent.count+2), self.frame.size.height);
    // reloaddata here to ensure the datasource change make effects, so that the scroll to item code below being excute correctly.
    [_collectionView reloadData];
    [_collectionView setNeedsLayout];
    [_collectionView layoutIfNeeded];
    if(_galleryContent && _galleryContent.count == 1)
    {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
    // reloaddata here to ensure that scroll to item code above make effects, so that the collectionview item would be draw immediately.
    [_collectionView reloadData];
    [_collectionView setNeedsLayout];
    [_collectionView layoutIfNeeded];
}

- (void)addVideoReachToEndNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerDidFinish:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[_player currentItem]];
}

- (void)removeVideoReachToEndNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[_player currentItem]];
}

- (void)moviePlayerDidFinish:(NSNotification *)notification
{
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (void)dealloc
{
    [self removeVideoReachToEndNotification];
}

@end

@implementation ZOWLoopGalleryViewImageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _imageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_imageView];
    [self configureConstraints];
}

- (void)configureConstraints
{
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|[_imageView]|"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(_imageView)]];
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|[_imageView]|"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(_imageView)]];
}

@end

@implementation ZOWLoopGalleryViewVideoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _previewImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_previewImageView];
    [self configureConstraints];
}

- (void)configureConstraints
{
    _previewImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|[_previewImageView]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(_previewImageView)]];
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|[_previewImageView]|"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(_previewImageView)]];
}

- (void)setVideoURL:(NSURL *)videoURL
{
    _videoURL = videoURL;
}

@end