//
//  ERCircleView.swift
//  EasyRadian
//
//  Created by admin on 5/16/18.
//  Copyright © 2018 Develop. All rights reserved.
//

import UIKit

class ERCircleView: UIView {

    // Use ER's shadow
    var showShadow: Bool {
        get { return (superview as! ERView).showShadow }
        set {
            if newValue {
                layer.shadowRadius = 10
                layer.shadowOpacity = 0.8
                layer.shadowColor = UIColor.gray.cgColor
                layer.shadowOffset = CGSize(width: 0, height: 5)
            }
        }
    }

    /// 绘制规则
    var drawRule: ERView.ERDrawRule!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = frame.width / 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ERCircleView {

    /// 绘制弧形
    func stroke(_ infos: [Any],
                colors: [UIColor],
                percentKey: String? = nil,
                completionHandle: (([CGPoint], [CGFloat]) -> Void)? = nil) {

        /// 解析所有的比例系数
        var total: Float = 0
        var percentNums = [Float]()
        for info in infos {
            if let info = info as? [String: Any], let key = percentKey {
                if let value = info[key] as? String {
                    if let num = Float(value.replacingOccurrences(of: "%", with: "")) {
                        total += num
                        percentNums.append(num)
                    }
                    continue
                }
                if let value = info[key] as? Float {
                    total += value
                    percentNums.append(value)
                }
                continue
            }
            if let intValue = info as? Int {
                total += Float(intValue)
                percentNums.append(Float(intValue))
                continue
            }
            if let floatValue = info as? Float {
                total += floatValue
                percentNums.append(floatValue)
                continue
            }
            if let strValue = info as? String, let num = Float(strValue.replacingOccurrences(of: "%", with: "")) {
                total += num
                percentNums.append(num)
            }
        }

        /// 绘制点和百分比
        var points = [CGPoint]()
        var percents = [CGFloat]()

        /// 计算百分比并且绘制视图
        let r = frame.width / 2
        var start = -CGFloat.pi / 2
        let point = CGPoint(x: r, y: r)
        for i in 0..<percentNums.count {
            let percent = CGFloat(percentNums[i] / total)
            let end = percent * 2 * CGFloat.pi + start
            let path = UIBezierPath.init(arcCenter: point,
                                         radius: r,
                                         startAngle: start,
                                         endAngle: end,
                                         clockwise: true)
            points.append(path.currentPoint)
            percents.append(percent)
            path.addLine(to: CGPoint(x: r, y: r))

            /// 弧形层
            let percentLayer = CAShapeLayer()
            percentLayer.path = path.cgPath
            percentLayer.fillColor = colors[i].cgColor
            layer.addSublayer(percentLayer)
            start = end
        }

        /// padding效果
        if drawRule == .padding {
            let path = UIBezierPath.init(arcCenter: point,
                                         radius: r / 2,
                                         startAngle: 0,
                                         endAngle: CGFloat.pi * 2,
                                         clockwise: true)
            let fillLayer = CAShapeLayer()
            fillLayer.path = path.cgPath
            fillLayer.fillColor = UIColor.white.cgColor
            layer.addSublayer(fillLayer)
        }

        if let handle = completionHandle {
            handle(points, percents)
        }
    }
}
