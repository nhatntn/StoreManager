//
//  SettingVC.swift
//  StoreManager
//
//  Created by nhatnt on 5/10/20.
//  Copyright © 2020 nhatnt. All rights reserved.
//

import UIKit
import Firebase

class SettingVC: UIViewController {
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBAction func didTapLogoutButton(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            UserDefaults.standard.set(false, forKey: "LoginStatus")
            Switcher.updateRootVC()
        } catch let signOutError as NSError {   
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .green
    }
    
}
