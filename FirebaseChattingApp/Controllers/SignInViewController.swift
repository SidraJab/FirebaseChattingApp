//
//  ViewController.swift
//  FirebaseChattingApp
//
//  Created by Sidra Jabeen on 15/08/2021.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - IBActions
    
    @IBAction func signInTapped(_ sender: UIButton) {
        self.signIn()
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        
        let vc = storyboard?.instantiateViewController(identifier: "RegisterViewController") as! RegisterViewController
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    //MARK: - CallingApiFuctions
    
    func signIn() {
        startAnimation()
        let mail = txtEmail.text!
        let pass = txtPassword.text!
        Auth.auth().signIn(withEmail: mail, password: pass) { (result, error) in
            
            guard error == nil else{
                return
            }
            guard let userID = Auth.auth().currentUser?.uid else{
                return
            }
            Database.database().reference().child("User").child(userID).getData { (error, snapshot) in
                guard error == nil else{
                    return
                }
                self.stopAnimation()
                print(snapshot)
                for child in snapshot.children{
                    if let childSnap = child as? DataSnapshot {
                        if childSnap.key == "Name" {
                            let value = childSnap.value
                            UserDefaults.standard.set(value, forKey: childSnap.key)
                            
                        }
                    }
                }

                DispatchQueue.main.async {
                    let vc = self.storyboard?.instantiateViewController(identifier: "ChannelViewController") as! ChannelViewController
                    vc.name = UserDefaults.standard.string(forKey: "Name") ?? ""
//                    vc.name = "User"
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
            
        }
    }
    
    func stopAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            spinnerView.willMove(toParent: nil)
            spinnerView.view.removeFromSuperview()
            spinnerView.removeFromParent()
        }
    }
}

