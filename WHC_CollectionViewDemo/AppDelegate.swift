//
//  AppDelegate.swift
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

extension UIColor {
    /// 主题颜色
    class func themeColor() -> UIColor{
        return UIColor(red: 38.0 / 255.0, green: 110.0 / 255.0, blue: 239.0 / 255.0, alpha: 1.0);
    }
    
    /// VC主背景颜色
    class func themeBackgroundColor() -> UIColor{
        return UIColor(red: 245.0 / 255.0, green: 246.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0);
    }
    
    /// 线颜色
    class func lineColor() -> UIColor{
        return UIColor(red: 197 / 255.0, green: 199 / 255.0, blue: 200 / 255.0, alpha: 1.0);
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.mainScreen().bounds);
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent;
        UINavigationBar.appearance().barStyle = .Black;
        UINavigationBar.appearance().barTintColor = UIColor.themeColor();
        UINavigationBar.appearance().translucent = true;
        
        let tabVC = UITabBarController();
        let oneVC = WHC_StyleOneVC(nibName: "WHC_StyleOneVC", bundle: nil);
        let oneNV = UINavigationController(rootViewController: oneVC);
        oneNV.tabBarItem.title = "OneStyle";
        oneNV.tabBarItem.image = UIImage(named: "tab");
        
        let twoVC = WHC_StyleTwoVC(nibName: "WHC_StyleTwoVC", bundle: nil);
        let twoNV = UINavigationController(rootViewController: twoVC);
        twoNV.tabBarItem.title = "TwoStyle";
        twoNV.tabBarItem.image = UIImage(named: "tab");
        
        let threeVC = WHC_StyleThreeVC(nibName: "WHC_StyleThreeVC", bundle: nil);
        let threeNV = UINavigationController(rootViewController: threeVC);
        threeNV.tabBarItem.title = "hreeStyle";
        threeNV.tabBarItem.image = UIImage(named: "tab");
        
        let fourVC = WHC_StyleFourVC(nibName: "WHC_StyleFourVC", bundle: nil);
        let fourNV = UINavigationController(rootViewController: fourVC);
        fourNV.tabBarItem.title = "FourStyle";
        fourNV.tabBarItem.image = UIImage(named: "tab");
        
        tabVC.viewControllers = [oneNV , twoNV , threeNV , fourNV];
        window?.rootViewController = tabVC;
        window?.makeKeyAndVisible();
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

