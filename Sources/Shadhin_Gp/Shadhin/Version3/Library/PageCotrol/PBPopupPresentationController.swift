//
//  PBPopupPresentationController.swift
//  PBPopupController
//
//  Created by Patrick BODET on 13/07/2018.
//  Copyright © 2018-2022 Patrick BODET. All rights reserved.
//

import UIKit

internal class PBPopupPresentationController: UIPresentationController
{
    internal weak var presentingVC: UIViewController!
    
    internal weak var popupController: PBPopupController!
    
    private var popupPresentationState: PBPopupPresentationState
    {
        return popupController.popupPresentationState
    }
    
    private var backingView: UIView!

    private var shouldUpdateBackingView: Bool = true
    
    internal var popupPresentationStyle = PBPopupPresentationStyle.deck {
        didSet {
            if self.popupPresentationStyle == .custom { return }
            
            if self.popupController.isContainerPresentationSheet {
                popupPresentationStyle = .fullScreen
            }
            if self.presentingVC.splitViewController != nil {
                popupPresentationStyle = .fullScreen
            }
            self.popupContentView1.popupPresentationStyle = popupPresentationStyle
        }
    }
    
    internal var isPresenting = false
    
    internal var animator: UIViewPropertyAnimator!
    
    private var finishAnimator: UIViewPropertyAnimator!
    
    private var popupContentView1: PBPopupContentView!
    {
        return popupController.containerViewController.popupContentView
    }
        
    private func dropShadowViewFor(_ view: UIView) -> UIView?
    {
        return popupController.dropShadowViewFor(view)
    }
    
    private var popupContentViewTopInset: CGFloat
    {
        #if targetEnvironment(macCatalyst)
        return 10.0
        #else
        if self.popupController.isContainerPresentationSheet {
            return 0.0
        }
        return UIDevice.current.userInterfaceIdiom == .pad ? 10.0 : 10.0
        #endif
    }
    
    private var statusBarFrame: CGRect
    {
        var frame = self.popupController.statusBarFrame(for: self.popupController.containerViewController.view)
        if self.popupPresentationStyle == .deck, frame.height == 0 {
            let height = presentingVC.view.safeAreaInsets.top
            frame.size.height = height > 0 ? height : 20 // probably an old iPhone
        }
        if self.popupController.isContainerPresentationSheet {
            frame.size.height = 0.0
        }
        return frame
    }
        
    internal var popupBarForPresentation: UIView!
    
    internal var imageViewForPresentation: PBPopupRoundShadowImageView?
    internal var stackViewForPresentation: PBPopupBarTitlesView?
    
    private var bottomModuleFrameForPopupStateOpen: CGRect = .zero
    
    private var dimmerView: PBPopupDimmerView! = {
        let view = PBPopupDimmerView()
        view.autoresizingMask = []
        view.backgroundColor = UIColor.black
        view.alpha = 0.0
        view.clipsToBounds = true
        return view
    }()
    
    private var blackView: PBPopupBlackView! = {
        let view = PBPopupBlackView()
        view.autoresizingMask = []
        view.backgroundColor = UIColor.black
        view.alpha = 1.0
        return view
    }()
    
    private var popupBarView: PBPopupBarView!
    {
        get {
            return popupController.popupBarView
        }
    }
    
    private var touchForwardingView: PBTouchForwardingView!
    
    private class PBTouchForwardingView: UIView
    {
        var passthroughViews: [UIView] = []
        weak var popupController: PBPopupController!
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            guard let hitView = super.hitTest(point, with: event) else { return nil }
            guard hitView == self else { return hitView }
            
            if event == nil {
                return self
            }
            #if targetEnvironment(macCatalyst)
            if #available(macCatalyst 13.4, *) {
                if event?.type == .hover {
                    return self
                }
            }
            #endif
            
