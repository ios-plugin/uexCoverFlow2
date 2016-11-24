//
//  EUExCoverFlow.m
//  EUExCoverFlow
//
//  Created by hongbao.cui on 13-4-25.
//  Copyright (c) 2013年 xll. All rights reserved.
//

#import "EUExCoverFlow2.h"
#import "EUtility.h"
//#import "ReflectionCoverFlow2View.h"
//#import "ReflectionCoverFlow2View+WebCache.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#define NUMBER_OF_VISIBLE_ITEMS 25
#define ITEM_SPACING 210.0f
#define INCLUDE_PLACEHOLDERS YES

static inline NSString * newUUID(){
    return [NSUUID UUID].UUIDString;
}
@implementation EUExCoverFlow2


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
        iCarouselCoverFlow *carousel = [[iCarouselCoverFlow alloc] initWithFrame:rect];
        carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        carousel.type = iCarouselTypeCoverFlow2;
        carousel.delegate = self;
        carousel.dataSource = self;
        carousel.decelerationRate = .5;
        
        carousel.strId = strId;
        carousel.clipsToBounds=YES;
        [carousel setBackgroundColor:[UIColor clearColor]];
        if (![self.dataArray containsObject:carousel]) {
            [self.dataArray addObject:carousel];
            [[self.webViewEngine webView] addSubview:carousel];
        }
       
    }

}
/***************新增接口*****************/
-(NSString*)create:(NSMutableArray *)array{
    ACArgsUnpack(NSDictionary *jsonDict) = array;
    if ([array count]==0) {
        NSLog(@"partamer is null!");
        return nil;
    }
    if (!jsonDict) {
        NSLog(@"--cui--jsonDict--is--null----");
        return nil;
    }
    float x,y,width,height;
    NSString *strId = nil;
    if ([array count]>0) {
        
        if (!self.itemsArray) {
            self.itemsArray = [NSMutableArray arrayWithCapacity:10];
        }
        NSArray *dataArray_ = [jsonDict objectForKey:@"imageUrl"];
        if ([self.itemsArray count]>0) {
            [self.itemsArray removeAllObjects];
        }
       
        [self.itemsArray addObjectsFromArray:dataArray_];//添加数据
        strId = ac_stringArg(jsonDict[@"id"]) ?: newUUID();
        self.loadingString = jsonDict[@"placeholderImage"];
        if (self.dataArray) {
            for (UIView *iCarouselView in self.dataArray) {
                iCarouselCoverFlow *icarousel =(iCarouselCoverFlow *)iCarouselView;
                if ([icarousel.strId isEqualToString:strId]) {
                    if (icarousel!=nil&&[icarousel isKindOfClass:[iCarouselCoverFlow class]]) {
                        [self performSelectorOnMainThread:@selector(reloadData:) withObject:icarousel waitUntilDone:NO];
                    }else{
                    }
                }
            }
        }

        NSLog(@"strId:%@",strId);
        x = [ac_numberArg(jsonDict[@"x"]) floatValue];
        y = [ac_numberArg(jsonDict[@"y"]) floatValue];
        width = [ac_numberArg(jsonDict[@"width"]) floatValue];
        height = [ac_numberArg(jsonDict[@"height"]) floatValue];
        BOOL isScrollWithWeb = [jsonDict[@"isScrollWithWeb"] boolValue];
        
        if (!self.dataArray) {
            self.dataArray = [NSMutableArray arrayWithCapacity:10];
        }
        CGRect rect = CGRectMake(x, y, width, height);
        iCarouselCoverFlow *carousel = [[iCarouselCoverFlow alloc] initWithFrame:rect];
        carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        carousel.type = iCarouselTypeCoverFlow2;
        carousel.delegate = self;
        carousel.dataSource = self;
        carousel.decelerationRate = .5;
        carousel.strId = strId;
        carousel.clipsToBounds=YES;
        [carousel setBackgroundColor:[UIColor clearColor]];
        if (![self.dataArray containsObject:carousel]) {
            [self.dataArray addObject:carousel];
            NSLog(@"count:%lu",(unsigned long)self.dataArray.count);
            if (isScrollWithWeb) {
                [[self.webViewEngine webScrollView] addSubview:carousel];
            } else {
                [[self.webViewEngine webView] addSubview:carousel];
            }
            
            return strId;
        }else{
            return nil;
        }
        
    }
    return nil;
}

