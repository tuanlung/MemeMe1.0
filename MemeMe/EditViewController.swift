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
    @IBOutlet weak var constraintForTopText: NSLayoutConstraint!
    @IBOutlet weak var constraintForBottomText: NSLayoutConstraint!
    
    // MARK: Properties
    var memeToSave: Meme? = nil
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var editingTextFieldTag: TextFieldTagEnum = .none
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initMemeTextAttributes()
        resetImageAndText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateButtonApperance()
        applyTextFormat()
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTextPosition()
    }
    
    
    // MARK: UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            imageView.image = image
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
        applyTextFormat()
        
        editingTextFieldTag = TextFieldTagEnum(rawValue: textField.tag)!
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        editingTextFieldTag = TextFieldTagEnum.none
        return true
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
        resetImageAndText()
        updateButtonApperance()
    }
    
    @IBAction func share(_ sender: Any) {
        
        let memeImage = takeSnapshot()
        
        memeToSave = Meme(topText: topTextField.text, bottomText: bottomTextField.text, image: imageView.image, memeImage: memeImage)
        
        let activityViewController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        
        // ipad needs to present it as a popover
        activityViewController.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        
        activityViewController.completionWithItemsHandler = saveMeme
        
        self.present(activityViewController, animated: true, completion: nil)
    }
}


extension EditViewController {
    
    // MARK: Helper functions
    func saveMeme(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) {
        if !completed {
            return
        }
        
        if let meme = memeToSave {
            appDelegate.memes.append(meme)
        }
    }
    
    func updateButtonApperance() {
        takePhotoButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = (imageView.image != nil)
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
    
    func initMemeTextAttributes() {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        appDelegate.memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 45)!,
            NSStrokeWidthAttributeName: -5,
            NSParagraphStyleAttributeName: style
        ]
    }
    
    func applyTextFormat() {
        topTextField.defaultTextAttributes = appDelegate.memeTextAttributes
        bottomTextField.defaultTextAttributes = appDelegate.memeTextAttributes
    }
    
    func resetImageAndText() {
        imageView.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
    }
    
    func updateTextPosition() {
        let height: CGFloat = snapshotView.frame.height
        var distance: CGFloat = 0.0
        
        if UIApplication.shared.statusBarOrientation.isPortrait {
            distance = height * 0.075
        } else {
            distance = height * 0.01
        }
        
        constraintForTopText.constant = distance
        constraintForBottomText.constant = distance
    }
}

