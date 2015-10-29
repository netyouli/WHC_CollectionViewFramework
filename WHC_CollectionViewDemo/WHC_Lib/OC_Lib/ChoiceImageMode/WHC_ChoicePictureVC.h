//
//  WHC_ChoicePictureVC.h
//  WHC_PhotoCameraChoicePictureDemo
//
//  Created by 吴海超 on 15/7/30.
//  Copyright (c) 2015年 吴海超. All rights reserved.
//
/*
 *  qq:712641411
 *  gitHub:https://github.com/netyouli
 *  csdn:http://blog.csdn.net/windwhc/article/category/3117381
 */



#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class WHC_ChoicePictureVC;

@protocol  WHC_ChoicePictureVCDelegate<NSObject>

- (void)WHCChoicePictureVC:(WHC_ChoicePictureVC *)choicePictureVC didSelectedPhotoArr:(NSArray *)photoArr;

@end

@interface WHC_ChoicePictureVC : UIViewController
@property (nonatomic , assign)id <WHC_ChoicePictureVCDelegate> delegate;
@property (nonatomic , assign)NSInteger maxChoiceImageNumber;
@property (nonatomic , strong) ALAssetsGroup  * assetsGroup;
@end
