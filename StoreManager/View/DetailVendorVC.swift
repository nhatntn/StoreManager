//
//  DetailVendorVC.swift
//  StoreManager
//
//  Created by nhatnt on 5/12/20.
//  Copyright © 2020 nhatnt. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestoreSwift
import SnapKit

class DetailVendorVC: UIViewController {
    private let db = Firestore.firestore()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 17, g: 45, b: 78)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = UIColor(r: 219, g: 226, b: 239)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    lazy var vendorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor(r: 17, g: 45, b: 78)
        return imageView
    }()
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.textAlignment = .right
        tf.backgroundColor = .white
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    let addressTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Address"
        tf.textAlignment = .right
        tf.backgroundColor = .white
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.textAlignment = .right
        tf.backgroundColor = .white
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.keyboardType = .numberPad
        return tf
    }()
    let phoneTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Phone"
        tf.textAlignment = .right
        tf.backgroundColor = .white
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.keyboardType = .numberPad
        return tf
    }()
    
    var vendor: Vendor!
    var items: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Detail Item"
        self.view.backgroundColor = UIColor(r: 219, g: 226, b: 239)
        self.setupHeaderView()
        self.setupTableView()
        self.loadData()
    }
    
    func setupHeaderView() {
        view.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(100)
            $0.left.right.equalToSuperview().inset(15)
            $0.height.equalTo(150)
        }
        
        headerView.addSubview(vendorImageView)
        vendorImageView.snp.makeConstraints {
            $0.left.top.bottom.equalToSuperview().inset(10)
            $0.width.equalTo(130)
        }
        if let urlString = vendor.imageUrl {
            let image = UIImage(named: "default-profile")!
            vendorImageView.imageFromServerURL(urlString: urlString, PlaceHolderImage: image)
        }
        
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(VendorDetailViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.separatorStyle = .none
        tableView.separatorColor = .white
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.left.bottom.right.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
//        self.items.removeAll()
//        self.db.collection("items").getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                self.showAlert(alertText: "Get Vendors", alertMessage: "Something went wrong\nPlease try later" +  err.localizedDescription)
//                return
//            }
//
//            for document in querySnapshot!.documents {
//                let item = try! DictionaryDecoder().decode(Vendor.self, from: document.data())
//                self.vendors.append(item)
//            }
//            self.tableView.reloadData()
//        }
    }
    
    private func loadData() {
//        self.nameTextField.text = item.name
//        self.descriptionTextField.text = item.description
//        self.priceTextField.text = "\(item.price)"
    }
}

extension DetailVendorVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as? VendorDetailViewCell,
//            vendors.count != 0 else {
//                return UITableViewCell()
//        }
//
//        let vendor = vendors[indexPath.row]
//        cell.backgroundColor = UIColor(r: 219, g: 226, b: 239)
//        cell.nameLabel.text = vendor.name
//        return cell
    }
    
}