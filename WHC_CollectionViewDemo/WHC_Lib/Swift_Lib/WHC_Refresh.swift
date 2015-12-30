//
//  WHC_Refresh.swift
//  CRM
//
//  Created by 吴海超 on 15/11/13.
//  Copyright © 2015年 吴海超. All rights reserved.
//

import UIKit

/// Refresh the style
enum WHCRefreshStyle: Int {
    case AllStyle
    case DownStyle
    case UpStyle
    case NoneStyle
}

/// The refresh update status
enum WHCRefreshState: Int {
    case NoneRefresh
    case PullRefresh
    case WillRefresh
    case DoingRefresh
    case FinishedRefresh
    case ResetRefresh
}

/// Refresh the animation types
enum WHCRefreshAnimationType: Int {
    case LoopErasure
    case CrossErasure
}

/// Refresh the constants
struct WHCRefreshConstant {
    static let drawDistance: CGFloat = 25;
    static let headerViewHeight: CGFloat = 40;
    static let footerVeiwHeight: CGFloat = 40;
    static let pading: CGFloat = 5;
    static var headerViewKey = 0;
    static var footerViewKey = 1;
    static let defaultStartAngle = CGFloat(M_PI_2);
    static var startColor = UIColor(red: 99.0 / 255, green: 211.0 / 255, blue: 155.0 / 255, alpha: 1.0);
    static var midColor = UIColor(red: 99.0 / 255, green: 211.0 / 255, blue: 155.0 / 255, alpha: 1.0);
    static var endColor = UIColor(red: 99.0 / 255, green: 211.0 / 255, blue: 155.0 / 255, alpha: 1.0);
    static let startLocation = NSNumber(float: 0);
    static let midLocation = NSNumber(float: 0.5);
    static let endLocation = NSNumber(float: 1);
    static let animateDuration = 0.5;
    static let drawIncrement: CGFloat = 1.0;
    static let drawCrossIncrement: CGFloat = 2;
    static let shockWaveIncrement: CGFloat = 150;
    static let promptFontSize: CGFloat = 12;
    static let promptFontScaleFactor: CGFloat = 0.5;
}

/// The refresh completes agent

@objc protocol WHCRefreshDelegate {
    optional func WHCDownRefresh();
    optional func WHCUpRefresh();
}

/// Refresh the view class

class WHCRefreshView: UIView {
    var initScrollViewEdge = UIEdgeInsets();
    var delegate: WHCRefreshDelegate!;
    var progressLayer: CAShapeLayer!;
    var gradientLayer: CAGradientLayer!;
    var radius: CGFloat = 0;
    var layerSize: CGFloat = 0;
    var promptLable: UILabel!;
    var prompt: String!;
    var refreshState = WHCRefreshState.NoneRefresh;
    var refreshAnimationType = WHCRefreshAnimationType.CrossErasure;
    var scrollView: UIScrollView!;
    var startAngle = WHCRefreshConstant.defaultStartAngle;
    var endAngle: CGFloat = 0;
    var refreshStyle = WHCRefreshStyle.NoneStyle {
        willSet {
            switch newValue {
            case .DownStyle:
                currentDrawIncrement = WHCRefreshConstant.headerViewHeight;
            case .UpStyle:
                currentDrawIncrement = WHCRefreshConstant.footerVeiwHeight;
            default:
                break;
            }
        }
    };
    private var isShockWaveAnimation = false;
    private var currentDrawIncrement: CGFloat = WHCRefreshConstant.headerViewHeight;
    private var isIncrement = false;
    private var displayTimer: CADisplayLink!;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.layer.masksToBounds = true;
        /// Set the initial parameters
        radius = (self.height() - 2 * WHCRefreshConstant.pading) / 2;
        layerSize = 2 * radius;
        
