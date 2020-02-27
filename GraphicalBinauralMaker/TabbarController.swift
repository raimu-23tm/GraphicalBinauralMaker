//
//  TabBarController.swift
//  GraphicalBinauralMaker
//
//  Created by apple on 2020/02/25.
//  Copyright © 2020 yo.sato. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if viewController is TabBarDelegate {
            let v = viewController as! TabBarDelegate
            v.didSelectTab(tabBarController: self)
        }
    }
}
