//
//  ViewController.swift
//  SwiftRssSample
//
//  Created by fukudas on 2014/10/30.
//  Copyright (c) 2014年 fukudas. All rights reserved.
//

import UIKit
import WebKit

class EntryViewController: UIViewController, WKNavigationDelegate {
    var entry: Entry?
    var wvEntry: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wvEntry = WKWebView()
        self.view = wvEntry!

        var url = NSURL(string: entry!.link)
        var request = NSURLRequest(URL: url!)
        wvEntry?.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