        /// Create refreshes the animation layer
        gradientLayer = CAGradientLayer();
        gradientLayer.frame = self.bounds;
        gradientLayer.backgroundColor = UIColor.clearColor().CGColor;
        gradientLayer.colors = [WHCRefreshConstant.startColor.CGColor,
            WHCRefreshConstant.midColor.CGColor,
            WHCRefreshConstant.endColor.CGColor];
        gradientLayer.locations = [WHCRefreshConstant.startLocation ,
            WHCRefreshConstant.midLocation,
            WHCRefreshConstant.endLocation];
        
        progressLayer = CAShapeLayer();
        progressLayer.frame = gradientLayer.bounds;
        progressLayer.backgroundColor = gradientLayer.backgroundColor;
        progressLayer.fillColor = WHCRefreshConstant.endColor.CGColor;
        progressLayer.strokeColor = WHCRefreshConstant.endColor.CGColor;
        progressLayer.lineWidth = 1.0;
        gradientLayer.mask = progressLayer;
        
        self.layer.addSublayer(gradientLayer);
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
    }
    
    
    /**
     *note: Refresh the end according to the clues
     */
    
    private func showPormpt() {
        if promptLable == nil {
            promptLable = UILabel(frame: self.bounds);
            promptLable.backgroundColor = UIColor.clearColor();
            promptLable.numberOfLines = 0;
            promptLable.font = UIFont.systemFontOfSize(WHCRefreshConstant.promptFontSize);
            promptLable.textAlignment = .Center;
            promptLable.minimumScaleFactor = WHCRefreshConstant.promptFontScaleFactor;
            promptLable.adjustsFontSizeToFitWidth = true;
        }
        if prompt?.characters.count > 0 {
            promptLable.text = prompt;
        }else {
            promptLable.text = "刷新完成";
        }
        self.addSubview(promptLable);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            [unowned self] () -> Void in
            self.promptLable?.removeFromSuperview();
            
            UIView.animateWithDuration(WHCRefreshConstant.animateDuration / 3,
                animations: { () -> Void in
                    (self.superview as! UIScrollView).contentInset = self.initScrollViewEdge;
                }, completion: { (finish) -> Void in
                    if !self.scrollView.dragging {
                        self.refreshState = .NoneRefresh;
                    }else {
                        self.refreshState = .ResetRefresh;
                    }
            })
            })
    }
    
    private func makeLayerImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(progressLayer.frame.size, progressLayer.opaque, 1);
        let context = UIGraphicsGetCurrentContext();
        progressLayer.renderInContext(context!);
        return UIGraphicsGetImageFromCurrentImageContext();
    }
    
    /**
    note: Update and set the refresh view animation path
    */
    
    func updateProgressValue(value: CGFloat) {
        switch refreshStyle {
        case .UpStyle:
            let scrollViewActualHeight = scrollView.height() - (initScrollViewEdge.top + initScrollViewEdge.bottom);
            var scrollBeyondHeight = scrollView.contentSize.height - scrollViewActualHeight - initScrollViewEdge.top;
            if scrollBeyondHeight < 0 {
                scrollBeyondHeight = -initScrollViewEdge.top;
            }
            let actualOffset = value - scrollBeyondHeight;
            switch refreshState {
            case .PullRefresh:
                if actualOffset > WHCRefreshConstant.drawDistance {
                    self.drawArcPath(distance: actualOffset - WHCRefreshConstant.drawDistance, radius: radius, animation: false);
                    if actualOffset > WHCRefreshConstant.drawDistance + WHCRefreshConstant.footerVeiwHeight {
                        refreshState = .WillRefresh;
                    }
                }else {
                    progressLayer.path = nil;
                }
            case .WillRefresh:
                if scrollView.dragging &&
                    actualOffset < WHCRefreshConstant.drawDistance + WHCRefreshConstant.footerVeiwHeight {
                        refreshState = .PullRefresh;
                }
            case .NoneRefresh:
                if scrollView.dragging {
                    refreshState = .PullRefresh;
                }
            case .ResetRefresh:
                refreshState = .NoneRefresh;
            default:
                break;
            }
            break;
        case .DownStyle:
            switch refreshState {
            case .PullRefresh:
                let distance = abs(value + initScrollViewEdge.top);
                if distance >= WHCRefreshConstant.drawDistance {
                    self.drawArcPath(distance: distance - WHCRefreshConstant.drawDistance , radius: radius , animation: false);
                    if -(initScrollViewEdge.top + scrollView.contentOffset.y) >
                        (WHCRefreshConstant.headerViewHeight + WHCRefreshConstant.drawDistance) {
                            refreshState = .WillRefresh;
                    }
                }else {
                    progressLayer.path = nil;
                }
            case .WillRefresh:
                if scrollView.dragging && -(initScrollViewEdge.top + scrollView.contentOffset.y) <
                    (WHCRefreshConstant.headerViewHeight + WHCRefreshConstant.drawDistance) {
                        refreshState = .PullRefresh;
                }
            case .NoneRefresh:
                if scrollView.dragging {
                    refreshState = .PullRefresh;
                }
            case .ResetRefresh:
                refreshState = .NoneRefresh;
            default:
                break;
            }
        default:
            break;
        }
    }
    
    private func crossIncrementAngle(value: CGFloat) -> CGFloat {
        return (value / 360) * CGFloat(2 * M_PI);
    }
    
    /**
    note: Refresh the view animation path
    */
    
    private func drawArcPath(distance distance: CGFloat, radius: CGFloat, animation: Bool) {
        progressLayer.path = nil;
        if radius < 1 {
            return;
        }
        let ratio = ( distance / self.height()) > 1.0 ? 1.0 : distance / self.height();
        if animation {
            switch refreshAnimationType {
            case .LoopErasure:
                startAngle = WHCRefreshConstant.defaultStartAngle;
                endAngle = startAngle - ratio * CGFloat(M_PI * 2.0);
                if !isIncrement {
                    endAngle = startAngle - (1 - ratio) * CGFloat(M_PI * 2);
                    if ratio == 0 {
                        endAngle = startAngle;
                    }
                    let angle = startAngle;
                    startAngle = endAngle;
                    endAngle = angle;
                }
            case .CrossErasure:
                if isIncrement {
                    startAngle += self.crossIncrementAngle(WHCRefreshConstant.drawCrossIncrement);
                    endAngle -= self.crossIncrementAngle(WHCRefreshConstant.drawCrossIncrement);
                    if startAngle >= WHCRefreshConstant.defaultStartAngle {
                        isIncrement = false;
                    }
                }else {
                    startAngle -= self.crossIncrementAngle(WHCRefreshConstant.drawCrossIncrement);
                    endAngle += self.crossIncrementAngle(WHCRefreshConstant.drawCrossIncrement);
                    if startAngle <= -WHCRefreshConstant.defaultStartAngle {
                        startAngle += self.crossIncrementAngle(WHCRefreshConstant.drawCrossIncrement);
                        endAngle -= self.crossIncrementAngle(WHCRefreshConstant.drawCrossIncrement);
                        isIncrement = true;
                    }
                }
            }
            
        }else {
            startAngle = WHCRefreshConstant.defaultStartAngle;
            endAngle = startAngle - ratio * CGFloat(M_PI * 2.0);
        }
        let path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, self.width() / 2, self.height() / 2);
        CGPathAddArc(path, nil, self.width() / 2, self.height() / 2, radius, startAngle, endAngle, true);
        progressLayer.path = path;
    }
    
    /**
    note: When refresh perform UI refresh animation operations
    */
    
    private func runRefreshAnimation(edge: UIEdgeInsets) {
        refreshState = .DoingRefresh;
        UIView.animateWithDuration(WHCRefreshConstant.animateDuration / 3,
            animations: { () -> Void in
                self.scrollView.contentInset = edge;
            }, completion: { (finish) -> Void in
                self.isShockWaveAnimation = false;
                self.createDisplayTimer();
                switch self.refreshStyle {
                case .UpStyle:
                    self.delegate?.WHCUpRefresh?();
                case .DownStyle:
                    self.delegate?.WHCDownRefresh?();
                default:
                    break;
                }
        })
    }
    
    /**
    note: Call this method when the network refresh operation of refresh the UI recovery operations
    */
    
    func finishedRefresh(prompt: String!) {
        self.prompt = prompt;
        switch refreshStyle {
        case .UpStyle ,.DownStyle:
            if refreshState == .NoneRefresh {
                return;
            }
            refreshState = .FinishedRefresh;
            self.removeDisplayTimer();
            self.drawArcPath(distance: self.height(), radius: radius, animation: false);
            self.isShockWaveAnimation = true;
            self.createDisplayTimer();
        default:
            break;
        }
    }
    
    func endRefresh() {
        if self.refreshState != .NoneRefresh &&
            self.refreshState != .ResetRefresh {
            self.refreshState = .NoneRefresh;
            self.removeDisplayTimer();
            self.drawArcPath(distance: 0, radius: -1, animation: false);
            self.promptLable?.text = "";
            self.promptLable?.removeFromSuperview();
            UIView.animateWithDuration(WHCRefreshConstant.animateDuration / 3,
                animations: { () -> Void in
                    (self.superview as! UIScrollView).contentInset = self.initScrollViewEdge;
                }, completion: { (finish) -> Void in
            })
        }
        
    }
    
    /**
    note: The next pull on or let go call this method when start to refresh operation
    */
    
    func startRefresh() {
        switch refreshStyle {
        case .UpStyle:
            switch refreshState {
            case .WillRefresh:
                let scrollViewActualHeight = scrollView.height() - (initScrollViewEdge.top + initScrollViewEdge.bottom);
                var offset: CGFloat = 0;
                if scrollViewActualHeight > scrollView.contentSize.height {
                    offset = WHCRefreshConstant.footerVeiwHeight;
                }
                switch refreshAnimationType {
                case .CrossErasure:
                    startAngle = WHCRefreshConstant.defaultStartAngle;
                    endAngle = startAngle - CGFloat(M_PI * 2.0);
                default:
                    break;
                }
                self.runRefreshAnimation(UIEdgeInsetsMake(self.initScrollViewEdge.top - offset,
                    self.initScrollViewEdge.left,
                    self.initScrollViewEdge.bottom + WHCRefreshConstant.footerVeiwHeight ,
                    self.initScrollViewEdge.right));
            default:
                break;
            }
        case .DownStyle:
            switch refreshState {
            case .WillRefresh:
                switch refreshAnimationType {
                case .CrossErasure:
                    startAngle = WHCRefreshConstant.defaultStartAngle;
                    endAngle = startAngle - CGFloat(M_PI * 2.0);
                default:
                    break;
                }
                self.runRefreshAnimation(UIEdgeInsetsMake(self.initScrollViewEdge.top + WHCRefreshConstant.headerViewHeight,
                    self.initScrollViewEdge.left,
                    self.initScrollViewEdge.bottom,
                    self.initScrollViewEdge.right));
            default:
                break;
            }
        default:
            break;
        }
    }
    
    /**
    note: Event processing screen update clock
    */
    
    func handleDisplayTimer() {
        if isShockWaveAnimation {
            currentDrawIncrement += WHCRefreshConstant.drawIncrement * 10;
            let radius = self.radius + WHCRefreshConstant.shockWaveIncrement + currentDrawIncrement;
            if radius >= self.width() / 2 + WHCRefreshConstant.shockWaveIncrement  {
                self.removeDisplayTimer();
                self.drawArcPath(distance: 0, radius: 0, animation: false);
                self.showPormpt();
            }else {
                self.drawArcPath(distance: self.height(), radius: radius, animation: false);
            }
        }else {
            switch refreshAnimationType {
            case .LoopErasure:
                if isIncrement {
                    if currentDrawIncrement >= self.height() {
                        isIncrement = false;
                    }
                }else {
                    if currentDrawIncrement <= 0 {
                        isIncrement = true;
                    }
                }
                if isIncrement {
                    currentDrawIncrement += WHCRefreshConstant.drawIncrement;
                }else {
                    currentDrawIncrement -= WHCRefreshConstant.drawIncrement;
                }
                self.drawArcPath(distance: currentDrawIncrement, radius: radius, animation: true);
            case .CrossErasure:
                self.drawArcPath(distance: currentDrawIncrement, radius: radius, animation: true);
            }
            
        }
        
    }
    
    /**
    note: Remove the screen to update the clock
    */
    
    private func removeDisplayTimer() {
        currentDrawIncrement = self.height();
        isIncrement = false;
        displayTimer?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes);
        displayTimer?.paused = true;
        displayTimer?.invalidate();
        displayTimer = nil;
    }
    
    /**
    note: To create a screen to update the clock
    */
    
    private func createDisplayTimer() {
        if displayTimer == nil {
            displayTimer = CADisplayLink(target: self, selector: Selector("handleDisplayTimer"));
            displayTimer.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes);
        }
    }
    
    /**
    note: Update to refresh the view at the bottom of the position
    */
    func updatePosition() {
        if refreshStyle == .UpStyle {
            let scrollViewActualHeight = scrollView.height() - (initScrollViewEdge.top + initScrollViewEdge.bottom);
            self.setY(max(scrollViewActualHeight , scrollView.contentSize.height));
        }
    }
}

