//
//  WHC_CameraVC.h
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

@class WHC_CameraVC;
@protocol  WHC_CameraVCDelegate<NSObject>

- (void)WHCCameraVC:(WHC_CameraVC *)cameraVC didSelectedPhoto:(UIImage *)photo;

@end

@interface WHC_CameraVC : UIViewController
@property (nonatomic , assign)id<WHC_CameraVCDelegate> delegate;
@end
