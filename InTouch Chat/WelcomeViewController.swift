//
//  WelcomeViewController.swift
//  InTouch chat
//
//  Created by Vladimir Brejcha on 25/04/2019.
//  Copyright @2019 Vladimir Korolev. All rights reserved.
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