extension UIScrollView {
    
    //MARK: - private -
    
    /**
    note: Refresh the public view
    */
    private func createRefreshView(frame frame: CGRect ,
        refreshStyle: WHCRefreshStyle ,
        refreshAnimationType: WHCRefreshAnimationType ,
        delegate: WHCRefreshDelegate) -> WHCRefreshView {
            let refreshView = WHCRefreshView(frame: frame);
            refreshView.delegate = delegate;
            refreshView.scrollView = self;
            refreshView.refreshStyle = refreshStyle;
            refreshView.backgroundColor = self.backgroundColor;
            refreshView.refreshAnimationType = refreshAnimationType;
            return refreshView;
    }
    
    /**
    note: At the head of the create refresh the view
    */
    
    private func createHeaderView(delegate: WHCRefreshDelegate ,refreshAnimationType: WHCRefreshAnimationType) {
        let headerView = self.createRefreshView(frame: CGRectMake(0,
            -WHCRefreshConstant.headerViewHeight,
            self.width(),
            WHCRefreshConstant.headerViewHeight),
            refreshStyle: .DownStyle,
            refreshAnimationType: refreshAnimationType,
            delegate: delegate);
        objc_setAssociatedObject(self, &WHCRefreshConstant.headerViewKey, headerView, .OBJC_ASSOCIATION_RETAIN);
        self.insertSubview(headerView, atIndex: 0);
    }
    