-(void)reloadData:(iCarousel *)icarousel{
    [icarousel reloadData];
}
-(void)setJsonData:(NSMutableArray *)array{
    if ([array count]==0) {
        NSLog(@"partamer is null!");
        return;
    }
    NSString *string = [array objectAtIndex:0];
    NSDictionary *jsonDict = [string ac_JSONValue];
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
            iCarouselCoverFlow *icarousel =(iCarouselCoverFlow *)iCarouselView;
            if ([icarousel.strId isEqualToString:idString]) {
                if (icarousel!=nil&&[icarousel isKindOfClass:[iCarouselCoverFlow class]]) {
                    [self performSelectorOnMainThread:@selector(reloadData:) withObject:icarousel waitUntilDone:NO];
                }else{
                }
            }
        }
    }
    
}
-(void)close:(NSMutableArray *)array{
    NSArray *dataArray = [NSArray arrayWithArray:self.dataArray];
    if ([array count]>0) {
        NSArray *idArr = ac_arrayArg(array[0]);
        if (idArr) {
            NSArray *IdArray = idArr;
            if (self.dataArray) {
                for (id stringid in IdArray) {
                    NSString *stringId = ac_stringArg(stringid);
                    NSLog(@"count1:%lu",(unsigned long)self.dataArray.count);
                   
                    for (iCarouselCoverFlow *iCarouselView in dataArray) {
                        iCarouselCoverFlow *icarousel =(iCarouselCoverFlow *)iCarouselView;
                        if (icarousel!=nil&&[icarousel isKindOfClass:[iCarouselCoverFlow class]]&&[icarousel.strId isEqualToString:stringId]){
                            [icarousel removeFromSuperview];
                            [self.dataArray removeObject:icarousel];
                        }
                       
                    }
                    
                }
            }
 
        }else{
            ACArgsUnpack(NSString* stringId) = array;
            for (iCarouselCoverFlow *iCarouselView in dataArray) {
                iCarouselCoverFlow *icarousel =(iCarouselCoverFlow *)iCarouselView;
                if (icarousel!=nil&&[icarousel isKindOfClass:[iCarouselCoverFlow class]]&&[icarousel.strId isEqualToString:stringId]){
                    [icarousel removeFromSuperview];
                    [self.dataArray removeObject:icarousel];
                }
            }
        }
        
            }else{
        //全部移除
        if (self.dataArray) {
            for (iCarouselCoverFlow *iCarouselView in self.dataArray) {
                [iCarouselView removeFromSuperview];
            }
            [self.dataArray removeAllObjects];
        }
    }
}

#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarouselCoverFlow *)carousel
{
    if([self.itemsArray count]>0){
        return [self.itemsArray count];
    }
    return 0;
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarouselCoverFlow *)carousel
{
    
    if([self.itemsArray count]>0){
        return [self.itemsArray count];
    }
    return 1;
}

