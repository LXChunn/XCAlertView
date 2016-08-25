//
//  XCAlertController.swift
//  XCAlertView-swift
//
//  Created by 刘小椿 on 16/6/6.
//  Copyright © 2016年 刘小椿. All rights reserved.
//

import UIKit

public protocol XCAlertControllerDelegate: NSObjectProtocol{
    func alertControllerDidCanceled(alertController:XCAlertController)
    
    func alertController(alertController:XCAlertController,didSelectRow row:NSInteger)
    
    func alertController(alertController:XCAlertController,colorWithRow row:NSInteger) -> UIColor
}

extension String{
    func xc_alert_findHeightForHavingWidth(widthValue:CGFloat,font:UIFont) -> CGSize {
        var size = CGSizeZero;
        if !self.isEmpty {
            let fram:CGRect = self.boundingRectWithSize(CGSizeMake(widthValue, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil)
            size = CGSizeMake(fram.width, fram.height);
        }
        return size;
    }
}

public class XCAlertController: UIWindow {
    let xc_AlertCellHeight:CGFloat = 48
    let xc_AlertSpace:CGFloat = 7
    let xc_AlertCancleButtonHeight:CGFloat = 48
    
    public weak var delegate: XCAlertControllerDelegate?
    var title:String?
    var actionActivities:NSArray?
    var tableView:UITableView?
    var cancleButton:UIButton?
    var interateView:UIView?
    var containView:UIView?
    var titleLable:UILabel?
    
    //MARK:public method
    public func initWithActivity(activitys: NSArray,title: String) -> AnyObject{
        assert(activitys.count != 0,"操作表不许为空")
        
        self.actionActivities = activitys
        self.title = title
        
        configAllUI();
        return self;
    }
    
    public func show(){
        showAnimation()
        self.windowLevel = UIWindowLevelAlert
        self.makeKeyAndVisible()
    }
    
