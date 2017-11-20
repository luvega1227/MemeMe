//
//  MemeEditorVC.swift
//  MemeMe
//
//  Created by Luis Vega on 1/19/17.
//  Copyright © 2017 Vega. All rights reserved.
//

import UIKit

class MemeEditorVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var cameraButtonItem: UIBarButtonItem!
    @IBOutlet weak var albumButtonItem: UIBarButtonItem!
    @IBOutlet weak var shareButton : UIBarButtonItem!
    @IBOutlet weak var memeImage: UIImageView!
    @IBOutlet weak var upperTextView: MemeTextField!
    @IBOutlet weak var lowerTextView: MemeTextField!
    @IBOutlet weak var navbar : UINavigationBar!
    @IBOutlet weak var toolbar : UIToolbar!
    
    
    // MARK: App Lifecycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setup delegate for text views
        lowerTextView.delegate = self
        upperTextView.delegate = self
        
        //Share button starts disabled
        shareButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        //Check if the camera exists
        cameraButtonItem.isEnabled = MemeMeUtils.isCameraAvailable()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    
    // MARK: Buttons Pressed
    
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        MemeMeUtils.openCamera(sourceController: self, delegate: self)
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        let model = MemeModel(
            upperText: upperTextView.text!,
            lowerText: lowerTextView.text!,
            backgroundImage: memeImage.image!,
            memeImage: produceImage()
        )
        
        let activityViewController = UIActivityViewController(activityItems: [model.memeImage], applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.save()
                self.dismiss(animated: true, completion: nil)
            }
        }

        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        memeImage.image = nil
        shareButton.isEnabled = false
    }
    
    @IBAction func albumButtonPressed(_ sender: Any) {
        MemeMeUtils.openImageGallery(sourceController: self, delegate: self)
    }
    
    
    // MARK: MemeMe Image
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            memeImage.image = selectedImage
            shareButton.isEnabled = true
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func produceImage() -> UIImage! {
        toolbar.isHidden = true
        navbar.isHidden = true
        
        // Render view to an image
        let generatedImage = MemeMeUtils.renderScreenToImage(view: self.view)
        
        toolbar.isHidden = false
        navbar.isHidden = false
        
        return generatedImage
    }
    
    func save() {
        _ = MemeModel(upperText: upperTextView.text!, lowerText: lowerTextView.text!, backgroundImage: memeImage.image!, memeImage: produceImage())
    }

    
    // MARK: Keyboard Notifications
    
    
    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        //Only makes the UI to go up when edditing the bottom text
        if lowerTextView.isEditing {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    private func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    
    // MARK: TextField Delegate
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //If the text field is in pristine state (i.e. still have the original value),
        //then we clear the text.
        if let memeTextField = textField as? MemeTextField {
            if memeTextField.isPristine {
                memeTextField.text = ""
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if let memeTextField = textField as? MemeTextField {
            if memeTextField.text!.isEmpty {
                memeTextField.restorePristine()
            } else {
                memeTextField.isPristine = false
            }
        }
    }
    
    //To hide the status bar
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
}
