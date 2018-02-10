//
//  LineView.swift
//  nhl-scores
//
//  Created by Alex King on 2/10/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit
import TinyConstraints

fileprivate enum Constants {
    static let defaultBackgroundColor = UIColor(hexString: "#C7C7CC")
}

class HorizontalLineView: UIView {
    
    init() {
        super.init(frame: .zero)
        height(UIScreen.scalePointSize)
        backgroundColor = Constants.defaultBackgroundColor
        setContentHuggingPriority(.required, for: .vertical)
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class VerticalLineView: UIView {
    
    init() {
        super.init(frame: .zero)
        width(UIScreen.scalePointSize)
        backgroundColor = Constants.defaultBackgroundColor
        setContentHuggingPriority(.required, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