    //MARK:private method
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configAllUI (){
        configInteratieView();
        
        var titleHeight :CGFloat = 0;
        
        if self.title?.characters.count > 0 {
            let size = self.title?.xc_alert_findHeightForHavingWidth(self.bounds.width - 10, font: UIFont.systemFontOfSize(12))
            titleHeight = (size?.height)! + 20
        }
        
        self.containView = UIView(frame: CGRectMake(0,self.bounds.height - (CGFloat)(self.actionActivities!.count) * xc_AlertCellHeight - xc_AlertSpace - xc_AlertCancleButtonHeight - titleHeight,self.bounds.width,(CGFloat)(self.actionActivities!.count) * xc_AlertCellHeight + xc_AlertSpace + xc_AlertCancleButtonHeight + titleHeight))
                                       
        self.containView!.backgroundColor = UIColor(white: 0.871, alpha: 1.000)
        self.addSubview(self.containView!)
        
        if self.title?.characters.count > 0 {
            let titleView:UIView = UIView(frame: CGRectMake(0, 0, (self.containView?.bounds.width)!, titleHeight))
            titleView.backgroundColor = UIColor.whiteColor()
            self.containView?.addSubview(titleView)
            
            self.titleLable = UILabel(frame: CGRectMake(5, 5, (self.containView?.bounds.width)! - 10, titleView.bounds.height - 10))
            self.titleLable?.font = UIFont.systemFontOfSize(12)
            self.titleLable?.backgroundColor = UIColor.whiteColor()
            self.titleLable?.textColor = UIColor.darkGrayColor()
            self.titleLable?.text = self.title
            self.titleLable?.numberOfLines = 0
            self.titleLable?.textAlignment = NSTextAlignment.Center
            titleView.addSubview(self.titleLable!)
        }
        
        self.tableView = UITableView(frame: CGRectMake(0, (self.containView?.bounds.height)! - (CGFloat)((self.actionActivities?.count)!) * xc_AlertCellHeight - xc_AlertCancleButtonHeight - xc_AlertSpace, self.bounds.width, (CGFloat)((self.actionActivities?.count)!) * xc_AlertCellHeight ))
        self.tableView?.scrollEnabled = false
        self.tableView?.userInteractionEnabled = true
        self.tableView?.tableFooterView = UIView()
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.backgroundColor = UIColor.whiteColor()
        self.tableView?.separatorColor = UIColor.clearColor()
        self.containView?.addSubview(self.tableView!)
        
        self.cancleButton = UIButton(frame: CGRectMake(0, (self.containView?.bounds.height)! - xc_AlertCancleButtonHeight, self.bounds.width, xc_AlertCancleButtonHeight))
        self.cancleButton?.setTitle("取消", forState: .Normal)
        self.cancleButton?.titleLabel?.font = UIFont.systemFontOfSize(18)
        self.cancleButton?.opaque = false
        self.cancleButton?.backgroundColor = UIColor.whiteColor()
        self.cancleButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.cancleButton?.addTarget(self, action: #selector(XCAlertController.cancelButtonClick(_:)), forControlEvents: .TouchUpInside)
        self.containView?.addSubview(self.cancleButton!)
    }
    
    private func configInteratieView() {
        self.interateView = UIView(frame: self.bounds)
        self.interateView?.addGestureRecognizer(UITapGestureRecognizer(target:self,action: #selector(self.handleTapGesture(_:))))
        self.interateView?.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.2)
        self.addSubview(self.interateView!)
    }
    
    func handleTapGesture(sender: UITapGestureRecognizer){
        dismissWithAnimation()
        if (self.delegate!.respondsToSelector(Selector("alertControllerDidCanceled:"))) {
            self.delegate?.alertControllerDidCanceled(self)
        }
    }
    
    private func showAnimation() {
        self.hidden = true
        let y:CGFloat = (self.containView?.frame.origin.y)!
        
        self.containView?.frame = CGRectMake(0, self.bounds.size.height, (self.containView?.bounds.width)!, (self.containView?.bounds.height)!)
        
        UIView.animateWithDuration(0.5,
                                   delay: 0,
                                   usingSpringWithDamping: 1.0,
                                   initialSpringVelocity: 1.0,
                                   options: UIViewAnimationOptions.CurveLinear,
                                   animations: { 
                                    self.containView?.frame = CGRectMake(0, y, (self.containView?.bounds.width)!, (self.containView?.bounds.height)!)
            }) { (true) in
                self.userInteractionEnabled = true
        }
    }
    
    private func dismissWithAnimation() {
        UIView.animateWithDuration(0.3,
                                   delay: 0,
                                   usingSpringWithDamping: 0.9,
                                   initialSpringVelocity: 0.9,
                                   options: UIViewAnimationOptions.CurveLinear,
                                   animations: { 
                                    self.containView?.frame = CGRectMake(0, self.bounds.height, (self.containView?.bounds.width)!,(self.containView?.bounds.height)!)
                                    self.interateView?.alpha = 0
            }) { (true) in
                self.userInteractionEnabled = true
                self.cancleButton?.removeFromSuperview()
                self.tableView?.removeFromSuperview()
                self.containView?.removeFromSuperview()
                self.interateView?.removeFromSuperview()
                self.resignFirstResponder()
                self.hidden = true
                UIApplication.sharedApplication().keyWindow?.makeKeyAndVisible()
        }
    }
    
    func cancelButtonClick(sender:AnyObject) {
        dismissWithAnimation()
        if (self.delegate!.respondsToSelector("alertControllerDidCanceled:")) {
            self.delegate?.alertControllerDidCanceled(self)
        }
    }
}

extension XCAlertController :UITableViewDelegate,UITableViewDataSource{
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.actionActivities?.count)!
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return xc_AlertCellHeight
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
        let lineTop = UILabel(frame: CGRectMake(0, 0, tableView.bounds.width, 1))
        lineTop.backgroundColor = UIColor(white: 0.961, alpha: 1.000)
        lineTop.tag = 900
        cell.addSubview(lineTop)
        
        let lineBottom = UILabel(frame: CGRectMake(0, xc_AlertCellHeight - 1, tableView.bounds.width, 1))
        lineBottom.backgroundColor = UIColor(white: 0.961, alpha: 1.000)
        lineTop.tag = 901
        cell.addSubview(lineBottom)
        
        if self.delegate!.respondsToSelector( Selector("alertController:colorWithRow:")) {
            let color:UIColor = (self.delegate?.alertController(self, colorWithRow: indexPath.row))!
            
            if !color.isEqual(nil) {
                cell.textLabel?.textColor = color
            }else{
                cell.textLabel?.textColor = UIColor.blackColor()
            }
        }else{
            cell.textLabel?.textColor = UIColor.blackColor()
        }
        
        cell.textLabel?.text = (self.actionActivities!.objectAtIndex(indexPath.row) as! String)
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        cell.textLabel?.font = UIFont.systemFontOfSize(18)
        cell.backgroundColor = UIColor.whiteColor()
        
        if indexPath.row == 0 {
            cell.viewWithTag(901)?.hidden = false
        }else{
            cell.viewWithTag(901)?.hidden = true
        }
        
        if self.title?.characters.count > 0 {
            if indexPath.row == 0 {
                cell.viewWithTag(900)?.hidden = false
            }else{
                cell.viewWithTag(900)?.hidden = true
            }
        }else{
            cell.viewWithTag(900)?.hidden = true
        }
        return cell
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        dismissWithAnimation()
        if self.delegate!.respondsToSelector( Selector("alertController:didSelectRow:")) {
            self.delegate?.alertController(self, didSelectRow: indexPath.row)
        }
    }
}
