//
//  LogInViewController.swift
//  InTouch chat
//
//  Created by Vladimir Brejcha on 25/04/2019.
//  Copyright @2019 Vladimir Korolev. All rights reserved.
//
//deinit for observers

import UIKit
import Firebase
import SVProgressHUD
import ChameleonFramework


class LogInViewController: UIViewController, UITextFieldDelegate {

    private var keyboardSize = CGFloat()
    
    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        logInButton.layer.cornerRadius = 5
        logInButton.backgroundColor = UIColor.flatOrange()
        hideKeyboardWhenTappedAround()

        passwordTextfield.delegate = self
        emailTextfield.delegate = self
    }
    
    @objc func keyBoardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        if self.view.frame.origin.y == 0 {
            guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
            let size = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.height
            keyboardSize = size
            UIView.animate(withDuration: duration) {
                self.view.frame.origin.y -= self.keyboardSize / 2
            }
        }
        
    }
    
    @objc func keyBoardWillHide(notification: NSNotification) {
        let userInfo = notification.userInfo!
        if self.view.frame.origin.y != 0 {
            guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
            UIView.animate(withDuration: duration) {
                self.view.frame.origin.y += self.keyboardSize / 2
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextfield:
            passwordTextfield.becomeFirstResponder()
            return true
        case passwordTextfield:
            textField.resignFirstResponder()
        default:
            return true
        }
        return true
        
    }
   
    @IBAction func logInPressed(_ sender: AnyObject) {
        if passwordTextfield.text!.count < 6 { // force unwrap
            let alertController = UIAlertController(title: "Error", message: "Passwrod must be longer than 6 symbols long", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        } else {
            SVProgressHUD.show()
            //MARK: - Log in the user
            if let email = emailTextfield.text, let password = passwordTextfield.text {
                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    if error != nil {
                        let alertController = UIAlertController(title: "Error", message: "Wrong email or password", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                        alertController.addAction(okAction)
                        SVProgressHUD.dismiss()
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        print("success")
                        SVProgressHUD.dismiss()
                        self.performSegue(withIdentifier: "goToChat", sender: self)
                    }
                }
            }
        }
       
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    


    
}  
