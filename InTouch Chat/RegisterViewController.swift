//
//  RegisterViewController.swift
//  InTouch chat
//
//  Created by Vladimir Brejcha on 25/04/2019.
//  Copyright @2019 Vladimir Korolev. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import ChameleonFramework


class RegisterViewController: UIViewController, UITextFieldDelegate {

    private var keyboardSize = CGFloat() //keyboard size will be stored here

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    
    //MARK: - controller life cycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerButton.layer.cornerRadius = 5
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
    
    //MARK: - registration logic
    @IBAction func registerPressed(_ sender: AnyObject) {
        if passwordTextfield.text!.count < 6 { // checking for password to be longer than 6 symbols
            let alertController = UIAlertController(title: "Error", message: "Password must be longer than 6 symbols long", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        } else {
            SVProgressHUD.show()
            Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
                if error != nil {
                    print(error!)
                    let alertController = UIAlertController(title: "Error", message: "Enter correct email", preferredStyle: .alert)
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
