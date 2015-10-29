//
//  WHC_CameraVC.m
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



#import "WHC_CameraVC.h"

@interface WHC_CameraVC ()<UIImagePickerControllerDelegate , UINavigationControllerDelegate>{
    UIImagePickerController   *  _cameraVC;
}

@end

@implementation WHC_CameraVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData{
    _cameraVC = [[UIImagePickerController alloc]init];
    _cameraVC.delegate = self;
    _cameraVC.allowsEditing = YES;
    _cameraVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    _cameraVC.view.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:_cameraVC.view];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    __weak  typeof(self)  sf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if(image != nil){
            if(_delegate && [_delegate respondsToSelector:@selector(WHCCameraVC:didSelectedPhoto:)]){
                [_delegate WHCCameraVC:sf didSelectedPhoto:image];
            }
        }
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage  * image = info[@"UIImagePickerControllerOriginalImage"];
    __weak  typeof(self)  sf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if(image != nil){
            if(_delegate && [_delegate respondsToSelector:@selector(WHCCameraVC:didSelectedPhoto:)]){
                [_delegate WHCCameraVC:sf didSelectedPhoto:image];
            }
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
