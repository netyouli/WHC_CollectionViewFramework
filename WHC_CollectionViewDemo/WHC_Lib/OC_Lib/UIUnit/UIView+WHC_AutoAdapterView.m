//
//  UIView+WHC_AutoAdapterView.m
//  WHC_AutoAdpaterViewDemo
//
//  Created by 吴海超 on 15/6/16.
//  Copyright (c) 2015年 吴海超. All rights reserved.
//

/*
 *  qq:712641411
 *  gitHub:https://github.com/netyouli
 *  csdn:http://blog.csdn.net/windwhc/article/category/3117381
 */


#import "UIView+WHC_AutoAdapterView.h"

#define KWHC_Iphone4ScreenWidth (320.0)      //iphone4屏幕宽度
#define KWHC_Iphone4ScreenHeight (480.0)     //iphone4屏幕高度

@implementation UIView (WHC_AutoAdapterView)


- (CGFloat)screenWidth{
    return CGRectGetWidth([UIScreen mainScreen].bounds);
}

- (CGFloat)screenHeight{
    return CGRectGetHeight([UIScreen mainScreen].bounds);
}

- (CGFloat)screenWidthRatio{
    return [self screenWidth] / KWHC_Iphone4ScreenWidth;
}

- (CGFloat)screenHeightRatio{
    return [self screenHeight] / KWHC_Iphone4ScreenHeight;
}

- (void)autoAdapterWithisStretch:(BOOL)isStretch{
    
    NSMutableArray  * subViewArr = [NSMutableArray arrayWithArray:self.subviews];
    for(NSInteger i = 0; i < subViewArr.count; i++){
        UIView  * subView = subViewArr[i];
        CGRect rc = subView.frame;
        rc.origin.y = [self screenHeightRatio] * CGRectGetMinY(rc);
        if(isStretch){
            rc.size.height = [self screenHeightRatio] * CGRectGetHeight(rc);
        }
        subView.frame = rc;
        if(isStretch && subView.subviews && subView.subviews.count > 1){
            [subView autoAdapterWithisStretch:YES];
        }
    }
}

- (void)autoVerAdapter{
    
    [self autoAdapterWithisStretch:NO];
}

- (void)autoVerAdapterWithStretch{
    
    [self autoAdapterWithisStretch:YES];
}

- (void)autoAdapter{
    
    [self autoHoriAdapter];
    [self autoVerAdapter];
}

- (void)autoAdapterWithStretch{
    
    [self autoHoriAdapter];
    [self autoVerAdapterWithStretch];
}


