//
//  AuthViewController.swift
//  newsReader
//
//  Created by Ivan Karpovich on 18.01.22.
//

// Swift // // Добавьте этот код в заголовок файла, например в ViewController.swift import FBSDKLoginKit // Добавьте этот код в тело класса ViewController: UIViewController { override func viewDidLoad() { super.viewDidLoad() let loginButton = FBLoginButton() loginButton.center = view.center view.addSubview(loginButton) } }

// Swift override func viewDidLoad() { super.viewDidLoad() if let token = AccessToken.current, !token.isExpired { // User is logged in, do work such as go to next view controller. } }

// Swift // // Дополните образец кода из раздела 6a. Добавление "Входа через Facebook" в код // Добавьте в метод viewDidLoad: loginButton.permissions = ["public_profile", "email"]


import UIKit
import Firebase

import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKCoreKit_Basics


class AuthViewController: UIViewController, LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("LogOut")
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if result!.isCancelled == false{
//            let firebaseAuth = Auth.auth()
//        do {
//          try firebaseAuth.signOut()
//        } catch let signOutError as NSError {
//          print("Error signing out: %@", signOutError)
//        }
//            print("df")
//
//        }else{
            if error == nil{
                GraphRequest(graphPath: "me", parameters: ["fields":"email,name"], tokenString: AccessToken.current?.tokenString, version: nil, httpMethod: HTTPMethod(rawValue: "GET") ?? HTTPMethod(rawValue: "GT")).start(completion: {
                    (nil, result, error) in
                    if error == nil{
                        print(result)
                        let credential = FacebookAuthProvider.credential(withAccessToken:
                                                                            AccessToken.current!.tokenString)
                        Auth.auth().signIn(with: credential, completion: {(result, error) in
                            var nameUsers: String = ""
                            if error == nil {
                                print(result?.user.uid)
                                nameUsers = (result?.user.email)!
                               
                            }
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            
                            guard let secondViewController = storyboard.instantiateViewController(identifier: "newsMenu") as? ViewController else { return }
                            secondViewController.nameUsers = nameUsers


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
        
        
        
        //        let loginButton = FBLoginButton()
        //        loginButton.center = view.center
        //        view.addSubview(loginButton)
        //        loginButton.permissions = ["public_profile", "email"]
        //
        //        if let token = AccessToken.current, !token.isExpired {
        ////            let viewController = storyboard?.instantiateViewController(withIdentifier: "newsMenu")
        ////            self.present(viewController!, animated: true)
        //            let credential = FacebookAuthProvider
        //              .credential(withAccessToken: AccessToken.current!.tokenString)
        //            Auth.auth().signIn(with: credential, completion: {(result, error) in
        //                if error == nil {
        //                    print(result?.user.uid)
        //                }
        //            })
        //
        //
        //        }
        
        //        let buttonFB = FBLoginButton()
        //        buttonFB.delegate = self
        //        buttonFB.read
        
        // Do any additional setup after loading the view.
                
    }
    
    @IBAction func facebookAction(_ sender: Any) {
        let login = LoginManager()
        login.logIn(permissions: [ "email","public_profile"], from: self) {(result, error) in
            if result!.isCancelled == false{
    //            let firebaseAuth = Auth.auth()
    //        do {
    //          try firebaseAuth.signOut()
    //        } catch let signOutError as NSError {
    //          print("Error signing out: %@", signOutError)
    //        }
    //            print("df")
    //
    //        }else{
                if error == nil{
                    GraphRequest(graphPath: "me", parameters: ["fields":"email,name"], tokenString: AccessToken.current?.tokenString, version: nil, httpMethod: HTTPMethod(rawValue: "GET") ?? HTTPMethod(rawValue: "GT")).start(completion: {
                        (nil, result, error) in
                        if error == nil{
                            print(result)
                            let credential = FacebookAuthProvider.credential(withAccessToken:
                                                                                AccessToken.current!.tokenString)
                            Auth.auth().signIn(with: credential, completion: {(result, error) in
                                var nameUsers: String = ""
                                if error == nil {
                                    print(result?.user.uid)
                                    nameUsers = (result?.user.email)!
                                   
                                }
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                
                                guard let secondViewController = storyboard.instantiateViewController(identifier: "newsMenu") as? ViewController else { return }
                                secondViewController.nameUsers = nameUsers


                                self.show(secondViewController, sender: nil)
                            })


                            
                        }
                    })
                }

               

            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

