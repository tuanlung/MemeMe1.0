//
//  SentMemeCollectionViewController.swift
//  MemeMe
//
//  Created by Tuan-Lung Wang on 5/30/17.
//  Copyright © 2017 Tuan-Lung Wang. All rights reserved.
//

import Foundation
import UIKit

class SentMemeCollectionViewController: UICollectionViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    
    // MARK: Properties
    var memes = [Meme]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        memes = appDelegate.memes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        appDelegate.currentViewStyle = .collectionView
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let space:CGFloat = 3.0
        let shorterSide = min(view.frame.size.width, view.frame.size.height)
        let dimension = (shorterSide - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        
        //verticalConstraintForTopLabel.constant = dimension/5
    }
    
    
    // MARK: Collection View Delegate Methods
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        appDelegate.currentMeme = appDelegate.memes[indexPath.row]
        let showMemeViewController = self.storyboard?.instantiateViewController(withIdentifier: "ShowMemeViewController") as! UIViewController
        navigationController?.pushViewController(showMemeViewController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! MemeCollectionViewCell
        cell.imageView.image = memes[indexPath.row].image
        
        // Text contents and format
        let topText = memes[indexPath.row].topText!
        let bottomText = memes[indexPath.row].bottomText!
        var textAttribute = appDelegate.memeTextAttributes
        textAttribute[NSFontAttributeName] = UIFont(name: "HelveticaNeue-CondensedBlack", size: flowLayout.itemSize.height/8)!
        
        cell.topLabel.attributedText = NSAttributedString(string: topText, attributes: textAttribute)
        cell.bottomLabel.attributedText = NSAttributedString(string: bottomText, attributes: textAttribute)
        
        // Adjust text position based on cell size
        let verticalMarginForLabel = flowLayout.itemSize.height / 5
        cell.verticalConstraintForTopLabel.constant = -verticalMarginForLabel
        cell.verticalConstraintForBottomLabel.constant = -verticalMarginForLabel
        
        
        return cell
    }
 
    
    // MARK: IBActions
    @IBAction func addMeme(_ sender: Any) {
        appDelegate.currentMeme = AppDelegate.initMeme
        dismiss(animated: true, completion: nil)
    }
}
