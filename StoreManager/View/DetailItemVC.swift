//
//  DetailItemVC.swift
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

class DetailItemVC: UIViewController {
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
    lazy var itemImageView: UIImageView = {
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
    let descriptionTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Description"
        tf.textAlignment = .right
        tf.backgroundColor = .white
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    let priceTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Price"
        tf.textAlignment = .right
        tf.backgroundColor = .white
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.keyboardType = .numberPad
        return tf
    }()
    
    var item: Item!
    var vendors: [Vendor] = []
    
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
        
        headerView.addSubview(itemImageView)
        itemImageView.snp.makeConstraints {
            $0.left.top.bottom.equalToSuperview().inset(10)
            $0.width.equalTo(130)
        }
        if let urlString = item.imageUrl {
            let image = UIImage(named: "default-product")!
            itemImageView.imageFromServerURL(urlString: urlString, PlaceHolderImage: image)
        }
        
        headerView.addSubview(nameTextField)
        nameTextField.snp.makeConstraints {
            $0.right.top.equalToSuperview().inset(10)
            $0.left.equalTo(itemImageView.snp.right).offset(10)
            $0.height.equalTo(43)
        }
        
        headerView.addSubview(descriptionTextField)
        descriptionTextField.snp.makeConstraints {
            $0.right.equalToSuperview().inset(10)
            $0.top.equalTo(nameTextField.snp.bottom)
            $0.left.equalTo(itemImageView.snp.right).offset(10)
            $0.height.equalTo(43)
        }
        
        headerView.addSubview(priceTextField)
        priceTextField.snp.makeConstraints {
            $0.right.equalToSuperview().inset(10)
            $0.top.equalTo(descriptionTextField.snp.bottom)
            $0.left.equalTo(itemImageView.snp.right).offset(10)
            $0.height.equalTo(43)
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
        
        self.vendors.removeAll()
        let availableVendor = self.item.vendors?.compactMap {
            return $1 > 0 ? $0 : nil
            } ?? []
        
        self.db.collection("vendors").whereField("name", in: availableVendor).getDocuments() { (querySnapshot, err) in
            if let err = err {
                self.showAlert(alertText: "Get Vendors", alertMessage: "Something went wrong\nPlease try later" +  err.localizedDescription)
                return
            }
            
            for document in querySnapshot!.documents {
                let item = try! DictionaryDecoder().decode(Vendor.self, from: document.data())
                self.vendors.append(item)
            }
            self.tableView.reloadData()
        }
    }
    
    private func loadData() {
        self.nameTextField.text = item.name
        self.descriptionTextField.text = item.description
        self.priceTextField.text = "\(item.price)"
    }
}

extension DetailItemVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vendors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as? VendorDetailViewCell,
            vendors.count != 0 else {
                return UITableViewCell()
        }
        
        let vendor = vendors[indexPath.row]
        cell.backgroundColor = UIColor(r: 219, g: 226, b: 239)
        cell.nameLabel.text = vendor.name
        return cell
    }
    
}

class VendorDetailViewCell: UITableViewCell {
    let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 63, g: 114, b: 175)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(cellView)
        cellView.addSubview(nameLabel)
        cellView.addSubview(priceLabel)
        self.selectionStyle = .none
        
        cellView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.right.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.centerY.equalTo(cellView)
            $0.top.bottom.right.equalToSuperview().inset(10)
        }
        
    }
}