    /**
    note: At the foot of the create refresh the view
    */
    
    private func createFooterView(delegate: WHCRefreshDelegate ,
        tableViewHeight: CGFloat ,
        refreshAnimationType: WHCRefreshAnimationType) {
            let footerView = self.createRefreshView(frame: CGRectMake(0,
                tableViewHeight,
                self.width(),
                WHCRefreshConstant.footerVeiwHeight),
                refreshStyle: .UpStyle,
                refreshAnimationType: refreshAnimationType,
                delegate: delegate);
            objc_setAssociatedObject(self, &WHCRefreshConstant.footerViewKey, footerView, .OBJC_ASSOCIATION_RETAIN);
            self.insertSubview(footerView, atIndex: 0);
    }
    
    /**
    note: Return to refresh the head the view
    */
    
    private func getHeaderView() -> WHCRefreshView! {
        return objc_getAssociatedObject(self, &WHCRefreshConstant.headerViewKey) as? WHCRefreshView;
    }
    
    /**
    note: Return to refresh the foot the view
    */
    
    private func getFooterView() -> WHCRefreshView! {
        return objc_getAssociatedObject(self, &WHCRefreshConstant.footerViewKey) as? WHCRefreshView;
    }
    
    /**
    note: Register to monitor
    */
    
    private func addObserver() {
        self.addObserver(self, forKeyPath: "contentOffset", options: .New, context: nil);
        self.addObserver(self, forKeyPath: "contentSize", options: .New, context: nil);
    }
    