            for passthroughView in passthroughViews {
                let point = convert(point, to: passthroughView)
                if passthroughView.hitTest(point, with: event) != nil {
                    if popupController.containerViewController.popupContentView.popupCanDismissOnPassthroughViews {
                        popupController.closePopupContent()
                    }
                    return nil
                }
            }
            return self
        }
    }
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?)
    {
        self.presentingVC = presentingViewController
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    deinit
    {
        PBLog("deinit \(self)")
    }
    
    // MARK: - UIPresentationController
    
    override var frameOfPresentedViewInContainerView: CGRect
    {
        return self.presentedViewFrameForPopupStateOpen()
    }
    
    override func containerViewWillLayoutSubviews()
    {
        super.containerViewWillLayoutSubviews()
        
        self.popupContentView1.frame = self.popupContentViewFrameForPopupStateOpen()
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView

        self.containerView?.layoutIfNeeded()
    }
    
    override func containerViewDidLayoutSubviews()
    {
        super.containerViewDidLayoutSubviews()

        self.containerView?.frame = self.popupContainerViewFrame()

        self.containerView?.layoutIfNeeded()
    }
    
    override func presentationTransitionWillBegin()
    {
        guard let presentedView = self.presentedView,
              let containerView = self.containerView,
              let coordinator = self.presentedViewController.transitionCoordinator
        else {
            return
        }
        
        containerView.frame = self.popupContainerViewFrame()
        
        let frame = containerView.bounds
        
        self.touchForwardingView = PBTouchForwardingView(frame: frame)
        self.touchForwardingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.touchForwardingView.passthroughViews = [self.presentingVC.view]
        self.touchForwardingView.popupController = self.popupController
        containerView.insertSubview(touchForwardingView, at: 0)
        
        self.setupBackingView()
        
        self.popupContentView1.contentView.addSubview(presentedView)
        self.popupContentView1.contentView.sendSubviewToBack(presentedView)
        
        self.popupContentView1.isHidden = true
        containerView.addSubview(self.popupContentView1)
        
        self.popupBarForPresentation = self.setupPopupBarForPresentation()
        if let popupBarForPresentation = self.popupBarForPresentation {
            self.popupContentView1.contentView.addSubview(popupBarForPresentation)
            popupBarForPresentation.alpha = 1.0
        }
        
        self.imageViewForPresentation = self.setupImageViewForPresentation()
        if let imageViewForPresentation = self.imageViewForPresentation {
            self.popupContentView1.contentView.addSubview(imageViewForPresentation)
            self.configureImageViewInStartPosition()
        }
        self.stackViewForPresentation = self.setupStackViewForPresentation()
        if let stackViewForPresentation = self.stackViewForPresentation {
            self.popupContentView1.contentView.addSubview(stackViewForPresentation)
            self.configureStackViewInStartPosition()
        }
        self.popupContentView1.popupCloseButton?.alpha = 0.0
        self.popupContentView1.popupCloseButton?.setButtonStateStationary()
        
        self.setupCornerRadiusForPopupContentViewAnimated(false, open: false)
        
        self.popupController.popupStatusBarStyle = self.popupController.popupPreferredStatusBarStyle
        
        coordinator.animate {context in
            self.animateBackingViewToDeck(true, animated: true)
            self.animateImageViewInFinalPosition()
            self.animateStackViewInFinalPosition()
            self.setupCornerRadiusForPopupContentViewAnimated(true, open: true)
            
            if !context.isInteractive {
                self.popupBarForPresentation?.alpha = 0.0
                self.popupContentView1.popupCloseButton?.alpha = 1.0
            }
            self.popupContentView1.updatePopupCloseButtonPosition()
            self.presentingVC.setNeedsStatusBarAppearanceUpdate()

            containerView.layoutIfNeeded()
        } completion: { _ in
            self.popupContentView1.popupImageView?.isHidden = false
            self.popupContentView1.popupImageModule?.isHidden = false
            self.popupContentView1.popupStackView?.isHidden = false
            self.popupContentView1.popupStackModule?.isHidden = false
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool)
    {
        self.popupBarForPresentation?.removeFromSuperview()
        self.popupBarForPresentation = nil
        self.imageViewForPresentation?.removeFromSuperview()
        self.imageViewForPresentation = nil
        self.stackViewForPresentation?.removeFromSuperview()
        self.stackViewForPresentation = nil
        
        if !completed {
            self.cleanup()
        }
        else {
            self.blackView?.alpha = 1.0
            NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        }
    }
    
    override func dismissalTransitionWillBegin()
    {
        guard let coordinator = self.presentedViewController.transitionCoordinator,
              let containerView = self.containerView
        else {
            return
        }
        
        self.popupBarForPresentation = self.setupPopupBarForPresentation()
        if let popupBarForPresentation = self.popupBarForPresentation {
            self.popupContentView1.contentView.addSubview(popupBarForPresentation)
            popupBarForPresentation.alpha = 0.0
        }
        
        self.imageViewForPresentation = self.setupImageViewForPresentation()
        if let imageViewForPresentation = self.imageViewForPresentation {
            self.popupContentView1.contentView.addSubview(imageViewForPresentation)
            self.configureImageViewInStartPosition()
        }
        self.stackViewForPresentation = self.setupStackViewForPresentation()
        if let stackViewForPresentation = self.stackViewForPresentation {
            self.popupContentView1.contentView.addSubview(stackViewForPresentation)
            self.configureStackViewInStartPosition()
        }
        if let backingView = self.backingView {
            backingView.removeFromSuperview()
        }
        self.backingView = nil
        self.setupBackingView()
        self.animateBackingViewToDeck(true, animated: false)
        
        self.popupContentView1.popupCloseButton?.setButtonStateTransitioning()
        
        self.popupController.popupStatusBarStyle = self.popupController.containerPreferredStatusBarStyle
        
        coordinator.animate { context in
            self.animateBackingViewToDeck(false, animated: true)
            if !context.isInteractive {
                self.animateImageViewInFinalPosition()
                self.animateStackViewInFinalPosition()
                self.popupBarForPresentation?.alpha = 1.0
                self.popupContentView1.popupCloseButton?.alpha = 0.0
            }
            
            self.setupCornerRadiusForPopupContentViewAnimated(true, open: false)
    
            self.presentingVC.setNeedsStatusBarAppearanceUpdate()

            containerView.layoutIfNeeded()
        } completion: { _ in
            self.popupContentView1.popupImageView?.isHidden = false
            self.popupContentView1.popupImageModule?.isHidden = false
            
            self.popupContentView1.popupStackView?.isHidden = false
            self.popupContentView1.popupStackModule?.isHidden = false
        }
    }
    
    internal func continueDismissalAnimationWithDurationFactor(_ durationFactor: CGFloat)
    {
        if let animator = self.animator {
            animator.stopAnimation(false)

            self.finishAnimator = UIViewPropertyAnimator(duration: animator.duration * Double(durationFactor), dampingRatio: 1, animations: {
                self.popupContentView1.frame = self.popupContentViewFrameForPopupStateClosed(finish: true, isInteractive: true)
                self.presentedView?.frame = self.presentedViewFrameForPopupStateClosed()
                self.animateBottomBarToHidden(false)
                self.animateBackingViewToDeck(false, animated: true)
                self.animateImageViewInFinalPosition()
                self.animateStackViewInFinalPosition()
                self.setupCornerRadiusForPopupContentViewAnimated(true, open: false)
                self.popupContentView1.popupCloseButton?.alpha = 0.0
                self.popupBarForPresentation?.alpha = 1.0
            })
            
            self.finishAnimator.addCompletion { (_) in
                animator.finishAnimation(at: .end)
            }
            
            self.finishAnimator.startAnimation()
        }
    }

    override func dismissalTransitionDidEnd(_ completed: Bool)
    {
        self.popupBarForPresentation?.removeFromSuperview()
        self.popupBarForPresentation = nil
        self.imageViewForPresentation?.removeFromSuperview()
        self.imageViewForPresentation = nil
        self.stackViewForPresentation?.removeFromSuperview()
        self.stackViewForPresentation = nil
        if completed {
            self.cleanup()
        }
        else {
            self.blackView?.alpha = 1.0
        }
    }
    
    @objc func didEnterBackground(_ sender: Any)
    {
        self.shouldUpdateBackingView = false
        delay(2) {
            self.shouldUpdateBackingView = true
        }
    }
    
    private func cleanup()
    {
        self.backingView?.removeFromSuperview()
        self.backingView = nil
        
        self.blackView?.removeFromSuperview()
        self.dimmerView?.removeFromSuperview()
        
        self.touchForwardingView.removeFromSuperview()
        self.touchForwardingView = nil
        
        self.presentedView?.removeFromSuperview()
        
        self.popupContentView1.removeFromSuperview()
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension PBPopupPresentationController: UIViewControllerAnimatedTransitioning
{
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return self.isPresenting ? self.popupContentView1.popupPresentationDuration : self.popupContentView1.popupDismissalDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        let animator = self.interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating
    {
        if self.animator != nil {
            return self.animator!
        }
        let presentedView = transitionContext.view(forKey: self.isPresenting ? .to : .from)
        
        var animator: UIViewPropertyAnimator!
        
        self.containerView?.layoutIfNeeded()

        if self.isPresenting {
            self.popupContentView1.frame = self.popupContentViewFrameForPopupStateClosed(finish: false)
            presentedView?.frame = self.presentedViewFrameForPopupStateClosed()
            
            self.popupContentView1.isHidden = false
            
            self.configureBottomModuleInStartPosition()
            
            let animations = {
                self.popupContentView1.frame = self.popupContentViewFrameForPopupStateOpen()
                presentedView?.frame = self.presentedViewFrameForPopupStateOpen()

                self.animateBottomBarToHidden(true)
                self.animateBottomModuleInFinalPosition()

                self.containerView?.layoutIfNeeded()
            }

            let completion: (() -> Void) = {() -> Void in
                if transitionContext.transitionWasCancelled {
                    // Restore the initial frame after cancel presenting
                    self.configureBottomModuleInOriginalPosition()
                }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
            animator = UIViewPropertyAnimator(duration: self.transitionDuration(using: transitionContext), dampingRatio: 1, animations: {
                animations()
            })
            animator.addCompletion { (_) in
                completion()
            }
        }
        else {
            // Dismiss
            self.popupContentView1.frame = self.popupContentViewFrameForPopupStateOpen()
            presentedView?.frame = self.presentedViewFrameForPopupStateOpen()
            
            self.animateBottomBarToHidden(true)
            
            let animations = {
                self.popupContentView1.frame = self.popupContentViewFrameForPopupStateClosed(finish: false, isInteractive: transitionContext.isInteractive)
                self.presentedView?.frame = self.presentedViewFrameForPopupStateClosed()

                if !transitionContext.isInteractive {
                    self.animateBottomBarToHidden(false)
                }
                self.containerView?.layoutIfNeeded()
            }

            let completion = {
                // Restore the initial frame after dismiss
                self.configureBottomModuleInOriginalPosition()
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }

            animator = UIViewPropertyAnimator(duration: self.transitionDuration(using: transitionContext), dampingRatio: 1, animations: {
                animations()
            })
            animator.addCompletion { (_) in
                completion()
            }
        }
        
        if transitionContext.isInteractive {
            animator.startAnimation()
            animator.pauseAnimation()
        }
        
        self.animator = animator
        return animator
    }
    
    func animationEnded(_ transitionCompleted: Bool)
    {
        self.animator = nil
    }
    
    // MARK: - User Interface Style & Size
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)
    {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            guard previousTraitCollection != nil, let backingView = self.backingView, self.shouldUpdateBackingView == true else { return }
            if self.traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                backingView.removeFromSuperview()
                self.backingView = nil
                self.setupBackingView()
                self.animateBackingViewToDeck(true, animated: false)
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let backingView = self.backingView {
            backingView.removeFromSuperview()
            self.backingView = nil
        }
        
        self.containerView?.layoutIfNeeded()
        coordinator.animate(alongsideTransition: { (context) in
            self.containerView?.frame = self.popupContainerViewFrame()
            self.blackView?.frame = self.popupBlackViewFrame()
            self.setupBackingView()
            self.animateBackingViewToDeck(true, animated: false)
            self.popupContentView1.frame = self.popupContentViewFrameForPopupStateOpen()
            self.setupCornerRadiusForPopupContentViewAnimated(true, open: true)
            self.popupContentView1.updatePopupCloseButtonPosition()
            self.containerView?.layoutIfNeeded()
        })
    }
}

// MARK: - Frames

extension PBPopupPresentationController
{
    private func popupContainerViewFrame() -> CGRect
    {
        var frame = self.presentingVC.view.frame
        if let dropShadowView = self.dropShadowViewFor(self.presentingVC.view) {
            frame = dropShadowView.frame
            frame.origin.x += self.presentingVC.view.frame.minX
            frame.size.width = self.presentingVC.view.frame.width
        }
        PBLog("\(frame)")
        return frame
    }
    
    /// Bottom above the tabBar
    private func popupBlackViewFrame() -> CGRect
    {
        var frame: CGRect = .zero
        if let dropShadowView = self.dropShadowViewFor(self.presentingVC.view) {
            frame = dropShadowView.bounds
        }
        else {
            frame = self.popupContentViewFrameForPopupStateOpen()
            frame.origin.y = 0
        }
        let popupBarViewFrame = self.popupController.popupBarViewFrameForPopupStateClosed()
        frame.size.height = popupBarViewFrame.maxY
        PBLog("\(frame)")
        return frame
    }
    
    private func dimmerViewFrame() -> CGRect
    {
        guard let containerView = self.containerView else { return .zero }
        
        var frame: CGRect = .zero
        frame = containerView.bounds
        self.dimmerView.frame.origin.x = self.popupContentViewFrameForPopupStateOpen().minX
        self.dimmerView.frame.size.width = self.popupContentViewFrameForPopupStateOpen().width
        PBLog("\(frame)")
        return frame
    }
    
    internal func popupContentViewFrameForPopupStateClosed(finish: Bool, isInteractive: Bool = false) -> CGRect
    {
        var frame: CGRect = .zero
        if !self.isPresenting && isInteractive && !finish {
            frame = self.presentingVC.defaultFrameForBottomBar()
            frame.origin.x = self.popupController.popupBarViewFrameForPopupStateClosed().origin.x
            frame.size.width = self.popupController.popupBarViewFrameForPopupStateClosed().width
        }
        else {
            frame = self.popupController.popupBarViewFrameForPopupStateClosed()
        }
        if #available(iOS 14, *) {
            if UIDevice.current.userInterfaceIdiom == .pad, let svc = self.presentingVC.splitViewController, self.dropShadowViewFor(svc.view) != nil {
                let x = self.presentingVC.view.safeAreaInsets.left
                frame.origin.x = x
                frame.size.width -= x
            }
        }
        PBLog("\(frame)")
        return frame
    }
    
    private func presentedViewFrameForPopupStateClosed() -> CGRect
    {
        var frame = self.popupContentViewFrameForPopupStateClosed(finish: false)
        frame.origin.x = 0
        frame.origin.y = 0
        frame.size.height = self.popupContentViewFrameForPopupStateOpen().height
        frame.size.width = self.popupContentViewFrameForPopupStateOpen().width
        PBLog("\(frame)")
        return frame
    }
    
    internal func popupContentViewFrameForPopupStateOpen() -> CGRect
    {
        guard let containerView = self.containerView else { return .zero }
        
        var x: CGFloat = self.presentingVC.defaultFrameForBottomBar().origin.x
        var y: CGFloat = 0.0

        var width = self.presentingVC.defaultFrameForBottomBar().size.width
        var height = containerView.bounds.height

        /*
        #if targetEnvironment(macCatalyst)
        if self.popupPresentationStyle == .fullScreen {
            //y = self.statusBarFrame.height
        }
        #endif
        */
        
        if self.popupPresentationStyle != .fullScreen {
            y = self.isCompactOrPhoneInLandscape() ? 0.0 : self.statusBarFrame.height + self.popupContentViewTopInset
            width = self.presentingVC.defaultFrameForBottomBar().size.width
            if self.popupPresentationStyle == .custom {
                y = height - self.popupContentView1.popupContentSize.height
                if self.popupContentView1.popupContentSize.width > 0 {
                    width = self.presentingVC.view.bounds.width
                    x = width - self.popupContentView1.popupContentSize.width
                    width = width - x
                }
            }
            height = height - y
        }
        var frame = CGRect(x: x, y: y, width: width, height: height)
        
        if self.presentingVC is UINavigationController || self.presentingVC is UITabBarController {
            frame = CGRect(x: 0.0, y: y, width: containerView.bounds.width, height: height)
            
            if #available(iOS 14, *) {
                if UIDevice.current.userInterfaceIdiom == .pad, let svc = self.presentingVC.splitViewController, self.dropShadowViewFor(svc.view) != nil {
                    let x = self.presentingVC.view.safeAreaInsets.left
                    frame = CGRect(x: x, y: y, width: containerView.bounds.width - x, height: height)
                }
            }
        }
        PBLog("\(frame)")
        return frame
    }
    
    private func presentedViewFrameForPopupStateOpen() -> CGRect
    {
        var frame = self.popupContentViewFrameForPopupStateOpen()
        frame.origin.x = 0
        frame.origin.y = 0
        PBLog("\(frame)")
        return frame
    }
    
    // MARK: - Corner radii
    
    internal func setupCornerRadiusForDimmerView()
    {
        if let dropShadowView = self.dropShadowViewFor(self.presentingVC.view) {
            self.dimmerView.layer.cornerRadius = dropShadowView.layer.cornerRadius
            if let svc = self.presentingVC.splitViewController, self.traitCollection.horizontalSizeClass == .regular {
                if svc.viewControllers.firstIndex(of: self.presentingVC) == 0 {
                    self.dimmerView.frame.origin.x = self.popupContentViewFrameForPopupStateOpen().minX
                    self.dimmerView.frame.size.width = self.popupContentViewFrameForPopupStateOpen().width
                    self.dimmerView.layer.maskedCorners = [.layerMinXMinYCorner]
                }
                else if svc.viewControllers.firstIndex(of: self.presentingVC) == 1 {
                    self.dimmerView.layer.maskedCorners = [.layerMaxXMinYCorner]
                }
            }
            if #available(iOS 13.0, *) {
                self.dimmerView.layer.cornerCurve = dropShadowView.layer.cornerCurve
            }
        }
    }
    
    internal func setupCornerRadiusForBackingViewAnimated(_ animated: Bool, open: Bool)
    {
        guard let backingView = self.backingView else { return }
        
        let defaultCornerRadius = self.popupController.cornerRadiusForWindow()
        
        var cornerRadius: CGFloat = 0.0
#if targetEnvironment(macCatalyst)
        cornerRadius = defaultCornerRadius
#else
        cornerRadius = open ? 10.0 : defaultCornerRadius
#endif
        if #available(iOS 13.0, *) {
            backingView.layer.cornerCurve = .continuous
        }
        backingView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        backingView.layer.cornerRadius = cornerRadius
    }
    
    internal func setupCornerRadiusForPopupContentViewAnimated(_ animated: Bool, open: Bool)
    {
        let defaultCornerRadius = self.popupController.cornerRadiusForWindow()
        
        var cornerRadius: CGFloat = 0.0
#if targetEnvironment(macCatalyst)
        cornerRadius = defaultCornerRadius
#else
        switch self.popupPresentationStyle {
        case .deck:
            cornerRadius = open ? (self.isCompactOrPhoneInLandscape() ? defaultCornerRadius : 10.0) : 0.0
        case .custom:
            cornerRadius = open ? (self.popupContentView1.popupContentSize.height == UIScreen.main.bounds.height ? 0.0 : 10.0) : 0.0
        case .fullScreen:
            cornerRadius = open ? defaultCornerRadius : 0.0
        }
        
        if #available(iOS 13.0, *) {
            self.popupContentView1.layer.cornerCurve = .continuous
        }
        if let dropShadowView = self.popupController.dropShadowViewFor(self.presentingVC.view) {
            cornerRadius = open ? dropShadowView.layer.cornerRadius : 0.0
            if #available(iOS 13.0, *) {
                self.popupContentView1.layer.cornerCurve = dropShadowView.layer.cornerCurve
            }
        }
