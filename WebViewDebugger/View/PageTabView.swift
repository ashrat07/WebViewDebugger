//
//  PageTabView.swift
//  WebViewDebugger
//
//  Created by Ashish on 30/07/20.
//  Copyright © 2020 Microsoft Corporation. All rights reserved.
//

import UIKit

protocol PageTabViewDelegate: NSObjectProtocol {
    
    func didSelectTabAtIndex(_ index: Int)
    
}

class PageTabScrollView: UIScrollView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDragging {
            self.next?.touchesBegan(touches, with: event)
        } else {
            super.touchesBegan(touches, with: event)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDragging {
            self.next?.touchesMoved(touches, with: event)
        } else {
            super.touchesMoved(touches, with: event)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDragging {
            self.next?.touchesEnded(touches, with: event)
        } else {
            super.touchesEnded(touches, with: event)
        }
    }
    
}

class PageTabView: UIView {
    
    weak var delegate: PageTabViewDelegate?
    
    var sectionTitles = [String]() {
        didSet {
            setNeedsDisplay()
        }
    }
    var selectionIndicatorHeight = CGFloat(3)
    var selectionIndicatorColor = UIColor.white
    var titleAttributes = [NSAttributedString.Key: Any]()
    var selectedTitleAttributes = [NSAttributedString.Key: Any]()
    var segmentEdgeInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    var xInset = CGFloat(0)
    
    private var scrollView: PageTabScrollView!
    private var selectionIndicatorLayer = CALayer()
    private var selectedSegmentIndex = 0
    private var segmentWidthsArray = [CGFloat]()
    private var scrollOffset = CGFloat(0)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func commonInit() {
        scrollView = PageTabScrollView()
        scrollView.scrollsToTop = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSegmentsRects()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        selectionIndicatorLayer.backgroundColor = selectionIndicatorColor.cgColor
        
        scrollView.layer.sublayers = nil
        
        for (index, title) in sectionTitles.enumerated() {
            let size = self.measureTitleAtIndex(index)
            let y = (self.frame.height - selectionIndicatorHeight - size.height) / 2
            var xOffset = scrollOffset
            for (i, width) in segmentWidthsArray.enumerated() {
                if index == i {
                    break
                }
                xOffset = xOffset + width
            }
            
            var rect = CGRect.zero
            if let widthForIndex = segmentWidthsArray[safe: index] {
                rect = CGRect(x: xOffset, y: y, width: widthForIndex, height: size.height)
            }
            
            let titleLayer = CATextLayer()
            titleLayer.frame = rect
            titleLayer.alignmentMode = .center
            titleLayer.truncationMode = .end
            let selected = index == selectedSegmentIndex ? true : false
            let attributes = selected ? selectedTitleAttributes : titleAttributes
            titleLayer.string = NSAttributedString(string: title, attributes: attributes)
            titleLayer.contentsScale = UIScreen.main.scale
            
            scrollView.layer.addSublayer(titleLayer)
        }
        
        if selectionIndicatorLayer.superlayer == nil {
            selectionIndicatorLayer.frame = frameForSelectionIndicator()
            scrollView.layer.addSublayer(selectionIndicatorLayer)
        }
    }
    
    private func updateSegmentsRects() {
        scrollView.frame = CGRect(x: 0, y: 0, width : self.frame.width, height: self.frame.height)
        segmentWidthsArray = []
        for index in 0 ..< sectionTitles.count {
            let stringWidth = measureTitleAtIndex(index).width + segmentEdgeInset.left + segmentEdgeInset.right
            segmentWidthsArray.append(stringWidth)
        }
        let totalSegmentedControlWidth = segmentWidthsArray.reduce(0, +)
        scrollOffset = max(xInset, (self.frame.width - totalSegmentedControlWidth) / 2)
        let width = max(totalSegmentedControlWidth + 2 * scrollOffset, self.frame.width)
        scrollView.contentSize = CGSize(width: width, height: self.frame.height)
    }
    
    private func frameForSelectionIndicator() -> CGRect {
        var selectedSegmentOffset = scrollOffset
        for (index, width) in segmentWidthsArray.enumerated() {
            if selectedSegmentIndex == index {
                break
            }
            selectedSegmentOffset = selectedSegmentOffset + width
        }
        if let segmentWidth = segmentWidthsArray[safe: selectedSegmentIndex] {
            let y = self.frame.height - selectionIndicatorHeight
            return CGRect(x: selectedSegmentOffset, y: y, width: segmentWidth, height: selectionIndicatorHeight)
        }
        return .zero
    }
    
    private func measureTitleAtIndex(_ index: Int) -> CGSize {
        if let title = sectionTitles[safe: index] {
            let selected = index == selectedSegmentIndex ? true : false
            let attributes = selected ? selectedTitleAttributes : titleAttributes
            let size = (title as NSString).size(withAttributes: attributes)
            return size
        }
        return .zero
    }
    
    // Mark - Index Change
    
    func setSelectedSegmentIndex(_ index: Int) {
        setSelectedSegmentIndex(index, animated: false)
    }
    
    func setSelectedSegmentIndex(_ index: Int, animated: Bool) {
        selectedSegmentIndex = index
        self.setNeedsDisplay()
        scrollToSelectedSegmentIndex(animated)
    }
    
    private func scrollToSelectedSegmentIndex(_ animated: Bool) {
        var offsetter = scrollOffset
        for (index, width) in segmentWidthsArray.enumerated() {
            if selectedSegmentIndex == index {
                break
            }
            offsetter = offsetter + width
        }
        if let segmentWidth = segmentWidthsArray[safe: selectedSegmentIndex] {
            let x = offsetter - (self.frame.width - segmentWidth) / 2
            let rectToScrollTo = CGRect(x: x, y: 0, width: self.frame.width, height: self.frame.height)
            scrollView.scrollRectToVisible(rectToScrollTo, animated: animated)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            if self.bounds.contains(touchLocation) {
                var segment = 0
                // To know which segment the user touched, we need to loop over the widths and substract it from the x position.
                var widthLeft = touchLocation.x + scrollView.contentOffset.x - scrollOffset
                for width in segmentWidthsArray {
                    widthLeft = widthLeft - width
                    // When we don't have any width left to substract, we have the segment index.
                    if widthLeft <= 0 || segment >= sectionTitles.count - 1 {
                        break
                    }
                    segment = segment + 1
                }
                if segment != selectedSegmentIndex {
                    // Check if we have to do anything with the touch event
                    self.setSelectedSegmentIndex(segment, animated: true)
                    delegate?.didSelectTabAtIndex(segment)
                }
            }
        }
    }
    
}