    /**
    note: Set the initial offset
    */
    
    private func setInitEdgeWithView(refreshView: WHCRefreshView!) {
        if refreshView != nil &&
            refreshView.refreshState == .NoneRefresh &&
            !self.dragging {
                refreshView.initScrollViewEdge = self.contentInset;
        }
    }
    
    /**
    note: To obtain the initial migration
    */
    
    private func initEdge() -> UIEdgeInsets {
        var edgeInset: UIEdgeInsets!;
        edgeInset = self.getHeaderView()?.initScrollViewEdge;
        if edgeInset == nil {
            edgeInset = self.getFooterView()?.initScrollViewEdge;
        }
        if edgeInset == nil {
            edgeInset = UIEdgeInsets();
        }
        return edgeInset;
    }
    
    /**
    note: end rolling
    */
    
    private func didEndScroll(style: WHCRefreshStyle) {
        switch style {
        case .DownStyle:
            self.getHeaderView().startRefresh();
        case .UpStyle:
            self.getFooterView().startRefresh();
        default:
            break;
        }
    }
    
    /**
    note: Are rolling
    */
    
    private func didStartScroll(offset: CGPoint) {
        if offset.y < -self.initEdge().top &&
            self.getHeaderView() != nil {
                let headerView = self.getHeaderView();
                let footerView = self.getFooterView();
                if footerView?.refreshState == .NoneRefresh ||
                    footerView?.refreshState == .PullRefresh ||
                    footerView?.refreshState == .ResetRefresh ||
                    footerView == nil {
                        if !self.dragging {
                            self.didEndScroll(.DownStyle);
                        }
                        headerView.updateProgressValue(offset.y);
                }
        }else if offset.y > -self.initEdge().top &&
            self.getFooterView() != nil {
                let footerView = self.getFooterView();
                let headerView = self.getHeaderView();
                if headerView?.refreshState == .NoneRefresh ||
                    headerView?.refreshState == .PullRefresh ||
                    headerView?.refreshState == .ResetRefresh ||
                    headerView == nil {
                        if !self.dragging {
                            self.didEndScroll(.UpStyle);
                        }
                        footerView.updateProgressValue(offset.y);
                }
        }
    }
    
    
    //MARK: - public -
    
