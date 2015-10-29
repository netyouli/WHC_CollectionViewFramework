//
//  WHC_StyleFourVC.swift
//  WHC_CollectionViewDemo
//
//  Created by 吴海超 on 15/10/28.
//  Copyright © 2015年 吴海超. All rights reserved.
//

/*
*  qq:712641411
*  gitHub:https://github.com/netyouli
*  csdn:http://blog.csdn.net/windwhc/article/category/3117381
*/


import UIKit

class WHC_StyleFourVC: UIViewController , WHC_MenuViewDelegate , WHC_ChoicePictureVCDelegate{

    private   var imageMenuView: WHC_MenuView!;
    private   var images = [UIImage]();
    private   let kMaxPictureChoiceNumber = 10;
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "WHC-集合菜单样式四";
        let menuParam = WHC_MenuViewParam.getWHCMenuViewDefaultParam(titles: nil, imageNames: nil, cacheWHCMenuKey: "");
        menuParam.isDynamicInsertMenuItem = true;   // 动态插入
        menuParam.insertMenuItemImageName = "add";  // 插入图片
        imageMenuView = WHC_MenuView(frame: UIScreen.mainScreen().bounds, menuViewParam: menuParam);
        imageMenuView.delegate = self;
        self.view.addSubview(imageMenuView);
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - WHC_MenuViewDelegate
    func WHCMenuViewClickDelete(item: WHC_MenuItem) {
        self.images.removeAtIndex(item.index);
    }
    
    func WHCMenuViewClickInsertItem(){
        let count = kMaxPictureChoiceNumber - self.images.count;
        if count == 0 {
            let alert = UIAlertView(title: "已选择3张,如更换图片请先长按已选图片进行删除", message: nil, delegate: nil, cancelButtonTitle: "确定");
            alert.show();
        }else {
            let vc = WHC_PictureListVC(nibName: "WHC_PictureListVC", bundle: nil);
            vc.delegate = self;
            vc.maxChoiceImageNumber = count;
            self.presentViewController(UINavigationController(rootViewController: vc), animated: true, completion: nil);
        }
    }
    
    //MARK: - WHC_ChoicePictureVCDelegate
    func WHCChoicePictureVC(choicePictureVC: WHC_ChoicePictureVC!, didSelectedPhotoArr photoArr: [AnyObject]!) {
        if photoArr != nil {
            for (_ , image) in photoArr.enumerate() {
                self.images.append(image as! UIImage);
            }
            self.imageMenuView.insertMenuItemsImage(self.images);
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
