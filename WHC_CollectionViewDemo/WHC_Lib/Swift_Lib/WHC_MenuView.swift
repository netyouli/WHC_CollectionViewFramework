//
//  WHC_MenuView.swift
//  CRM
//
//  Created by 吴海超 on 15/9/29.
//  Copyright © 2015年 吴海超. All rights reserved.
//

/*
*  qq:712641411
*  gitHub:https://github.com/netyouli
*  csdn:http://blog.csdn.net/windwhc/article/category/3117381
*/


import UIKit

extension Array {
    /// 交换下标对象
    mutating func exchangeObject(index1: Int , _ index2:Int){
        if index1 != index2 {
            let object = self[index1];
            self[index1] = self[index2];
            self[index2] = object;
        }
    }
}

enum WHC_MenuViewOrientation {
    /// 垂直布局
    case Vertical
    /// 横向布局
    case Horizontal
}

enum WHC_DragOrientation {
    /// 向上
    case Up
    /// 向下
    case Down
    /// 向左
    case Left
    /// 向右
    case Right
}

@objc protocol WHC_MenuViewDelegate{
    optional func WHCMenuView(menuView: WHC_MenuView ,item: WHC_MenuItem, title: String);
    optional func WHCMenuViewClickDelete(item: WHC_MenuItem);
    optional func WHCMenuViewClickInsertItem();
}

class  WHC_MenuViewParam{
    /// 缓存菜单key
    var cacheWHCMenuKey: String!;
    /// 分段标题集合
    var segmentPartTitles: [String]!;
    /// 分段图片集合
    var segmentPartImageNames: [String]!;
    /// 分段文字颜色
    var txtColor = UIColor.grayColor();
    /// 选择背景色
    var selectedBackgroundColor: UIColor!;
    /// 网格线的颜色
    var lineColor: UIColor = UIColor.lineColor();
    /// 分割视图集合
    var segmentViews: [UIView]!; // 这个属性这个版本废除不可使用
    /// 菜单视图布局方向
    var menuOrientation: WHC_MenuViewOrientation!;
    /// 每行个数
    var column = 4;
    /// 间隙
    var pading: CGFloat = 5.0;
    /// 字体大小
    var txtSize: CGFloat = 12.0;
    /// 是否能够排序
    var canSort = true;
    /// 是否能够删除
    var canDelete = true;
    /// 是否能够添加
    var canAdd = false;
    /// 是否显示页标签
    var canShowPageCtl = true;
    /// 线宽
    var lineWidth: CGFloat = 0.5;
    /// 顶部是否有线
    var isShowTopLine = true;
    /// 是否网格显示
    var isGridShow = true;
    /// 是否动态插入菜单项
    var isDynamicInsertMenuItem = false;
    /// 动态插入背景图片名称
    var insertMenuItemImageName: String!;
    /// 是否自动拉伸菜单高度
    var autoStretchHeight = false;
    /// 获取默认视图菜单配置参数
    class func getWHCMenuViewDefaultParam(titles
                               titles: [String]! ,
                           imageNames: [String]! ,
                      cacheWHCMenuKey: String)->WHC_MenuViewParam{

        let param = WHC_MenuViewParam();
        param.segmentPartTitles = titles;
        param.segmentPartImageNames = imageNames;
        param.selectedBackgroundColor = UIColor.themeBackgroundColor();
        param.menuOrientation = .Vertical;
        param.cacheWHCMenuKey = cacheWHCMenuKey;
        return param;
    }
}

class WHC_MenuView: UIView ,WHC_MenuItemDelegate , WHC_MoreMenuItemVCDelegate , UIScrollViewDelegate{
    /// 缓存标题集合key
    private let kWHCTitlesKey = "WHC-TitlesKey";
    private let kWHCDeleteTitlesKey = "WHC-DeleteTitlesKey";
    private let kWHCImageNamesKey = "WHC-ImageNamesKey";
    private let kWHCDeleteImageNamesKey = "WHC-DeleteImageNamesKey";
    /// 页控件高度
    private let kPageCtlHeight: CGFloat = 20.0;
    /// 更多按钮标题
    private let kMoreTxt = "●●●";
    /// 动画周期
    private let kWHCAnimationTime = 0.5;
    /// 菜单项视图集合
    private var menuItems: [WHC_MenuItem]!;
    /// 菜单项坐标集合
    private var menuItemPoints: [CGPoint]!;
    /// 被删除菜单项标题集合
    private var deletedMenuItemTitles = [String]();
    /// 被删除菜单项图片名称集合
    private var deletedMenuItemImageNames = [String]();
    /// 初始菜单项标题集合
    private var menuItemTitles: [String]!;
    /// 初始菜单项图片名称集合
    private var menuItemImageNames: [String]!;
    /// 开始按下点
    private var startPoint = CGPointZero;
    /// 当前移动点
    private var currentMovePoint = CGPointZero;
    /// 移动的菜单项
    private var moveMenuItem: WHC_MenuItem!;
    /// 移动菜单条件是否满足
    private var canMoveMenuItem = false;
    /// 移动菜单下标
    private var moveMenuItemIndex = 0;
    /// 是否正在进行动画移动
    private var isAnimationMoving  = false;
    /// 是否触摸结束
    private var isTouchEnd = false;
    /// 菜单项尺寸
    private var menuItemSize: CGFloat = 0.0;
    /// 线宽
    private var lineWidth: CGFloat = 0.5;
    /// 当前删除菜单项
    private var currentDeleteMenuItem: WHC_MenuItem!;
    /// 初始偏移
    private var initEdge: UIEdgeInsets!;
    /// 屏幕刷新时钟
    private var displayLink: CADisplayLink!;
    /// 移动增量
    private var moveIncrement = 0;
    /// 插入菜单图片集合
    private var insertMenuImages: [UIImage]!;
    /// 页控件
    private var pageCtl: UIPageControl!;
    /// 滚动控件
    private var scrollView: UIScrollView!;
    /// 拖拽方向
    private var dragOri: WHC_DragOrientation!;
    /// 是否继续执行偏移动画
    private var canMoveAnimation = false;
    /// 菜单代理
    var delegate: WHC_MenuViewDelegate?;
    /// 是否是更多界面
    var isMoreMenuItem = false;
    /// 构建视图菜单配置参数
    var menuViewParam: WHC_MenuViewParam!{
        willSet{
            if self.menuViewParam == nil {
                self.initData();
                self.layoutUI();
            }
        }
    };
    
