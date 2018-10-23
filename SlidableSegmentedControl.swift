//
//  SlidableSegmentedControl.swift
//  SlidableSegmentedControl
//
//  Created by Владимир Светланов on 23/10/2018.
//  Copyright © 2018 Svetlanov Vladimir. All rights reserved.
//

import UIKit

public protocol SlidableSegmentedControlDelegate: class {
    func didSelectSegment(sender: SlidableSegmentedControl)
}

public class SlidableSegmentedControl: UIView, UIGestureRecognizerDelegate {
    
    public struct Constants {
        public static var cornerRadius: CGFloat = 14.5
        public static var font: UIFont = UIFont.systemFont(ofSize: 14)
        public static var normalTextColor: UIColor = #colorLiteral(red: 0.6235294118, green: 0.6235294118, blue: 0.6235294118, alpha: 1)
        public static var normalBackgroundColor: UIColor = #colorLiteral(red: 0.9294117647, green: 0.9294117647, blue: 0.9294117647, alpha: 1)
        public static var selectedTextColor: UIColor = #colorLiteral(red: 0.9882352941, green: 0.4078431373, blue: 0.1294117647, alpha: 1)
        public static var selectedBackgroundColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        public static var selectedBorderColor: UIColor = #colorLiteral(red: 0.9882352941, green: 0.4078431373, blue: 0.1294117647, alpha: 1)
        public static var selectedBorderWidth: CGFloat = 1
        public static var panGestureTriggerVelocity: CGFloat = 500
    }
    
    //////////////////////////
    // MARK: - Properties  //
    //////////////////////////
    
    public weak var delegate: SlidableSegmentedControlDelegate?
    
    public typealias Handler = (SlidableSegmentedControl) -> Void
    public var onSelection: Handler?
    
    public var numberOfSegments: Int { return labelsPairs.count }
    public private(set) var selectedSegmentIndex: Int?
    
    private typealias LabelsPair = (background: UILabel, foreground: UILabel)
    private var labelsPairs: [LabelsPair] = []
    
