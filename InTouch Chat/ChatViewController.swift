//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    private var messageArray = [Message]()
    private var keyboardSize = CGFloat()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTextfield.delegate = self
        navigationItem.hidesBackButton = true
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapRecognizer)
        
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        retrieveMessages()
        messageTableView.separatorStyle = .none
        
        hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    //MARK: - Moving view on Keyboard frame changing
    @objc func keyBoardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
        let size = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.height
        keyboardSize = size
        UIView.animate(withDuration: duration) {
            self.view.frame.origin.y -= self.keyboardSize
        }
    }
    
    @objc func keyBoardWillHide(notification: NSNotification) {
        let userInfo = notification.userInfo!
        guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
        UIView.animate(withDuration: duration) {
            self.view.frame.origin.y += self.keyboardSize
        }
    }
    
    //MARK: - TableView DataSource Methods
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String? {
            cell.messageBackground.backgroundColor = UIColor.flatOrange()
            cell.leftConstraint.constant = 45
        } else {
            cell.messageBackground.backgroundColor = UIColor.flatNavyBlue()
            cell.rightConstraint.constant = 45
        }
        
        return cell
    }
    
    
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped(sender: UIGestureRecognizer) {
        messageTextfield.endEditing(true)
        
    }
    
    
    //TODO: Declare configureTableView here:
    private func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 12.0
    }
    
    //MARK:- TextField Delegate Methods

//    internal func textFieldDidBeginEditing(_ textField: UITextField) {
//        UIView.animate(withDuration: 0.5) {
//            self.heightConstraint.constant = 308
//            self.view.layoutIfNeeded()
//        }
//    }
//
//    internal func textFieldDidEndEditing(_ textField: UITextField) {
//        UIView.animate(withDuration: 0.5) {
//            self.heightConstraint.constant = 50
//            self.view.layoutIfNeeded()
//        }
//
//
//    }
    
    //MARK: - Send & Recieve from Firebase
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        
        let messageDictionary = ["Sender" : Auth.auth().currentUser?.email, "Message" : messageTextfield.text]
        
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            if error != nil {
                print(error!)
            } else {
                print("message saved")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
    }
    
    private func retrieveMessages() {
        let messageDB = Database.database().reference().child("Messages")
        
        messageDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! [String : String]
            let text = snapshotValue["Message"]!
            let sender = snapshotValue["Sender"]!
            
            let messageObject = Message()
            messageObject.messageBody = text
            messageObject.sender = sender
            
            self.messageArray.append(messageObject)
            
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Error \(error.localizedDescription)")
        }
    }
    


}
