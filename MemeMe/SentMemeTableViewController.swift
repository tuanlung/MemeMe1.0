//
//  SentMemeTableViewController.swift
//  MemeMe
//
//  Created by Tuan-Lung Wang on 5/30/17.
//  Copyright © 2017 Tuan-Lung Wang. All rights reserved.
//

import Foundation
import UIKit

class SentMemeTableViewController: UITableViewController {
    
    // MARK: Properties
    var memes = [Meme]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        memes = appDelegate.memes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.currentViewStyle = .tableView
        tabBarController?.tabBar.isHidden = false
    }
    
    
    // MARK: Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        appDelegate.currentMeme = appDelegate.memes[indexPath.row]
        let showMemeViewController = self.storyboard?.instantiateViewController(withIdentifier: "ShowMemeViewController")
        navigationController?.pushViewController(showMemeViewController!, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! MemeTableViewCell
        cell.customTextLabel!.text = memes[indexPath.row].topText + "..." + memes[indexPath.row].bottomText
        cell.customImageView?.image = memes[indexPath.row].image
        
        let topText = memes[indexPath.row].topText!
        let bottomText = memes[indexPath.row].bottomText!
        var textAttribute = appDelegate.memeTextAttributes
        textAttribute[NSFontAttributeName] = UIFont(name: "HelveticaNeue-CondensedBlack", size: 12)!
        
        cell.topLabel.attributedText = NSAttributedString(string: topText, attributes: textAttribute)
        cell.bottomLabel.attributedText = NSAttributedString(string: bottomText, attributes: textAttribute)
        
        return cell
    }
    
    
    // MARK: IBActions
    @IBAction func addMeme(_ sender: Any) {
        appDelegate.currentMeme = AppDelegate.initMeme
        dismiss(animated: true, completion: nil)
    }
    
}
