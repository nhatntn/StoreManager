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
import DownPicker

class SettingVC: UITableViewController{
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var languagePickerView: DownPicker!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSignOutButton()
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

