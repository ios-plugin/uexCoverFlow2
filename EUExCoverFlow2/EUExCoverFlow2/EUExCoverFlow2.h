//
//  EUExCoverFlow.h
//  EUExCoverFlow
//
//  Created by hongbao.cui on 13-4-25.
//  Copyright (c) 2013年 xll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EUExBase.h"
#import "iCarouselCoverFlow2.h"
@interface EUExCoverFlow2 :  EUExBase<iCarouselDelegate,iCarouselDataSource>{
    
}
@property(nonatomic,retain)NSMutableArray *dataArray;
@property(nonatomic,retain)NSMutableArray *itemsArray;
@property(nonatomic,copy)NSString *loadingString;
@property(nonatomic,retain)UIView *selectedView;
@end
