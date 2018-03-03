//
//  ReactiveExt.swift
//  nhl-scores
//
//  Created by Alex King on 3/3/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import ReactiveCocoa

extension Reactive where Base: UIScrollView {
    
    /// Sets the scrollView's contentOffset.
    public var contentOffset: BindingTarget<CGPoint> {
        return makeBindingTarget { $0.contentOffset = $1 }
    }
    
}
