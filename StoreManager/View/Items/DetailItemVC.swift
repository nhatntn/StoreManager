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
import RxSwift
import RxCocoa

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
    private let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
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
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectImageView)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.backgroundColor = .white
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    let descriptionTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Description"
        tf.backgroundColor = .white
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    let priceTextField: CurrencyTextField = {
        let tf = CurrencyTextField()
        tf.placeholder = "Price"
        tf.backgroundColor = .white
        tf.locale = Locale(identifier: "en_US")
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.keyboardType = .numberPad
        return tf
    }()
    let countTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "No."
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
        let save = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItems = [save]
        
        self.setupHeaderView()
        self.setupTableView()
        self.setupData()
        DispatchQueue.main.async {
            self.loadData()
        }
    }
    
    @objc func saveTapped() {
        guard let id = item.id, let name = nameTextField.text, let description = descriptionTextField.text,
            let priceString = priceTextField.text, let count = countTextField.text else {
                return
        }
        
        // To update age and favorite color:
        db.collection("items").document(id).updateData([
            "name": name,
            "description": description,
            "price": Int(priceString.filter{ $0 != "$"}) ?? 0,
            "count": Int(count) ?? 0
        ]) { err in
            if err != nil {
                self.showAlert(alertText: "Update Item", alertMessage: "Please check your inputs\nAnd try again")
                return
            }
            self.showAlert(alertText: "Update Item", alertMessage: "Successfully") { _ in
                self.navigationController?.popViewController(animated: true)
            }
            
            let storageRef = Storage.storage().reference().child("items_images").child("\(id).jpg")
            if let itemImg = self.itemImageView.image, let uploadData = itemImg.jpegData(compressionQuality: 0.1) {
                
                storageRef.putData(uploadData, metadata: nil, completion: { (_, err) in
                    
                    if let error = err {
                        print(error)
                    }
                    
                    storageRef.downloadURL(completion: { (url, err) in
                        if let err = err {
                            print(err)
                            return
                        }
                        
                        guard let url = url else { return }
                        self.db.collection("items").document(id).updateData([
                            "imageUrl": url.absoluteString,
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                            }
                        }
                    })
                    
                })
            }
        }
    }
    
    @objc func handleSelectImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func setupHeaderView() {
        view.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(100)
            $0.left.right.equalToSuperview().inset(15)
            $0.height.equalTo(192)
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
        
        headerView.addSubview(inputContainerView)
        inputContainerView.snp.makeConstraints {
            $0.top.bottom.equalTo(itemImageView)
            $0.left.equalTo(itemImageView.snp.right).offset(10)
            $0.right.top.equalToSuperview().inset(10)
        }
        
        inputContainerView.addSubview(nameTextField)
        nameTextField.snp.makeConstraints {
            $0.right.left.equalToSuperview().inset(10)
            $0.top.equalToSuperview()
            $0.height.equalTo(43)
        }
        
        let nameSeperator = self.createSeparatorView()
        inputContainerView.addSubview(nameSeperator)
        nameSeperator.snp.makeConstraints {
             $0.left.width.equalToSuperview()
             $0.top.equalTo(nameTextField.snp.bottom)
             $0.height.equalTo(1)
        }
        
        inputContainerView.addSubview(descriptionTextField)
        descriptionTextField.snp.makeConstraints {
            $0.right.left.equalToSuperview().inset(10)
            $0.top.equalTo(nameTextField.snp.bottom)
            $0.height.equalTo(43)
        }
        
        let descriptionSeperator = self.createSeparatorView()
        inputContainerView.addSubview(descriptionSeperator)
        descriptionSeperator.snp.makeConstraints {
             $0.left.width.equalToSuperview()
             $0.top.equalTo(descriptionTextField.snp.bottom)
             $0.height.equalTo(1)
        }
        
        inputContainerView.addSubview(priceTextField)
        priceTextField.snp.makeConstraints {
            $0.right.left.equalToSuperview().inset(10)
            $0.top.equalTo(descriptionTextField.snp.bottom)
            $0.height.equalTo(43)
        }
        
        let priceSeperator = self.createSeparatorView()
        inputContainerView.addSubview(priceSeperator)
        priceSeperator.snp.makeConstraints {
             $0.left.width.equalToSuperview()
             $0.top.equalTo(priceTextField.snp.bottom)
             $0.height.equalTo(1)
        }
        
        inputContainerView.addSubview(countTextField)
        countTextField.snp.makeConstraints {
            $0.right.left.equalToSuperview().inset(10)
            $0.top.equalTo(priceTextField.snp.bottom)
            $0.height.equalTo(43)
        }
        
        inputContainerView.bringSubviewToFront(nameSeperator)
        inputContainerView.bringSubviewToFront(descriptionSeperator)
        inputContainerView.bringSubviewToFront(priceSeperator)
    }
    
    private func createSeparatorView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        
    }
    
    private func setupData() {
        self.nameTextField.text = item.name
        self.descriptionTextField.text = item.description
        self.priceTextField.text = "\(item.price)".asCurrency(locale: self.priceTextField.locale)
        self.countTextField.text = "\(item.count ?? 0)"
    }
    
    private func loadData() {
        let availableVendor = self.item.vendors
        guard let userId = Auth.auth().currentUser?.uid, availableVendor.count != 0 else {
            return
        }
        
        self.db.collection("vendors").whereField("userId", isEqualTo: userId).whereField("id", in: availableVendor).addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                self.showAlert(alertText: "Get Vendors", alertMessage: "Something went wrong\nPlease try later" +  err.localizedDescription)
                return
            }

            self.vendors.removeAll()
            for document in querySnapshot!.documents {
                let item = try! DictionaryDecoder().decode(Vendor.self, from: document.data())
                self.vendors.append(item)
            }
            self.tableView.reloadData()
        }
    }
    
}

extension DetailItemVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
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
        cell.addressLabel.text = vendor.address
        cell.emailLabel.text = vendor.email
        cell.item = item
        if let item = vendor.products.first(where: { (item) -> Bool in
            return item.name == self.item.name
        }) {
            cell.priceLabel.text = "\(item.price)$"
        }
        return cell
    }
    
}

extension DetailItemVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            itemImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
}

