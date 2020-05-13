//
//  LoginVC+handlers.swift
//  StoreManager
//
//  Created by nhatnt on 5/11/20.
//  Copyright © 2020 nhatnt. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestoreSwift

enum SignStep {
    case signUp
    case signIn
}

extension LoginVC: UINavigationControllerDelegate {
    fileprivate var currentStep: SignStep {
        get {
            return loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? .signIn : .signUp
        }
    }
    
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleSignIn()
        } else {
            handleSignUp()
        }
        switch currentStep {
        case .signIn:
            handleSignIn()
        case .signUp:
            handleSignUp()
        }
    }
    
    @objc func handleForgetPassword() {
        guard let email = emailTextField.text else {
            self.showErrorAlert(with: "Please input your email")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let err = error {
                self.showErrorAlert(with: err)
                return
            }
            self.showAlert(alertText: "Reset your password", alertMessage: "A request email to reset your password was sent\nCheck your mail to continue")
        }
    }
    
    func showErrorAlert(with error: Error, completion: (() -> Void)? = nil) {
        var title: String = "ERROR"
        switch currentStep {
        case .signIn:
            title = "Sign In Failed"
        case .signUp:
            title = "Sign Up Failed"
        }
        
        let alert = UIAlertController(title: title,
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: completion)
    }
    
    fileprivate func handleSignIn() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            self.showErrorAlert(with: "Form is not valid")
            return
        }
        
        if email.isEmpty || password.isEmpty {
            self.showErrorAlert(with: "Something went wrong\nPlease check your inputs!")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if let error = error, user == nil {
                self.showErrorAlert(with: error)
                return
            }
            UserDefaults.standard.set(user != nil, forKey: "LoginStatus")
            Switcher.updateRootVC()
        })
        
    }
    
    fileprivate func handleSignUp() {
        guard let email = emailTextField.text, let name = nameTextField.text,
            let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text else {
            self.showErrorAlert(with: "Form is not valid")
            return
        }
        
        if email.isEmpty || password.isEmpty || name.isEmpty {
            self.showErrorAlert(with: "Something went wrong\nCheck your input again!")
            return
        }
        
        if password != confirmPassword {
            self.showErrorAlert(with: "Passwords do not match") {
                self.confirmPasswordTextField.text = ""
                self.passwordTextField.text = ""
            }
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
            guard let user = user?.user, error == nil else {
                self?.handleError(error!)
                return
            }
            
            let uid = user.uid
            //successfully authenticated user
            let userDatabase = User(id: uid, name: name, email: email)
            if let dict = userDatabase.dictionary {
                self?.registerUserIntoDatabaseWithUID(uid, values: dict as [String : AnyObject])
            }

            UserDefaults.standard.set(true, forKey: "LoginStatus")
            Switcher.updateRootVC()
        }
    }
    
    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData(values) { (err) in
            if err != nil {
                print(err ?? "")
                return
            }
            UserDefaults.standard.set(values["outOfStock"] ?? 5, forKey: "outOfStock")
            UserDefaults.standard.set(values["nearOutOfStock"] ?? 10, forKey: "nearOutOfStock")
            UserDefaults.standard.set(values["language"] ?? "English", forKey: "language")
            self.dismiss(animated: true, completion: nil)
        }
    }

}
