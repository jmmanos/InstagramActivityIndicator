//
//  ViewController.swift
//  InstagramActivityIndicator
//
//  Created by John Manos on 2/3/17.
//  Copyright © 2017 John Manos. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBAction func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let indicator = recognizer.view as? InstagramActivityIndicator else { return }
        
        if indicator.isAnimating {
            indicator.stopAnimating()
        } else {
            indicator.startAnimating()
        }
    }
}

