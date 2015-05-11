//
//  EUExCoverFlow.m
//  EUExCoverFlow
//
//  Created by hongbao.cui on 13-4-25.
//  Copyright (c) 2013年 xll. All rights reserved.
//

#import "EUExCoverFlow2.h"
#import "iCarouselCoverFlow2.h"
#import "EUtility.h"
#import "JSON.h"
#import "ReflectionCoverFlow2View.h"
#import "ReflectionCoverFlow2View+WebCache.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#define NUMBER_OF_VISIBLE_ITEMS 25
#define ITEM_SPACING 210.0f
#define INCLUDE_PLACEHOLDERS YES

@implementation EUExCoverFlow2
@synthesize dataArray;
@synthesize itemsArray;
@synthesize loadingString;
@synthesize selectedView;
-(id)initWithBrwView:(EBrowserView *)eInBrwView{
    if (self = [super initWithBrwView:eInBrwView]) {
        
    }
    return self;
}
-(void)clean{
    [self close:nil];
    if (self.dataArray) {
        self.dataArray = nil;
    }
    if (self.itemsArray) {
        self.itemsArray = nil;
    }
    if (self.loadingString) {
        self.loadingString = nil;
    }
    if (self.selectedView) {
        self.selectedView = nil;
    }
    [super clean];
}
-(void)dealloc{
    [self close:nil];
    if (self.dataArray) {
        self.dataArray = nil;
    }
    if (self.itemsArray) {
        self.itemsArray = nil;
    }
    if (self.loadingString) {
        self.loadingString = nil;
    }
    if (self.selectedView) {
        self.selectedView = nil;
    }
    [super dealloc];
}
-(void)open:(NSMutableArray *)array{
    float x,y,width,height;
    NSString *strId = nil;
    if ([array count]>0&&[array count]<8) {
        strId = [NSString stringWithFormat:@"%@",[array objectAtIndex:0]];
        x = [[array objectAtIndex:1] floatValue];
        y = [[array objectAtIndex:2] floatValue];
        width = [[array objectAtIndex:3] floatValue];
        height = [[array objectAtIndex:4] floatValue];
        
        if (!self.dataArray) {
            self.dataArray = [NSMutableArray arrayWithCapacity:1];
        }
        CGRect rect = CGRectMake(x, y, width, height);        
        iCarouselCoverFlow2 *carousel = [[iCarouselCoverFlow2 alloc] initWithFrame:rect];
        carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        carousel.type = iCarouselTypeCoverFlow;
        carousel.delegate = self;
        carousel.dataSource = self;
        carousel.decelerationRate = 0.5;
        carousel.strId = strId;
        carousel.clipsToBounds=YES;
        [carousel setBackgroundColor:[UIColor clearColor]];
        if (![self.dataArray containsObject:carousel]) {
            [self.dataArray addObject:carousel];
            [EUtility brwView:self.meBrwView addSubview:carousel];
        }
        [carousel release];
        NSString *jsstr = [NSString stringWithFormat:@"if(uexCoverFlow2.loadData!=null){uexCoverFlow2.loadData('%@')}",strId];
        [EUtility brwView:meBrwView evaluateScript:jsstr];
    }

}
-(void)reloadData:(iCarouselCoverFlow2 *)icarousel{
    [icarousel reloadData];
}
-(void)setJsonData:(NSMutableArray *)array{
    if ([array count]==0) {
        NSLog(@"partamer is null!");
        return;
    }
    NSString *string = [array objectAtIndex:0];
    NSDictionary *jsonDict = [string JSONValue];
    if (!jsonDict) {
        NSLog(@"--cui--jsonDict--is--null----");
        return;
    }
    if (!self.itemsArray) {
        self.itemsArray = [NSMutableArray arrayWithCapacity:1];
    }
    NSArray *dataArray_ = [jsonDict objectForKey:@"data"];
    if ([self.itemsArray count]>0) {
        [self.itemsArray removeAllObjects];
    }
    [self.itemsArray addObjectsFromArray:dataArray_];//添加数据
    NSString *idString = [NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"id"]];
    NSString *colorStr = [NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"selectColor"]];
    NSString *alpa = [NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"alpha"]];
    if (!self.selectedView) {
        self.selectedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        [self.selectedView setBackgroundColor:[EUtility ColorFromString:colorStr]];
        [self.selectedView setAlpha:[alpa floatValue]];
    }
    self.loadingString = [array objectAtIndex:1];
    if (self.dataArray) {
        for (UIView *iCarouselView in self.dataArray) {
            iCarouselCoverFlow2 *icarousel =(iCarouselCoverFlow2 *)iCarouselView;
            if ([icarousel.strId isEqualToString:idString]) {
                if (icarousel!=nil&&[icarousel isKindOfClass:[iCarouselCoverFlow2 class]]) {
                    [self performSelectorOnMainThread:@selector(reloadData:) withObject:icarousel waitUntilDone:NO];
                }else{
                }
            }
        }
    }
    
}
-(void)close:(NSMutableArray *)array{
    if ([array count]>0) {
        NSString *IdStr = [array objectAtIndex:0];
        NSArray *IdArray = [IdStr componentsSeparatedByString:@","];
        if (self.dataArray) {
            for (NSString *stringId in IdArray) {
                for (iCarouselCoverFlow2 *iCarouselView in self.dataArray) {
                    iCarouselCoverFlow2 *icarousel =(iCarouselCoverFlow2 *)iCarouselView;
                    if (icarousel!=nil&&[icarousel isKindOfClass:[iCarouselCoverFlow2 class]]&&[icarousel.strId isEqualToString:stringId]) {
                            [icarousel removeFromSuperview];
                    }
                }
            }
        }
    }else{
        //全部移除
        if (self.dataArray) {
            for (iCarouselCoverFlow2 *iCarouselView in self.dataArray) {
                [iCarouselView removeFromSuperview];
            }
        }
    }
}
#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarouselCoverFlow2 *)carousel
{
    if([self.itemsArray count]>0){
        return [self.itemsArray count];
    }
    return 0;
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarouselCoverFlow2 *)carousel
{
    //limit the number of items views loaded concurrently (for performance reasons)
    if([self.itemsArray count]>0){
        return [self.itemsArray count];
    }
    return 1;
}

