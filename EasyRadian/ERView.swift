//
//  ERView.swift
//  EasyRadian
//
//  Created by admin on 5/16/18.
//  Copyright © 2018 Develop. All rights reserved.
//

import UIKit

public class ERView: UIView {

    //MARK: - Statements

    /// 绘制规则
    ///
    /// - padding: 绘制圆环
    /// - fill: 绘制弧形
    public enum ERDrawRule {
        case padding
        case fill
    }

    /// 子视图位置
    public enum ERLocation: Int {
        case top
        case left
        case right
        case bottom
        case none
    }

    //MARK: -
    //MARK: public vars

    /// 绘制规则, default is fill mode
    public var drawRule: ERDrawRule = .fill

    /// 绘制弧形时，是否添加阴影
    public var showShadow = true

    /// 是否显示百分比在弧形图上
    public var showPercents = true

    /// 3D效果
    public var show3DEffect = false

    /// 是否创建柱状图(柱状体暂不支持3D效果)
    public var allowHistogram = true

    /// 是否首先显示柱状图
    public var isHistogramFirst = false

    /// 标题以及相关
    public var titleText: String?       /// 标题
    public var titleLabel: UILabel? {   /// 标题实例
        get { return _titleLabel }
    }

    /// 摘要信息相关
    public var showDigest = true                /// 是否显示摘要, 默认true
    public var digestKey: String?               /// 取摘要标题值所需的键. let digestText = drawsInfo[0][digestKey]
    public var digestLoc: ERLocation?           /// 摘要视图所在位置

    /// 百分比
    public var percentKey: String?      /// 取百分比值所需的键. let percent = drawsInfo[0][percentKey]

    /**
     * 绘制信息格式说明:
     *      - [Int]/[Float]...等等。纯数字或字符串数组.
     *        例如: [20, 20, 60]/[20.5, 20.2, 59.3]/["20", "30", "50"]/["20%", "80%"]
     *      - [[String: Any]],包含有digest信息和百分比信息
     *        例如: [[digestKey: "氧气", percentKey: "21%"], [digestKey: "氮气", percentKey: "76%"]]
     *        此处digestKey、percentKey对应上面的属性，所以必须在startDraw()之前设置。
     *        另外，percentKey对应的值可以参考纯数字或字符串数组,支持Int/Float/String...
     */
    public var drawsInfo: [Any]?

    /// 绘制每一块的颜色. 若不设置，将会自动生成随机颜色
    public var colors: [UIColor]?

    //MARK: -
    //MARK: private vars
    /// 标题
    fileprivate var _titleLabel: UILabel?

    /// 是否调用了startDraw
    fileprivate var _isStartedDraw = false

    /// 弧形图容器
    fileprivate var _circleView: UIView!

    /// 柱状图容器
    fileprivate var _histogramView: ERHistogramView?

    //MARK: -

