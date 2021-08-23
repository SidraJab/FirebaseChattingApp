//
//  AddChannelsViewController.swift
//  FirebaseChattingApp
//
//  Created by Sidra Jabeen on 20/08/2021.
//

import UIKit
import Firebase

class AddChannelsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblUsers: UITableView!
    
    var users = [user]()
    var rowSelectedValue: Bool = false
    var currentUser: String?
    var channeltable = [user]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getDataFromFirebase()
        self.tblUsers.delegate = self
        self.tblUsers.dataSource = self
        self.tblUsers.register(UINib(nibName: "AllUsersTableViewCell", bundle: nil), forCellReuseIdentifier: "AllUsersTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllUsersTableViewCell", for: indexPath) as! AllUsersTableViewCell
        cell.textLabel?.text = user.name
        cell.btnAdd.tag = indexPath.row
        cell.btnAdd.addTarget(self, action: #selector(addUser(sender:)), for: .touchUpInside)
        
        let id = users[indexPath.row].id
        if users[indexPath.row].rowValue {
            cell.viewAdd.isHidden = true
            self.findUser(name: users[indexPath.row].name, id: users[indexPath.row].id, cell: cell)
        } else if self.channeltable.contains(where: {$0.id == id}) {
            cell.viewAdd.isHidden = true

        } else {
            cell.viewAdd.isHidden = false
        }

        return cell
    }
    
    @objc func addUser(sender: UIButton) {
        
        self.users[sender.tag].rowValue = true
        self.tblUsers.reloadData()
        
        }
    
    func getDataFromFirebase() {
        
        Database.database().reference().child("User").getData { [self] (error, snapshot) in
            guard error == nil else{
                return
            }
            guard let userID = Auth.auth().currentUser?.uid else{
                return
            }
            print(snapshot)
            for child in snapshot.children{
                if let childSnap = child as? DataSnapshot{
                    if (childSnap.value as? [String: Any]) != nil{
                        let value = childSnap.value as! [String: Any]
                        let u = FirebaseChattingApp.user()
                        u.id = childSnap.key
                        u.name = value["Name"] as! String
                        print(u.id)
                        if userID != u.id{
                            users.append(u)
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.tblUsers.reloadData()
                }
            }
            
        }
        
    }
    
    func findUser(name: String, id: String, cell: AllUsersTableViewCell) {
        
//        cell.viewAdd.isHidden = true
        let timeStamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        guard let userID = Auth.auth().currentUser?.uid else{
            return
        }
        
        if !(self.channeltable.contains(where: {$0.id == id})) {
            
            let alert = UIAlertController(title: "Warning", message: "Are you sure, You want to add this sure", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {(alert: UIAlertAction!) in
                
                let dic = ["senderid" : id ,"senderName" : name , "datetime" : Date().debugDescription]
                Database.database().reference().child("Channels").child(userID).child("\(timeStamp)").setValue(dic)
                //
                let dic2 = ["senderid" : "\(userID)" ,"senderName" : self.currentUser , "datetime" : Date().debugDescription]
                Database.database().reference().child("Channels").child(id).child("\(timeStamp)").setValue(dic2)
                
                self.showAlert(alertTitle: "Chat App", alertMessage: "Successfully Added!")
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: {(alert: UIAlertAction!) in
                
                self.dismiss(animated: true, completion: nil)

            }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }

    func showAlert(alertTitle : String, alertMessage : String) {
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(alert: UIAlertAction!) in
            
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}
