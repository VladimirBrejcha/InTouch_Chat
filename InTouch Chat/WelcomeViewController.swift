//
//  WelcomeViewController.swift
//  Flash Chat
//
//  This is the welcome view controller - the first thign the user sees
//

import UIKit
import ChameleonFramework


class WelcomeViewController: UIViewController {

    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.backgroundColor = UIColor.flatOrange()
        logInButton.backgroundColor = UIColor.flatNavyBlue()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