#endif

        /// splitViewController master or detail
        if let svc = self.presentingVC.splitViewController, self.traitCollection.horizontalSizeClass == .regular {
            if svc.viewControllers.firstIndex(of: self.presentingVC) == 0 {
                self.popupContentView1.layer.maskedCorners = [.layerMinXMinYCorner]
            }
            else if svc.viewControllers.firstIndex(of: self.presentingVC) == 1 {
                self.popupContentView1.layer.maskedCorners = [.layerMaxXMinYCorner]
            }
            if self.popupPresentationStyle == .custom {
                self.popupContentView1.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
        }
        else {
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.popupContentView1.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
            else {
                if !self.popupController.isContainerPresentationSheet {
                    self.popupContentView1.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                }
            }
        }
        self.popupContentView1.layer.cornerRadius = cornerRadius
    }
    
    
    // MARK: - Snapshot views
    
    private func setupBackingView()
    {
        guard let containerView = self.containerView else { return }
        
        if self.popupPresentationStyle == .custom || self.popupController.isContainerPresentationSheet || self.presentingVC.splitViewController != nil {
            self.dimmerView.frame = self.dimmerViewFrame()
            self.setupCornerRadiusForDimmerView()
            containerView.addSubview(self.dimmerView)
            containerView.sendSubviewToBack(self.dimmerView)
            return
        }

        if self.backingView == nil {
            let isHidden = self.popupBarView.isHidden
            self.popupBarView.isHidden = true
            let alpha = self.popupBarView.alpha
            self.popupBarView.alpha = 0.0
            
            self.blackView.frame = self.popupBlackViewFrame()
            
            var imageRect = self.blackView.bounds
            
            let x = self.presentingVC.view.frame.minX
            if x < 0 {
                imageRect.origin.x = -x
                imageRect.size.width += x
            }
            
            //for debug
            //let image = presentingVC.view.makeSnapshot(from: imageRect)
            
            var snapshotView = self.presentingVC.view!
            if let nc = self.presentingVC.navigationController {
                snapshotView = nc.view
            }
            self.backingView = snapshotView.resizableSnapshotView(from: imageRect, afterScreenUpdates: true, withCapInsets: .zero)
            self.backingView.autoresizingMask = []
            
            self.popupBarView.isHidden = isHidden
            self.popupBarView.alpha = alpha
            
            self.backingView.frame = imageRect
            
            self.backingView.clipsToBounds = true
            
            self.setupCornerRadiusForBackingViewAnimated(false, open: false)
            
            if #available(iOS 13.0, *) {
                self.dimmerView.backgroundColor = self.traitCollection.userInterfaceStyle == .light ? .black : .lightGray
            }
            
            self.dimmerView.frame = self.backingView.bounds
            self.backingView.addSubview(self.dimmerView)
            
            if self.blackView.window == nil {
                self.containerView?.addSubview(self.blackView)
                self.containerView?.sendSubviewToBack(self.blackView)
            }
            self.blackView.addSubview(self.backingView)
        }
    }
    
    private func animateBackingViewToDeck( _ deck: Bool, animated: Bool)
    {
        if deck == true {
            self.dimmerView.alpha = 0.2
            if self.presentingVC.splitViewController != nil { return }
            
            if self.popupPresentationStyle != .custom {
                let scaledXY = (self.presentingVC.view.bounds.width - self.presentingVC.view.layoutMargins.right * 2) / self.presentingVC.view.bounds.width
                
                if let dropShadowView = self.dropShadowViewFor(self.presentingVC.view) {
                    
                    if self.popupPresentationStyle == .fullScreen { return }
                    
                    let translatedY = dropShadowView.superview!.bounds.height * ((1 - scaledXY) / 2) + 10
                    dropShadowView.superview?.transform = CGAffineTransform(a: scaledXY, b: 0.0, c: 0.0, d: scaledXY, tx: 1.0, ty: -translatedY)
                }
                else {
                    self.backingView.transform = .identity
                    let translatedY = self.statusBarFrame.height - (self.statusBarFrame.height > 0 ? (self.backingView.bounds.height * (1 - scaledXY) / 2) : 0.0)
                    self.backingView.transform = CGAffineTransform(a: scaledXY, b: 0.0, c: 0.0, d: scaledXY, tx: 1.0, ty: translatedY)
                    self.setupCornerRadiusForBackingViewAnimated(animated, open: true)
                }
            }
        }
        else {
            self.dimmerView.alpha = 0.0
            if self.presentingVC.splitViewController != nil { return }
            if let dropShadowView = self.dropShadowViewFor(self.presentingVC.view) {
                dropShadowView.superview?.transform = .identity
            }
            else {
                self.setupCornerRadiusForBackingViewAnimated(animated, open: false)
                if let backingView = self.backingView {
                    backingView.transform = .identity
                }
            }
        }
    }
    
    private func setupPopupBarForPresentation() -> UIView?
    {
        let alpha = self.popupBarView.alpha
        self.popupBarView.alpha = 1.0
        
        self.presentingVC.popupBar.setHighlighted(false, animated: false)
        
        if !self.isCompactOrPhoneInLandscape() && self.popupContentView1.popupImageView != nil {
            self.presentingVC.popupBar.shadowImageView.isHidden = true
        }
        
        if !self.isCompactOrPhoneInLandscape() && self.popupContentView1.popupStackView != nil {
            self.presentingVC.popupBar.shadowStackView.isHidden = true
        }
        
        var rect = self.popupBarView.frame
        if self.presentingVC.splitViewController != nil {
            rect.origin.x = self.popupContentViewFrameForPopupStateOpen().minX
            rect.size.width = self.popupContentViewFrameForPopupStateOpen().width
        }
        
        //for debug
        //let image = self.presentingVC.view.makeSnapshot(from: rect)
        
        let view = self.presentingVC.view.resizableSnapshotView(from: rect, afterScreenUpdates: true, withCapInsets: .zero)
        
        if self.presentingVC.popupBar.popupBarStyle == .prominent {
            self.presentingVC.popupBar.shadowImageView.isHidden = false
            self.presentingVC.popupBar.shadowStackView.isHidden = false
        }
        
        self.popupBarView.alpha = alpha
        
        return view
    }
    
    // MARK: - Bottom bar
    
    private func animateBottomBarToHidden( _ hidden: Bool)
    {
        self.presentingVC._animateBottomBarToHidden(hidden)
    }
    
    // MARK: - Image view
    
    private func setupImageViewForPresentation() -> PBPopupRoundShadowImageView?
    {
        if self.isCompactOrPhoneInLandscape() {return nil}
        
        if self.presentingVC.popupBar.popupBarStyle == .prominent, let imageView = self.popupContentView1.popupImageView, let shadowImageView = self.presentingVC.popupBar.shadowImageView  {
            
            let moduleView = PBPopupRoundShadowImageView(frame: .zero)

            moduleView.image = imageView.image

            if self.isPresenting {
                moduleView.imageView.backgroundColor = shadowImageView.backgroundColor
                moduleView.imageView.contentMode = shadowImageView.contentMode
                moduleView.imageView.clipsToBounds = shadowImageView.clipsToBounds
                moduleView.imageView.layer.cornerRadius = shadowImageView.layer.cornerRadius

                moduleView.clipsToBounds = shadowImageView.clipsToBounds
                moduleView.cornerRadius = shadowImageView.cornerRadius
                moduleView.shadowColor = shadowImageView.shadowColor
                moduleView.shadowOpacity = shadowImageView.shadowOpacity
                moduleView.shadowOffset = shadowImageView.shadowOffset
                moduleView.shadowRadius = shadowImageView.shadowRadius
            }
            else {
                moduleView.imageView.backgroundColor = imageView.backgroundColor
                moduleView.imageView.contentMode = imageView.contentMode
                moduleView.imageView.clipsToBounds = imageView.clipsToBounds
                moduleView.cornerRadius = imageView.layer.cornerRadius

                if let imageModule = self.popupContentView1.popupImageModule {
                    moduleView.clipsToBounds = imageModule.clipsToBounds
                    moduleView.shadowColor = UIColor(cgColor: imageModule.layer.shadowColor ?? UIColor.black.cgColor)
                    moduleView.shadowOpacity = imageModule.layer.shadowOpacity
                    moduleView.shadowOffset = imageModule.layer.shadowOffset
                    moduleView.shadowRadius = imageModule.layer.shadowRadius
                }
            }
            return moduleView
        }
        return nil
    }
    
    private func configureImageViewInStartPosition()
    {
        if self.isCompactOrPhoneInLandscape() {return}
        
        guard let presentedView = self.presentedView else { return }
        guard let popupBar = self.presentingVC.popupBar else { return }
        guard popupBar.popupBarStyle == .prominent else { return }
        guard let imageViewForPresentation = self.imageViewForPresentation else { return }
        guard let imageView = self.popupContentView1.popupImageView else { return }
        
        if self.isPresenting {
            var closedFrame = popupBar.shadowImageView.frame

            closedFrame.origin.x -= self.popupContentViewFrameForPopupStateOpen().minX
            if closedFrame.origin.x < 0 {
                closedFrame.origin.x = popupBar.shadowImageView.frame.minX
            }
            
            imageViewForPresentation.frame = closedFrame
        }
        else {
            let openFrame = imageView.convert(imageView.bounds, to: presentedView)
            imageViewForPresentation.frame = openFrame
            imageViewForPresentation.isHidden = false
        }
        imageView.isHidden = true
        if let imageModule = self.popupContentView1.popupImageModule {
            imageModule.isHidden = true
        }
        
    }
    
    internal func animateImageViewInFinalPosition()
    {
        if self.isCompactOrPhoneInLandscape() {return}
        
        guard let presentedView = self.presentedView else { return }
        guard let popupBar = self.presentingVC.popupBar else { return }
        guard popupBar.popupBarStyle == .prominent else { return }
        guard let imageViewForPresentation = self.imageViewForPresentation else { return }
        guard let imageView = self.popupContentView1.popupImageView else { return }
        guard let shadowImageView = popupBar.shadowImageView else { return }
        
        if self.isPresenting {
            let openFrame = imageView.convert(imageView.bounds, to: presentedView)
            imageViewForPresentation.frame = openFrame
            if imageView.layer.cornerRadius > 0 {
                imageViewForPresentation.cornerRadius = imageView.layer.cornerRadius
            }
            imageViewForPresentation.imageView.backgroundColor = imageView.backgroundColor
            imageViewForPresentation.imageView.contentMode = imageView.contentMode
            imageViewForPresentation.imageView.clipsToBounds = imageView.clipsToBounds
            
            if let imageModule = self.popupContentView1.popupImageModule {
                imageViewForPresentation.clipsToBounds = imageModule.clipsToBounds
                imageViewForPresentation.shadowColor = UIColor(cgColor: imageModule.layer.shadowColor ?? UIColor.black.cgColor)
                imageViewForPresentation.shadowOpacity = imageModule.layer.shadowOpacity
                imageViewForPresentation.shadowOffset = imageModule.layer.shadowOffset
                imageViewForPresentation.shadowRadius = imageModule.layer.shadowRadius
            }
        }
        else {
            var closedFrame = popupBar.shadowImageView.frame
            
            closedFrame.origin.x -= self.popupContentViewFrameForPopupStateOpen().minX
            if closedFrame.origin.x < 0 {
                closedFrame.origin.x = popupBar.shadowImageView.frame.minX
            }
            
            imageViewForPresentation.frame = closedFrame
            imageViewForPresentation.cornerRadius = shadowImageView.cornerRadius
            imageViewForPresentation.imageView.backgroundColor = shadowImageView.backgroundColor
            imageViewForPresentation.imageView.contentMode = shadowImageView.contentMode
            imageViewForPresentation.imageView.clipsToBounds = shadowImageView.imageView.clipsToBounds
            
            imageViewForPresentation.clipsToBounds = shadowImageView.clipsToBounds
            imageViewForPresentation.shadowColor = shadowImageView.shadowColor
            imageViewForPresentation.shadowOpacity = shadowImageView.shadowOpacity
            if popupBar.imageShadowOpacity > 0.0 {
                imageViewForPresentation.shadowOpacity = popupBar.imageShadowOpacity
            }
            imageViewForPresentation.shadowOffset = shadowImageView.shadowOffset
            imageViewForPresentation.shadowRadius = shadowImageView.shadowRadius
        }
    }
    // MARK: - stack view
    
    private func setupStackViewForPresentation() -> PBPopupBarTitlesView?
    {
        if self.isCompactOrPhoneInLandscape() {return nil}
        
        if self.presentingVC.popupBar.popupBarStyle == .prominent, let stackView = self.popupContentView1.popupStackView, let shadowStackView = self.presentingVC.popupBar.shadowStackView  {
            
            let moduleView = PBPopupBarTitlesView.initial()
            //moduleView.backgroundColor = .magenta.withAlphaComponent(0.5)
            if self.isPresenting {
                moduleView.titleLabel?.font = shadowStackView.titleLabel?.font
                moduleView.subtitleLabel?.font = shadowStackView.subtitleLabel?.font
                moduleView.titleLabel?.text = shadowStackView.titleLabel?.text
                moduleView.subtitleLabel?.text = shadowStackView.subtitleLabel?.text
                moduleView.titleLabel?.textColor = shadowStackView.titleLabel?.textColor
                moduleView.subtitleLabel?.textColor = shadowStackView.subtitleLabel?.textColor
            }
            else {
                moduleView.titleLabel?.font = stackView.titleLabel?.font
                moduleView.subtitleLabel?.font = stackView.subtitleLabel?.font
                moduleView.titleLabel?.text = stackView.titleLabel?.text
                moduleView.subtitleLabel?.text = stackView.subtitleLabel?.text
                moduleView.titleLabel?.textColor = stackView.titleLabel?.textColor
                moduleView.subtitleLabel?.textColor = stackView.subtitleLabel?.textColor
            }
            return moduleView
        }
        return nil
    }
    
    private func configureStackViewInStartPosition()
    {
        if self.isCompactOrPhoneInLandscape() {return}
        
        guard let presentedView = self.presentedView else { return }
        guard let popupBar = self.presentingVC.popupBar else { return }
        guard popupBar.popupBarStyle == .prominent else { return }
        guard let stackViewForPresentation = self.stackViewForPresentation else { return }
        guard let stackView = self.popupContentView1.popupStackView else { return }
        
        if self.isPresenting {
            var closedFrame = popupBar.shadowStackView.frame
            
            closedFrame.origin.x -= self.popupContentViewFrameForPopupStateOpen().minX
            if closedFrame.origin.x < 0 {
                closedFrame.origin.x = popupBar.shadowStackView.frame.minX
            }
            
            stackViewForPresentation.frame = closedFrame
            stackViewForPresentation.alignment = .leading
        }
        else {
            let openFrame = stackView.convert(stackView.bounds, to: presentedView)
            stackViewForPresentation.frame = openFrame
            stackViewForPresentation.isHidden = false
        }
        
        stackView.isHidden = true
        if let stackModule = self.popupContentView1.popupStackModule{
            stackModule.isHidden = true
        }
    }
    
    internal func animateStackViewInFinalPosition()
    {
        if self.isCompactOrPhoneInLandscape() {return}
        
        guard let presentedView = self.presentedView else { return }
        guard let popupBar = self.presentingVC.popupBar else { return }
        guard popupBar.popupBarStyle == .prominent else { return }
        guard let stackViewForPresentation = self.stackViewForPresentation else { return }
        guard let stackView = self.popupContentView1.popupStackView else { return }
        guard let shadowStackView = popupBar.shadowStackView else { return }
        
        if self.isPresenting {
            let openFrame = stackView.convert(stackView.bounds, to: presentedView)
            stackViewForPresentation.frame = openFrame
            //stackViewForPresentation.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
            //stackViewForPresentation.subtitleLabel?.font = .systemFont(ofSize: 10, weight: .regular)
        }
        else {
            var closedFrame = popupBar.shadowStackView.frame
            
//            closedFrame.origin.x -= self.popupContentViewFrameForPopupStateOpen().minX
//            if closedFrame.origin.x < 0 {
//                closedFrame.origin.x = popupBar.shadowStackView.frame.minX
//            }
            
            stackViewForPresentation.frame = closedFrame
            stackViewForPresentation.alignment = .leading
            //stackViewForPresentation.titleLabel?.textAlignment = .left
            //stackViewForPresentation.subtitleLabel?.textAlignment = .left
            
        }
    }
    // MARK: - Bottom module
    
    private func configureBottomModuleInStartPosition()
    {
        guard let popupBar = self.presentingVC.popupBar else { return }
        guard popupBar.popupBarStyle == .prominent else { return }
        guard let imageViewForPresentation = self.imageViewForPresentation else { return }
        guard let imageView = self.popupContentView1.popupImageView else { return }
        guard let topModule = self.popupContentView1.popupTopModule else { return }
        guard let bottomModule = self.popupContentView1.popupBottomModule else { return }
        guard let bottomModuleTopConstraint = self.popupContentView1.popupBottomModuleTopConstraint else { return }
        
        if self.isPresenting {
            let openFrame = bottomModule.frame
            
            // Save the bottom module real position when open
            self.bottomModuleFrameForPopupStateOpen = openFrame
            
            // Move up bottom module just below imageForPresentation
            bottomModule.frame.origin.y = topModule.frame.origin.y + topModule.frame.height + bottomModuleTopConstraint.constant - (imageView.frame.size.height - imageViewForPresentation.frame.size.height)
        }
        else {
            if self.bottomModuleFrameForPopupStateOpen != .zero {
                bottomModule.frame = self.bottomModuleFrameForPopupStateOpen
            }
        }
    }
    
    internal func animateBottomModuleInFinalPosition()
    {
        guard let popupBar = self.presentingVC.popupBar else { return }
        guard popupBar.popupBarStyle == .prominent else { return }
        guard self.imageViewForPresentation != nil else { return }
        guard let topModule = self.popupContentView1.popupTopModule else { return }
        guard let bottomModule = self.popupContentView1.popupBottomModule else { return }
        guard let bottomModuleTopConstraint = self.popupContentView1.popupBottomModuleTopConstraint else { return }
        
        if self.isPresenting {
            // Animate bottom module frame to its open position
            bottomModule.frame = self.bottomModuleFrameForPopupStateOpen
        }
        else {
            bottomModule.frame.origin.y = topModule.frame.origin.y + topModule.frame.height + bottomModuleTopConstraint.constant
        }
    }
    
    private func configureBottomModuleInOriginalPosition()
    {
        guard let popupBar = self.presentingVC.popupBar else { return }
        guard popupBar.popupBarStyle == .prominent else { return }
        guard let bottomModule = self.popupContentView1.popupBottomModule else { return }
        
        if self.bottomModuleFrameForPopupStateOpen != .zero {
            bottomModule.frame = self.bottomModuleFrameForPopupStateOpen
        }
    }
    
    // MARK: - Helpers
    
    private func isCompactOrPhoneInLandscape() -> Bool
    {
        if self.traitCollection.verticalSizeClass == .compact {return true}
        let orientation = self.popupController.statusBarOrientation(for: self.popupController.containerViewController.view)
        return UIDevice.current.userInterfaceIdiom == .phone && (orientation == .landscapeLeft || orientation == .landscapeRight)
    }
    
    private func isRegularSizeClass() -> Bool
    {
        let orientation = self.popupController.statusBarOrientation(for: self.popupController.containerViewController.view)
        if orientation == .landscapeLeft || orientation == .landscapeRight {
            return self.traitCollection.horizontalSizeClass == .regular
        }
        else {
            return self.traitCollection.verticalSizeClass == .regular
        }
    }

    private func delay(_ delay:Double, closure:@escaping ()->())
    {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    private func _viewFor(_ view: UIView?, selfOrSuperviewKindOf aClass: AnyClass) -> UIView?
    {
        if view?.classForCoder == aClass {
            return view
        }
        var superview: UIView? = view?.superview
        while superview != nil {
            if superview?.classForCoder == aClass {
                return superview
            }
            superview = superview?.superview
        }
        return nil
    }
}

// MARK: - Custom views

extension PBPopupPresentationController
{
    internal class PBPopupDimmerView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    internal class PBPopupBlackView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
