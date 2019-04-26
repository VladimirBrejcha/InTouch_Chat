//
//  LogInViewController.swift
//  InTouch chat
//
//  Created by Vladimir Brejcha on 25/04/2019.
//  Copyright @2019 Vladimir Korolev. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import ChameleonFramework


class LogInViewController: UIViewController, UITextFieldDelegate {

    private var keyboardSize = CGFloat() //keyboard size will be stored here
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    
    //MARK: - controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logInButton.layer.cornerRadius = 5
        passwordTextfield.delegate = self
        emailTextfield.delegate = self
        
        observersSetUp()
        
        hideKeyboardWhenTappedAround()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK:- Keyboard methods
    fileprivate func observersSetUp() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        if self.view.frame.origin.y == 0 { //checking if view frame is on default position
            guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
            let size = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.height
            keyboardSize = size //saving keyboard size to use it later in keyboardWillhide
            UIView.animate(withDuration: duration) {
                self.view.frame.origin.y -= self.keyboardSize / 2 - self.view.safeAreaInsets.bottom
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let userInfo = notification.userInfo!
        if self.view.frame.origin.y != 0 { //checking if view frame is on default position
            guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
            UIView.animate(withDuration: duration) {
                self.view.frame.origin.y += self.keyboardSize / 2 - self.view.safeAreaInsets.bottom
            }
        }
    }
    
    //MARK: - TextFieldDelegate methods
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextfield:
            passwordTextfield.becomeFirstResponder()
        case passwordTextfield:
            textField.resignFirstResponder()
        default:
            print("")
        }
        return true
    }
    
    //MARK: - login logic
    @IBAction func logInPressed(_ sender: AnyObject) {
        SVProgressHUD.show()
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if error != nil {
                    let alertController = UIAlertController(title: "Error", message: "Wrong email or password", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                } else {
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "goToChat", sender: self)
                }
            }
        }
    }
    
    
}  
