//
//  DebugMenuViewController.swift
//  nhl-scores
//
//  Created by Alex King on 1/27/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit
import TinyConstraints
import RealmSwift

class DebugMenuViewController: UIViewController {
    
    private lazy var clearGamesButton: UIButton = {
        let button = UIButton()
        button.setTitle("Clear Games", for: .normal)
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.backgroundColor = .gray
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        button.addTarget(self, action: #selector(clearGamesTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        title = "Debug Menu"
        let exitButton = UIBarButtonItem(title: "Exit", style: .plain, target: self, action: #selector(exitButtonTapped))
        navigationItem.rightBarButtonItem = exitButton
    }
    
}

private extension DebugMenuViewController {
    
    func setupViews() {
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(clearGamesButton)
        clearGamesButton.translatesAutoresizingMaskIntoConstraints = false
        clearGamesButton.top(to: view, view.safeAreaLayoutGuide.topAnchor, offset: 12)
        clearGamesButton.left(to: view, offset: 12)
    }
    
    @objc
    func clearGamesTapped() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(Game.self))
        }
    }
    
    @objc
    func exitButtonTapped() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
