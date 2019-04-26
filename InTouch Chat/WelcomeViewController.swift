//
//  WelcomeViewController.swift
//  InTouch chat
//
//  Created by Vladimir Brejcha on 25/04/2019.
//  Copyright @2019 Vladimir Korolev. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase


class WelcomeViewController: UIViewController {

    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var creditsImageView: UIImageView!
    @IBOutlet weak var backgroundView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //remember user
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "goToChat", sender: self)
        }
    }
    @IBAction func creditsButtonPressed(_ sender: Any) {
        if creditsImageView.isHidden == true {
            creditsImageView.isHidden = false
            backgroundView.alpha = 0.5
        } else {
            creditsImageView.isHidden = true
            backgroundView.alpha = 0.85
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
