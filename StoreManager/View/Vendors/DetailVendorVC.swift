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
import RxSwift
import RxCocoa

class DetailVendorVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    private let db = Firestore.firestore()
    private let disposeBag = DisposeBag()
    lazy var newItem: Item? = { return self.items[0] }()
    var items = [Item]()
    var countTextField: UITextField!
    
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
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectImageView)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.textAlignment = .center
        tf.backgroundColor = .white
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    let addressTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Address"
        tf.textAlignment = .center
        tf.backgroundColor = .white
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.textAlignment = .center
        tf.backgroundColor = .white
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.keyboardType = .numberPad
        return tf
    }()
    let phoneTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Phone"
        tf.textAlignment = .center
        tf.backgroundColor = .white
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.keyboardType = .numberPad
        return tf
    }()
    
    var vendor: Vendor!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Detail Vendor"
        let add = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItems = [add]
        
        self.view.backgroundColor = UIColor(r: 17, g: 45, b: 78)
        self.setupProfileView()
        self.setupTableView()
        self.loadVendorData()
        self.loadItemsData()
    }
    
    @objc func saveTapped() {
        guard let id = vendor.id, let name = nameTextField.text, let address = addressTextField.text,
            let email = emailTextField.text, let phone = phoneTextField.text else {
            return
        }
        
        db.collection("vendors").document(id).updateData([
            "name": name,
            "address": address,
            "email": email,
            "phone": phone,
        ]) { err in
            if err != nil {
                self.showAlert(alertText: "Update Vendor", alertMessage: "Please check your inputs\nAnd try again")
                return
            }
            self.showAlert(alertText: "Update Vendor", alertMessage: "Successfully") { _ in
                self.navigationController?.popViewController(animated: true)
            }
            
            let storageRef = Storage.storage().reference().child("vendors_images").child("\(id).jpg")
            if let vendorImg = self.vendorImageView.image, let uploadData = vendorImg.jpegData(compressionQuality: 0.1) {
                
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
                        self.db.collection("vendors").document(id).updateData([
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
    
    func setupProfileView() {
        view.addSubview(vendorImageView)
        vendorImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(100)
            $0.width.height.equalTo(130)
        }
        if let urlString = vendor.imageUrl {
            let image = UIImage(named: "default-profile")!
            vendorImageView.imageFromServerURL(urlString: urlString, PlaceHolderImage: image)
        }
        
        view.addSubview(nameTextField)
        nameTextField.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(vendorImageView.snp.bottom).offset(15)
            $0.left.right.equalToSuperview().inset(15)
            $0.height.equalTo(40)
        }
        
        view.addSubview(addressTextField)
        addressTextField.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(nameTextField.snp.bottom).offset(15)
            $0.left.right.equalToSuperview().inset(15)
            $0.height.equalTo(40)
        }
        
        view.addSubview(emailTextField)
        emailTextField.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(addressTextField.snp.bottom).offset(15)
            $0.left.right.equalToSuperview().inset(15)
            $0.height.equalTo(40)
        }
        
        view.addSubview(phoneTextField)
        phoneTextField.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(emailTextField.snp.bottom).offset(15)
            $0.left.right.equalToSuperview().inset(15)
            $0.height.equalTo(40)
        }
        
        nameTextField.text = vendor.name
        addressTextField.text = vendor.address
        emailTextField.text = vendor.email
        phoneTextField.text = vendor.phone
    }
    
    func setupTableView() {
        let titleLabel = UILabel()
        self.view.addSubview(titleLabel)
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.text = "Items Provided"
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(phoneTextField.snp.bottom).offset(15)
            $0.left.right.equalToSuperview().inset(15)
        }
        
        let addButton = UIButton(type: .system)
        self.view.addSubview(addButton)
        addButton.setTitle("Add", for: UIControl.State())
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setTitleColor(UIColor(r: 219, g: 226, b: 239), for: UIControl.State())
        addButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        addButton.snp.makeConstraints {
            $0.top.equalTo(phoneTextField.snp.bottom).offset(15)
            $0.right.equalToSuperview().inset(15)
            $0.height.equalTo(titleLabel)
        }
        addButton.rx.tap.bind {
            self.handleAddNewItem()
        }.disposed(by: disposeBag)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(VendorDetaillItemViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.separatorStyle = .none
        tableView.separatorColor = .white
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
            $0.left.bottom.right.equalToSuperview()
        }
    }
    
    @objc func handleAddNewItem(message: String? = nil) {
        let title = message ?? "Add New Item"
        let alert = UIAlertController(title: title, message: "\n\n\n\n\n\n", preferredStyle: .alert)
        
        let pickerFrame = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
        
        alert.view.addSubview(pickerFrame)
        pickerFrame.dataSource = self
        pickerFrame.delegate = self
        
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "No. order"
            textField.keyboardType = .numberPad
            self.countTextField = textField
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (UIAlertAction) in
            guard let id = self.vendor.id, let newItem = self.newItem, let count = Int(self.countTextField.text ?? "") else {
                self.handleAddNewItem(message: "Your input empty! Try again")
                return
            }
            
            var addedItem = newItem
            addedItem.count = count
            var products = self.vendor.products
            products.append(addedItem)
            let dictData = products.map { $0.dictionary ?? [:] }
            
            self.db.collection("vendors").document(id).updateData([
                "products": dictData
            ]) { err in
                if let err = err {
                    self.showAlert(alertText: "Add New Item", alertMessage: "Something went wrong\nPlease try later" +  err.localizedDescription)
                    return
                } else {
                    self.showAlert(alertText: "Add New Item", alertMessage: "Successfully")
                    
                    guard let itemId = addedItem.id else {
                        return
                    }
                    self.db.collection("items").document(itemId).updateData([
                        "count": FieldValue.increment(Int64(count)),
                        "vendors": FieldValue.arrayUnion([id])
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                    self.loadVendorData()
                }
            }
        }))
        self.present(alert,animated: true, completion: nil )
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        newItem = items[row]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        self.loadVendorData()
    }
    
    private func loadItemsData() {
        self.db.collection("items").getDocuments() { (querySnapshot, err) in
            if let err = err {
                self.showAlert(alertText: "Get Items", alertMessage: "Something went wrong\nPlease try later" + err.localizedDescription)
                return
            }
            
            for document in querySnapshot!.documents {
                let item = try! DictionaryDecoder().decode(Item.self, from: document.data())
                self.items.append(item)
            }
        }
    }
    
    private func loadVendorData() {
        guard let id = self.vendor.id else {
            return
        }

        self.db.collection("vendors").document(id).getDocument { (document, err) in
            if let document = document, document.exists {
                let vendor = try! DictionaryDecoder().decode(Vendor.self, from: document.data() ?? [:])
                self.vendor = vendor
            }
        }
        
        self.tableView.reloadData()
    }
    
    private func getItems() -> [Item] {
        let reduceList = self.vendor.products.reduce([Item]()) { (items, current) in
            if items.contains(where: { $0.name == current.name }) {
                return items
            }
            var result = items
            result.append(current)
            return result
        }
        return reduceList
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
        return self.getItems().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as? VendorDetaillItemViewCell,
            vendor.products.count != 0 else {
                return UITableViewCell()
        }
        let items = self.getItems()
        let item = items[indexPath.row]
        cell.backgroundColor = UIColor(r: 219, g: 226, b: 239)
        cell.nameLabel.text = item.name
        cell.priceLabel.text = "\(item.price) $"
        return cell
    }
    
}

extension DetailVendorVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
            vendorImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
}

class VendorDetaillItemViewCell: UITableViewCell {
    let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 17, g: 45, b: 78)
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
        label.textColor = UIColor.white
        label.textAlignment = .right
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
            $0.left.equalToSuperview().offset(20)
            $0.top.bottom.equalToSuperview().inset(10)
        }
        
        priceLabel.snp.makeConstraints {
            $0.right.equalToSuperview().inset(20)
            $0.top.bottom.equalToSuperview().inset(10)
        }
    }
}
