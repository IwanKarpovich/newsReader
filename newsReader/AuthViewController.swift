//
//  AuthViewController.swift
//  newsReader
//
//  Created by Ivan Karpovich on 18.01.22.
//

// Swift // // Добавьте этот код в заголовок файла, например в ViewController.swift import FBSDKLoginKit // Добавьте этот код в тело класса ViewController: UIViewController { override func viewDidLoad() { super.viewDidLoad() let loginButton = FBLoginButton() loginButton.center = view.center view.addSubview(loginButton) } }

import UIKit

class AuthViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var enterbutton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

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