    /**
    note: At the end of the refresh invoke this method
    @param: style The end of the set type
    @param: prompt At the end of refresh the clues
    */
    
    func whc_setFinishedRefresh(style style: WHCRefreshStyle , prompt: String!) {
        switch style {
        case .DownStyle:
            self.getHeaderView().finishedRefresh(prompt);
        case .UpStyle:
            self.getFooterView().finishedRefresh(prompt);
        default:
            break;
        }
    }
    
    /**
    note: Refresh this method is called at the end of the language and use the default prompt
    @param: style The end of the set type
    */
    
    func whc_setFinishedRefresh(style style: WHCRefreshStyle) {
        self.whc_setFinishedRefresh(style: style, prompt: nil);
    }
    
    func whc_endRefresh() {
        self.getHeaderView()?.endRefresh();
    }
    
    /**
    note: Call this method when interface appear can refresh request
    */
    
    func whc_startRefresh() {
        UIView.animateWithDuration(WHCRefreshConstant.animateDuration / 2,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: { () -> Void in
                self.contentOffset = CGPointMake(self.contentOffset.x,
                    -(self.getHeaderView().height() + self.getHeaderView().initScrollViewEdge.top));
            }) { (finish) -> Void in
        }
        self.getHeaderView()?.refreshState = .WillRefresh;
        self.getHeaderView()?.startRefresh();
    }
    
