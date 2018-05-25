//
//  LoginViewController.swift
//  SeniorDesignProject2
//
//  Created by James Scherer on 10/20/17.
//  Copyright © 2017 James Scherer. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController : UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var bottomLayoutGuideConstraint: NSLayoutConstraint!
    
    // Mark: View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let userTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))

        view.addGestureRecognizer(userTap)
        
        NotificationCenter.default.addObserver(self, selector:  #selector(self.keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(self.keyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        if self.emailField.text == "" || self.passwordField.text == "" {
            
            let alertController = UIAlertController(title:"Error", message: "Please enter an email and password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            Firebase.Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: { (user, error) in
                if error == nil {
                    // Print into the console if the login is successful
                    
                    self.performSegue(withIdentifier: "LoginToChat", sender: nil)
                } else {
                    
                    // Tells the user that there is an error and then get firebase to tell them the error
                    
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
    }
    
    // MARK: - Notifications
    
    @objc func keyboardWillShowNotification(_ notification: Notification) {
        let keyboardEndFrame = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        bottomLayoutGuideConstraint.constant = view.bounds.maxY - convertedKeyboardEndFrame.minY
    }
    
    @objc func keyboardWillHideNotification(_ notification: Notification) {
        bottomLayoutGuideConstraint.constant = 48
    }
    
    // MARK: Navigation
    
    override  func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "LoginToChat" {
            let navVc = segue.destination as! UINavigationController
            let channelVc = navVc.viewControllers.first as! ChannelListViewController
        
            channelVc.senderDisplayName = emailField?.text
        } else if segue.identifier == "LoginToSignUp"{
            
        }
    }
    
    //Calls this function when the tap is recognized.
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
}
