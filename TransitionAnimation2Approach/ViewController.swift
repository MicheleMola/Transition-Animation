//
//  ViewController.swift
//  TransitionAnimation2Approach
//
//  Created by Michele Mola on 20/04/2019.
//  Copyright © 2019 Michele Mola. All rights reserved.
//

import UIKit

enum DraggablePosition {
  case collapsed
  case open
  
  var heightmultiplier: CGFloat {
    switch self {
    case .collapsed: return 1
    case .open: return 0
    }
  }
  
  func yOrigin(for maxHeight: CGFloat) -> CGFloat {
    return maxHeight - (maxHeight * heightmultiplier)
  }
}

class ViewController: UIViewController {
  
  @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
  
  private var animator: UIViewPropertyAnimator?
  private var panOnPresented = UIGestureRecognizer()
  private var draggablePosition: DraggablePosition = .collapsed
  
  private var canDragIn = true
  
  private let VIEW_HEIGHT: CGFloat = 260
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
  }
  
  private func setupView() {
    animator = UIViewPropertyAnimator(duration: 0.4, curve: .linear)
    animator?.isInterruptible = true
    panOnPresented = UIPanGestureRecognizer(target: self, action: #selector(userDidPan(panRecognizer:)))
    self.view.addGestureRecognizer(panOnPresented)
  }
  
  @objc private func userDidPan(panRecognizer: UIPanGestureRecognizer) {
    
    let translationPoint = panRecognizer.translation(in: self.view)
    let currentOriginY = draggablePosition.yOrigin(for: self.VIEW_HEIGHT)
    
    let newOffset = currentOriginY + translationPoint.y
    
    if canDragIn {
      switch panRecognizer.state {
      case .changed, .began:
        self.viewHeightConstraint.constant = newOffset <= 0 ? 0 : newOffset
        self.view.layoutIfNeeded()
        
      case .ended:
        canDragIn = false
        animate(newOffset)
      default: break
      }

    }
    
  }
  
  private func animate(_ offset: CGFloat) {
    
    if offset > VIEW_HEIGHT/2 {
      animate(to: .open)
    } else {
      animate(to: .collapsed)
    }
  }
  
  private func animate(to position: DraggablePosition) {
    
    guard let animator = animator else { return }
    
    animator.addAnimations {
      self.viewHeightConstraint.constant = position.yOrigin(for: self.VIEW_HEIGHT)
      self.view.layoutIfNeeded()
    }
    
    animator.addCompletion { animatingPosition in
      if animatingPosition == .end {
        self.draggablePosition = position
        self.canDragIn = true
      }
    }
    
    animator.startAnimation()
  }
  
}

