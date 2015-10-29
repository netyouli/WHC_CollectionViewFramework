//
//  UIView+WHC_AutoAdapterView.h
//  UIView+WHC_AutoAdapterView
//
//  Created by 吴海超 on 15/6/16.
//  Copyright (c) 2015年 吴海超. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 *  qq:712641411
 *  gitHub:https://github.com/netyouli
 *  csdn:http://blog.csdn.net/windwhc/article/category/3117381
 */


typedef enum _WHCAutoAdpterLabelType:NSInteger{
    
    LabelNoneScale = 1,       //不缩放
    
    LabelRatioSacle,          //以相对4s方式缩放
    
    LabelStretchSacle,        //拉伸缩放
    
}WHCAutoAdpterLabelType;

@interface UIView (WHC_AutoAdapterView)

//! 获取当前屏幕宽度
- (CGFloat)screenWidth;

//! 获取当前屏幕高度
- (CGFloat)screenHeight;

//! 获取当前屏幕宽度与4s比例
- (CGFloat)screenWidthRatio;

//! 获取当前屏幕高度与4s比例
- (CGFloat)screenHeightRatio;

//! 自动横向适配当前view
- (void)autoHoriAdapter;

- (void)autoHoriAdapterWithLabelSacleType:(WHCAutoAdpterLabelType)scaleType;

//! 自动竖向适配当前view,但不拉伸高度
- (void)autoVerAdapter;

//! 自动竖向适配当前view,同时拉伸高度
- (void)autoVerAdapterWithStretch;

//! 自动横竖向适配当前view,但不拉伸高度
- (void)autoAdapter;

//! 自动横竖向适配当前view,同时拉伸高度
- (void)autoAdapterWithStretch;

@end
