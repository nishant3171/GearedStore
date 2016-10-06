//
//  SlideOutAnimationController.swift
//  GearedStore
//
//  Created by Nishant Punia on 03/10/16.
//  Copyright © 2016 MLBNP. All rights reserved.
//

import UIKit

class SlideOutAnimationController: NSObject,UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        if let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) {
            
            let duration = transitionDuration(using: transitionContext)
            
            UIView.animate(withDuration: duration, animations: {
                fromView.center.y -= containerView.bounds.size.height
                fromView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                }, completion: { (finished) in
                    transitionContext.completeTransition(finished)
            })
        }
        
    }
}
