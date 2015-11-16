//
//  WHC_Refresh.swift
//  CRM
//
//  Created by 吴海超 on 15/11/13.
//  Copyright © 2015年 吴海超. All rights reserved.
//

import UIKit

enum WHCRefreshStyle: Int {
    case AllStyle
    case DownStyle
    case UpStyle
    case NoneStyle
}

struct WHCRefreshConstant {
    static let headerViewHeight: CGFloat = 50;
    static let footerVeiwHeight: CGFloat = 44;
    static let pading: CGFloat = 5;
    static var headerViewKey = 0;
    static var footerViewKey = 1;
    static let startColor = UIColor.orangeColor();
    static let endColor = UIColor.blueColor();
    static let startLocation = NSNumber(float: 0);
    static let endLocation = NSNumber(float: 1);
}

@objc protocol WHCRefreshDelegate {
    optional func WHCDownRefresh();
    optional func WHCUpRefresh();
}

private class WHCRefreshView: UIView {
    var initScrollViewEdge = UIEdgeInsets();
    var delegate: WHCRefreshDelegate!;
    var progressLayer: CAShapeLayer!;
    var gradientLayer: CAGradientLayer!;
    var radius: CGFloat = 0;
    var layerSize: CGFloat = 0;
    var promptLable: UILabel!;
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.layer.masksToBounds = true;
        radius = (self.height() - 2 * WHCRefreshConstant.pading) / 2;
        layerSize = 2 * radius;
        gradientLayer = CAGradientLayer();
        gradientLayer.frame = self.bounds;//CGRectMake((self.width() - layerSize) / 2.0, WHCRefreshConstant.pading, layerSize, layerSize);
        gradientLayer.backgroundColor = UIColor.clearColor().CGColor;
        gradientLayer.colors = [WHCRefreshConstant.startColor.CGColor , WHCRefreshConstant.endColor.CGColor];
        gradientLayer.locations = [WHCRefreshConstant.startLocation , WHCRefreshConstant.endLocation];
        
        progressLayer = CAShapeLayer();
        progressLayer.frame = gradientLayer.bounds;
        progressLayer.backgroundColor = gradientLayer.backgroundColor;
        progressLayer.fillColor = WHCRefreshConstant.endColor.CGColor;
        progressLayer.strokeColor = WHCRefreshConstant.endColor.CGColor;
        progressLayer.lineWidth = 1.0;
        gradientLayer.mask = progressLayer;
        self.layer.addSublayer(gradientLayer);
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    func updateProgressValue(value: CGFloat) {
        let startAngle: CGFloat = CGFloat(M_PI / 2.0);
        let endAngle: CGFloat = (value / WHCRefreshConstant.headerViewHeight > 1.0 ? 1.0 : value / WHCRefreshConstant.headerViewHeight) * CGFloat(M_PI * 2.0) - startAngle;
        let path = CGPathCreateMutable();
        CGPathAddArc(path, nil, self.width() / 2, self.height() / 2, radius, startAngle, endAngle, true);
        progressLayer.path = path;
    }
}

private class WHCHeaderView: WHCRefreshView {
    override init(frame: CGRect) {
        super.init(frame: frame);
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
}

private class WHCFooterView: WHCRefreshView {
    override init(frame: CGRect) {
        super.init(frame: frame);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
}

extension UIScrollView {

    private func createHeaderView(delegate: WHCRefreshDelegate) {
        for view in self.subviews {
            if view is WHCHeaderView {
                view.removeFromSuperview();
                break;
            }
        }
        let headerView = WHCHeaderView(frame: CGRectMake(0,
                                            -WHCRefreshConstant.headerViewHeight,
                                            self.screenWidth(),
                                            WHCRefreshConstant.headerViewHeight));
        headerView.delegate = delegate;
        headerView.backgroundColor = self.backgroundColor;
        objc_setAssociatedObject(self, &WHCRefreshConstant.headerViewKey, headerView, .OBJC_ASSOCIATION_RETAIN);
        self.insertSubview(headerView, atIndex: 0);
    }
    
    private func createFooterView(delegate: WHCRefreshDelegate) {
        
    }
    
    private func getHeaderView() -> WHCHeaderView {
        return objc_getAssociatedObject(self, &WHCRefreshConstant.headerViewKey) as! WHCHeaderView;
    }
    
    private func getFooterView() -> WHCFooterView {
        return objc_getAssociatedObject(self, &WHCRefreshConstant.footerViewKey) as! WHCFooterView;
    }
    
    private func addObserver() {
        self.addObserver(self, forKeyPath: "contentOffset", options: .New, context: nil);
        self.addObserver(self, forKeyPath: "contentSize", options: .New, context: nil);
    }
    
    func whc_setRefreshStyle(refreshStyle: WHCRefreshStyle , delegate: WHCRefreshDelegate) {
        
        if refreshStyle != .NoneStyle {
            self.addObserver();
        }
        
        switch refreshStyle {
        case .AllStyle:
            self.createHeaderView(delegate);
            self.createFooterView(delegate);
            break;
        case .DownStyle:
            self.createHeaderView(delegate);
            break;
        case .UpStyle:
            self.createFooterView(delegate);
            break;
        default:
            break;
        }
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        let key = keyPath != nil ? keyPath! : "";
        if change != nil {
            switch key {
                case "contentOffset":
                    self.didScroll(((change![NSKeyValueChangeNewKey]) as! NSValue).CGPointValue());
                    break;
                case "contentSize":
                    break;
                default:
                    break;
            }
        }
    }
    
    private func didScroll(offset: CGPoint) {
        self.getHeaderView().updateProgressValue(offset.y);
    }
}
