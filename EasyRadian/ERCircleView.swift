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

    /// 3D效果
    public var show3DEffect = false

    override init(frame: CGRect) {
        super.init(frame: frame)
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

        /// 设置背景色
        backgroundColor = show3DEffect ? .clear : .white

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

            /// 计算路径等
            let percent = CGFloat(percentNums[i] / total)
            let end = percent * 2 * CGFloat.pi + start
            let path = UIBezierPath.init(arcCenter: point,
                                         radius: r,
                                         startAngle: start,
                                         endAngle: end,
                                         clockwise: true)

            /// 绘制弧形层
            let percentLayer = CAShapeLayer()

            /// 3D效果
            if show3DEffect {
                percentLayer.transform = CATransform3DMakeScale(1, 0.8, 1)
                if start < CGFloat.pi {

                    let shadowPath = UIBezierPath()
                    shadowPath.addArc(withCenter: point,
                                      radius: r,
                                      startAngle: max(0, start),
                                      endAngle: min(end, CGFloat.pi),
                                      clockwise: true)
                    let x1 = shadowPath.currentPoint.x
                    let y1 = shadowPath.currentPoint.y - 16
                    shadowPath.addLine(to: CGPoint(x: x1, y: y1))
                    shadowPath.addArc(withCenter: CGPoint(x: r, y: r + 16),
                                      radius: r,
                                      startAngle: min(end, CGFloat.pi),
                                      endAngle: max(0, start),
                                      clockwise: false)
                    let x2 = shadowPath.currentPoint.x
                    let y2 = shadowPath.currentPoint.y + 16
                    shadowPath.addLine(to: CGPoint(x: x2, y: y2))

                    /// 3D效果层
                    let extLayer = CAShapeLayer()
                    extLayer.path = shadowPath.cgPath
                    extLayer.transform = CATransform3DMakeScale(1, 0.8, 1)
                    extLayer.fillColor = colors[i].cgColor
                    layer.addSublayer(extLayer)

                    /// 添加阴影
                    let shadowLayer = CAShapeLayer()
                    shadowLayer.path = shadowPath.cgPath
                    shadowLayer.transform = CATransform3DMakeScale(1, 0.8, 1)
                    shadowLayer.fillColor = UIColor(white: 0, alpha: 0.4).cgColor
                    layer.addSublayer(shadowLayer)

                    /// 保存百分显示点
                    points.append(CGPoint(x: x2, y: y2 - y2 * sin(0.1 * CGFloat.pi)))
                } else {
                    points.append(path.currentPoint)
                }
            } else {
                points.append(path.currentPoint)
            }

            path.addLine(to: CGPoint(x: r, y: r))
            percentLayer.path = path.cgPath
            percentLayer.fillColor = colors[i].cgColor
            layer.addSublayer(percentLayer)
            start = end

            /// 保存百分比
            percents.append(percent)
        }

        /// padding效果
        if drawRule == .padding && !show3DEffect {
            let path = UIBezierPath(arcCenter: point,
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
