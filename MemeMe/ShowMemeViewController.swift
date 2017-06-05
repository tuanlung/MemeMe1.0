//
//  ShowMemeViewController.swift
//  MemeMe
//
//  Created by Tuan-Lung Wang on 6/1/17.
//  Copyright © 2017 Tuan-Lung Wang. All rights reserved.
//

import Foundation
import UIKit

class ShowMemeViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        imageView.image = appDelegate.currentMeme.memeImage
        tabBarController?.tabBar.isHidden = true
    }
    
    
    // MARK: IBActions
    @IBAction func editButtonTapped(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