    /// 构造器
    ///
    /// - Parameters:
    ///   - frame: ER视图的frame
    ///   - drawsInfo: 需要绘制的信息
    ///   - colors: 绘制弧形的颜色,若不设置则会随机生成颜色.
    public convenience init?(frame: CGRect, drawsInfo: [Any]? = nil, colors: [UIColor]? = nil) {
        guard frame.width > 50 && frame.height > 50 else {
            print("你设置视图宽高太小，不能绘制.")
            return nil
        }
        self.init(frame: frame)
        self.drawsInfo = drawsInfo
        self.colors = colors
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ERView {

    /**
     * 绘制百分比图
     *      所有的设置在startDraw调用之前设置
     */
    public func startDraw() {

        guard !_isStartedDraw else {
            print("请不要调用两次startDraw方法！推荐设置好所有参数，然后调用该方法.")
            return
        }
        _isStartedDraw = true

        guard let drawsInfo = drawsInfo else {
            print("未发现需要绘制的信息。")
            return
        }

        /// 绘制标题
        var th: CGFloat = allowHistogram ? 25 : 5
        if let titleText = titleText {
            if _titleLabel == nil {
                let textHeight = max(25, ERView.getHeight(of: titleText, limitWidth: frame.width - 80))
                _titleLabel = UILabel(frame: CGRect(x: 40, y: 5, width: frame.width - 80, height: textHeight))
                _titleLabel?.textAlignment = .center
                _titleLabel?.numberOfLines = 0
                _titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
                addSubview(_titleLabel!)
                th = max(th, textHeight)
            }
            _titleLabel?.text = titleText
        }

        /// 生成颜色
        if colors == nil {
            colors = [UIColor]()
        }
        if colors!.count != drawsInfo.count && colors!.count <= drawsInfo.count {
            let startIndex = colors!.count
            for _ in startIndex..<drawsInfo.count {
                let color = ERView.randomColor(neitherColors: colors)
                colors?.append(color)
            }
        }

        /// 声明两个视图，承载circleView和histogramView
        let vFrame = CGRect(x: 0, y: th + 5, width: frame.width, height: frame.height - th - 5)
        _circleView = UIView(frame: vFrame)
        stroke(_circleView, with: drawsInfo)
        addSubview(_circleView)

        if let histogramView = allowHistogram ? ERHistogramView(frame: vFrame) : nil {
            /// 创建切换按钮
            let switchBtn = UIButton(frame: CGRect(x: bounds.width - 35, y: 5, width: 30, height: th))
            switchBtn.layer.cornerRadius = 3
            switchBtn.layer.borderWidth = 1
            switchBtn.layer.borderColor = UIColor.blue.cgColor
            switchBtn.titleLabel?.font = UIFont.systemFont(ofSize: 8)
            switchBtn.setTitleColor(UIColor.blue, for: .normal)
            switchBtn.showsTouchWhenHighlighted = true
            switchBtn.addTarget(self, action: #selector(switchGraphics), for: .touchUpInside)
            addSubview(switchBtn)

            if isHistogramFirst {
                switchBtn.setTitle("弧形图", for: .normal)
                addSubview(histogramView)
                sendSubview(toBack: _circleView)
            } else {
                switchBtn.setTitle("柱状图", for: .normal)
                insertSubview(histogramView, at: 0)
            }
            _histogramView = histogramView
            _histogramView?.showPercent = showPercents
            _histogramView?.show3DEffect = show3DEffect
            _histogramView?.stroke(drawsInfo,
                                   colors: colors!,
                                   digestKey: digestKey,
                                   percentKey: percentKey)
            { (points, percents) in

            }
        }
    }

    /// 绘制弧形视图
    ///
    /// - Parameters:
    ///   - circleView: 弧形时图承载容器
    ///   - drawsInfo: 绘制信息
    ///   - offsetY: 偏移
    fileprivate func stroke(_ circleView: UIView, with drawsInfo: [Any]) {
        /// 绘制摘要
        var maxDigestWidth: CGFloat = 0
        var maxDigestHeight: CGFloat = 0
        if showDigest,
            let infos = drawsInfo as? [[String: Any]],
            let digestLoc = digestLoc,
            let digestKey = digestKey
        {
            /// 在top/bottom模式下，计算摘要所需高度
            let scalar = circleView.bounds.width > 320 ? 4 : 3
            let count = infos.count / scalar + (infos.count % scalar == 0 ? 0 : 1)
            maxDigestHeight = CGFloat(count) * 20

            /// 计算绘制起始点
            var startX: CGFloat = 5
            var startY: CGFloat = 20
            let w = circleView.bounds.width / 4
            if digestLoc == .bottom {
                startY = circleView.bounds.height - maxDigestHeight - 5
            }


            for i in 0..<infos.count {
                let color = colors!.count > i ? colors![i] : ERView.randomColor(neitherColors: colors)
                let digest = infos[i][digestKey] as? String ?? ""
                let digestWidth = ERView.calculateString(digest, limitWidth: CGFloat(MAXFLOAT), limitHeight: 20)
                if digestWidth > maxDigestWidth {
                    maxDigestWidth = digestWidth
                }
                if digestLoc == .right {
                    startX = circleView.bounds.width * 0.75
                }

                let deltaW: CGFloat = digestLoc == .right ? 25 : 20
                let colorX = digestLoc == .right ? w - 23 : 0
                let labelX: CGFloat = digestLoc == .right ? 0 : 20
                let digestView = UIView(frame: CGRect(x: startX, y: startY, width: w, height: 20))
                let colorView = UIView(frame: CGRect(x: colorX, y: 2, width: 16, height: 16))
                let digestLabel = UILabel(frame: CGRect(x: labelX, y: 0, width: w - deltaW, height: 20))

                colorView.backgroundColor = color
                digestLabel.text = digest
                digestLabel.numberOfLines = 2
                digestLabel.textColor = .black
                digestLabel.textAlignment = digestLoc == .right ? .right : .left
                if digestWidth + 25 > frame.width / 4 {
                    digestLabel.font = UIFont.systemFont(ofSize: 8)
                } else {
                    digestLabel.font = UIFont.systemFont(ofSize: 12)
                }

                digestView.addSubview(digestLabel)
                digestView.addSubview(colorView)
                circleView.addSubview(digestView)

                if digestLoc == .right || digestLoc == .left {
                    startY += 20
                } else {
                    startX += (circleView.bounds.width - 10) / CGFloat(scalar)
                    if startX >= circleView.bounds.width - 5 {
                        startX = 5
                        startY += 20
                    }
                }
            }
        }

        /// 创建弧形容器视图
        var x = circleView.bounds.width / 2
        var y = circleView.bounds.height / 2
        if let loc = digestLoc {
            switch loc {
            case .bottom:
                let offsetY1: CGFloat = 25
                let offsetY2 = circleView.bounds.height - maxDigestHeight
                let destY = offsetY1 + (offsetY2 - offsetY1) / 2
                let reserveY = circleView.bounds.height - offsetY1 - circleView.bounds.width / 4  - (showPercents ? 30 : 0)
                y = max(reserveY, destY)
            case .top:
                let offsetY = maxDigestHeight
                let destY = offsetY + (circleView.bounds.height - offsetY) / 2
                let reserveY = circleView.bounds.height - 5 - circleView.bounds.width / 4 + (showPercents ? 30 : 0)
                y = min(reserveY, destY)
            case .left:
                let offsetY = maxDigestHeight
                if offsetY > circleView.bounds.height / 2 - circleView.bounds.width / 4 {
                    x += circleView.bounds.width / 8
                }
            default:
                let offsetY = maxDigestHeight
                if offsetY > circleView.bounds.height / 2 - circleView.bounds.width / 4 {
                    x -= circleView.bounds.width / 10
                }
            }
        }

        let w = min(circleView.bounds.width / 2, circleView.bounds.height / 2)
        let radianView = ERCircleView(frame: CGRect(x: 0, y: 0, width: w, height: w))
        radianView.drawRule = drawRule
        radianView.showShadow = showShadow
        radianView.show3DEffect = show3DEffect
        radianView.center = CGPoint(x: x, y: y)
        circleView.addSubview(radianView)

        /// 开始绘制
        radianView.stroke(drawsInfo, colors: colors!, percentKey: percentKey) {[unowned self, radianView] (points, percents) in
            guard self.showPercents else { return }
            for i in 0..<points.count {
                let currentPoint = circleView.convert(points[i], from: radianView)
                let extPoints = self.calculateExtendPoint(circleView.bounds, p: radianView.center, currentPoint)
                let path = UIBezierPath()
                path.move(to: currentPoint)
                path.addLine(to: extPoints.0)
                path.close()

                /// 添加线条
                let line = CAShapeLayer()
                line.path = path.cgPath
                line.strokeColor = self.colors?[i].cgColor
                circleView.layer.addSublayer(line)

                /// 添加百分比标签
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
                label.center = extPoints.1
                label.textAlignment = .center
                label.font = UIFont.systemFont(ofSize: 10)
                label.text = String(format: "%.1f%%", percents[i] * 100)
                circleView.addSubview(label)
            }
        }
    }

    /// 切换绘制图形
    @objc fileprivate func switchGraphics(_ btn: UIButton) {
        if btn.title(for: .normal) == "柱状图" {
            UIView.transition(from: _circleView,
                              to: _histogramView!,
                              duration: 2.0,
                              options: .transitionFlipFromRight)
            {[unowned self] isStoped in
                self.bringSubview(toFront: self._histogramView!)
            }
            btn.setTitle("弧形图", for: .normal)
        } else {
            UIView.transition(from: _histogramView!,
                              to: _circleView!,
                              duration: 2.0,
                              options: .transitionFlipFromLeft)
            {[unowned self] isStoped in
                self.bringSubview(toFront: self._circleView)
            }
            btn.setTitle("柱状图", for: .normal)
        }
    }

    /// 根据原点p和已知点p1计算扩展的两个点
    ///
    /// - Parameters:
    ///   - p: 原点
    ///   - p1: 已知点
    /// - Returns: 原点与已知点线上的两个点
    fileprivate func calculateExtendPoint(_ frame: CGRect, p: CGPoint, _ p1: CGPoint) -> (CGPoint, CGPoint) {

        /// 计算扩展点相对宽高
        let deltaX = max(p1.x, p.x) - min(p1.x, p.x)
        let deltaY = max(p1.y, p.y) - min(p1.y, p.y)
        let x2: CGFloat, y2: CGFloat
        let x3: CGFloat, y3: CGFloat
        if deltaX > deltaY {
            x2 = deltaX + min(frame.width * 0.1, 25)
            y2 = x2 * deltaY / deltaX
            x3 = deltaX + min(frame.width * 0.15, 35)
            y3 = x3 * deltaY / deltaX
        } else {
            y2 = deltaY + min(frame.width * 0.1, 25)
            x2 = y2 * deltaX / deltaY
            y3 = deltaY + min(frame.width * 0.15, 35)
            x3 = y3 * deltaX / deltaY
        }

        /// 根据象限返回点
        /// 第四象限
        if p1.x >= p.x && p1.y >= p.y {
            return (CGPoint(x: p.x + x2, y: p.y + y2), CGPoint(x: p.x + x3, y: p.y + y3))
        }
            /// 第三象限
        else if p1.x <= p.x && p1.y >= p.y {
            return (CGPoint(x: p.x - x2, y: p.y + y2), CGPoint(x: p.x - x3, y: p.y + y3))
        }
            /// 第二象限
        else if p1.x <= p.x && p1.y <= p.y {
            return (CGPoint(x: p.x - x2, y: p.y - y2), CGPoint(x: p.x - x3, y: p.y - y3))
        }
            /// 第一象限
        else {
            return (CGPoint(x: p.x + x2, y: p.y - y2), CGPoint(x: p.x + x3, y: p.y - y3))
        }
    }
}

//MARK: - Supports
extension ERView {

    class func getWidth(of str: String, limitHeight height: CGFloat) -> CGFloat {
        return calculateString(str, limitWidth: CGFloat(MAXFLOAT), limitHeight: height)
    }

    class func getHeight(of str: String, limitWidth width: CGFloat) -> CGFloat {
        return calculateString(str, limitWidth: width, limitHeight: CGFloat(MAXFLOAT))
    }

    class func calculateString(_ str: String, limitWidth: CGFloat, limitHeight: CGFloat) -> CGFloat {
        #if swift(>=4)
        let size = (str as NSString).boundingRect(with: CGSize(width: limitWidth, height: limitHeight),
                                                  options: .usesLineFragmentOrigin,
                                                  attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)],
                                                  context: nil).size
        if limitWidth == CGFloat(MAXFLOAT) {
            return size.width
        } else {
            return size.height
        }
        #else
        return (str as NSString).boundingRect(with: CGSize(width: limitWidth, height: limitHeight),
        options: .usesLineFragmentOrigin,
        attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)],
        context: nil).width
        #endif
    }

    /// 随机生成颜色
    ///
    /// - Returns: 返回颜色. 不能为白色
    class func randomColor(neitherColors colors: [UIColor]? = nil) -> UIColor {
        let r = arc4random_uniform(256)
        let g = arc4random_uniform(256)
        let b = arc4random_uniform(256)

        if r == 255 && g == 255 && b == 255 {
            return randomColor(neitherColors: colors)
        }
        let color = UIColor(red: CGFloat(r) / 255,
                            green: CGFloat(g) / 255,
                            blue: CGFloat(b) / 255,
                            alpha: 1)
        if colors?.contains(color) == true {
            return randomColor(neitherColors:colors)
        } else {
            return color
        }
    }
}
