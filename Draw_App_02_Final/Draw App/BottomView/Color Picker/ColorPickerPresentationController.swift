//
//  ColorPickerPresentationController.swift
//  Draw App
//
//  Created by Bogdan Redkin on 20/10/2022.
//

import UIKit

class ColorPickerPresentationController: UIPresentationController {
    
    private let interactor = UIPercentDrivenInteractiveTransition()
    private var isInteractive = false
    private var propertyAnimator: UIViewPropertyAnimator!
    private var bottomConstraint: NSLayoutConstraint?
    private weak var scrollView: UIScrollView?

    let backgroundView: UIView = {
        let backgroundView = UIView(frame: .zero)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return backgroundView
    }()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var bounds = presentingViewController.view.bounds
        bounds.size.height = bounds.height / 4 * 3
        let origin = CGPoint(x: 0, y: presentingViewController.view.bounds.height - bounds.size.height)
        return CGRect(origin: origin, size: bounds.size)
    }
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, scrollView: UIScrollView) {
        self.scrollView = scrollView
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        registerForKeyboardNotifications()
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppearHandler(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppearHandler(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        guard let containerView = containerView else { return }
        
        if let presentedView {
            containerView.addSubview(presentedView)

            presentedView.pinToSuperviewEdgesWithInsets(left: .zero, right: .zero)
            bottomConstraint = presentedView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: frameOfPresentedViewInContainerView.height)
            bottomConstraint?.isActive = true
            presentedView.heightAnchor.constraint(equalToConstant: frameOfPresentedViewInContainerView.height).isActive = true
            presentedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            presentedView.layer.cornerRadius = 10
            
            containerView.layoutIfNeeded()
        }
        
        backgroundView.frame = containerView.bounds
        containerView.insertSubview(backgroundView, at: 0)
        backgroundView.pinToSuperviewEdges()
        backgroundView.alpha = 0

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandled))
        presentedView?.addGestureRecognizer(panGesture)
        panGesture.cancelsTouchesInView = false
        panGesture.delegate = self
        scrollView?.panGestureRecognizer.addTarget(self, action: #selector(panGestureHandled))
        scrollView?.panGestureRecognizer.cancelsTouchesInView = false
                        
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureHandled)))

        self.bottomConstraint?.constant = .zero
        
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            containerView.layoutIfNeeded()
            self.backgroundView.alpha = 1
        }, completion: nil)
    }

    
    @objc private func keyboardAppearHandler(notification: NSNotification) {
        guard
            let bottomConstraint = bottomConstraint,
            let presentedView = presentedView,
            let textInput = presentedView.findFirstResponder(),
            let textInputFrame = textInput.superview?.convert(textInput.frame, to: presentedView.superview)
        else {
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else {
                return
            }
                        
            let keyboardOverlap = textInputFrame.maxY - keyboardFrame.minY + 20
            if keyboardOverlap > 0 {
                bottomConstraint.constant = -max(presentedView.frame.minY - keyboardOverlap, frameOfPresentedViewInContainerView.origin.y)
            }
        } else if notification.name == UIResponder.keyboardWillHideNotification {
            bottomConstraint.constant = .zero
        }
    }
    
    @objc func tapGestureHandled(_ gesture: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true)
    }
    
    @objc func panGestureHandled(_ gesture: UIPanGestureRecognizer) {
        guard let containerView else { return }
                
        updateScrollViewOffset(gesture)
        let translation = gesture.translation(in: containerView)
        
        let percent = translation.y / containerView.bounds.height
        
        switch gesture.state {
        case .began:
            if !presentedViewController.isBeingDismissed {
                isInteractive = true
                presentedViewController.dismiss(animated: true)
            }
        case .changed:
            interactor.update(percent)
        case .cancelled:
            interactor.cancel()
            isInteractive = false
        case .ended:
            let velocity = gesture.velocity(in: containerView).y
            interactor.completionSpeed = 0.9
            if percent > 0.3 || velocity > 1600 {
                interactor.finish()
            } else {
                interactor.cancel()
            }
            isInteractive = false
        default:
            break
        }
    }
    
    private func updateScrollViewOffset(_ gesture: UIPanGestureRecognizer) {
        guard let scrollView = scrollView else { return }
        if interactor.percentComplete > 0 {
            scrollView.contentOffset.y = -scrollView.adjustedContentInset.top
        }
    }
    
    override func dismissalTransitionWillBegin() {
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.backgroundView.alpha = 0
        })
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        propertyAnimator = nil
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
                
        if propertyAnimator != nil && !propertyAnimator.isRunning {
            presentedView?.frame = frameOfPresentedViewInContainerView
            presentedView?.layoutIfNeeded()
        }
    }
}

extension ColorPickerPresentationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        interruptibleAnimator(using: transitionContext).startAnimation()
    }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        propertyAnimator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext),
                                                  timingParameters: UISpringTimingParameters(dampingRatio: 1.0,
                                                                                            initialVelocity: CGVector(dx: 1, dy: 1)))

        bottomConstraint?.constant = presentedViewController.isBeingPresented ? .zero : frameOfPresentedViewInContainerView.height

        propertyAnimator.addAnimations { [unowned self] in
            if self.presentedViewController.isBeingPresented {
                transitionContext.view(forKey: .to)?.frame = self.frameOfPresentedViewInContainerView
                transitionContext.view(forKey: .to)?.layoutIfNeeded()
            } else {
                transitionContext.view(forKey: .from)?.frame.origin.y = transitionContext.containerView.frame.maxY
                transitionContext.view(forKey: .from)?.layoutIfNeeded()
            }
        }
        propertyAnimator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        return propertyAnimator
    }
}

extension ColorPickerPresentationController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        self
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        isInteractive ? interactor : nil
    }
}
 
extension ColorPickerPresentationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer, let containerView else { return true }
        let velocity = panGesture.velocity(in: containerView)
        return abs(velocity.y) > abs(velocity.x)
    }
}
