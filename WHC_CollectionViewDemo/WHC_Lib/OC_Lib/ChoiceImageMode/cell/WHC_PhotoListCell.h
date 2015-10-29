//
//  WHC_PhotoListCell.h
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


#import <UIKit/UIKit.h>

@protocol WHC_PhotoListCellDelegate <NSObject>

- (BOOL)WHCPhotoListCurrentChoiceState:(BOOL)selected;

- (void)WHCPhotoListCancelChoicePhoto;
@end

@interface WHC_PhotoListCell : UITableViewCell

@property (nonatomic , assign)id<WHC_PhotoListCellDelegate>delegate;

@property (nonatomic , assign)NSInteger listColumn;

- (void)setAssets:(NSArray*)assets;

+ (CGFloat)cellHeight;

@end
