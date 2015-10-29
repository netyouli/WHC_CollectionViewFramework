//
//  WHC_Asset.m
//  work
//
//  Created by WHC on 14-6-23.
//  Copyright (c) 2014年 WHC. All rights reserved.
//

/*
 *  qq:712641411
 *  iOS大神qq群:460122071
 *  gitHub:https://github.com/netyouli
 *  csdn:http://blog.csdn.net/windwhc/article/category/3117381
 */


#import "WHC_Asset.h"
@implementation WHC_Asset
- (id)initWithAsset:(ALAsset *)asset
{
    self = [super init];
    if(self){
        _asset = asset;
        _selected = NO;
    }
    return self;
}
@end
