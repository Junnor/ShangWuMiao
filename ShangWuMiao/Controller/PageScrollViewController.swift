//
//  PageScrollViewController.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/26.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

class PageScrollViewController: UIViewController {
    
    // MARK: - Public Properties
    
    // ------------------------------------------------------------------------------
    // Configure when init
    var bgImagesName: [String]!
    var promptImagesName: [String]!
    
    // ------------------------------------------------------------------------------
    
    // Optinal
    var pagesTitle: [String]?
    
    // All have default setted
    var allowedRecursive: Bool = false
    var hidePageController: Bool = false
    
    // Indicator color
    var pageIndicatorTintColor: UIColor = UIColor.gray
    var currentPageIndicatorTintColor: UIColor = UIColor.black
    
    // Y position
    lazy var pageControllerY: CGFloat = { [weak self] in
        if let strongSelf = self {
            return strongSelf.view.bounds.size.height
        }
        return 0.0
        }()
    
    lazy var titleY: CGFloat = {
        return 100
    }()
    
    
    fileprivate let bgColors: [UIColor] =
        [UIColor(red: CGFloat(99)/255.0, green:  CGFloat(150)/255.0, blue: CGFloat(229)/255.0, alpha: 1),
         UIColor(red: CGFloat(255)/255.0, green:  CGFloat(137)/255.0, blue: CGFloat(128)/255.0, alpha: 1),
         UIColor(red: CGFloat(133)/255.0, green:  CGFloat(222)/255.0, blue: CGFloat(192)/255.0, alpha: 1),
         UIColor(red: CGFloat(241)/255.0, green:  CGFloat(207)/255.0, blue: CGFloat(100)/255.0, alpha: 1)]
    
    // ------------------------------------------------------------------------------
    // MARK: - Private Properties
    // Frame of title label & page controller
    private let titleLabelHeight: CGFloat = 30
    private lazy var titleFrame: CGRect = { [weak self] in
        if let strongSelf = self {
            if strongSelf.bgImagesName == nil {
                return .zero
            }
            let x: CGFloat = 0
            let y: CGFloat = strongSelf.titleY - strongSelf.titleLabelHeight
            let width: CGFloat = strongSelf.view.bounds.size.width
            let height: CGFloat = strongSelf.titleLabelHeight
            return CGRect(x: x, y: y, width: width, height: height)
        }
        return .zero
        }()
    
    private let pageControllerHeight: CGFloat = 50
    private lazy var pageControllerFrame: CGRect = { [weak self] in
        if let strongSelf = self {
            let x: CGFloat = 0
            let y: CGFloat = strongSelf.pageControllerY - strongSelf.pageControllerHeight
            let width = strongSelf.view.bounds.size.width
            let height: CGFloat = strongSelf.pageControllerHeight
            return CGRect(x: x, y: y, width: width, height: height)
        }
        return .zero
        }()
    
    // Page container
    private var pageViewController: UIPageViewController!
    
    // Custom pageController
    fileprivate var pageController: UIPageControl!
    
    // Track the index of pageController
    fileprivate var lastPageIndex = 0
    
    // MARK: - View Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bgImagesName = ["page0", "page1", "page2", "page3"]
        promptImagesName = ["promptImg0", "promptImg1", "promptImg2", "promptImg3"]
        pagesTitle = ["Page 1", "Page 2", "Page 3", "page 4"]
        
        //        if pagesTitle != nil && pagesTitle?.count != bgImagesName.count {
        //            print("Warning: If you set titles, then titles count must equal images count")
        //            abort()
        //        }
        
        setPageViewController()
        setPageController()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(toLoginVC),
                                               name: toLoginViewController,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Helper
    @objc private func toLoginVC() {
        performSegue(withIdentifier: "Login", sender: nil)
    }
    
    @objc private func setPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        let startingContentViewController = viewControllerAt(0)
        let viewControllers = [startingContentViewController!]
        pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        
        pageViewController.view.frame = view.bounds
        
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
    }
    
    @objc private func setPageController() {
        pageController = UIPageControl(frame: pageControllerFrame)
        pageController.numberOfPages = bgImagesName.count
        //        pageController.pageIndicatorTintColor = pageIndicatorTintColor
        //        pageController.currentPageIndicatorTintColor = currentPageIndicatorTintColor
        pageController.addTarget(self, action: #selector(valueChangeAction), for: .valueChanged)
        view.addSubview(pageController)
        view.bringSubview(toFront: pageController)
        
        // Hide? pageViewController
        pageController.isHidden = hidePageController
    }
    
    @objc private func valueChangeAction() {
        let vc = viewControllerAt(pageController.currentPage)
        let viewControllers = [vc!]
        let direction: UIPageViewControllerNavigationDirection = pageController.currentPage > lastPageIndex ? .forward : .reverse
        lastPageIndex = pageController.currentPage
        
        pageViewController.setViewControllers(viewControllers, direction: direction, animated: true, completion: nil)
    }
    
    @objc fileprivate func viewControllerAt(_ index: Int) -> UIViewController? {
        if bgImagesName.count == 0 || index >= bgImagesName.count {
            return nil
        }
        let pageContentViewControllr = PageContentViewController()
        if pagesTitle != nil {
            pageContentViewControllr.pageTitle = pagesTitle![index]
        }
        pageContentViewControllr.labelFrame = titleFrame
        pageContentViewControllr.imageName = bgImagesName[index]
        pageContentViewControllr.pageIndex = index
        pageContentViewControllr.promptImageName = promptImagesName[index]
        
        pageContentViewControllr.bgColor = bgColors[index]
        
        return pageContentViewControllr
    }
}


// MARK: - Page View DataSource
extension PageScrollViewController: UIPageViewControllerDataSource {
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let pageContentViewController = viewController as! PageContentViewController
        var index = pageContentViewController.pageIndex
        
        if index == NSNotFound { return nil }
        
        if allowedRecursive {
            if index == 0 {
                index = bgImagesName.count - 1
                return viewControllerAt(index!)
            }
        } else {
            if index == 0 { return nil }
        }
        
        index = index! - 1
        return viewControllerAt(index!)
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let pageContentViewController = viewController as! PageContentViewController
        var index = pageContentViewController.pageIndex
        if index == NSNotFound { return nil }
        index = index! + 1
        
        if allowedRecursive {
            if index == bgImagesName.count {
                index = 0
                return viewControllerAt(index!)
            }
        } else {
            if index == bgImagesName.count {
                // MARK: TO-DO [Add action, if you want]
                return nil
            }
        }
        
        return viewControllerAt(index!)
    }
    
}

// MARK: - Page View Delegate
extension PageScrollViewController: UIPageViewControllerDelegate {
    
    // For the custom pageController
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let firstPageContentViewController = pendingViewControllers.first! as! PageContentViewController
        pageController.currentPage = firstPageContentViewController.pageIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        lastPageIndex = pageController.currentPage
    }
    
}
