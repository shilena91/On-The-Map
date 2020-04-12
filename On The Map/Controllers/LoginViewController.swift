//
//  ViewController.swift
//  On The Map
//
//  Created by Hoang on 8.4.2020.
//  Copyright © 2020 Hoang. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    @IBAction func loginPressed(_ sender: UIButton) {
        setLoggingIn(true)
        guard let username = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        UdacityClient.postRequest(username: username, password: password) { (response, error) in
            self.setLoggingIn(false)
            if response {
                UdacityClient.getRequest()
                self.performSegue(withIdentifier: "goToMapTabBar", sender: self)
            }
            if error != nil {
                let alert = UIAlertController(title: "Wrong email or password!", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }

    @IBAction func signUpPressed(_ sender: UIButton) {
        let app = UIApplication.shared
        app.open(URL(string: "https://auth.udacity.com/sign-up?next=https://classroom.udacity.com/authenticated")!, options: [:], completionHandler: nil)
    }
    
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            activityIndicator.startAnimating()
        }
        else {
            activityIndicator.stopAnimating()
        }
        emailTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
    }
    
}


//MARK: - TextField delegate functions

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true

    }
    
}
