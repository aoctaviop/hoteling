//
//  PageViewController.swift
//  Hoteling
//
//  Created by Andres Padilla on 4/19/18.
//  Copyright © 2018 Growth Acceleration Partners. All rights reserved.
//

import UIKit

protocol AvailableDesksDelegate: class {
    func bookDesk(desk: Desk)
    func showDeskLocation(desk: Desk)
    func isFiltering() -> Bool
    func selectedDate() -> String
    func site() -> String
    func room() -> String
    func sortType() -> SortType
    func updateFilteringIfNeeded()
    func firstDateOfTheWeek () -> String
    func lastDateOfTheWeek () -> String
}

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    weak var deskDelegate: AvailableDesksDelegate?
    
    var subViewControllers: [UIViewController] = []
    var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        dataSource = self
    }
    
    // To set the pager transition style
    required init(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return subViewControllers.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex: Int = subViewControllers.index(of: viewController) ?? 0
        
        if currentIndex <= 0 {
            return nil
        }
        
        return subViewControllers[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex: Int = subViewControllers.index(of: viewController) ?? 0
        
        if currentIndex >= subViewControllers.count - 1 {
            return nil
        }
        
        return subViewControllers[currentIndex + 1]
    }

    // MARK: -
    
    func updateViews() {
        setViewControllers([subViewControllers[0]], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
    }
    
    func moveToViewAtIndex(index: Int) {
        let direction = index >= currentIndex ? UIPageViewController.NavigationDirection.forward : UIPageViewController.NavigationDirection.reverse
        setViewControllers([subViewControllers[index]], direction: direction, animated: true, completion: nil)
        currentIndex = index
    }
}