    //MARK: - 初始化方法
    convenience init(frame: CGRect , menuViewParam: WHC_MenuViewParam){
        self.init(frame: frame);
        self.menuViewParam = menuViewParam;
        self.initData();
        self.layoutUI();
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.backgroundColor = UIColor.whiteColor();
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }

    private func initData(){
        if !self.menuViewParam.isDynamicInsertMenuItem {
            if self.menuViewParam.cacheWHCMenuKey != nil {
                if self.menuViewParam.canSort || self.menuViewParam.canDelete {
                    let us = NSUserDefaults.standardUserDefaults();
                    let object = us.objectForKey(self.menuViewParam.cacheWHCMenuKey);
                    if object != nil {
                        let cacheInfoDict: NSDictionary = object as! NSDictionary;
                        let titles: [String] = cacheInfoDict[kWHCTitlesKey] as! [String];
                        let imageNames: [String] = cacheInfoDict[kWHCImageNamesKey] as! [String];
                        let deleteTitles: [String] = cacheInfoDict[kWHCDeleteTitlesKey] as! [String];
                        let deleteImageNames: [String] = cacheInfoDict[kWHCDeleteImageNamesKey] as! [String];
                        var reset = false;
                        if titles.count + deleteTitles.count == self.menuViewParam.segmentPartTitles.count {
                            for (_ , title) in self.menuViewParam.segmentPartTitles.enumerate() {
                                if !titles.contains(title) &&
                                    !deleteTitles.contains(title) {
                                        reset = true;
                                        break;
                                }
                            }
                        }else {
                            reset = true;
                        }
                        if reset {
                            us.setObject([kWHCTitlesKey: self.menuViewParam.segmentPartTitles ,
                                kWHCImageNamesKey: self.menuViewParam.segmentPartImageNames,
                                kWHCDeleteImageNamesKey: [String](),
                                kWHCDeleteTitlesKey: [String]()], forKey: self.menuViewParam.cacheWHCMenuKey);
                            self.menuItemTitles = self.menuViewParam.segmentPartTitles;
                            self.menuItemImageNames = self.menuViewParam.segmentPartImageNames;
                        }else {
                            self.menuItemTitles = titles;
                            self.menuItemImageNames = imageNames;
                            self.deletedMenuItemTitles = deleteTitles;
                            self.deletedMenuItemImageNames = deleteImageNames;
                        }
                    }else {
                        us.setObject([kWHCTitlesKey: self.menuViewParam.segmentPartTitles ,
                            kWHCImageNamesKey: self.menuViewParam.segmentPartImageNames,
                            kWHCDeleteImageNamesKey: [String](),
                            kWHCDeleteTitlesKey: [String]()], forKey: self.menuViewParam.cacheWHCMenuKey);
                        self.menuItemTitles = self.menuViewParam.segmentPartTitles;
                        self.menuItemImageNames = self.menuViewParam.segmentPartImageNames;
                    }
                    us.synchronize();
                }
            }else{
                self.menuItemTitles = self.menuViewParam.segmentPartTitles;
                self.menuItemImageNames = self.menuViewParam.segmentPartImageNames;
            }
        }else {
            self.menuViewParam.canAdd = false;
            self.menuViewParam.canSort = false;
        }
        self.menuItems = [WHC_MenuItem]();
        self.menuItemPoints = [CGPoint]();
    }
    
