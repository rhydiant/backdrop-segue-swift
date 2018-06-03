//
//  BackdropSegue.swift
//  PopoverSpike
//
//  Created by Rhydian Thomas on 3/6/18.
//  Copyright © 2018 Rhydian Thomas. All rights reserved.
//

import UIKit

///
/// A backdrop segue proving custom `UIStoryboardSegue`s to present
/// and dismiss a `UIViewController` using the backdrop UI pattern.
///
///   See https://material.io/design/components/backdrop.htm
///
/// Using storyboards, create a `custom` segue and assign the class
/// `BackdropPresentingSegue`. Create an unwind segue and assign the
/// class as `BackdropDismissSegue`.
///


// MARK: - BackdropPresentingSegue

class BackdropPresentingSegue: UIStoryboardSegue, UIViewControllerTransitioningDelegate {

    // MARK: - Override methods

    override func perform() {
        destination.modalPresentationStyle = .custom
        destination.transitioningDelegate = self
        source.present(destination, animated: true, completion: nil)
    }


    // MARK: - UIViewControllerTransitioningDelegate

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BackdropPresentingTransitionAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BackdropDismissingTransitionAnimator()
    }

}


// MARK: - BackdropDismissSegue

class BackdropDismissSegue: UIStoryboardSegue, UIViewControllerTransitioningDelegate {

    // MARK: - Override methods

    override func perform() {
        source.modalPresentationStyle = .custom
        source.transitioningDelegate = self
        source.dismiss(animated: true, completion: nil)
    }


    // MARK: - UIViewControllerTransitioningDelegate

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BackdropPresentingTransitionAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BackdropDismissingTransitionAnimator()
    }

}


// MARK: - BackdropPresentingTransitionAnimator

class BackdropPresentingTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    // MARK: - UIViewControllerAnimatedTransitioning

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view else {
            return
        }

        // set the intial state

        let containerView = transitionContext.containerView
        let height = containerView.frame.size.height - 200

        // add an overlay

        let overlay = UIView(frame: .zero)
        overlay.backgroundColor = .black
        containerView.addSubview(overlay)
        overlay.frame = containerView.bounds
        overlay.alpha = 0
        overlay.tag = 1001

        // add the toView

        containerView.addSubview(toView)

        toView.translatesAutoresizingMaskIntoConstraints = false
        toView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        toView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        toView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        toView.heightAnchor.constraint(equalToConstant: height).isActive = true

        // transform

        toView.transform = CGAffineTransform(translationX: 0, y: height)

        // corners

        toView.layer.cornerRadius = 16
        toView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]


        // animate to final state

        UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                       animations: {
                        overlay.alpha = 0.6
                        toView.transform = CGAffineTransform.identity
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }

}


// MARK: - BackdropDismissingTransitionAnimator

class BackdropDismissingTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    // MARK: - UIViewControllerAnimatedTransitioning

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view else {
            return
        }

        // set the intial state

        transitionContext.containerView.addSubview(fromView)
        fromView.transform = CGAffineTransform.identity

        // animate to final state

        UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        fromView.transform = CGAffineTransform(translationX: 0, y: fromView.frame.size.height)
                        if let overlay = transitionContext.containerView.viewWithTag(1001) {
                            overlay.alpha = 0
                        }
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

}
