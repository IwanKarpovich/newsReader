//
//  AuthViewController.swift
//  newsReader
//
//  Created by Ivan Karpovich on 18.01.22.
//

import UIKit
import Firebase

import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKCoreKit_Basics


class AuthViewController: UIViewController, LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if result!.isCancelled == false{
            if error == nil{
                GraphRequest(graphPath: "me", parameters: ["fields":"email,name"], tokenString: AccessToken.current?.tokenString, version: nil, httpMethod: HTTPMethod(rawValue: "GET") ).start(completion: {
                    (nil, result, error) in
                    if error == nil{
                        let credential = FacebookAuthProvider.credential(withAccessToken:
                                                                            AccessToken.current!.tokenString)
                        Auth.auth().signIn(with: credential, completion: {(result, error) in
                            var userNames: String = ""
                            if error == nil {
                                userNames = (result?.user.email)!
                                
                            }
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            
                            guard let secondViewController = storyboard.instantiateViewController(identifier: "newsMenu") as? NewsViewController else { return }
                            secondViewController.userNames = userNames
                            
                            
                            self.show(secondViewController, sender: nil)
                        })
                    }
                })
            }
        }
        
    }
    
    
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var enterbutton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let buttonFD = FBLoginButton()
        buttonFD.delegate = self
        buttonFD.permissions = ["public_profile", "email"]
        buttonFD.frame.origin.y = 500
        buttonFD.frame.origin.x = 100
        self.view.addSubview(buttonFD)
        
        
    }
    
    @IBAction func facebookAction(_ sender: Any) {
        let login = LoginManager()
        login.logIn(permissions: [ "email","public_profile"], from: self) {(result, error) in
            if result!.isCancelled == false{
                
                if error == nil{
                    GraphRequest(graphPath: "me", parameters: ["fields":"email,name"], tokenString: AccessToken.current?.tokenString, version: nil, httpMethod: HTTPMethod(rawValue: "GET") ).start(completion: {
                        (nil, result, error) in
                        if error == nil{
                            let credential = FacebookAuthProvider.credential(withAccessToken:
                                                                                AccessToken.current!.tokenString)
                            Auth.auth().signIn(with: credential, completion: {(result, error) in
                                var userNames: String = ""
                                if error == nil {
                                    userNames = (result?.user.email)!
                                    
                                }
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                
                                guard let secondViewController = storyboard.instantiateViewController(identifier: "newsMenu") as? NewsViewController else { return }
                                secondViewController.userNames = userNames
                                
                                
                                self.show(secondViewController, sender: nil)
                            })
                        }
                    })
                }
            }
        }
    }
}

