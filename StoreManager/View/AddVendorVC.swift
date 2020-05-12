//
//  AddVendorVC.swift
//  StoreManager
//
//  Created by nhatnt on 5/12/20.
//  Copyright © 2020 nhatnt. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import FirebaseFirestoreSwift
import RxSwift
import RxCocoa

class AddVendorVC: UIViewController {
    private let disposeBag = DisposeBag()
    private let db = Firestore.firestore()
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "default-profile")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectImageView)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let addressTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Address"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let addressSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let phoneTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Phone"
        tf.keyboardType = .numberPad
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        view.addSubview(inputsContainerView)
        view.addSubview(imageView)
        
        setupImageView()
        setupInputsContainerView()
        setupAddButton()
    }
    
    func setupImageView() {
        //need x, y, width, height constraints
        self.imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(120)
            $0.width.height.equalTo(180)
        }
    }
    
    @objc func handleSelectImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    
    func setupInputsContainerView() {
        inputsContainerView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(200)
            $0.width.equalToSuperview().offset(-30)
        }
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(addressTextField)
        inputsContainerView.addSubview(addressSeparatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(phoneTextField)
        
        nameTextField.snp.makeConstraints {
            $0.left.equalToSuperview().inset(12)
            $0.top.equalToSuperview()
            $0.width.equalTo(inputsContainerView.snp.width)
            $0.height.equalTo(50)
        }
        
        nameSeparatorView.snp.makeConstraints {
            $0.left.width.equalToSuperview()
            $0.top.equalTo(nameTextField.snp.bottom)
            $0.height.equalTo(1)
        }
        
        addressTextField.snp.makeConstraints {
            $0.left.equalToSuperview().inset(12)
            $0.top.equalTo(nameTextField.snp.bottom)
            $0.width.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        addressSeparatorView.snp.makeConstraints {
            $0.left.width.equalToSuperview()
            $0.top.equalTo(addressTextField.snp.bottom)
            $0.height.equalTo(1)
        }
        
        emailTextField.snp.makeConstraints {
            $0.left.equalToSuperview().inset(12)
            $0.top.equalTo(addressTextField.snp.bottom)
            $0.width.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        emailSeparatorView.snp.makeConstraints {
            $0.left.width.equalToSuperview()
            $0.top.equalTo(emailTextField.snp.bottom)
            $0.height.equalTo(1)
        }
        
        phoneTextField.snp.makeConstraints {
            $0.left.equalToSuperview().inset(12)
            $0.top.equalTo(emailTextField.snp.bottom)
            $0.width.equalToSuperview()
            $0.height.equalTo(50)
        }
    }
    
    func setupAddButton() {
        self.addButton.rx.tap.bind {
            guard let email = self.emailTextField.text, let address = self.addressTextField.text,
                let name = self.nameTextField.text else {
                    self.showAlert(alertText: "Add New Vendor", alertMessage: "Please check your inputs\nAnd try again")
                    return
            }
            
            if !self.emailTextField.isValidEmail() {
                self.showAlert(alertText: "Add New Vendor", alertMessage: "Your email adress is invalid")
                return
            }
            
            self.db.collection("vendors").whereField("name", isEqualTo: name).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    self.showAlert(alertText: "Add New Vendor", alertMessage: "Something went wrong\nPlease try later" +  err.localizedDescription)
                    return
                }
                if querySnapshot!.documents.count > 0 {
                    self.showAlert(alertText: "Add New Vendor", alertMessage: "Account name already registered\nPlease try another")
                    return
                }
                let phone = self.phoneTextField.text
                let products = [Item(name: "abc", price: 100, description: "xyz", imageUrl: "", vendors: nil)]
                self.addVendor(name: name, address: address,
                               email: email, phone: phone, products: products)
            }
        }.disposed(by: disposeBag)
    }
    
    func addVendor(name: String, address: String?, email: String?, phone: String?, products: [Item]?) {
        let vendor = Vendor(name: name, address: address, email: email, phone: phone, products: products)
        guard let dictData = vendor.dictionary else {
            self.showAlert(alertText: "Add New Vendor", alertMessage: "Please check your inputs\nAnd try again")
            return
        }
        
        var ref: DocumentReference? = nil
        ref = db.collection("vendors").addDocument(data: dictData) { err in
            if err != nil {
                self.showAlert(alertText: "Add New Vendor", alertMessage: "Please check your inputs\nAnd try again")
                return
            }
            self.showAlert(alertText: "Add New Vendor", alertMessage: "Successfully") { _ in
                self.navigationController?.popViewController(animated: true)
            }
            
            let id =  ref!.documentID
            let storageRef = Storage.storage().reference().child("vendors_images").child("\(id).jpg")
            if let profileImage = self.imageView.image, let uploadData = profileImage.jpegData(compressionQuality: 0.1) {
                
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
}

extension AddVendorVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
            imageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