- (UIView *)carousel:(iCarouselCoverFlow *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIImageView *)view
{
    if ([self.itemsArray count]>0) {
        //UILabel *labelView = nil;
        //create new view if no view is available for recycling
        if (view == nil)
        {
            id data = [self.itemsArray objectAtIndex:index];
            NSDictionary *dict = nil;
            NSString *url = nil;
            if ([data isKindOfClass:[NSDictionary class]]) {
                dict = (NSDictionary*)data;
                url = [self absPath:[dict objectForKey:@"imageUrl"]];
            }
            if ([data isKindOfClass:[NSString class]]) {
                url = [self absPath:(NSString*)data];
            }
            
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
            view = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
            if ([url hasPrefix:@"http"]||[url hasPrefix:@"https"]) {
                NSURL *url_ = [NSURL URLWithString:url];
                [view setImageWithURL:url_ placeholderImage:bgImage];
            }else{
                [view setImage:bgImage];
//                [view update];
            }
//            labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, height-45, view.bounds.size.width, 45)];
//            labelView.backgroundColor = [UIColor blackColor];
//            labelView.alpha = 1;//隐藏图片底部的标题栏
//            labelView.textAlignment = UITextAlignmentLeft;
//            labelView.font = [UIFont systemFontOfSize:12.0];
            view.layer.borderColor = [UIColor whiteColor].CGColor;
            view.layer.borderWidth = 5.0;
            [view setContentMode:UIViewContentModeScaleAspectFill];
            [view setClipsToBounds:YES];
            //[view addSubview:labelView];
        }
        else
        {
            //labelView = [[view subviews] lastObject];
        }
        //set label
        //labelView.text = [[self.itemsArray objectAtIndex:index] objectForKey:@"title"];
        //labelView.textColor = [UIColor whiteColor];
        return view;
    }
    return nil;
}
- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value{
    if (option == iCarouselOptionWrap) {
        return YES;
    }
    return value;
}
- (NSInteger)numberOfPlaceholdersInCarousel:(iCarouselCoverFlow *)carousel
{
	//note: placeholder views are only displayed if wrapping is disabled
	return INCLUDE_PLACEHOLDERS? 2: 0;
}
//- (UIView *)carousel:(iCarouselCoverFlow *)carousel placeholderViewAtIndex:(NSInteger)index reusingView:(UIImageView *)view
//{
//    if ([self.itemsArray count]>0) {
//        UILabel *label = nil;
//        
//        //create new view if no view is available for recycling
//        if (view == nil)
//        {
//            NSDictionary *dict = [self.itemsArray objectAtIndex:index];
//            NSString *url = [self absPath:[dict objectForKey:@"imageUrl"]];
//            UIImage *bgImage = nil;
//            if ([url hasPrefix:@"http"]||[url hasPrefix:@"https"]) {
//                bgImage = [UIImage imageWithContentsOfFile:[self absPath:self.loadingString]];//pholder
//            }else{
//                bgImage = [UIImage imageWithContentsOfFile:url];
//            }//            int x = 0;
//            //            int y = 0;
//            //            int width = 0;
//            //            int height = 0;
//            //            width = (carousel.frame.size.width)/1.5;
//            //            height = (carousel.frame.size.height);
//            int x = (carousel.frame.size.width-bgImage.size.width/2)/2;
//            int y = (carousel.frame.size.height-bgImage.size.height/2)/2;
//            int width = bgImage.size.width/2;
//            int height = bgImage.size.height/2;
//            
//            view = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
//            if ([url hasPrefix:@"http"]||[url hasPrefix:@"https"]) {
//                NSURL *url_ = [NSURL URLWithString:url];
//                [view setImageWithURL:url_ placeholderImage:bgImage];
//                //                [view setDynamic:YES];
//            }else{
//                [view setImage:bgImage];
//            }
//            view.layer.borderColor = [UIColor whiteColor].CGColor;
//            view.layer.borderWidth = 5.0;
//            label = [[UILabel alloc] initWithFrame:view.bounds];
//            label.backgroundColor = [UIColor clearColor];
//            label.textAlignment = UITextAlignmentCenter;
//            label.font = [UIFont systemFontOfSize:18.0f];
//            [view setContentMode:UIViewContentModeCenter];
//            //            [view setClipsToBounds:YES];
//            [view addSubview:label];
//        }
//        else
//        {
//            label = [[view subviews] lastObject];
//        }
//        
//        //set label
//        label.text = (index == 0)? @"[": @"]";
//        return view;
//    }
//    return nil;
//}


- (CGFloat)carouselItemWidth:(iCarouselCoverFlow *)carousel
{
    //slightly wider than item view
//    return ITEM_SPACING;
    return carousel.frame.size.width;
}

- (CATransform3D)carousel:(iCarouselCoverFlow *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * _carousel.itemWidth);
}


-(void)carousel:(iCarouselCoverFlow *)carousel didSelectItemAtIndex:(NSInteger)index{
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexCoverFlow2.onItemSelected" arguments:ACArgsPack(carousel.strId,@(index))];
}

- (BOOL)carousel:(iCarouselCoverFlow *)carousel shouldSelectItemAtIndex:(NSInteger)index{
   
    return YES;
}

- (void)carouselWillBeginDragging:(iCarouselCoverFlow *)carousel{
    if (self.selectedView) {
        [self.selectedView removeFromSuperview];
    }
}
- (void)carouselDidEndDragging:(iCarouselCoverFlow *)carousel willDecelerate:(BOOL)decelerate{
    if (self.selectedView) {
        [self.selectedView removeFromSuperview];
    }
}
@end
