//
//  WHC_Asset.h
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


#import <AssetsLibrary/AssetsLibrary.h>

@interface WHC_Asset : ALAsset
@property (nonatomic, retain) ALAsset *asset;
@property (nonatomic, assign) BOOL selected;
- (id)initWithAsset:(ALAsset *)asset;
@end
