//
//  SubscriptionFormController.swift
//  SwiftRssSample
//
//  Created by fukudas on 2014/10/30.
//  Copyright (c) 2014年 fukudas. All rights reserved.
//

import UIKit

class FeedFormController: UIViewController {
    var isFound = false
    var feed: NSDictionary? = nil
    
    @IBOutlet weak var tfUrl: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Confirm", style: UIBarButtonItemStyle.Plain, target: self, action: "getFeed")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var controller = segue.destinationViewController as FeedConfirmController
        controller.feed = self.feed!
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return self.isFound
    }
    
    func getFeed() {
        var request = FeedUtil.Request();
        request.endPoint = tfUrl.text
        
        FeedUtil.getFeed(request, completionHander: { (status, detail, data) in
            if (status != FeedUtil.Response.Status.Ok || data == nil) {
                // TODO: アラートダイアログ表示
                self.isFound = false
                dispatch_async(dispatch_get_main_queue(), {
                    var alert = UIAlertView(title: "注意", message: "ご指定のRSSが見つかりませんでした", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                })                
                return
            }
            
            self.isFound = true
            self.feed = data
            dispatch_async(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier(Identifiers.Segues.FeedConfirm, sender: nil)
            })
        })
    }
}