- (UIView *)carousel:(iCarouselCoverFlow2 *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIImageView *)view
{
    if ([self.itemsArray count]>0) {
        UITextView *labelView = nil;
        //create new view if no view is available for recycling
        if (view == nil)
        {
            NSDictionary *dict = [self.itemsArray objectAtIndex:index];
            NSString *url = [self absPath:[dict objectForKey:@"imageUrl"]];
            UIImage *bgImage = nil;
            if ([url hasPrefix:@"http"]||[url hasPrefix:@"https"]) {
                bgImage = [UIImage imageWithContentsOfFile:[self absPath:self.loadingString]];//pholder
            }else{
                bgImage = [UIImage imageWithContentsOfFile:url];
            }
            int x = 0;
            int y = 0;
            int width = bgImage.size.width*3/5;//carousel.frame.size.width/1.3;//224   353  96 107
            int height = bgImage.size.height*3/5;//carousel.frame.size.height/1.2;//320,460
//            int x = (carousel.frame.size.width-bgImage.size.width/2)/2;
//            int y = (carousel.frame.size.height-bgImage.size.height/2)/2;
//            int width = bgImage.size.width/2;
//            int height = bgImage.size.height/2;
            view = [[[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)] autorelease];
            if ([url hasPrefix:@"http"]||[url hasPrefix:@"https"]) {
                NSURL *url_ = [NSURL URLWithString:url];
                [view setImageWithURL:url_ placeholderImage:bgImage];
            }else{
                [view setImage:bgImage];
//                [view update];
            }
            labelView = [[[UITextView alloc] initWithFrame:CGRectMake(0, height-45, view.bounds.size.width, 45)] autorelease];
            labelView.backgroundColor = [UIColor blackColor];
            labelView.alpha = 0;//隐藏图片底部的标题栏
            labelView.textAlignment = UITextAlignmentLeft;
            labelView.font = [UIFont systemFontOfSize:12.0];
//            view.layer.borderColor = [UIColor whiteColor].CGColor;
//            view.layer.borderWidth = 5.0;
//            [view setContentMode:UIViewContentModeScaleAspectFill];
//            [view setClipsToBounds:YES];
            [view addSubview:labelView];
        }
        else
        {
            labelView = [[view subviews] lastObject];
        }
        //set label
        labelView.text = [[self.itemsArray objectAtIndex:index] objectForKey:@"title"];
        labelView.textColor = [UIColor whiteColor];
        return view;
    }
    return nil;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarouselCoverFlow2 *)carousel
{
	//note: placeholder views are only displayed if wrapping is disabled
	return INCLUDE_PLACEHOLDERS? 2: 0;
}

