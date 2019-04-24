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
        
        setMessageView()
        
        retrieveMessages()
        
        setObservers()
        
        hideKeyboardWhenTappedAround()
    }
    
    
    fileprivate func setObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    fileprivate func setMessageView() {
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapRecognizer)
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTableView.separatorStyle = .none
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 12.0
        
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        messageTableView.register(UINib(nibName: "MyMessageViewCell", bundle: nil), forCellReuseIdentifier: "myMessageViewCell")
        
        navigationItem.hidesBackButton = true
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
        let myCell = tableView.dequeueReusableCell(withIdentifier: "myMessageViewCell", for: indexPath) as! CustomMessageCell
        
        //checking which user is logged in to separate his messages from others messages
        if messageArray[indexPath.row].sender == Auth.auth().currentUser?.email as String? {
            myCell.messageBody.text = messageArray[indexPath.row].messageBody
            myCell.senderUsername.text = messageArray[indexPath.row].sender
            return myCell
        } else {
            cell.messageBody.text = messageArray[indexPath.row].messageBody
            cell.senderUsername.text = messageArray[indexPath.row].sender
            return cell
        }
    }
    
    
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    //this function is used to block table view cell from being selected
    @objc func tableViewTapped(sender: UIGestureRecognizer) {
        messageTextfield.endEditing(true)
    }
    
    
    //MARK: - Send & Recieve from Firebase
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDataBase = Database.database().reference().child("Messages")
        let messageDictionary = ["Sender" : Auth.auth().currentUser?.email, "Message" : messageTextfield.text]
        
        if messageTextfield.text == "" {
            self.messageTextfield.isEnabled = true
            self.sendButton.isEnabled = true
            return
        }
        
        messagesDataBase.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            if error != nil {
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                
                let alertController = UIAlertController(title: "Error", message: "Smth went wrong:( Try again later", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
                print(error!)
            } else {
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
                let lastRow: Int = self.messageTableView.numberOfRows(inSection: 0) - 1
                let indexPath = IndexPath(row: lastRow, section: 0)
                self.messageTableView.scrollToRow(at: indexPath, at: .none, animated: true)
            }
        }
    }
    
    private func retrieveMessages() {
        
        //finding a context with messages
        let messageDataBase = Database.database().reference().child("Messages")
        
        //listening to data changes in context
        messageDataBase.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! [String : String]
            let messageText = snapshotValue["Message"]!
            let sender = snapshotValue["Sender"]!
            
            let messageObject = Message()
            messageObject.messageBody = messageText
            messageObject.sender = sender
            
            self.messageArray.append(messageObject)
            
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
