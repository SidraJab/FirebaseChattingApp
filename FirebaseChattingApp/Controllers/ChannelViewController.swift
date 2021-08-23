//
//  ChannelViewController.swift
//  FirebaseChattingApp
//
//  Created by Sidra Jabeen on 15/08/2021.
//

import UIKit
import Firebase

class user{
    var name = ""
    var id = ""
    var rowValue = false
}

class ChannelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var tblMessages: UITableView!
    @IBOutlet weak var viewAddBtn: UIView!
    
    //MARK: - Propertites
    
//    var user: [User] = []
    var users = [user]()
    var currentChannelAlertController: UIAlertController?
    var name: String?
    var channel: User?
    var selectedUserId: String?
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logoutBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logoutUser))
        self.navigationItem.rightBarButtonItem  = logoutBarButtonItem
        self.navigationItem.hidesBackButton = true
        
        viewAddBtn.layer.cornerRadius = 25
        self.tblMessages.delegate = self
        self.tblMessages.dataSource = self
        self.tblMessages.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        self.getDataFromFirebase()
        self.getChatUsers()
    }
    
    //MARK: - IBAction
    
    @IBAction func addUser(_sender: UIButton) {
        
        let vc = storyboard?.instantiateViewController(identifier: "AddChannelsViewController") as! AddChannelsViewController
        vc.currentUser = self.name
        vc.channeltable = self.users
        navigationController?.pushViewController(vc, animated: true)
        
//        let alertController = UIAlertController(title: "Create a new Channel", message: nil, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        alertController.addTextField { field in
//            field.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
//            field.enablesReturnKeyAutomatically = true
//            field.autocapitalizationType = .words
//            field.clearButtonMode = .whileEditing
//            field.placeholder = "Channel name"
//            field.returnKeyType = .done
//            field.tintColor = .lightGray
//        }
//
//
//        let createAction = UIAlertAction(
//            title: "Create",
//            style: .default) { _ in
//            self.findUser()
//        }
//        createAction.isEnabled = true
//        alertController.addAction(createAction)
//        alertController.preferredAction = createAction
//
//        present(alertController, animated: true) {
//            alertController.textFields?.first?.becomeFirstResponder()
//        }
//        currentChannelAlertController = alertController
    }
    
    func getChatUsers() {
        
        guard let userID = Auth.auth().currentUser?.uid else{
            return
        }
        
        Database.database().reference().child("Channels").child(userID).observe(.value) { snapshot in
            self.users.removeAll()
            for item in snapshot.children{
                
                if let snap = item as? DataSnapshot{
                    if let dictionary = snap.value as? [String: Any]
                    {
                        let u = FirebaseChattingApp.user()
                        u.name = dictionary["senderName"] as! String
                        u.id = dictionary["senderid"] as! String
                        self.selectedUserId = u.id
                        print(u.id)
                        self.users.append(u)
                    }
                }
                DispatchQueue.main.async {
                    
                    self.tblMessages.reloadData()
                }
            }
            
        } withCancel: { (error) in
            print(error.localizedDescription)
        }

    }
    
    func findUser() {
        guard
            let alertController = currentChannelAlertController,
            let channelName = alertController.textFields?.first?.text
        else {
            return
        }
        let ref = Database.database().reference()
        ref.child("User").queryOrdered(byChild: "Name").queryStarting(atValue: channelName).queryEnding(atValue: channelName+"\u{f8ff}").observe(.value, with: { snapshot in
            for child in snapshot.children{
                if let childSnap = child as? DataSnapshot{
                    if (childSnap.value as? [String:Any]) != nil{
                        let value = childSnap.value as! [String:Any]
                        let u = FirebaseChattingApp.user()
                        //                        u.id = value as! String
                        u.name = value["Name"] as! String
                        //                        print(u.id)
                        print(u.name)
                        //                        self.users.append(u)
                        //                        self.selectedUserId = "\(childSnap.key)"
                        let timeStamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
                        guard let userID = Auth.auth().currentUser?.uid else{
                            return
                        }
                        
                        if !(self.users.contains(where: {$0.id == childSnap.key})) {
                            let dic = ["senderid" : "\(childSnap.key)" ,"senderName" : u.name , "datetime" : Date().debugDescription]
                            Database.database().reference().child("Channels").child(userID).child("\(timeStamp)").setValue(dic)
                            self.tblMessages.reloadData()
                            //
                            let dic2 = ["senderid" : "\(userID)" ,"senderName" : self.name , "datetime" : Date().debugDescription]
                            Database.database().reference().child("Channels").child(childSnap.key).child("\(timeStamp)").setValue(dic2)
                            self.tblMessages.reloadData()
                        } else {
                            self.showAlert(alertTitle: "Alert", alertMessage: "User Already Added!")
                        }
                    }
                }
            }
            //            Database.database().reference().child("Channels").child(userID).setValue()
        })
    }
    
    @objc private func textFieldDidChange(_ field: UITextField) {
        guard let alertController = currentChannelAlertController else {
            return
        }
        alertController.preferredAction?.isEnabled = field.hasText
    }
    
    @objc func logoutUser(){
        self.navigationController?.popViewController(animated: true)
    }

    
    //MARK: - Tableview Delegates & Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = user.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let otherName = users[indexPath.row].name
        let otherId = users[indexPath.row].id
        guard let userID = Auth.auth().currentUser?.uid else{
            return
        }
        var chatid = "\(userID)_\(otherId)"
        Database.database().reference().child("chats").getData { (error, snapShot) in
            guard error == nil else{
                return
            }
            for item in snapShot.children{
                if let snap =  item as? DataSnapshot{
                    if snap.key.contains(userID) && snap.key.contains(otherId){
                        chatid = snap.key
                        print(chatid)
                    }
                }
                
            }
            DispatchQueue.main.async {
                let vc = ChatViewController()
                vc.title = self.users[indexPath.row].name
                vc.myId = userID
                vc.chatId = chatid
                vc.other = otherId
                vc.userID = self.selectedUserId ?? ""
                vc.myName = self.name ?? "User"
                vc.otherName = otherName
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
        
    }
    
    func showAlert(alertTitle : String, alertMessage : String) {
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Others
    
//    func getDataFromFirebase() {
//
//        Database.database().reference().child("Channels").getData { [self] (error, snapshot) in
//            guard error == nil else{
//                return
//            }
//            //            guard let userID = Auth.auth().currentUser?.uid else{
//            //                return
//            //            }
//            print(snapshot)
//            for child in snapshot.children{
//                if let childSnap = child as? DataSnapshot{
//                    if (childSnap.value as? [String: Any]) != nil{
//                        let value = childSnap.value as! [String: Any]
//                        let getUser = value as [String:Any]
//                        let u = FirebaseChattingApp.user()
//                        u.id = childSnap.key
//                        u.name = getUser["senderName"] as! String
//                        print(u.id)
//                        users.append(u)
//                    }
//                }
//                DispatchQueue.main.async {
//                    self.tblMessages.reloadData()
//                }
//            }
//
//        }
//
//    }
    
    
//    func createChannel() {
//        guard
//            let alertController = currentChannelAlertController,
//            let channelName = alertController.textFields?.first?.text
//        else {
//            return
//        }
//
//        Database.database().reference().child("User").child(channelName).getData { [self] (error, snapshot) in
//            guard error == nil else{
//                return
//            }
//            //            guard let userID = Auth.auth().currentUser?.uid else{
//            //                return
//            //            }
//            guard let name = Auth.auth().currentUser?.displayName else{
//                return
//            }
//            print(snapshot)
//
//            let ref = Database.database().reference()
//            ref.child("User").child(name).observeSingleEvent(of: .value) { (snapshot) in
//
//                if let value = snapshot.value {
//                    //                    UserDataManager.user.saveUserData(userDict: value)
//                    //                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController{
//                    //                        vc.modalPresentationStyle = .overFullScreen
//                    //                        self.present(vc, animated: true, completion: nil)
//                    //                    }
//                    print(value)
//                    //                    users.append(value)
//                    self.tblMessages.reloadData()
//                }
//            }
//            DispatchQueue.main.async {
//                self.tblMessages.reloadData()
//            }
//        }
//
//    }
}

struct User {
    let id: Int
    let channelId: Int
    let name: String
    
    init(name: String, id: Int, channelId: Int) {
        self.id = id
        self.channelId = channelId
        self.name = name
    }
}

