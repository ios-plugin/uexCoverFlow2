//
//  ReflectionCoverFlow2View+WebCache.m
//  SDWebImage
//
//  Created by Olivier Poitrey on 14/03/12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//

#import "ReflectionCoverFlow2View+WebCache.h"
@implementation ReflectionCoverFlow2View (WebCache)

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    self.image = placeholder;
    if (url)
    {
        [manager downloadWithURL:url delegate:self ];
    }

}
- (void)cancelCurrentImageLoad
{
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}
- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    NSLog(@"图片下载成功%@",image);
//    CGSize size = CGSizeMake(image.size.width,image.size.height);
////    CGSize size = CGSizeMake(247,300);
//    self.frame = CGRectMake((self.frame.size.width-size.width)/2,(self.frame.size.height-size.height)/2,size.width,size.height);
    self.image =image;
;
}
@end
