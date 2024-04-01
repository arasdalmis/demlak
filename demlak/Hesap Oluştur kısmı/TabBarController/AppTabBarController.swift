//
//  AppTabBarController.swift
//  demlak
//
//  Created by Davut Dalmış on 29.03.2024.
//

import UIKit

class AppTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewControllers()
    }

    private func setupViewControllers() {
        let firstVC = DiscoverController(nibName: "DiscoverController", bundle: nil)
        firstVC.tabBarItem = UITabBarItem(title: "Keşfet",
                                          image: UIImage(named: "Keşfet"),
                                          selectedImage: UIImage(named: "Keşfet"))

        let secondVC = AdsController(nibName: "AdsController", bundle: nil)
        secondVC.tabBarItem = UITabBarItem(title: "İlanlar",
                                           image: UIImage(named: "ilanlar"),
                                           selectedImage: UIImage(named: "ilanlar"))

        let thirdVC = SharingController(nibName: "SharingController", bundle: nil)
        thirdVC.tabBarItem = UITabBarItem(title: "Paylaş",
                                          image: UIImage(systemName: "plus.app"),
                                          selectedImage: UIImage(systemName: "plus.app.fill"))

        let fourthVC = SearchingController(nibName: "SearchingController", bundle: nil)
        fourthVC.tabBarItem = UITabBarItem(title: "Ara",
                                           image: UIImage(systemName: "magnifyingglass"),
                                           selectedImage: UIImage(systemName: "magnifyingglass"))

        let fifthVC = MyProfileController(nibName: "MyProfileController", bundle: nil)
        fifthVC.tabBarItem = UITabBarItem(title: "Ben",
                                          image: UIImage(systemName: "person.circle"),
                                          selectedImage: UIImage(systemName: "person.circle.fill"))

        let viewControllerList = [firstVC, secondVC, thirdVC, fourthVC, fifthVC]
        viewControllers = viewControllerList.map { UINavigationController(rootViewController: $0) }
    }
}
