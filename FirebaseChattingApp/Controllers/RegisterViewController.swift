//
//  RegisterViewController.swift
//  FirebaseChattingApp
//
//  Created by Sidra Jabeen on 15/08/2021.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPasword: UITextField!
    @IBOutlet weak var txtContact: UITextField!
    
    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - IBAction
    
    @IBAction func registerNowTapped(_ sender: UIButton) {
        self.signupAPI()
    }
    
    //MARK: - CallingFunctions
    
    func signupAPI(){
        Auth.auth().createUser(withEmail: txtEmail.text!, password: txtPasword.text!) { (result, error) in
            if error == nil{
                let ref = Database.database().reference()
                if let user = result?.user{
                    let dic = ["Name":"\(self.txtName.text!)",
                               "Email":"\(self.txtEmail.text!)",
                               "password":"\(self.txtPasword.text!)",
                    "Contact":"\(self.txtContact.text!)"]
                    ref.child("User").child("\(user.uid)").setValue(dic)
//                    self.dismiss(animated: true, completion: nil)
                    
                    self.showAlert(alertTitle: "Chat App", alertMessage: "Successfully Sign-Up")
                }
                
            }else{
                if let error = error as NSError? {
                    switch AuthErrorCode(rawValue: error.code) {
                    case .operationNotAllowed:
                        print("operationNotAllowed")
                    case .emailAlreadyInUse:
                        print("emailAlreadyInUse")
                    case .invalidEmail:
                        print("invalidEmail")
                    case .weakPassword:
                        print("weakPassword")
                    default:
                        print("Error: \(error.localizedDescription)")
                    }
                    
                } else {
                    print("User signs up successfully")
                }
            }
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
