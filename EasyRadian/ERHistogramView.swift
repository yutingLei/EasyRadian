//
//  ERHistogramView.swift
//  EasyRadian
//
//  Created by admin on 5/22/18.
//  Copyright © 2018 Develop. All rights reserved.
//

import UIKit

class ERHistogramView: UIView {

    /// 显示3D效果
    var show3DEffect: Bool!

    /// 显示百分比
    var showPercent = true

    /// 绘制信息
    fileprivate var drawsInfo: [Any]!

    /// 获取摘要值的key
    fileprivate var digestKey: String?

    /// 获取百分比值得key
    fileprivate var percentKey: String?

    /// 绘制每个柱形图所对应的颜色
    fileprivate var colors: [UIColor]!

    /// 开始绘制
    fileprivate var isStarting = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ERHistogramView {
    /// 绘制弧形
    func stroke(_ drawsInfo: [Any],
                colors: [UIColor],
                digestKey: String? = nil,
                percentKey: String? = nil,
                completionHandle: (([CGPoint], [CGFloat]) -> Void)? = nil) {
        if drawsInfo.count == colors.count {
            self.drawsInfo = drawsInfo
            self.digestKey = digestKey
            self.percentKey = percentKey
            self.colors = colors
            self.isStarting = true
            setNeedsDisplay()
        }
    }

    /// 绘制
    override func draw(_ rect: CGRect) {
        guard isStarting else { return }
        let parsedInfo = parse(drawsInfo)
        let total = parsedInfo.0
        let percentNums = parsedInfo.1
        let digests = parsedInfo.2
        if percentNums.count > 0 {

            /// 横纵坐标轴的长度和原点
            let x = bounds.width / 8
            let y = bounds.height * 0.125
            let w = bounds.width * 0.75
            let h = bounds.height * 0.75

            /// 绘制坐标
            let context = UIGraphicsGetCurrentContext()
            context?.setLineWidth(1)
            context?.setStrokeColor(UIColor.black.cgColor)
            context?.move(to: CGPoint(x: x, y: y))
            context?.addLine(to: CGPoint(x: x, y: y + h))
            context?.addLine(to: CGPoint(x: x + w, y: y + h))

            /// 绘制纵轴的刻度和该刻度对应的百分比
            context?.setLineWidth(0.5)
            var percentValue = 100
            var sy = y
            for _ in 0..<6 {
                let percentLabel = UILabel(frame: CGRect(x: x * 0.25, y: sy - 10, width: x * 0.65, height: 20))
                percentLabel.adjustsFontSizeToFitWidth = true
                percentLabel.text = String(format: "%d%%", percentValue)
                percentLabel.textAlignment = .right
                addSubview(percentLabel)
                percentValue -= 20

                context?.move(to: CGPoint(x: x, y: sy))
                context?.addLine(to: CGPoint(x: x + 5, y: sy))
                sy += h / 5
            }
            context?.drawPath(using: .stroke)

            /// 绘制柱状图和对应的标签
            var sx = x
            let sw = w / CGFloat(percentNums.count)
            let deltaW: CGFloat = show3DEffect ? 0.5 : 0.25
            for j in 0..<percentNums.count {

                let startX = sx + sw * deltaW
                if digests.count > j {
                    let sh = min(y * 0.75, ERView.getHeight(of: digests[j], limitWidth: sw * (1 - deltaW)))
                    let digestLabel = UILabel(frame: CGRect(x: startX, y: y + h, width: sw * (1 - deltaW), height: sh))
                    digestLabel.font = UIFont.systemFont(ofSize: 10)
                    digestLabel.numberOfLines = 0
                    digestLabel.textAlignment = .center
                    digestLabel.text = digests[j]
                    addSubview(digestLabel)
                }

                /// 绘制柱状
                let percent = percentNums[j] / total
                let sh = h * CGFloat(percent)
                let sy = y + h - sh
                context?.setFillColor(colors[j].cgColor)
                context?.fill(CGRect(x: startX, y: sy, width: sw * (1 - deltaW), height: sh))

                /// 是否显示百分比在柱形上方
                let ew = sw * (1 - deltaW)
                if showPercent {
                    let sy = y + h - sh - ew * 0.3 - 20
                    let sx = startX + ew * (show3DEffect ? 0.3 : 0)
                    let digestLabel = UILabel(frame: CGRect(x: sx, y: sy, width: sw * (1 - deltaW), height: 20))
                    digestLabel.adjustsFontSizeToFitWidth = true
                    digestLabel.textAlignment = .center
                    digestLabel.text = String(format: "%.1f%%", percent * 100)
                    addSubview(digestLabel)
                }

                /// 是否显示3D效果
                if show3DEffect {
                    let topPath = CGMutablePath()
                    topPath.move(to: CGPoint(x: startX, y: sy))
                    topPath.addLine(to: CGPoint(x: startX + ew, y: sy))
                    topPath.addLine(to: CGPoint(x: startX + ew * 1.3, y: sy - ew * 0.3))
                    topPath.addLine(to: CGPoint(x: startX + ew * 0.3, y: sy - ew * 0.3))
                    topPath.addLine(to: CGPoint(x: startX, y: sy))
                    context?.addPath(topPath)
                    context?.setFillColor(colors[j].cgColor)
                    context?.drawPath(using: .fill)
                    context?.addPath(topPath)
                    context?.setFillColor(UIColor(white: 0.2, alpha: 0.2).cgColor)
                    context?.drawPath(using: .fill)

                    let rightPath = CGMutablePath()
                    rightPath.move(to: CGPoint(x: startX + ew, y: sy))
                    rightPath.addLine(to: CGPoint(x: startX + ew, y: sy + sh))
                    rightPath.addLine(to: CGPoint(x: startX + ew * 1.3, y: sy + sh - ew * 0.3))
                    rightPath.addLine(to: CGPoint(x: startX + ew * 1.3, y: sy - ew * 0.3))
                    rightPath.addLine(to: CGPoint(x: startX + ew, y: sy))
                    context?.addPath(rightPath)
                    context?.setFillColor(colors[j].cgColor)
                    context?.drawPath(using: .fill)
                    context?.addPath(rightPath)
                    context?.setFillColor(UIColor(white: 0.2, alpha: 0.6).cgColor)
                    context?.drawPath(using: .fill)
                }
                sx += sw
            }
        }
    }

    /// 解析绘制信息
    fileprivate func parse(_ infos: [Any]) -> (Float, [Float], [String]) {
        /// 解析所有的比例系数
        var total: Float = 0
        var percentNums = [Float]()
        var digests = [String]()
        for info in infos {
            if let info = info as? [String: Any], let key2 = percentKey, let key1 = digestKey  {
                if let percent = info[key2] as? String {
                    if let num = Float(percent.replacingOccurrences(of: "%", with: "")) {
                        total += num
                        percentNums.append(num)
                    }
                }
                else if let percent = info[key2] as? Float {
                    total += percent
                    percentNums.append(percent)
                }
                if let digest = info[key1] as? String {
                    digests.append(digest)
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
        return (total, percentNums, digests)
    }
}