    private func layoutUI(){
        self.scrollView = UIScrollView(frame: self.bounds);
        self.addSubview(self.scrollView);
        self.scrollView.showsHorizontalScrollIndicator = false;
        self.scrollView.showsVerticalScrollIndicator = false;
        if self.menuViewParam != nil {
            if !self.menuViewParam.isDynamicInsertMenuItem {
                if self.menuViewParam.canDelete {
                    self.menuItemTitles.append(kMoreTxt);
                    self.menuItemImageNames.append("");
                }
                self.createGridViewLayout();
            }else {
                self.insertMenuItemsImage([UIImage]());
            }
        }
        if self.menuViewParam.canSort ||
            self.menuViewParam.canDelete ||
            self.menuViewParam.isDynamicInsertMenuItem {
                self.scrollView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: Selector("handleSortGesture:")));
        }
    }
    
    
    //MARK: - 私有方法
    
    /// 创建动态插入菜单
    private func createDynamicInsertLayout(){
        for (_ , view) in self.scrollView.subviews.enumerate() {
            if view is WHC_MenuItem {
                view.removeFromSuperview();
            }
        }
        self.menuItems.removeAll();
        self.menuItemPoints.removeAll();
        self.menuItemSize = self.width() / CGFloat(self.menuViewParam.column);
        let rowCount = self.insertMenuImages.count / self.menuViewParam.column + (self.insertMenuImages.count % self.menuViewParam.column == 0 ? 0 : 1);
        for row in 0...rowCount - 1 {
            for index in 0...self.menuViewParam.column - 1 {
                let currentIndex = row * self.menuViewParam.column + index;
                if currentIndex < self.insertMenuImages.count {
                    let menuItem = WHC_MenuItem(frame: CGRectMake(CGFloat(index) * (menuItemSize),
                        CGFloat(row) * (menuItemSize),
                        menuItemSize ,
                        menuItemSize),
                        pading: self.menuViewParam.pading);
                    menuItem.delegate = self;
                    menuItem.index = currentIndex;
                    menuItem.fontSize = 0;
                    menuItem.setImage(self.insertMenuImages[currentIndex]);
                    menuItem.selectedBackgroundColor = UIColor.clearColor();
                    if currentIndex == self.insertMenuImages.count - 1 {
                        menuItem.insertMark = true;
                    }
                    self.menuItems.append(menuItem);
                    self.scrollView.addSubview(menuItem);
                    self.menuItemPoints.append(menuItem.center);
                }
            }
        }
    }
    
    /// 创建网格菜单
    private func createGridViewLayout(){
        for (_ , view) in self.scrollView.subviews.enumerate() {
            if view is WHC_MenuItem {
                view.removeFromSuperview();
            }
        }
        self.menuItems.removeAll();
        self.menuItemPoints.removeAll();
        var sumCount = 0;
        if self.menuItemImageNames != nil || self.menuItemTitles != nil {
            sumCount = self.menuItemTitles == nil ? self.menuItemImageNames.count : self.menuItemTitles.count;
        }
        switch self.menuViewParam.menuOrientation! {
        case .Vertical:
            self.lineWidth = self.menuViewParam.isGridShow ? self.menuViewParam.lineWidth : 0;
            self.menuItemSize = (self.width() - (self.menuViewParam.isGridShow ? CGFloat(self.menuViewParam.column - 1) * self.lineWidth : 0)) / CGFloat(self.menuViewParam.column);
            let rowCount = sumCount / self.menuViewParam.column + (sumCount % self.menuViewParam.column == 0 ? 0 : 1);
            if rowCount < 1 {
                return;
            }
            self.createGridViewModel(rowCount, sumCount: sumCount, page: 0, pageCount: 0);
            self.createGridLineLayout();
        case .Horizontal:
            self.scrollView.delegate = self;
            self.menuViewParam.isShowTopLine = false;
            self.menuViewParam.isGridShow = false;
            self.menuItemSize = (self.width() - (self.menuViewParam.isGridShow ? CGFloat(self.menuViewParam.column - 1) * self.lineWidth : 0)) / CGFloat(self.menuViewParam.column);
            let rowCount = Int(self.height() / self.menuItemSize);
            let pageCount = rowCount * self.menuViewParam.column;
            let sumPageCount = sumCount / pageCount + (sumCount % pageCount != 0 ? 1 : 0);
            if self.menuViewParam.canShowPageCtl && self.pageCtl == nil {
                self.scrollView.setHeight(CGFloat(rowCount) * self.menuItemSize);
                self.setHeight(CGFloat(rowCount) * self.menuItemSize + kPageCtlHeight);
                self.pageCtl = UIPageControl(frame: CGRectMake(0, CGFloat(rowCount) * self.menuItemSize, self.width(), kPageCtlHeight));
                self.pageCtl.currentPageIndicatorTintColor = UIColor.greenColor();
                self.pageCtl.pageIndicatorTintColor = UIColor(white: 0.9, alpha: 1.0);
                self.pageCtl.numberOfPages = sumPageCount;
                self.addSubview(self.pageCtl);
            }else if self.menuViewParam.autoStretchHeight {
                self.setHeight(CGFloat(rowCount) * self.menuItemSize);
                self.scrollView.setHeight(self.height());
            }
            for page in 0...sumPageCount - 1 {
                self.createGridViewModel(rowCount, sumCount: sumCount, page: page, pageCount: pageCount);
            }
            self.scrollView.pagingEnabled = true;
            self.scrollView.contentSize = CGSizeMake(CGFloat(sumPageCount) * self.width(), 0);
        }

    }
    
    /// 创建网格公共模块
    private func createGridViewModel(rowCount: Int , sumCount: Int, page: Int, pageCount: Int){
        for row in 0...rowCount - 1 {
            for index in 0...self.menuViewParam.column - 1 {
                let currentIndex = row * self.menuViewParam.column + index + page * pageCount;
                if currentIndex < sumCount {
                    var imageName = "";
                    if currentIndex < self.menuItemImageNames.count {
                        imageName = self.menuItemImageNames[currentIndex];
                    }
                    let title = self.menuItemTitles != nil && (currentIndex < self.menuItemTitles .count) ? self.menuItemTitles[currentIndex] : "";
                    let menuItem = WHC_MenuItem(frame: CGRectMake(CGFloat(index) * (menuItemSize + lineWidth) + CGFloat(page) * self.width(),
                        CGFloat(row) * (menuItemSize + lineWidth) + (self.menuViewParam.isShowTopLine ? lineWidth : 0),
                        menuItemSize ,
                        menuItemSize),
                        pading: self.menuViewParam.pading);
                    menuItem.delegate = self;
                    menuItem.title = title;
                    menuItem.titleColor = self.menuViewParam.txtColor;
                    menuItem.imageName = imageName;
                    menuItem.index = currentIndex;
                    menuItem.fontSize = self.menuViewParam.txtSize;
                    menuItem.selectedBackgroundColor = self.menuViewParam.selectedBackgroundColor;
                    self.menuItems.append(menuItem);
                    self.scrollView.addSubview(menuItem);
                    self.menuItemPoints.append(menuItem.center);
                }
            }
        }

    }
    
    /// 创建网格线布局
    private func createGridLineLayout(){
        if self.menuViewParam.isGridShow {
            for (_ , view) in self.scrollView.subviews.enumerate() {
                if view is UILabel {
                    view.removeFromSuperview();
                }
            }
        }
        switch self.menuViewParam.menuOrientation! {
        case .Vertical:
            let sumCount = self.menuItemTitles == nil ? self.menuItemImageNames.count : self.menuItemTitles.count;
            let rowCount = sumCount / self.menuViewParam.column + (sumCount % self.menuViewParam.column == 0 ? 0 : 1);
            if rowCount < 1 {
                return;
            }
            if self.menuViewParam.isGridShow && self.menuViewParam.isShowTopLine {
                let line = UILabel(frame: CGRectMake(0,
                    0,
                    self.width(),
                    lineWidth));
                line.backgroundColor = self.menuViewParam.lineColor;
                self.scrollView.addSubview(line);
            }
            for row in 0...rowCount - 1 {
                if self.menuViewParam.isGridShow {
                        let rowLine = UILabel(frame: CGRectMake(0,
                            CGFloat(row + 1) * menuItemSize + CGFloat(row) * lineWidth + (self.menuViewParam.isShowTopLine ? lineWidth : 0),
                            self.width(),
                            lineWidth));
                        rowLine.backgroundColor = self.menuViewParam.lineColor;
                        self.scrollView.addSubview(rowLine);
                }
            }
            if self.menuViewParam.isGridShow {
                for i in 1...self.menuViewParam.column {
                    let columnLine = UILabel(frame: CGRectMake(menuItemSize * CGFloat(i) + CGFloat(i - 1) * lineWidth,
                        lineWidth,
                        lineWidth,
                        CGFloat(rowCount) * menuItemSize + CGFloat(rowCount) * lineWidth));
                    columnLine.backgroundColor = self.menuViewParam.lineColor;
                    self.scrollView.addSubview(columnLine);
                }
            }
            var contentHeight = CGFloat(rowCount) * menuItemSize;
            if self.menuViewParam.isGridShow {
                contentHeight += CGFloat(rowCount) * lineWidth + (self.menuViewParam.isShowTopLine ? self.lineWidth : 0);
            }
            if self.menuViewParam.autoStretchHeight {
                self.setHeight(contentHeight);
                self.scrollView.setHeight(contentHeight);
            }else {
                self.scrollView.contentSize = CGSizeMake(self.width(), contentHeight);
            }
            break;
        case .Horizontal:
            break;
        }
    }
    
    /// 通过长按点获取对应的菜单下标
    private func getMenuItemIndex(point: CGPoint) -> Int{
        var index = -1;
        for menuItem in self.scrollView.subviews {
            if menuItem is WHC_MenuItem        &&
               self.moveMenuItem !== menuItem  &&
            CGRectContainsPoint(menuItem.frame, point) &&
            (menuItem as! WHC_MenuItem).title != kMoreTxt{
                index = (menuItem as! WHC_MenuItem).index;
                break;
            }
        }
        return index;
    }
    
    /// 通过菜单项标题获取相应的菜单项对象
    private func getMenuItem(title: String) -> WHC_MenuItem!{
        var menuItem: WHC_MenuItem! = nil;
        for (index, item) in self.menuItems.enumerate() {
            if item.title == title {
                menuItem = self.menuItems[index];
                break;
            }
        }
        return menuItem;
    }
    //MARK: - 类方法
    
    /// 创建删除/插入图标
    class func createImage(isDelete: Bool , size: CGSize) -> UIImage! {
        let pading:CGFloat = 2;
        UIGraphicsBeginImageContext(size);
        let context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 2);
        if isDelete {
            CGContextSetFillColorWithColor(context, UIColor.redColor().CGColor);
        }else {
            CGContextSetFillColorWithColor(context, UIColor(red: 63.0 / 255.0, green: 145.0 / 255.0, blue: 49.0 / 255.0, alpha: 1.0).CGColor);
        }
        CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor);
        CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
        CGContextDrawPath(context, .Fill);
        CGContextMoveToPoint(context, pading, size.height / 2);
        CGContextAddLineToPoint(context, size.width - pading, size.height / 2);
        if !isDelete {
            CGContextMoveToPoint(context, size.width / 2, pading);
            CGContextAddLineToPoint(context, size.width / 2, size.height - pading);
        }
        CGContextDrawPath(context, .Stroke);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    //MARK: - 公共方法
    
    /// 获取菜单项图片集合
    func getImages() -> [UIImage] {
        var images = [UIImage]();
        for (_ , item) in self.menuItems.enumerate() {
            let imageObject = item.imageObject();
            if imageObject != nil {
                images.append(imageObject!);
            }
        }
        return images;
    }
    
    /// 更新图片集合
    func update(imagesName imagesName: [String] , titles: [String]!){
        if self.menuItemImageNames != nil {
            self.menuItemImageNames.removeAll();
        }
        if self.menuItemTitles != nil {
            self.menuItemTitles.removeAll();
        }
        if titles != nil {
            self.menuItemTitles = titles;
        }
        self.menuItemImageNames = imagesName;
        self.createGridViewLayout();
    }
    
    /// 插入图片菜单集合
    func insertMenuItemsImage(images: [UIImage]){
        self.insertMenuImages = images;
        if self.menuViewParam.insertMenuItemImageName == nil {
            self.insertMenuImages.append(WHC_MenuView.createImage(false, size: CGSizeMake(80, 80)));
        }else {
            self.insertMenuImages.append(UIImage(named: self.menuViewParam.insertMenuItemImageName)!);
        }
        self.createDynamicInsertLayout();
    }
    
    /// 处理屏幕时钟
    func handleDisplayLink(){
        if self.scrollView.contentOffset.y >= -self.initEdge.top {
            self.scrollView.setContentOffset(CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y - CGFloat(self.moveIncrement)), animated: false);
            self.moveMenuItem.center = CGPointMake(self.moveMenuItem.centerX(), self.moveMenuItem.centerY() - CGFloat(self.moveIncrement));
            switch self.dragOri! {
            case .Up:
                if self.scrollView.contentOffset.y < -self.initEdge.top {
                    self.moveIncrement = 0;
                    self.scrollView.contentOffset.y = -self.initEdge.top;
                    self.removeDisplayerLink();
                }
            case .Down:
                if self.scrollView.contentSize.height - self.height() + self.initEdge.bottom <= self.scrollView.contentOffset.y{
                    self.scrollView.contentOffset.y = self.scrollView.contentSize.height - self.height() + self.initEdge.bottom;
                    self.moveIncrement = 0;
                    self.removeDisplayerLink();
                }
            case .Left:
                break;
            case .Right:
                break;
            }
            self.sortWHCMenuView(self.moveMenuItem.center , isSorted: nil);
        }
    }
    
    /// 获取添加菜单项标题集合
    func getInsertTitles() -> [String]! {
        return self.deletedMenuItemTitles;
    }
    
    /// 获取添加菜单项图片名称集合
    func getInsertImageNames() -> [String]! {
        return self.deletedMenuItemImageNames;
    }
    
    /// 保存插入后菜单项的状态
    func saveInsertedMenuItemState(){
        
        let us = NSUserDefaults.standardUserDefaults();
        let object = us.objectForKey(self.menuViewParam.cacheWHCMenuKey);
        if object != nil {
            var titles: [String] = self.menuItemTitles;
            if titles.contains(kMoreTxt) {
                titles.removeAtIndex(titles.count - 1);
            }
            us.setObject([kWHCTitlesKey: titles ,
                kWHCImageNamesKey: self.menuItemImageNames,
                kWHCDeleteImageNamesKey: self.deletedMenuItemImageNames,
                kWHCDeleteTitlesKey: self.deletedMenuItemTitles],
                forKey: self.menuViewParam.cacheWHCMenuKey)
            us.synchronize();
        }
    }
    
    /// 保存编辑后菜单项的状态
    func saveEditedMenuItemState(){
        self.menuItemImageNames.removeAll();
        self.menuItemTitles.removeAll();
        for (_ , item) in self.menuItems.enumerate() {
            self.menuItemTitles.append(item.title);
            self.menuItemImageNames.append(item.imageName);
        }
        let us = NSUserDefaults.standardUserDefaults();
        let object = us.objectForKey(self.menuViewParam.cacheWHCMenuKey);
        if object != nil {
            if self.isMoreMenuItem {
                let cacheMenuDict: NSDictionary = object as! NSDictionary;
                let cacheMenuMutableDict: NSMutableDictionary = cacheMenuDict.mutableCopy() as! NSMutableDictionary;
                cacheMenuMutableDict.setObject(self.menuItemTitles, forKey: kWHCDeleteTitlesKey)
                cacheMenuMutableDict.setObject(self.menuItemImageNames, forKey: kWHCDeleteImageNamesKey);
                us.setObject(cacheMenuMutableDict,
                    forKey: self.menuViewParam.cacheWHCMenuKey)
                us.synchronize();
            }else {
                self.saveInsertedMenuItemState();
            }
        }
    }
    
    /// 通过菜单项标题设置消息红色气泡
    func setMenuItemRedMark(title: String){
        let menuItem = self.getMenuItem(title);
        if menuItem != nil {
            menuItem.showMark();
        }
    }
    
    /// 通过菜单项标题移除消息红色气泡
    func removeMenuItemRedMark(title: String){
        let menuItem = self.getMenuItem(title);
        if menuItem != nil {
            menuItem.hideMark();
        }
    }
    
    /// 获取菜单项标题集合
    func getMenuItemTitles()->[String]{
        var menuItemTitles: [String] = [String]();
        for (index , _) in self.menuItemTitles.enumerate() {
            menuItemTitles.append(self.menuItemTitles[index]);
        }
        return menuItemTitles;
    }
    //MARK: - 手势排序
    
    private func addDisplayerLink(){
        if self.displayLink == nil {
            self.displayLink = CADisplayLink(target: self, selector: Selector("handleDisplayLink"));
            self.displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode);
        }else{
            self.displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode);
        }
    }
    
    private func stopDisplayerLink(){
        if self.displayLink != nil {
            self.displayLink.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode);
        }
    }
    
    private func removeDisplayerLink(){
        if self.displayLink != nil {
            self.displayLink.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode);
            self.displayLink.paused = true;
            self.displayLink.invalidate();
            self.displayLink = nil;
        }
    }
    
    func handleSortGesture(sender: UILongPressGestureRecognizer){
        switch sender.state {
        case .Began:
            if self.initEdge == nil {
                self.initEdge = self.scrollView.contentInset;
            }
            self.currentMovePoint = CGPointZero;
            self.canMoveMenuItem = false;
            self.moveMenuItem = nil;
            self.isTouchEnd = false;
            let point = sender.locationInView(sender.view);
            self.moveMenuItemIndex = self.getMenuItemIndex(point);
            if self.moveMenuItemIndex > -1 {
                if self.menuViewParam.canSort {
                    self.canMoveMenuItem = true;
                    self.canMoveAnimation = true;
                }
                self.moveMenuItem = self.menuItems[self.moveMenuItemIndex];
                if !self.moveMenuItem.insertMark {
                    self.scrollView.bringSubviewToFront(self.moveMenuItem);
                    self.moveMenuItem.setLongPressBackgroundColor();
                    if self.menuViewParam.canAdd {
                        self.moveMenuItem.addInsertButton();
                    }else if self.menuViewParam.canDelete ||
                        self.menuViewParam.isDynamicInsertMenuItem {
                            self.moveMenuItem.addDeleteButton();
                    }
                }
                self.startPoint = self.moveMenuItem.center;
            }
        case .Changed:
            if self.canMoveMenuItem && self.menuViewParam.canSort {
                self.currentMovePoint = sender.locationInView(sender.view);
                var moveUp = false;
                if self.menuViewParam.menuOrientation == .Vertical {
                    if self.currentMovePoint.y < self.moveMenuItem.centerY() {
                        moveUp = true;
                    }
                }else {
                    self.dragOri = .Right;
                    if self.currentMovePoint.x < self.moveMenuItem.centerX() {
                        self.dragOri = .Left;
                    }
                }
                self.moveMenuItem.center = self.currentMovePoint;
                if !self.isAnimationMoving {
                    self.removeDisplayerLink();
                    if self.menuViewParam.menuOrientation == .Vertical {
                        if self.moveMenuItem.y() > 0 {
                            if moveUp {
                                self.dragOri = .Up;
                                let diff = self.moveMenuItem.y() - self.initEdge.top - self.scrollView.contentOffset.y;
                                if diff < -1 {
                                    self.moveIncrement = Int(-diff);
                                    self.addDisplayerLink();
                                }
                            }else{
                                self.dragOri = .Down;
                                let diff = self.moveMenuItem.maxY() - self.height() - self.scrollView.contentOffset.y + self.initEdge.bottom;
                                if diff > 1 && (self.scrollView.contentOffset.y + 1) < (self.scrollView.contentSize.height - self.height()){
                                    self.moveIncrement = Int(-diff);
                                    self.addDisplayerLink();
                                }
                            }
                        }
                    }else {
                        if  self.moveMenuItem.x() > 0 && self.canMoveAnimation{
                            if self.pageCtl.currentPage < self.pageCtl.numberOfPages - 1 &&
                                self.dragOri == .Right {
                                if moveMenuItem.maxX() > (CGFloat(self.pageCtl.currentPage + 1) * self.width() + 10) &&
                                moveMenuItem.maxX() < CGFloat(self.pageCtl.currentPage + 1) * self.width() + self.menuItemSize {
                                    self.canMoveAnimation = false;
                                    UIView.animateWithDuration(kWHCAnimationTime, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                                        self.scrollView.contentOffset = CGPointMake(CGFloat(self.pageCtl.currentPage + 1) * self.width(), 0);
                                        }, completion: { (finish) -> Void in
                                            self.pageCtl.currentPage += 1;
                                            self.moveMenuItem.center = CGPointMake(CGFloat(self.pageCtl.currentPage + 1) * self.width() - self.moveMenuItem.width() / 2.0, self.moveMenuItem.centerY());
                                            self.setMoveAnimation();
                                    });
                                }
                            }else if self.pageCtl.currentPage > 0 {
                                if moveMenuItem.x() < (CGFloat(self.pageCtl.currentPage) * self.width() - 10) {
                                    self.canMoveAnimation = false;
                                    UIView.animateWithDuration(kWHCAnimationTime, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                                        self.scrollView.contentOffset = CGPointMake(CGFloat(self.pageCtl.currentPage - 1) * self.width(), 0);
                                        }, completion: { (finish) -> Void in
                                            self.pageCtl.currentPage -= 1;
                                            self.moveMenuItem.center = CGPointMake(CGFloat(self.pageCtl.currentPage) * self.width() + self.moveMenuItem.width() / 2.0, self.moveMenuItem.centerY());
                                            self.setMoveAnimation();
                                    });
                                }
                            }
                        }
                    }
                    self.sortWHCMenuView(self.currentMovePoint , isSorted: nil);
                }
            }
        case .Cancelled ,
             .Ended:
            self.canMoveAnimation = false;
            self.removeDisplayerLink();
            self.isTouchEnd = true;
            
            self.moveMenuItem?.resetRect(self.startPoint);
            if self.menuViewParam.canSort {
                self.saveEditedMenuItemState();
            }
        default:
            break;
        }
    }
    
    private func sortWHCMenuView(movePoint: CGPoint , isSorted: ((Bool) -> Void)?){
        let currentIndex = self.getMenuItemIndex(movePoint);
        if currentIndex > -1 {
            self.isAnimationMoving = true;
            UIView.animateWithDuration(kWHCAnimationTime / 2.0,
                animations: { () -> Void in
                    if currentIndex > self.moveMenuItemIndex {
                        for var i = currentIndex ; i > self.moveMenuItemIndex ; i-- {
                            let menuItem = self.menuItems[i];
                            menuItem.sendSubviewToBack(self.moveMenuItem);
                            var menuItemPoint = self.menuItemPoints[i - 1];
                            if i == self.moveMenuItemIndex + 1 {
                                let movingMenuItemCenter = self.menuItemPoints[self.moveMenuItemIndex];
                                menuItemPoint.x = movingMenuItemCenter.x;
                                menuItemPoint.y = movingMenuItemCenter.y;
                            }
                            menuItem.center = menuItemPoint;
                        }
                    } else if currentIndex < self.moveMenuItemIndex {
                        for var i = currentIndex ; i < self.moveMenuItemIndex ; i++ {
                            let menuItem = self.menuItems[i];
                            menuItem.sendSubviewToBack(self.moveMenuItem);
                            var menuItemPoint = self.menuItemPoints[i + 1];
                            if i == self.moveMenuItemIndex - 1 {
                                let movingMenuItemCenter = self.menuItemPoints[self.moveMenuItemIndex];
                                menuItemPoint.x = movingMenuItemCenter.x;
                                menuItemPoint.y = movingMenuItemCenter.y;
                            }
                            menuItem.center = menuItemPoint;
                        }
                    }
                },
                completion: { (finish: Bool) -> Void in
                    self.menuItems.exchangeObject(self.moveMenuItemIndex, currentIndex);
                    if currentIndex > self.moveMenuItemIndex {
                        for var i = self.moveMenuItemIndex ; i < currentIndex - 1 ; i++ {
                            self.menuItems.exchangeObject(i, i + 1);
                        }
                    }else if currentIndex < self.moveMenuItemIndex {
                        for var i = self.moveMenuItemIndex ; i > currentIndex + 1; i-- {
                            self.menuItems.exchangeObject(i, (i - 1 < 0 ? 0 : i - 1));
                        }
                    }
                    for i in 0...(self.menuItems.count - 1){
                        self.menuItems[i].index = i;
                    }
                    self.startPoint = self.menuItemPoints[currentIndex];
                    if self.isTouchEnd && self.startPoint != self.moveMenuItem.center {
                        self.moveMenuItem.center = self.startPoint;
                        self.saveEditedMenuItemState();
                    }
                    self.moveMenuItemIndex = currentIndex;
                    self.isAnimationMoving = false;
                    isSorted?(true);
            })
        }else {
            isSorted?(false);
        }
    }
    
    //MARK: - WHC_MoreMenuItemVCDelegate
    func WHCMoreMenuItemVC(moreVC: WHC_MoreMenuItemVC, addTitles: [String]!, addImageNames: [String]!) {
        if addTitles != nil {
            for (_ , value) in addTitles.enumerate() {
                self.menuItemTitles.insert(value, atIndex: self.menuItemTitles.count - 1);
                if self.deletedMenuItemTitles.contains(value) {
                    self.deletedMenuItemTitles.removeAtIndex(self.deletedMenuItemTitles.indexOf(value)!);
                }
            }
        }
        if addImageNames != nil {
            for (_ , value) in addImageNames.enumerate() {
                self.menuItemImageNames.insert(value, atIndex: self.menuItemImageNames.count - 1);
                if self.deletedMenuItemImageNames.contains(value) {
                    self.deletedMenuItemImageNames.removeAtIndex(self.deletedMenuItemImageNames.indexOf(value)!);
                }
            }
        }
        let us = NSUserDefaults.standardUserDefaults();
        let object = us.objectForKey(self.menuViewParam.cacheWHCMenuKey);
        if object != nil {
            let cacheMenuDict: NSMutableDictionary = (object as! NSDictionary).mutableCopy() as! NSMutableDictionary;
            self.deletedMenuItemTitles = cacheMenuDict[self.kWHCDeleteTitlesKey] as! [String];
            self.deletedMenuItemImageNames = cacheMenuDict[self.kWHCDeleteImageNamesKey] as! [String];
        }
        self.saveInsertedMenuItemState();
        self.createGridViewLayout();
    }
    //MARK: - WHC_MenuItemDelegate
    
    func WHCMenuItemClick(item: WHC_MenuItem , title: String , index: Int){
        if self.menuViewParam.isDynamicInsertMenuItem {
            if item.insertMark {
                self.delegate?.WHCMenuViewClickInsertItem?();
            }
        }else {
            if title == kMoreTxt {
                var currentVC: UIViewController!;
                let rootVC = UIApplication.sharedApplication().delegate?.window??.rootViewController;
                if rootVC is UINavigationController {
                    currentVC = (rootVC as! UINavigationController).topViewController;
                }else if rootVC is UITabBarController {
                    let tabBarVC: UIViewController = (rootVC as! UITabBarController).selectedViewController!;
                    if tabBarVC is UINavigationController {
                        currentVC = (tabBarVC as! UINavigationController).topViewController;
                    }else{
                        currentVC = tabBarVC;
                    }
                }else{
                    currentVC = rootVC;
                }

                let vc = WHC_MoreMenuItemVC();
                vc.delegate = self;
                vc.menuItemTitles = self.deletedMenuItemTitles;
                vc.menuItemImageNames = self.deletedMenuItemImageNames;
                vc.cacheWHCMenuKey = self.menuViewParam.cacheWHCMenuKey;
                vc.pading = self.menuViewParam.pading;
                currentVC?.presentViewController(UINavigationController(rootViewController: vc), animated: true, completion: nil);
            }else {
                self.delegate?.WHCMenuView?(self , item: item , title: title);
            }
        }
    }
    
    func WHCMenuItemClickInsert(item: WHC_MenuItem) {
        let itemIndex = item.index;
        self.deletedMenuItemTitles.append(item.title);
        self.deletedMenuItemImageNames.append(item.imageName);
        UIView.animateWithDuration(self.kWHCAnimationTime, animations: { () -> Void in
            item.transform = CGAffineTransformMakeScale(0.1, 0.1);
            }) { (finish) -> Void in
                let isDeleteRow = ((self.menuItems.count % self.menuViewParam.column != 1) ? false : true);
                item.removeFromSuperview();
                UIView.animateWithDuration(self.kWHCAnimationTime, animations: { () -> Void in
                    if itemIndex < self.menuItems.count - 1 {
                        for index in itemIndex + 1 ... self.menuItems.count - 1 {
                            let nextMenuItem = self.menuItems[index];
                            let newNextMenuItemCenter = self.menuItemPoints[index - 1];
                            nextMenuItem.center = newNextMenuItemCenter;
                        }
                    }
                    }, completion: { (finish) -> Void in
                        self.menuItems.removeAtIndex(itemIndex);
                        self.menuItemTitles.removeAtIndex(itemIndex);
                        self.menuItemImageNames.removeAtIndex(itemIndex);
                        self.menuItemPoints.removeAll();
                        if self.menuItems.count > 0 {
                            for index in 0...self.menuItems.count - 1 {
                                let menuItem = self.menuItems[index];
                                menuItem.index = index;
                                self.menuItemPoints.append(menuItem.center);
                            }
                        }
                        self.isAnimationMoving = false;
                        if isDeleteRow {
                            self.createGridLineLayout();
                        }
                        
                        let us = NSUserDefaults.standardUserDefaults();
                        let object = us.objectForKey(self.menuViewParam.cacheWHCMenuKey);
                        if object != nil {
                            let cacheMenuDict: NSMutableDictionary = (object as! NSDictionary).mutableCopy() as! NSMutableDictionary;
                            var deleteTitles: [String] = cacheMenuDict[self.kWHCDeleteTitlesKey] as! [String];
                            var deleteImageNames: [String] = cacheMenuDict[self.kWHCDeleteImageNamesKey] as! [String];
                            if deleteImageNames.contains(item.imageName) {
                                deleteImageNames.removeAtIndex(deleteImageNames.indexOf(item.imageName)!);
                            }
                            if deleteTitles.contains(item.title) {
                                deleteTitles.removeAtIndex(deleteTitles.indexOf(item.title)!);
                            }
                            cacheMenuDict.setObject(deleteTitles, forKey: self.kWHCDeleteTitlesKey)
                            cacheMenuDict.setObject(deleteImageNames, forKey: self.kWHCDeleteImageNamesKey);
                            us.setObject(cacheMenuDict,
                                forKey: self.menuViewParam.cacheWHCMenuKey)
                            us.synchronize();
                        }
                })
                
            }
    }
    
    func WHCMenuItemClickDelete(item: WHC_MenuItem) {
        self.currentDeleteMenuItem = item;
        self.scrollView.bringSubviewToFront(item);
        let itemCenterPoint = item.center;
        
        if self.menuViewParam.isDynamicInsertMenuItem {
            let itemIndex = item.index;
            UIView.animateWithDuration(self.kWHCAnimationTime, animations: { () -> Void in
                item.transform = CGAffineTransformMakeScale(0.1, 0.1);
                }) { (finish) -> Void in
                    item.removeFromSuperview();
                    UIView.animateWithDuration(self.kWHCAnimationTime, animations: { () -> Void in
                        if itemIndex < self.menuItems.count - 1 {
                            for index in itemIndex + 1 ... self.menuItems.count - 1 {
                                let nextMenuItem = self.menuItems[index];
                                let newNextMenuItemCenter = self.menuItemPoints[index - 1];
                                nextMenuItem.center = newNextMenuItemCenter;
                            }
                        }
                        }, completion: { (finish) -> Void in
                            self.insertMenuImages.removeAtIndex(itemIndex);
                            self.menuItems.removeAtIndex(itemIndex);
                            self.menuItemPoints.removeAll();
                            if self.menuItems.count > 0 {
                                for index in 0...self.menuItems.count - 1 {
                                    let menuItem = self.menuItems[index];
                                    menuItem.index = index;
                                    self.menuItemPoints.append(menuItem.center);
                                }
                            }
                            self.isAnimationMoving = false;
                            self.delegate?.WHCMenuViewClickDelete?(item);
                    })
            }

        }else {
            let moreItemCenterPoint = self.getMenuItem(kMoreTxt).center;
            let transform = CGAffineTransformMakeTranslation(moreItemCenterPoint.x - itemCenterPoint.x,
                moreItemCenterPoint.y - itemCenterPoint.y);
            UIView.animateWithDuration(kWHCAnimationTime, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                item.transform = CGAffineTransformScale(transform, 0.1, 0.1);
                }, completion: { (finish) -> Void in
                    self.currentDeleteMenuItem.hidden = true;
                    let itemIndex = self.currentDeleteMenuItem.index;
                    self.deletedMenuItemTitles.append(self.currentDeleteMenuItem.title);
                    self.deletedMenuItemImageNames.append(self.currentDeleteMenuItem.imageName);
                    self.currentDeleteMenuItem.removeFromSuperview();
                    let isDeleteRow = ((self.menuItems.count % self.menuViewParam.column != 1) ? false : true);
                    self.menuItemImageNames.removeAtIndex(itemIndex);
                    self.menuItemTitles.removeAtIndex(itemIndex);
                    self.isAnimationMoving = true;
                    UIView.animateWithDuration(self.kWHCAnimationTime, animations: { () -> Void in
                        for index in itemIndex + 1 ... self.menuItems.count - 1 {
                            let nextMenuItem = self.menuItems[index];
                            let newNextMenuItemCenter = self.menuItemPoints[index - 1];
                            nextMenuItem.center = newNextMenuItemCenter;
                        }
                        }) { (finish) -> Void in
                            self.menuItems.removeAtIndex(itemIndex);
                            self.menuItemPoints.removeAll();
                            for index in 0...self.menuItems.count - 1 {
                                let menuItem = self.menuItems[index];
                                menuItem.index = index;
                                self.menuItemPoints.append(menuItem.center);
                            }
                            self.isAnimationMoving = false;
                            self.saveEditedMenuItemState();
                            if isDeleteRow {
                                self.createGridLineLayout();
                            }
                    }

            })
        }
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        self.currentDeleteMenuItem.hidden = true;
        let itemIndex = self.currentDeleteMenuItem.index;
        self.deletedMenuItemTitles.append(self.currentDeleteMenuItem.title);
        self.deletedMenuItemImageNames.append(self.currentDeleteMenuItem.imageName);
        self.currentDeleteMenuItem.removeFromSuperview();
        let isDeleteRow = ((self.menuItems.count % self.menuViewParam.column != 1) ? false : true);
        self.menuItemImageNames.removeAtIndex(itemIndex);
        self.menuItemTitles.removeAtIndex(itemIndex);
        self.isAnimationMoving = true;
        UIView.animateWithDuration(kWHCAnimationTime, animations: { () -> Void in
            for index in itemIndex + 1 ... self.menuItems.count - 1 {
                let nextMenuItem = self.menuItems[index];
                let newNextMenuItemCenter = self.menuItemPoints[index - 1];
                nextMenuItem.center = newNextMenuItemCenter;
            }
        }) { (finish) -> Void in
            self.menuItems.removeAtIndex(itemIndex);
            self.menuItemPoints.removeAll();
            for index in 0...self.menuItems.count - 1 {
                let menuItem = self.menuItems[index];
                menuItem.index = index;
                self.menuItemPoints.append(menuItem.center);
            }
            self.isAnimationMoving = false;
            self.saveEditedMenuItemState();
            if isDeleteRow {
                self.createGridLineLayout();
            }
        }
    }
    
    //MARK: - UIScrollViewDelegate
    
    func setMoveAnimation(){
        self.canMoveAnimation = true;
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.pageCtl?.currentPage = Int(floor((scrollView.contentOffset.x - self.pageCtl.width() / 2.0) / self.pageCtl.width())) + 1;
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        self.performSelector(Selector("setMoveAnimation"), withObject: nil, afterDelay: 0.5);
    }
}