- (UIView *)carousel:(iCarouselCoverFlow2 *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIImageView *)view
{
    if ([self.itemsArray count]>0) {
        UITextView *label = nil;
        
        //create new view if no view is available for recycling
        if (view == nil)
        {
            NSDictionary *dict = [self.itemsArray objectAtIndex:index];
            NSLog(@"dict:%@",dict);
            NSString *url = [self absPath:[dict objectForKey:@"imageUrl"]];
            UIImage *bgImage = nil;
            if ([url hasPrefix:@"http"]||[url hasPrefix:@"https"]) {
                bgImage = [UIImage imageWithContentsOfFile:[self absPath:self.loadingString]];//pholder
            }else{
                bgImage = [UIImage imageWithContentsOfFile:url];
            }//            int x = 0;
//            int y = 0;
//            int width = 0;
//            int height = 0;
//            width = (carousel.frame.size.width)/1.5;
//            height = (carousel.frame.size.height);
            int x = (carousel.frame.size.width-bgImage.size.width/2)/2;
            int y = (carousel.frame.size.height-bgImage.size.height/2)/2;
            int width = bgImage.size.width/2;
            int height = bgImage.size.height/2;

            view = [[[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)] autorelease];
            if ([url hasPrefix:@"http"]||[url hasPrefix:@"https"]) {
                NSURL *url_ = [NSURL URLWithString:url];
                [view setImageWithURL:url_ placeholderImage:bgImage];
//                [view setDynamic:YES];
            }else{
                [view setImage:bgImage];
            }
            view.layer.borderColor = [UIColor whiteColor].CGColor;
            view.layer.borderWidth = 5.0;
            label = [[[UITextView alloc] initWithFrame:view.bounds] autorelease];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = UITextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:18.0f];
            [view setContentMode:UIViewContentModeCenter];
//            [view setClipsToBounds:YES];
            [view addSubview:label];
        }
        else
        {
            label = [[view subviews] lastObject];
        }
        
        //set label
        label.text = (index == 0)? @"[": @"]";
        return view;
    }
    return nil;
}

- (CGFloat)carouselItemWidth:(iCarouselCoverFlow2 *)carousel
{
    //slightly wider than item view
//    return ITEM_SPACING;
    return carousel.frame.size.width;
}

- (CGFloat)carousel:(iCarouselCoverFlow2 *)carousel itemAlphaForOffset:(CGFloat)offset
{
	//set opacity based on distance from camera
    return 1.0f - fminf(fmaxf(offset, 0.0f), 1.0f);
}

- (CATransform3D)carousel:(iCarouselCoverFlow2 *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 0.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * _carousel.itemWidth);
}

- (BOOL)carouselShouldWrap:(iCarouselCoverFlow2 *)carousel
{
    //wrap all carousels
    return YES;
}
-(void)carousel:(iCarouselCoverFlow2 *)carousel didSelectItemAtIndex:(NSInteger)index{
    NSString *jsonString = [NSString stringWithFormat:@"if(uexCoverFlow2.onItemSelected!=null){uexCoverFlow2.onItemSelected('%@','%d')}",carousel.strId,index];
    [EUtility brwView:meBrwView evaluateScript:jsonString];
}
-(void)carousel:(iCarouselCoverFlow2 *)carousel didSelectItemEndAtIndex:(NSInteger)index{
    if (self.selectedView) {
        [self.selectedView removeFromSuperview];
    }
}
- (BOOL)carousel:(iCarouselCoverFlow2 *)carousel shouldSelectItemAtIndex:(NSInteger)index{
    ReflectionCoverFlow2View *flectionView =(ReflectionCoverFlow2View *)carousel.currentItemView;
    if (self.selectedView&&flectionView) {
        [self.selectedView setFrame:CGRectMake(0, 0, flectionView.frame.size.width, flectionView.frame.size.height)];
        [flectionView addSubview:self.selectedView];
    }
    return YES;
}
//-(void)setPageIndex:(iCarousel *)carousel{
//    int currentItemIndex =carousel.currentItemIndex;
//    NSLog(@"currentItemIndex:%d",currentItemIndex);
//    for (UIContainsiCarouselView *iCarouselView in self.dataArray) {
//        for (UIView *subView in [iCarouselView subviews]) {
//            if (subView!=nil&&[subView isKindOfClass:[StyledPageControl class]]) {
//                StyledPageControl *page = (StyledPageControl *)subView;
//                if (page) {
//                    [page setCurrentPage:currentItemIndex];
//                }
//            }
//        }
//    }
//}
- (void)carouselWillBeginDragging:(iCarouselCoverFlow2 *)carousel{
//    [self setPageIndex:carousel];
    if (self.selectedView) {
        [self.selectedView removeFromSuperview];
    }
}
- (void)carouselDidEndDragging:(iCarouselCoverFlow2 *)carousel willDecelerate:(BOOL)decelerate{
//    [self setPageIndex:carousel];
    if (self.selectedView) {
        [self.selectedView removeFromSuperview];
    }
}
- (void)carouselWillBeginDecelerating:(iCarouselCoverFlow2 *)carousel{
    
}
- (void)carouselDidEndDecelerating:(iCarouselCoverFlow2 *)carousel{
//    [self setPageIndex:carousel];
}
- (void)carouselDidEndScrollingAnimation:(iCarouselCoverFlow2 *)carousel{
//    [self setPageIndex:carousel];
}
@end