    private lazy var backgroundStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var foregroundContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.selectedBackgroundColor
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var foregroundStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var selectingMask: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    private lazy var selectingView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.borderWidth = Constants.selectedBorderWidth
        view.layer.borderColor = Constants.selectedBorderColor.cgColor
        view.layer.masksToBounds = true
        return view
    }()
    
    private var selectingViewWidth: CGFloat {
        return numberOfSegments > 0 ? bounds.width / CGFloat(numberOfSegments) : 0
    }
    private var selectingViewHeight: CGFloat {
        return bounds.height
    }
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let panGesture = UITapGestureRecognizer()
        panGesture.addTarget(self, action: #selector(self.didRecognizeTapGesture(sender:)))
        panGesture.delegate = self
        return panGesture
    }()
    
    private lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(self.didRecognizePanGesture(sender:)))
        panGesture.delegate = self
        return panGesture
    }()
    
    /////////////////////////
    // MARK: - Overrides  //
    /////////////////////////
    
    public override var intrinsicContentSize: CGSize {
        return backgroundStackView.intrinsicContentSize
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateSelectingLayout(animated: false)
    }
    
    ////////////////////
    // MARK: - Init  //
    ////////////////////
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        self.backgroundColor = Constants.normalBackgroundColor
        self.layer.cornerRadius = Constants.cornerRadius
        
        backgroundStackView.frame = bounds
        backgroundStackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundStackView.addGestureRecognizer(tapGesture)
        addSubview(backgroundStackView)
        
        foregroundContainer.frame = bounds
        foregroundContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        foregroundContainer.layer.mask = selectingMask
        addSubview(foregroundContainer)
        
        foregroundStackView.frame = foregroundContainer.bounds
        foregroundStackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        foregroundContainer.addSubview(foregroundStackView)
        
        selectingView.addGestureRecognizer(panGesture)
        addSubview(selectingView)
    }
    
    //////////////////////
    // MARK: - Update  //
    //////////////////////
    
    private func updateSelectingLayout(animated: Bool) {
        guard let selectedSegmentIndex = selectedSegmentIndex else {
            selectingView.frame = .zero
            selectingMask.path = getRoundLayerPath(for: .zero)
            return
        }
        
        let originX = CGFloat(selectedSegmentIndex) * selectingViewWidth
        let originY = bounds.minY
        let origin = CGPoint(x: originX, y: originY)
        let size = CGSize(width: selectingViewWidth, height: selectingViewHeight)
        let frame = CGRect(origin: origin, size: size)
        
        if animated {
            animateSelection(to: frame)
        } else {
            selectingView.frame = frame
            selectingMask.path = getRoundLayerPath(for: frame)
        }
    }
    
    ///////////////////////
    // MARK: - Actions  //
    ///////////////////////
    
    // MARK: Public
    public func insertSegment(withTitle title: String, at segment: Int) {
        let segment = segment < numberOfSegments ? segment : numberOfSegments
        let labelsPair = createLabelsPair(withTitle: title)
        labelsPairs.insert(labelsPair, at: segment)
        
        if numberOfSegments == 1 {
            selectedSegmentIndex = 0
        }
        
        backgroundStackView.insertArrangedSubview(labelsPair.background, at: segment)
        foregroundStackView.insertArrangedSubview(labelsPair.foreground, at: segment)
        
        updateSelectingLayout(animated: false)
    }
    
    public func removeSegment(at segment: Int) {
        guard segment < numberOfSegments else { return }
        
        let removableLabelsPair = labelsPairs.remove(at: segment)
        removableLabelsPair.background.removeFromSuperview()
        removableLabelsPair.foreground.removeFromSuperview()
        
        if let selectedSegmentIndex = selectedSegmentIndex {
            if selectedSegmentIndex > segment {
                self.selectedSegmentIndex = selectedSegmentIndex - 1
            } else if selectedSegmentIndex == segment {
                self.selectedSegmentIndex = nil
            }
        }
        
        updateSelectingLayout(animated: false)
    }
    
    public func selectSegment(at index: Int, animated: Bool) {
        let oldIndex = selectedSegmentIndex
        selectedSegmentIndex = index
        updateSelectingLayout(animated: oldIndex == nil ? false : animated)
        if oldIndex != index {
            didChangeSelectedSegment()
        }
    }
    
    // MARK: Private
    private func didChangeSelectedSegment() {
        delegate?.didSelectSegment(sender: self)
        onSelection?(self)
    }
    
    @objc
    private func didRecognizeTapGesture(sender: UITapGestureRecognizer) {
        let point = sender.location(in: backgroundStackView)
        let targets = labelsPairs.map({ $0.background })
        guard let index = targets.firstIndex(where: { $0.frame.contains(point) }) else { return }
        selectSegment(at: index, animated: true)
    }
    
    @objc
    private func didRecognizePanGesture(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            break
            
        case .changed:
            let translation = sender.translation(in: selectingView)
            if selectingView.frame.maxX + translation.x > bounds.maxX {
                selectingView.center.x = bounds.maxX - (selectingView.frame.width / 2)
            } else if selectingView.frame.minX + translation.x < bounds.minX {
                selectingView.center.x = bounds.minX + (selectingView.frame.width / 2)
            } else {
                selectingView.center.x += translation.x
            }
            selectingMask.path = getRoundLayerPath(for: selectingView.frame)
            sender.setTranslation(.zero, in: selectingView)
            
        case .ended, .cancelled, .failed:
            guard labelsPairs.count >= 2 else { return }
            let nearestCenters = labelsPairs.map({ $0.foreground.center.x - selectingView.center.x })
                .enumerated()
                .sorted(by: { abs($0.1) < abs($1.1) })
                .map({ (index: $0.0, distance: $0.1) })
            let leftNearestCenter = nearestCenters[0].distance <= 0 ? nearestCenters[0] : nearestCenters[1]
            let rightNearestCenter = nearestCenters[0].distance >= 0 ? nearestCenters[0] : nearestCenters[1]
            let resultCenter: (index: Int, distance: CGFloat)
            
            let velocity = sender.velocity(in: selectingView)
            if velocity.x <= -Constants.panGestureTriggerVelocity {
                resultCenter = leftNearestCenter
            } else if velocity.x >= Constants.panGestureTriggerVelocity {
                resultCenter = rightNearestCenter
            } else if abs(leftNearestCenter.distance) <= abs(rightNearestCenter.distance) {
                resultCenter = leftNearestCenter
            } else {
                resultCenter = rightNearestCenter
            }
            selectSegment(at: resultCenter.index, animated: true)
            
        default: break
        }
    }
    
    private func animateSelection(to frame: CGRect) {
        CATransaction.begin()
        CATransaction.setDisableActions(false)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeIn))
        
        let position = CGPoint(x: frame.midX, y: frame.midY)
        let path = getRoundLayerPath(for: frame)
        
        let positionAnimation = createPositionAnimation(position, for: selectingView.layer)
        let pathAnimation = createPathAnimation(path, for: selectingMask)
        
        selectingView.layer.add(positionAnimation, forKey: "selectingView")
        selectingView.layer.position = position
        selectingView.frame = frame
        
        selectingMask.add(pathAnimation, forKey: "selectingMask")
        selectingMask.path = path
        
        CATransaction.setAnimationDuration(max(positionAnimation.settlingDuration, pathAnimation.settlingDuration))
        CATransaction.commit()
    }
    
    private func createPositionAnimation(_ position: CGPoint, for layer: CALayer) -> CASpringAnimation {
        let oldValue = layer.presentation()?.position ?? layer.position
        let newValue = position
        
        let animation = CASpringAnimation(keyPath: #keyPath(CALayer.position))
        animation.fromValue = NSValue(cgPoint: oldValue)
        animation.toValue = NSValue(cgPoint: newValue)
        animation.isRemovedOnCompletion = false
        return animation
    }
    
    private func createPathAnimation(_ path: CGPath, for layer: CAShapeLayer) -> CASpringAnimation {
        let oldValue = layer.presentation()?.path ?? layer.path
        let newValue = path
        
        let animation = CASpringAnimation(keyPath: #keyPath(CAShapeLayer.path))
        animation.fromValue = oldValue
        animation.toValue = newValue
        animation.isRemovedOnCompletion = false
        return animation
    }
    
    /////////////////////
    // MARK: - Utils  //
    /////////////////////
    
    private func createLabelsPair(withTitle title: String) -> LabelsPair {
        let foregroundLabel = createLabel(withTitle: title, textColor: Constants.selectedTextColor)
        let backgroundLabel = createLabel(withTitle: title, textColor: Constants.normalTextColor)
        return (background: backgroundLabel, foreground: foregroundLabel)
    }
    
    private func createLabel(withTitle title: String, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.text = title
        label.textAlignment = .center
        label.font = Constants.font
        label.textColor = textColor
        return label
    }
    
    private func getRoundLayerPath(for frame: CGRect) -> CGPath {
        return UIBezierPath(roundedRect: frame, cornerRadius: Constants.cornerRadius).cgPath
    }
    
    /////////////////////////
    // MARK: - Delegates  //
    /////////////////////////
    
    // MARK: UIGestureRecognizerDelegate
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        switch gestureRecognizer {
        case panGesture:
            let velocity = panGesture.velocity(in: self)
            let isHorizontal = abs(velocity.x) > abs(velocity.y)
            return isHorizontal && numberOfSegments > 1
        default:
            return true
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
