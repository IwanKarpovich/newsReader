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
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKCoreKit_Basics


class AuthViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var enterbutton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let loginButton = FBLoginButton()
        loginButton.center = view.center
        view.addSubview(loginButton)
        loginButton.permissions = ["public_profile", "email"]
    
        if let token = AccessToken.current, !token.isExpired {
//            let viewController = storyboard?.instantiateViewController(withIdentifier: "newsMenu")
//            self.present(viewController!, animated: true)
            let credential = FacebookAuthProvider
              .credential(withAccessToken: AccessToken.current!.tokenString)
            
            
        }
        
//        let buttonFB = FBLoginButton()
//        buttonFB.delegate = self
//        buttonFB.read
        
        // Do any additional setup after loading the view.
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
