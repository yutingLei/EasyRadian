//
//  ViewController.swift
//  Example
//
//  Created by admin on 5/21/18.
//  Copyright © 2018 Develop. All rights reserved.
//

import UIKit
import EasyRadian

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let frame = CGRect.init(x: 0, y: 64, width: view.frame.width, height: view.frame.height - 64)
        let drawsInfo = [["type": "华为", "percent": "35%"],
                         ["type": "OPPO", "percent": "20%"],
                         ["type": "vivo", "percent": "25%"],
                         ["type": "小米", "percent": "5%"],
                         ["type": "苹果", "percent": "5%"],
                         ["type": "三星", "percent": "5%"],
                         ["type": "金立", "percent": "5%"]]
        if let erView = ERView(frame: frame, drawsInfo: drawsInfo) {
            erView.titleText = "2017年8月中国手机市场排名"
            erView.digestKey = "type"
            erView.percentKey = "percent"
            erView.digestLoc = .top
            erView.show3DEffect = true
            erView.isHistogramFirst = true
            erView.drawStart()
            view.addSubview(erView)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