- (void)autoHoriAdapterWithLabelSacleType:(WHCAutoAdpterLabelType)scaleType{
    NSMutableArray  * subViewArr = [NSMutableArray arrayWithArray:self.subviews];
    NSMutableArray  * rowViewArr = [NSMutableArray array];
    for (NSInteger i = 0; i < subViewArr.count; i++) {
        UIView * subView = subViewArr[i];
        if(rowViewArr.count == 0){
            NSMutableArray * subRowViewArr = [NSMutableArray array];
            [subRowViewArr addObject:subView];
            [rowViewArr addObject:subRowViewArr];
            
        }else{
            BOOL isAddSubView = NO;
            for (NSInteger j = 0; j < rowViewArr.count; j++) {
                NSMutableArray  * subRowViewArr = rowViewArr[j];
                BOOL  isAtRow = YES;
                for (NSInteger w = 0; w < subRowViewArr.count; w++) {
                    UIView  * rowSubView = subRowViewArr[w];
                    if(CGRectGetMinY(subView.frame) > rowSubView.center.y ||
                       CGRectGetMaxY(subView.frame) < rowSubView.center.y){
                        isAtRow = NO;
                        break;
                    }
                }
                if(isAtRow){
                    isAddSubView = YES;
                    [subRowViewArr addObject:subView];
                    break;
                }
            }
            if(!isAddSubView){
                NSMutableArray * subRowViewArr = [NSMutableArray array];
                [subRowViewArr addObject:subView];
                [rowViewArr addObject:subRowViewArr];
            }
        }
    }
    
    for(NSInteger s = 0; s < rowViewArr.count; s++){
        NSMutableArray  * subRowViewArr = rowViewArr[s];
        NSInteger  variableCount = 0;
        for (NSInteger i = 0; i < subRowViewArr.count; i++) {
            for (NSInteger j = i + 1; j < subRowViewArr.count; j++) {
                UIView  * v1 = subRowViewArr[i];
                UIView  * v2 = subRowViewArr[j];
                if(v1.center.x > v2.center.x){
                    [subRowViewArr exchangeObjectAtIndex:i withObjectAtIndex:j];
                }
            }
            UIView * subRowView = subRowViewArr[i];
            if(![subRowView isKindOfClass:[UILabel class]] &&
               ![subRowView isKindOfClass:[UISwitch class]] &&
               ![subRowView isKindOfClass:[UIStepper class]] &&
               ![subRowView isKindOfClass:[UIImageView class]]){
                variableCount++;
                if([subRowView isKindOfClass:[UIButton class]]){
                    UIButton  * btn = (UIButton *)subRowView;
                    NSString  * strBtnTitle = btn.titleLabel.text;
                    if(strBtnTitle && strBtnTitle.length > 0){}else{
                        variableCount--;
                    }
                }
            }
        }
        
        if(subRowViewArr.count == 1){
            UIView * view = subRowViewArr[0];
            CGRect  rc = view.frame;
            if(![view isKindOfClass:[UIImageView class]]){
                switch (scaleType) {
                    case LabelNoneScale:
                        
                        break;
                    case LabelRatioSacle:
                        rc.origin.x   *= [self screenWidthRatio];
                        rc.size.width *= [self screenWidthRatio];
                        break;
                    case LabelStretchSacle:{
                        CGFloat  oldMaxXPading = CGRectGetWidth(self.frame) / [self screenWidthRatio] - CGRectGetMaxX(rc);
                        CGFloat  minXPading = CGRectGetMinX(rc);
                        rc.size.width = CGRectGetWidth(self.frame) - oldMaxXPading - minXPading;
                    }
                        break;
                    default:
                        break;
                }
            }else{
                rc.origin.x = (CGRectGetWidth(self.frame) - rc.size.width) / 2.0;
            }
            view.frame = rc;
            if(view.subviews && view.subviews.count > 0 && ![view isKindOfClass:[UISearchBar class]]){
                [view autoHoriAdapterWithLabelSacleType:scaleType];
            }
            continue;
        }
        
        
        UIView  * v = subRowViewArr.lastObject;
        CGFloat   differ = CGRectGetWidth(self.frame) - CGRectGetMaxX(v.frame) - CGRectGetMinX(((UIView *)subRowViewArr[0]).frame);
        if(differ < 0.0){
            differ = CGRectGetWidth(self.frame) - CGRectGetMaxX(v.frame);
        }
        if(differ < 0.0){
            differ = 0.0;
        }
        CGFloat   avgDiffer = differ / (CGFloat)variableCount;
        if(variableCount == 0){
            avgDiffer = 0.0;
        }
        
        NSMutableArray   * spaceArr = [NSMutableArray new];
        
        for (NSInteger i = 0; i < subRowViewArr.count - 1; i++) {
            UIView  * v1 = subRowViewArr[i];
            UIView  * v2 = subRowViewArr[i + 1];
            CGFloat   space = CGRectGetMinX(v2.frame) - CGRectGetMaxX(v1.frame);
            [spaceArr addObject:@(space)];
        }
        
        BOOL  isAllLabel = (variableCount == 0 && subRowViewArr.count > 1) ? YES : NO;
        if(isAllLabel){
            avgDiffer = differ / (CGFloat)subRowViewArr.count;
            for (NSInteger i = 0; i < subRowViewArr.count; i++) {
                UIView  * view = subRowViewArr[i];
                CGRect  rc = view.frame;
                switch (scaleType) {
                    case LabelNoneScale:
                        if(i != 0){
                            UIView  * v2 = subRowViewArr[i - 1];
                            rc.origin.x = CGRectGetMaxX(v2.frame) + [spaceArr[i - 1] floatValue];
                        }
                        break;
                    case LabelRatioSacle:
                        rc.origin.x   *= [self screenWidthRatio];
                        rc.size.width *= [self screenWidthRatio];
                        break;
                    case LabelStretchSacle:
                        if(i != 0){
                            UIView  * v2 = subRowViewArr[i - 1];
                            rc.origin.x = CGRectGetMaxX(v2.frame) + [spaceArr[i - 1] floatValue];
                        }
                        if(![view isKindOfClass:[UIImageView class]]){
                            rc.size.width += avgDiffer;//rc.size.width = [self screenWidthRatio] * CGRectGetWidth(rc);
                        }
                        break;
                    default:
                        break;
                }
                view.frame = rc;
            }
            continue;
        }
        
        
        for (NSInteger i = 0; i < subRowViewArr.count; i++) {
            UIView  * v1 = subRowViewArr[i];
            CGRect vRC = v1.frame;
            if(![v1 isKindOfClass:[UILabel class]] &&
               ![v1 isKindOfClass:[UISwitch class]] &&
               ![v1 isKindOfClass:[UIStepper class]] &&
               ![v1 isKindOfClass:[UIImageView class]]){
                if([self isKindOfClass:[UIScrollView class]]){
                    vRC.size.width *= [self screenWidthRatio];
                }else{
                    vRC.size.width += avgDiffer;
                }
                if([v1 isKindOfClass:[UIButton class]]){
                    UIButton  * btn = (UIButton *)v1;
                    NSString  * strBtnTitle = btn.titleLabel.text;
                    if(strBtnTitle && strBtnTitle.length > 0){}else{
                        vRC.size.width -= avgDiffer;
                    }
                }
            }
            if(i != 0){
                UIView  * v2 = subRowViewArr[i - 1];
                if([self isKindOfClass:[UIScrollView class]]){
                    vRC.origin.x *= [self screenWidthRatio];
                }else{
                    vRC.origin.x = CGRectGetMaxX(v2.frame) + [spaceArr[i - 1] floatValue];
                }
            }
            v1.frame = vRC;
            if(v1.subviews && v1.subviews.count > 0 && ![v1 isKindOfClass:[UISearchBar class]]){
                [v1 autoHoriAdapterWithLabelSacleType:scaleType];
            }
        }
    }

}

- (void)autoHoriAdapter{
    [self autoHoriAdapterWithLabelSacleType:LabelStretchSacle];
}

@end
