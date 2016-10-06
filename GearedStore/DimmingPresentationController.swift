//
//  DimmingPresentationController.swift
//  GearedStore
//
//  Created by Nishant Punia on 20/09/16.
//  Copyright © 2016 MLBNP. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    
    lazy var dimmingView = GradientView(frame: CGRect.zero)
    
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView!.bounds
        containerView?.insertSubview(dimmingView, at: 0)
        
        dimmingView.alpha = 0
        if let transitionCoordinator = presentedViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 1
                }, completion: nil)
        }
        
        func dismissalTransitionWillBegin() {
            if let transitionCoordinator =
            presentedViewController.transitionCoordinator { transitionCoordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
            }, completion: nil)
            }
        }
    }

    override var shouldRemovePresentersView: Bool {
        return false
    }
}
