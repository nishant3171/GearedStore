//
//  FadeOutController.swift
//  GearedStore
//
//  Created by Nishant Punia on 04/10/16.
//  Copyright © 2016 MLBNP. All rights reserved.
//

import UIKit

class FadeOutController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) {
            let duration = transitionDuration(using: transitionContext)
            
            UIView.animate(withDuration: duration, animations: { 
                fromView.alpha = 0
                }, completion: { (finished) in
                    transitionContext.completeTransition(finished)
            })
        }
    }
}
