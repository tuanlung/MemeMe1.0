//
//  EditViewController.swift
//  MemeMe
//
//  Created by Tuan-Lung Wang on 5/30/17.
//  Copyright © 2017 Tuan-Lung Wang. All rights reserved.
//

import UIKit

class EditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var takePhotoButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var snapshotView: UIView!
    
    
    // MARK: Properties
    var memeToSave: Meme? = nil
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var editingTextFieldTag: TextFieldTagEnum = .none
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initMemeTextAttributes()
        
        topTextField.delegate = self
        bottomTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        syncToCurrentMeme()
        updateButtonApperance()
        
        topTextField.defaultTextAttributes = appDelegate.memeTextAttributes
        bottomTextField.defaultTextAttributes = appDelegate.memeTextAttributes
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToTabBarController" {
            let destination = segue.destination as! UITabBarController
            destination.selectedIndex = appDelegate.currentViewStyle.rawValue
        }
    }

    
    // MARK: UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            appDelegate.currentMeme.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: View height adjustment with keyboard methods
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if editingTextFieldTag == .bottom {
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillDisappear(_ notification: Notification) {
        view.frame.origin.y = 0.0
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    
    // MARK: UITextFieldDelegate methods
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        
        // Need to re-apply the format in case textField was nil previously
        topTextField.defaultTextAttributes = appDelegate.memeTextAttributes
        bottomTextField.defaultTextAttributes = appDelegate.memeTextAttributes
        
        editingTextFieldTag = TextFieldTagEnum(rawValue: textField.tag)!
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        if TextFieldTagEnum(rawValue: textField.tag) == .top {
            appDelegate.currentMeme.topText = textField.text
        } else if TextFieldTagEnum(rawValue: textField.tag) == .bottom {
            appDelegate.currentMeme.bottomText = textField.text
        } else {
            print("incorrect textField tag detected")
        }
        editingTextFieldTag = TextFieldTagEnum.none
    }
    
    
    // MARK: IBActions
    @IBAction func takeAPicture(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        self.present(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func pickPhotoFromAlbum(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        if appDelegate.memes.isEmpty {
            appDelegate.currentMeme = AppDelegate.initMeme
            syncToCurrentMeme()
            updateButtonApperance()
        } else {
            self.performSegue(withIdentifier: "segueToTabBarController", sender: nil)
        }
    }

    @IBAction func share(_ sender: Any) {
        
        let memeImage = takeSnapshot()
        memeToSave = Meme(topText: topTextField.text, bottomText: bottomTextField.text, image: imageView.image, memeImage: memeImage)

        let activityViewController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = performSegueAfterSharing
        
        self.present(activityViewController, animated: true, completion: nil)
    }
}


extension EditViewController {
    
    func saveMeme(_ meme: Meme) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.memes.append(meme)
    }
    
    func updateButtonApperance() {
        takePhotoButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        cancelButton.isEnabled = appDelegate.memes.isEmpty ? (imageView.image != nil) : true
        shareButton.isEnabled = imageView.image != nil
    }
    
    func takeSnapshot() -> UIImage {
        
        UIGraphicsBeginImageContext(imageView.frame.size)

        // Shift the view-to-draw to the top-left of the picture
        let horizontalAdjustment = view.frame.minX - snapshotView.frame.minX
        let verticalAdjustment = view.frame.minY - snapshotView.frame.minY
        let snapshotRect = snapshotView.frame.offsetBy(dx: horizontalAdjustment, dy: verticalAdjustment)

        // Change the background color to white
        let originalBackgroundColor = snapshotView.backgroundColor
        snapshotView.backgroundColor = UIColor.white
        
        // Take snapshot of everything under snapshotView
        snapshotView.drawHierarchy(in: snapshotRect, afterScreenUpdates: true)
        
        // Change back the background color
        snapshotView.backgroundColor = originalBackgroundColor

        let memeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memeImage
    }
    
    func showToolbars(isHidden: Bool) {
        topToolbar.isHidden = isHidden
        bottomToolbar.isHidden = isHidden
    }
    
    func performSegueAfterSharing(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) {
        if completed {
            saveMeme(memeToSave!)
            
            self.performSegue(withIdentifier: "segueToTabBarController", sender: nil)
        }
    }
    
    func syncToCurrentMeme() {
        imageView.image = appDelegate.currentMeme.image
        topTextField.text = appDelegate.currentMeme.topText
        bottomTextField.text = appDelegate.currentMeme.bottomText
    }
    
    func initMemeTextAttributes() {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        appDelegate.memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 25)!,
            NSStrokeWidthAttributeName: -5,
            NSParagraphStyleAttributeName: style
        ]
    }
}

