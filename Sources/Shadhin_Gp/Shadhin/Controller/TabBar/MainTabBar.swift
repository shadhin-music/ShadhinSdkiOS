//
//  MainTabBar.swift
//  Shadhin
//
//  Created by Rezwan on 6/19/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

public class MainTabBar: UITabBarController , UITabBarControllerDelegate {
    static var shared : MainTabBar? =  nil
    var wasLoginSuccess = false
    public override func viewDidLoad() {
        super.viewDidLoad()
        MainTabBar.shared = self
        self.delegate = self
        if #available(iOS 13.0, *) {
            UITabBar.appearance().barTintColor = .systemBackground
        } else {
            UITabBar.appearance().barTintColor = .white
        }
        UITabBar.appearance().tintColor = .tintColor
        UITabBar.appearance().isTranslucent = true

        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = UITabBar.appearance().standardAppearance
        }
        
//        let homeItem = UITabBarItem(title: "Home", image: UIImage(named: "ic_home_2"), tag: 0)
//        let home = HomeVCv3.instantiateNib()
//        let nav = UINavigationController(rootViewController: home)
//        nav.tabBarItem = homeItem
//        viewControllers?[0] = nav
        if let nav = viewControllers?[0] as? UINavigationController{
            nav.setViewControllers([HomeVCv3.instantiateNib()], animated: true)
        }
        if let nav = viewControllers?[4] as? UINavigationController{
            nav.setViewControllers([SubscriptionVCv3.instantiateNib()], animated: true)
        }
        Log.info("Tabbar didload")
        
        if let tabBarController = self.tabBarController {
            tabBarController.delegate = self
        }
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Log.info("Tabbar willappear")
    }

    //func to perform spring animation on imageview
    func performSpringAnimation(imgView: UIImageView) {

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {

            imgView.transform = CGAffineTransform.init(scaleX: 1.4, y: 1.4)

            //reducing the size
            UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                imgView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }) { (flag) in
            }
        }) { (flag) in

        }
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        Log.info("shouldSelect : ")
        guard let index = tabBarController.viewControllers?.firstIndex(of: viewController) else {return true}
        
//        if !ShadhinCore.instance.isUserLoggedIn && index == 1{
//         //   showNotUserPopUp(callingVC: self)
//            return false
//        }
//        
        if index == 4 {
            let vc  = SubscriptionVCv3.instantiateNib()
            let navVC = UINavigationController(rootViewController: vc)
            navVC.isNavigationBarHidden = true
            navVC.modalPresentationStyle = .fullScreen
            navVC.modalTransitionStyle = .coverVertical
            if var top = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = top.presentedViewController {
                    top = presentedViewController
                }
                top.present(navVC, animated: true, completion: nil)
            }
            
            return false
        }
        return true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if wasLoginSuccess{
            showLoginSuccessNoti()
        }
    }
    
    public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        //transition to gp music's tab9
    }
    
    func showLoginSuccessNoti(){
        // Generate top floating entry and set some properties
        var attributes = EKAttributes.topFloat
        //attributes.entryBackground = .gradient(gradient: .init(colors: [EKColor(.systemGreen), EKColor(.systemGreen)], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
        attributes.entryBackground = .color(color: EKColor(.init(rgb: 0x00B0FF)))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.statusBar = .dark
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.width), height: .intrinsic)

        let title = EKProperty.LabelContent(text: "Success", style: .init(font: .boldSystemFont(ofSize: 16), color: .white))
        let description = EKProperty.LabelContent(text: "Login in successful", style: .init(font: .systemFont(ofSize: 12), color: .white))
        //let image = EKProperty.ImageContent(image: UIImage(named: imageName)!, size: CGSize(width: 35, height: 35))
        let simpleMessage = EKSimpleMessage(image: nil, title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)

        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
        wasLoginSuccess = false
    }
    
    func showError(title: String, msg: String){
        var attributes = EKAttributes.topFloat
        attributes.entryBackground = .color(color: EKColor(.init(rgb: 0xEF5350)))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.statusBar = .dark
        attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
        attributes.displayDuration = 2.6
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.width), height: .intrinsic)
        attributes.entryInteraction = .forward

        let title = EKProperty.LabelContent(text: title, style: .init(font: .boldSystemFont(ofSize: 16), color: .white))
        let description = EKProperty.LabelContent(text: msg, style: .init(font: .systemFont(ofSize: 12), color: .white))
        let simpleMessage = EKSimpleMessage(image: nil, title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)

        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }

}

extension MainTabBar {
    // UITabBarControllerDelegate method
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Check if the selected view controller is a navigation controller
        if let navigationController = viewController as? UINavigationController {
            // Assuming your UITableView or UICollectionView is the root view controller of the navigation controller
            if let rootViewController = navigationController.viewControllers.first as? HomeVCv3 {
                // Scroll to the top
                rootViewController.collectionView?.setContentOffset(CGPoint.zero, animated: true)
            }
        }
    }
}
