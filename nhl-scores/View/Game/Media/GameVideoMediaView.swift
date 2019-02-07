//
//  GameVideoMediaView.swift
//  nhl-scores
//
//  Created by Alex King on 2/6/19.
//  Copyright © 2019 Alex King. All rights reserved.
//

import Foundation
import UIKit
import TinyConstraints
import ReactiveSwift
import ReactiveCocoa

class GameVideoMediaView: UIView {
    
    private let media: VideoMedia
    private let tapClosure: ((URL) -> Void)
    
    init(videoMedia: VideoMedia, tapClosure: @escaping ((URL) -> Void)) {
        self.media = videoMedia
        self.tapClosure = tapClosure
        super.init(frame: .zero)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.applyCardStyle()
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var imageView = UIImageView(contentMode: .scaleAspectFill)
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        return label
    }()
    
    private lazy var button = UIButton()
    
}

extension GameVideoMediaView {
    
    func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(cardView)
        cardView.edgesToSuperview(insets: TinyEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        
        cardView.addSubview(containerView)
        containerView.edgesToSuperview()
        
        containerView.addSubview(imageView)
        imageView.edgesToSuperview()
        imageView.widthToHeight(of: imageView, multiplier: (16/9))
        imageView.height(160)
        if let imageURL = media.thumbnailImageURL.flatMap({ URL(string: $0) }) {
            imageView.imageFromServerURL(imageURL.absoluteString)
        }
        
        addSubview(button)
        button.edgesToSuperview()
        
        button.reactive.controlEvents(.touchUpInside).observeValues { [weak self] _ in
            guard let self = self, let url = self.media.videoURL, let actualURL = URL(string: url) else {
                return
            }
            self.tapClosure(actualURL)
        }
    }
}
