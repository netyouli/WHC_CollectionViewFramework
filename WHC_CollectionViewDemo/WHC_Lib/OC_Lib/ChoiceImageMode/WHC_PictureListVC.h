//
//  WHC_PictureListVC.h
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
#import "WHC_ChoicePictureVC.h"
@interface WHC_PictureListVC : UIViewController
@property (nonatomic , assign)id <WHC_ChoicePictureVCDelegate> delegate;
@property (nonatomic , assign)NSInteger maxChoiceImageNumber;
@end
