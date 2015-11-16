# WHC_CollectionViewDemo

##  作者:吴海超
##  联系qq:712641411


## 目前独一无二封装最完美的网格菜单开源组件，支持用户行为习惯自定义菜单项位置和个数
##   (用户可长按菜单项进行排序，删除，添加，自动保存用户编辑后的状态)
## 同时集成最新最轻最有个性的下拉上拉刷新组件(支持自定义刷新颜色定制和刷新动画选择)
#具体使用方式请下载demo阅读里面很详细


###该组件支持参数自定义样式说明如下：
```swift
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

```

##总体运行效果
![](https://github.com/netyouli/WHC_CollectionViewFramework/blob/master/WHC_CollectionViewDemo/gif/whc.gif)

##下拉刷新运行效果
![](https://github.com/netyouli/WHC_CollectionViewFramework/blob/master/WHC_CollectionViewDemo/gif/whc1.gif)

####运行效果OneStyle调用方式代码如下：
```swift
    let menuParam = WHC_MenuViewParam.getWHCMenuViewDefaultParam(titles: ["WHC","公司通知","直销客户","渠道客户","拜访管理","拜访回馈","回馈问题","销售计划","项目报备","项目跟踪","合同管理","收款管理","工作小结","请假申请","费用申请","汇总统计","发布通知","客户审核","回馈批注","小结批注","报备审核","市场推广","售后服务","费用审核","请假审批","w","h","c","吴海超","吴","超","海","iOS","Android","WP","手机","苹果","大神"], imageNames: ["icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2"], cacheWHCMenuKey: "WHC-集合菜单样式一");

    let menuView = WHC_MenuView(frame: UIScreen.mainScreen().bounds, menuViewParam: menuParam);
    menuView.delegate = self;
    self.view.addSubview(menuView);
```


####运行效果TwoStyle调用方式代码如下：
```swift
    self.automaticallyAdjustsScrollViewInsets = false;
    let menuParam = WHC_MenuViewParam.getWHCMenuViewDefaultParam(titles: ["WHC","公司通知","直销客户","渠道客户","拜访管理","拜访回馈","回馈问题","销售计划","项目报备","项目跟踪","合同管理","收款管理","工作小结","请假申请","费用申请","汇总统计","发布通知","客户审核","回馈批注","小结批注","报备审核","市场推广","售后服务","费用审核","请假审批","w","h","c","吴海超","吴","超","海","iOS","Android","WP","手机","苹果","大神"], imageNames: ["icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2"], cacheWHCMenuKey: "WHC-集合菜单样式二");

    menuParam.menuOrientation = .Horizontal;  // 横向布局菜单
    let menuView = WHC_MenuView(frame: CGRectMake(0, 64.0, self.view.screenWidth(), self.view.screenHeight() - 114), menuViewParam: menuParam);
    menuView.delegate = self;
    self.view.addSubview(menuView);
```

####运行效果ThreeStyle调用方式代码如下：
```swift
    let menuParam = WHC_MenuViewParam.getWHCMenuViewDefaultParam(titles: nil, imageNames: nil , cacheWHCMenuKey: "");
    menuParam.canDelete = false;          // 不能删除
    menuParam.canSort = false;            // 不能排序
    menuParam.isGridShow = false;         // 没有网格
    menuParam.autoStretchHeight = true;   // 自动拉伸菜单自身
    menuParam.pading = 1;                 // 间隙
    self.imageMenuView = WHC_MenuView(frame: menuView.frame, menuViewParam: menuParam);
    self.imageMenuView.delegate = self;
    self.backView.addSubview(self.imageMenuView);

    func displayCell(imagesName: [String], otherParam: AnyObject!) {
        self.imageMenuView.update(imagesName: imagesName, titles: nil);
        self.bottomView.setY(self.imageMenuView.maxY() + 1);
        self.backView.setHeight(self.bottomView.maxY());
        self.contentView.setHeight(self.backView.maxY());
        self.setHeight(self.contentView.height());
    }


    /// 下拉上拉加载更多集成方式

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "WHC-集合菜单样式三";
        self.tableView.backgroundColor = UIColor.themeBackgroundColor();
        self.tableView.registerNib(UINib(nibName: kCellName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: kCellName);
        // 默认刷新动画样式
        self.tableView.whc_setRefreshStyle(refreshStyle: .AllStyle, tableViewHeight: self.view.screenHeight(), delegate: self);
        // 可修改刷新动画样式
//        self.tableView.whc_setRefreshStyle(refreshStyle: .AllStyle, refreshAnimationType: .CrossErasure, tableViewHeight: self.view.screenHeight(), delegate: self);
        // Do any additional setup after loading the view.
    }





/// 刷新代理实现
    func WHCUpRefresh(){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
        [unowned self] () -> Void in

        self.count += 1;
        if self.count > self.imagesName.count {
            self.count = self.imagesName.count;
            self.tableView.whc_setFinishedRefresh(style: .UpStyle , prompt: "所有已经加载完");
        }else {
            self.tableView.whc_setFinishedRefresh(style: .UpStyle);
        }
        self.tableView.reloadData();
        })
    }
    func WHCDownRefresh(){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
        [unowned self] () -> Void in
        self.count -= 1;
        if self.count < 1 {
            self.count = 1;
            self.tableView.whc_setFinishedRefresh(style: .DownStyle , prompt: "已经到第一页");
        }else {
            self.tableView.whc_setFinishedRefresh(style: .DownStyle);
        }
            self.tableView.reloadData();
        })
    }

```


####运行效果FourStyle调用方式代码如下：
```swift
    let menuParam = WHC_MenuViewParam.getWHCMenuViewDefaultParam(titles: nil, imageNames: nil, cacheWHCMenuKey: "");
    menuParam.isDynamicInsertMenuItem = true;   // 动态插入
    menuParam.insertMenuItemImageName = "add";  // 插入图片
    imageMenuView = WHC_MenuView(frame: UIScreen.mainScreen().bounds, menuViewParam: menuParam);
    imageMenuView.delegate = self;
    self.view.addSubview(imageMenuView);

//代理：

//MARK: - WHC_MenuViewDelegate
    func WHCMenuViewClickDelete(item: WHC_MenuItem) {
        self.images.removeAtIndex(item.index);
    }

    func WHCMenuViewClickInsertItem(){
        let count = kMaxPictureChoiceNumber - self.images.count;
        if count == 0 {
            let alert = UIAlertView(title: "已选择10张,如更换图片请先长按已选图片进行删除", message: nil, delegate: nil, cancelButtonTitle: "确定");
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

```
