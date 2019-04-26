//
//  ViewController.swift
//  InTouch chat
//
//  Created by Vladimir Brejcha on 25/04/2019.
//  Copyright @2019 Vladimir Korolev. All rights reserved.
//


import UIKit
import Firebase
import ChameleonFramework


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    private var messageArray = [Message]() //array to save messages while they are delivering to server
    private var keyboardSize = CGFloat() //saving keyboard size to use it later in keyboardWillhide
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    
    //MARK: - controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMessageView()
        
        retrieveMessages()
        
        setObservers()
        
        hideKeyboardWhenTappedAround()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: - View setup
    fileprivate func setMessageView() {
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTableView.allowsSelection = false
        messageTableView.separatorStyle = .none
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 12.0
        
        messageTableView.register(UINib(nibName: "CustomMessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        messageTableView.register(UINib(nibName: "MyMessageViewCell", bundle: nil), forCellReuseIdentifier: "myMessageViewCell")
        
        messageTextfield.delegate = self
        
        navigationItem.hidesBackButton = true
    }
    
    //MARK:- Keyboard methods
    fileprivate func setObservers() {
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
                self.view.frame.origin.y -= self.keyboardSize - self.view.safeAreaInsets.bottom
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let userInfo = notification.userInfo!
        if self.view.frame.origin.y != 0 { //checking if view frame is on default position
            guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
            UIView.animate(withDuration: duration) {
                self.view.frame.origin.y += self.keyboardSize - self.view.safeAreaInsets.bottom
            }
        }
    }
    
    //MARK: - TableView DataSource Methods
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        let myCell = tableView.dequeueReusableCell(withIdentifier: "myMessageViewCell", for: indexPath) as! MyMessageViewCell
        
        //checking which user is logged in to separate his messages from others messages
        if messageArray[indexPath.row].sender == Auth.auth().currentUser?.email as String? {
            myCell.messageBody.text = messageArray[indexPath.row].messageBody
            myCell.senderUsername.text = messageArray[indexPath.row].sender
            myCell.backgroundViewWidth.constant =  self.view.frame.width / 3
            return myCell
        } else {
            cell.messageBody.text = messageArray[indexPath.row].messageBody
            cell.senderUsername.text = messageArray[indexPath.row].sender
            cell.backgroundViewWidth.constant = self.view.frame.width / 3
            return cell
        }
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    //this function used to scroll tableview to the last message
    private func scrollToBottom()  {
        let indexPath = IndexPath(row: messageTableView.numberOfRows(inSection: 0) - 1, section: 0)
        self.messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        self.view.layoutIfNeeded()
    }
    
    //MARK: - Send & Recieve from Firebase
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false //blocking possibility to send new messages if old one is not sent yet
        
        let messagesDataBase = Database.database().reference().child("Messages")
        let messageDictionary = ["Sender" : Auth.auth().currentUser?.email, "Message" : messageTextfield.text]
        
        if messageTextfield.text == "" { //blocking empty messages
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
            }
        }
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendPressed(sendButton)
        return true
    }
    
    private func retrieveMessages() {
        
        //creating a context with messages
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
            self.scrollToBottom()
        }
    }
    
    //MARK: - Log out logic
    @IBAction func logOutPressed(_ sender: AnyObject) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Error \(error.localizedDescription)")
        }
    }
    
    
}
