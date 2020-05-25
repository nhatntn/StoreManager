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
    @IBOutlet weak var saveButotn: UIBarButtonItem!
    
    private let disposeBag = DisposeBag()
    private let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    private var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSignOutButton()
        self.setupSaveButton()
        DispatchQueue.main.async {
            self.loadData()
        }
    }
    
    private func setupSaveButton() {
        //Đăng kí event tap vô button với RxSwift
        self.saveButotn.rx.tap.bind {
            self.saveSettings()
        }.disposed(by: disposeBag)
    }
    
    private func loadData() {
        guard let uid = self.uid else {
            return
        }
        self.db.collection("users").document(uid).addSnapshotListener { (document, err) in
            if let document = document, document.exists {
                let user = try! DictionaryDecoder().decode(User.self, from: document.data() ?? [:])
                self.user = user
                
                self.outOfStockTextField.text = "\(user.outOfStock ?? 5)"
                self.nearOutOfStockTextField.text = "\(user.nearOutOfStock ?? 10)"
            } else {
                self.showAlert(alertText: "Get Settings", alertMessage: "Something went wrong\nPlease try later" + (err?.localizedDescription ?? ""))
            }
        }
    }
    
    private func saveSettings() {
        guard let uid = self.uid, let outOfStock = Int(self.outOfStockTextField.text ?? ""),
            let nearOutOfStock = Int(self.nearOutOfStockTextField.text ?? "") else {
                self.showAlert(alertText: "Save Settings", alertMessage: "Check your inputs\nAnd try again")
                return
        }
        self.db.collection("users").document(uid).updateData([
            "outOfStock" : outOfStock,
            "nearOutOfStock": nearOutOfStock
        ]) { (err) in
            if let err = err {
                self.showAlert(alertText: "Save Settings", alertMessage: "Something went wrong\nPlease try later" +  err.localizedDescription)
                return
            }
            self.showAlert(alertText: "Save Settings", alertMessage: "Successfully") { _ in
                self.nearOutOfStockTextField.resignFirstResponder()
                self.outOfStockTextField.resignFirstResponder()
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

