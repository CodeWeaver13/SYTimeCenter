//
//  ViewController.swift
//  SYTimerCenter
//
//  Created by wangshiyu13 on 2017/2/22.
//  Copyright © 2017年 wangshiyu13. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        SYTimerCenter.default.createTimer(.seconds(1), repeatsCount: 5) {
            print("我真屌")
        }
        SYTimerCenter.default.createTimer(.seconds(1), afterTime: .seconds(5)) {
            let view = UIView()
            view.backgroundColor = UIColor.red
            view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            self.view.addSubview(view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

