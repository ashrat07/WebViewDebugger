//
//  PageTabViewController.swift
//  WebViewDebugger
//
//  Created by Ashish on 30/07/20.
//  Copyright © 2020 Microsoft Corporation. All rights reserved.
//

import UIKit

class PageTabViewController: UIViewController {
    
    private let result: [(String, Any)]!
    private var currentIndex: Int = 0
    private var pageTabView: PageTabView!
    private var pageViewController: UIPageViewController!
    
    var composeAction: (() -> Void)?
        
    init(result: [(String, Any)]) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private(set) lazy var _viewControllers: [UIViewController] = {
        return result.map({ (sectionName, value) -> UIViewController in
            let viewController = SimpleTableViewController(value: value)
            viewController.title = sectionName.uppercased()
            return viewController
        })
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Debugger"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(compose)),
            UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(search))
        ]
        
        view.backgroundColor = UIColor.black

        pageTabView = PageTabView()
        pageTabView.sectionTitles = result.map({ $0.0.uppercased() })
        pageTabView.titleAttributes = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.darkGray
        ]
        pageTabView.selectedTitleAttributes = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.black
        ]
        pageTabView.selectionIndicatorColor = .black
        pageTabView.backgroundColor = .white
        view.addSubview(pageTabView)
        pageTabView.delegate = self
        pageTabView.translatesAutoresizingMaskIntoConstraints = false
        pageTabView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pageTabView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pageTabView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pageTabView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let options = [UIPageViewController.OptionsKey.interPageSpacing: 20]
        pageViewController = UIPageViewController.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        if let viewController = _viewControllers.first {
            pageViewController.setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
        }
        let containerView = pageViewController.view!
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: pageTabView.bottomAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        self.addChild(pageViewController)
    }
    
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func compose() {
        composeAction?()
    }
    
    @objc private func search() {
        
    }
    
    private func scrollToPage(atIndex index: Int) {
        if let viewController = _viewControllers[safe: index] {
            let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse
            pageViewController.setViewControllers([viewController], direction: direction, animated: true, completion: nil)
            currentIndex = index
        }
    }

}

extension PageTabViewController: PageTabViewDelegate {
    
    func didSelectTabAtIndex(_ index: Int) {
        scrollToPage(atIndex: index)
    }
    
}

extension PageTabViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = _viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard _viewControllers.count > previousIndex else {
            return nil
        }
        
        return _viewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = _viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let viewControllersCount = _viewControllers.count
        
        guard viewControllersCount != nextIndex else {
            return nil
        }
        
        guard viewControllersCount > nextIndex else {
            return nil
        }
        
        return _viewControllers[nextIndex]
    }
    
}

extension PageTabViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard finished,
            let viewController = pageViewController.viewControllers?.last,
            let viewControllerIndex = _viewControllers.firstIndex(of: viewController) else {
                return
        }
        
        currentIndex = viewControllerIndex
        pageTabView.setSelectedSegmentIndex(currentIndex, animated: true)
    }
    
}
