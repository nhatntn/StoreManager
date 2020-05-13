//
//  SettingVC.swift
//  StoreManager
//
//  Created by nhatnt on 5/10/20.
//  Copyright © 2020 nhatnt. All rights reserved.
//

import UIKit
import Firebase
import RxSwift
import RxCocoa

class SettingVC: UITableViewController{
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var outOfStockTextField: UITextField!
    @IBOutlet weak var nearOutOfStockTextField: UITextField!
    private let disposeBag = DisposeBag()
    private let db = Firestore.firestore()
    private var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSignOutButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        self.db.collection("users").document(uid).getDocument { (document, err) in
            if let document = document, document.exists {
                let user = try! DictionaryDecoder().decode(User.self, from: document.data() ?? [:])
                self.user = user
                
                self.outOfStockTextField.text = "\(user.outOfStock)"
                self.nearOutOfStockTextField.text = "\(user.nearOutOfStock)"
            } else {
                self.showAlert(alertText: "Get Settings", alertMessage: "Something went wrong\nPlease try later" + (err?.localizedDescription ?? ""))
            }
        }
    }
    
    private func setupSignOutButton() {
        signOutButton.rx.tap.bind {
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                UserDefaults.standard.set(false, forKey: "LoginStatus")
                Switcher.updateRootVC()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }.disposed(by: disposeBag)
    }
    
}

