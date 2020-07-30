//
//  FloatingView.swift
//  WebViewDebugger
//
//  Created by Ashish on 30/07/20.
//  Copyright © 2020 Microsoft Corporation. All rights reserved.
//

import UIKit

public class FloatingView: UIView {
    
    private struct Constants {
        static let actionButtonSize: CGFloat = 44
        static let actionButtonMargin: CGFloat = 20
        static let actionButtonCornerRadius: CGFloat = 10
        static let playImageName = "play"
        static let stopImageName = "stop"
        static let pauseImageName = "pause"
    }
    
    let startStopActionButton = UIButton()
    let pauseActionButton = UIButton()
    var startActionHandler: (() -> Void)?
    var pauseActionHandler: (() -> Void)?
    var stopActionHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let bundle = Bundle(for: Self.self)
        
        startStopActionButton.setImage(UIImage(named: Constants.playImageName, in: bundle, with: nil), for: .normal)
        startStopActionButton.setImage(UIImage(named: Constants.stopImageName, in: bundle, with: nil), for: .selected)
        startStopActionButton.backgroundColor = .white
        addSubview(startStopActionButton)
        startStopActionButton.layer.cornerRadius = Constants.actionButtonCornerRadius
        startStopActionButton.layer.shadowColor = UIColor.black.cgColor
        startStopActionButton.layer.shadowOpacity = 1
        startStopActionButton.layer.shadowOffset = .zero
        startStopActionButton.addTarget(self, action: #selector(actionHandler(_:)), for: .touchUpInside)
        
        let image = UIImage(named: Constants.pauseImageName, in: bundle, with: nil)
        pauseActionButton.setImage(image, for: .normal)
        let selectedImage = image?.imageWithAlpha(0.5)
        // Cannot use disabled state here because then the touch events will passthrough
        pauseActionButton.setImage(selectedImage, for: .selected)
        pauseActionButton.backgroundColor = .white
        addSubview(pauseActionButton)
        pauseActionButton.layer.cornerRadius = Constants.actionButtonCornerRadius
        pauseActionButton.isHidden = true
        pauseActionButton.layer.shadowColor = UIColor.black.cgColor
        pauseActionButton.layer.shadowOpacity = 1
        pauseActionButton.layer.shadowOffset = .zero
        pauseActionButton.addTarget(self, action: #selector(actionHandler(_:)), for: .touchUpInside)
        
        var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(drag(_:)))
        startStopActionButton.addGestureRecognizer(panGestureRecognizer)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(drag(_:)))
        pauseActionButton.addGestureRecognizer(panGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let screenSize = UIScreen.main.bounds.size
        frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        
        startStopActionButton.frame = CGRect(
            x: frame.width - safeAreaInsets.right - Constants.actionButtonMargin - Constants.actionButtonSize,
            y: frame.height / 2,
            width: Constants.actionButtonSize,
            height: Constants.actionButtonSize
        )
        pauseActionButton.frame = CGRect(
            x: startStopActionButton.frame.minX,
            y: startStopActionButton.frame.minY - Constants.actionButtonSize,
            width: Constants.actionButtonSize,
            height: Constants.actionButtonSize
        )
    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if let _ = subview.hitTest(convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
    
    // Action
    
    @objc private func actionHandler(_ button: UIButton) {
        if button == startStopActionButton {
            if button.isSelected {
                startStopActionButton.isSelected = false
                hidePauseActionButton()
                stopActionHandler?()
            }
            else {
                startStopActionButton.isSelected = true
                showPauseActionButton()
                startActionHandler?()
            }
        }
        else {
            pauseActionHandler?()
            pauseActionButton.isSelected = true
            startStopActionButton.isSelected = false
        }
    }
    
    public func startAction() {
        startStopActionButton.isSelected = true
        showPauseActionButton()
    }
    
    private func showPauseActionButton() {
        pauseActionButton.isHidden = false
        pauseActionButton.isSelected = false
        startStopActionButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        pauseActionButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func hidePauseActionButton() {
        pauseActionButton.isHidden = true
        startStopActionButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    private var initialPosition: CGPoint = .zero
    
    @objc func drag(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        let screenSize = UIScreen.main.bounds.size
        switch recognizer.state {
        case .began:
            initialPosition = recognizer.view?.frame.origin ?? .zero
            
        case .changed:
            if recognizer.view == startStopActionButton {
                let minX = safeAreaInsets.left + Constants.actionButtonMargin
                let maxX = screenSize.width - safeAreaInsets.right - Constants.actionButtonMargin - Constants.actionButtonSize
                let x = min(max(initialPosition.x + translation.x, minX), maxX)
                let minY = safeAreaInsets.top + Constants.actionButtonMargin + Constants.actionButtonSize
                let maxY = screenSize.height - safeAreaInsets.bottom - Constants.actionButtonMargin - Constants.actionButtonSize
                let y = min(max(initialPosition.y + translation.y, minY), maxY)
                startStopActionButton.frame = CGRect(x: x, y: y, width: Constants.actionButtonSize, height: Constants.actionButtonSize)
                startStopActionButton.setNeedsLayout()
                pauseActionButton.frame = CGRect(x: x, y: y - Constants.actionButtonSize, width: Constants.actionButtonSize, height: Constants.actionButtonSize)
                pauseActionButton.setNeedsLayout()
            }
            else {
                let minX = safeAreaInsets.left + Constants.actionButtonMargin
                let maxX = screenSize.width - safeAreaInsets.right - Constants.actionButtonMargin - Constants.actionButtonSize
                let x = min(max(initialPosition.x + translation.x, minX), maxX)
                let minY = safeAreaInsets.top + Constants.actionButtonMargin
                let maxY = screenSize.height - safeAreaInsets.bottom - Constants.actionButtonMargin - 2 * Constants.actionButtonSize
                let y = min(max(initialPosition.y + translation.y, minY), maxY)
                startStopActionButton.frame = CGRect(x: x, y: y + Constants.actionButtonSize, width: Constants.actionButtonSize, height: Constants.actionButtonSize)
                startStopActionButton.setNeedsLayout()
                pauseActionButton.frame = CGRect(x: x, y: y, width: Constants.actionButtonSize, height: Constants.actionButtonSize)
                pauseActionButton.setNeedsLayout()
            }
            
        case .ended, .failed, .cancelled:
            if recognizer.view == startStopActionButton {
                let minX = safeAreaInsets.left + Constants.actionButtonMargin
                let maxX = screenSize.width - safeAreaInsets.right - Constants.actionButtonMargin - Constants.actionButtonSize
                let x = initialPosition.x + translation.x < screenSize.width / 2 ? minX : maxX
                let minY = safeAreaInsets.top + Constants.actionButtonMargin + Constants.actionButtonSize
                let maxY = screenSize.height - safeAreaInsets.bottom - Constants.actionButtonMargin - Constants.actionButtonSize
                let y = min(max(initialPosition.y + translation.y, minY), maxY)
                startStopActionButton.frame = CGRect(x: x, y: y, width: Constants.actionButtonSize, height: Constants.actionButtonSize)
                startStopActionButton.setNeedsLayout()
                pauseActionButton.frame = CGRect(x: x, y: y - Constants.actionButtonSize, width: Constants.actionButtonSize, height: Constants.actionButtonSize)
                pauseActionButton.setNeedsLayout()
            }
            else {
                let minX = safeAreaInsets.left + Constants.actionButtonMargin
                let maxX = screenSize.width - safeAreaInsets.right - Constants.actionButtonMargin - Constants.actionButtonSize
                let x = initialPosition.x + translation.x < screenSize.width / 2 ? minX : maxX
                let minY = safeAreaInsets.top + Constants.actionButtonMargin
                let maxY = screenSize.height - safeAreaInsets.bottom - Constants.actionButtonMargin - 2 * Constants.actionButtonSize
                let y = min(max(initialPosition.y + translation.y, minY), maxY)
                startStopActionButton.frame = CGRect(x: x, y: y + Constants.actionButtonSize, width: Constants.actionButtonSize, height: Constants.actionButtonSize)
                startStopActionButton.setNeedsLayout()
                pauseActionButton.frame = CGRect(x: x, y: y, width: Constants.actionButtonSize, height: Constants.actionButtonSize)
                pauseActionButton.setNeedsLayout()
            }
            
        default:
            break
        }
    }
    
}
