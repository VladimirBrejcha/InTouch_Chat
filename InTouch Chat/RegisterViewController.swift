//
//  RegisterViewController.swift
//  Flash Chat
//
//  This is the View Controller which registers new users with Firebase
//

import UIKit
import Firebase
import SVProgressHUD
import ChameleonFramework


class RegisterViewController: UIViewController, UITextFieldDelegate {

    private var keyboardSize = CGFloat()
    
    //Pre-linked IBOutlets

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        registerButton.layer.cornerRadius = 5
        registerButton.backgroundColor = UIColor.flatOrange()
        passwordTextfield.delegate = self
        emailTextfield.delegate = self
        hideKeyboardWhenTappedAround()
    }
    
    @objc func keyBoardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let beginFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.origin.y
        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.origin.y
        if endFrame == beginFrame {
            return
        }
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
        let size = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.height
        keyboardSize = size
        UIView.animate(withDuration: duration) {
            self.view.frame.origin.y -= size / 2
        }
        
        
    }
    
    @objc func keyBoardWillHide(notification: NSNotification) {
        let userInfo = notification.userInfo!
        guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
        UIView.animate(withDuration: duration) {
            self.view.frame.origin.y += self.keyboardSize / 2
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


    
    @IBAction func registerPressed(_ sender: AnyObject) {
        if passwordTextfield.text!.count < 6 { // force unwrap
            let alertController = UIAlertController(title: "Error", message: "Passwrod must be longer than 6 symbols long", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        } else {
            SVProgressHUD.show()
            Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
                
                if error != nil {
                    print(error!)
                } else {
                    SVProgressHUD.dismiss()
                    print("success")
                    self.performSegue(withIdentifier: "goToChat", sender: self)
                }
            }
        }
    } 
    
    @IBAction func rememberMeToggled(_ sender: UISwitch) {
        
    }
    
}