    /**
    note: Set the refresh list list type and proxy objects and use the default height and refresh the animation type by default
    @param: refreshStyle Refresh the style
    @param: delegate agent object
    */
    
    func whc_setRefreshStyle(refreshStyle refreshStyle: WHCRefreshStyle ,
        delegate: WHCRefreshDelegate) {
            self.whc_setRefreshStyle(refreshStyle: refreshStyle,
                refreshAnimationType: .LoopErasure,
                tableViewHeight: self.height(),
                delegate: delegate);
    }
    
    /**
    note: Set the refresh list type and proxy objects and use a custom list and refresh the animation type by default
    @param: refreshStyle Refresh the style
    @param: tableViewHeight A custom list of height
    @param: delegate agent object
    */
    
    func whc_setRefreshStyle(refreshStyle refreshStyle: WHCRefreshStyle,
        tableViewHeight: CGFloat,
        delegate: WHCRefreshDelegate) {
            self.whc_setRefreshStyle(refreshStyle: refreshStyle,
                refreshAnimationType: .LoopErasure,
                tableViewHeight: tableViewHeight,
                delegate: delegate);
    }
    
    /**
    note: Set the refresh list type and proxy objects and use a custom list and animation types
    @param: refreshAnimationType Animation the Type
    @param: refreshStyle Refresh the style
    @param: tableViewHeight A custom list of height
    @param: delegate agent object
    */
    
    func whc_setRefreshStyle(refreshStyle refreshStyle: WHCRefreshStyle ,
        refreshAnimationType: WHCRefreshAnimationType,
        tableViewHeight: CGFloat,
        delegate: WHCRefreshDelegate) {
            
            if refreshStyle != .NoneStyle {
                self.addObserver();
            }
            switch refreshStyle {
            case .AllStyle:
                self.createHeaderView(delegate ,refreshAnimationType: refreshAnimationType);
                self.createFooterView(delegate , tableViewHeight: tableViewHeight
                    ,refreshAnimationType: refreshAnimationType);
            case .DownStyle:
                self.createHeaderView(delegate ,refreshAnimationType: refreshAnimationType);
            case .UpStyle:
                self.createFooterView(delegate , tableViewHeight: tableViewHeight
                    ,refreshAnimationType: refreshAnimationType);
            case .NoneStyle:
                for view in self.subviews {
                    if view is WHCRefreshView {
                        view.removeFromSuperview();
                        break;
                    }
                }
            }
    }
    
    // MARK: - listener -
    public override func observeValueForKeyPath(keyPath: String?,
        ofObject object: AnyObject?,
        change: [String : AnyObject]?,
        context: UnsafeMutablePointer<Void>) {
            
            let key = keyPath != nil ? keyPath! : "";
            if change != nil {
                switch key {
                case "contentOffset":
                    if self.getHeaderView()?.refreshState == .NoneRefresh {
                        if self.getFooterView() != nil {
                            self.setInitEdgeWithView(self.getFooterView());
                        }else {
                            self.setInitEdgeWithView(self.getHeaderView());
                        }
                    }
                    if self.getFooterView()?.refreshState == .NoneRefresh {
                        if self.getHeaderView() != nil {
                            self.setInitEdgeWithView(self.getHeaderView());
                        }else {
                            self.setInitEdgeWithView(self.getFooterView());
                        }
                    }
                    self.didStartScroll(((change![NSKeyValueChangeNewKey]) as! NSValue).CGPointValue());
                case "contentSize":
                    self.getFooterView()?.updatePosition();
                default:
                    break;
                }
            }
    }
}
