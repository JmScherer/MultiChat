//
//  SignUpViewController.swift
//  
//
//  Created by James Scherer on 3/10/18.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signUpButtonOutlet: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let userTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        view.addGestureRecognizer(userTap)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func signUpButtonPressed(_ sender: Any) {
        if self.emailField.text == "" || self.passwordField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title:"OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            
            Firebase.Auth.auth().createUser(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: { (user, error) in
                
                if error == nil {
                    print("you have successfully signed up!")
                    
                    self.performSegue(withIdentifier: "SignUpToChat", sender: nil)
                    
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            })
            
        }
        
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for:segue, sender: sender)
        
        if segue.identifier == "SignUpToChat" {
            let navVc = segue.destination as! UINavigationController
            let channelVc = navVc.viewControllers.first as! ChannelListViewController
            
            channelVc.senderDisplayName = emailField?.text
        }
        
    }
 
    //Calls this function when the tap is recognized.
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        emailField.resignFirstResponder();
        passwordField.resignFirstResponder();
    }

    
    
}
