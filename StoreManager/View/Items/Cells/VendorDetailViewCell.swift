//
//  VendorDetailViewCell.swift
//  StoreManager
//
//  Created by nhatnt on 5/14/20.
//  Copyright © 2020 nhatnt. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import MessageUI
import RxCocoa
import RxSwift

class VendorDetailViewCell: UITableViewCell {
    private let disposeBag = DisposeBag()
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
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let orderTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "No. Order"
        tf.textAlignment = .center
        tf.backgroundColor = .white
        tf.keyboardType = .numberPad
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let orderButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 17, g: 45, b: 78)
        button.setTitle("Order", for: UIControl.State())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControl.State())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    var item: Item? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        orderButton.rx.tap.bind {
            self.handleOrder()
        }.disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleOrder() {
        let itemName = self.item?.name ?? ""
        let count = self.orderTextField.text ?? ""
        let receiver = self.emailLabel.text ?? ""
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        guard var topController = keyWindow?.rootViewController else {
            return
        }
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self as? MFMailComposeViewControllerDelegate
            mail.setToRecipients([receiver])
            mail.setMessageBody("<p>I want to order your product: \(itemName) with \(count) objects</p>", isHTML: true)
            topController.present(mail, animated: true)
        } else {
            topController.showAlert(alertText: "Send Email", alertMessage: "Please login a email on your device\nAnd try again")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func setupView() {
        self.selectionStyle = .none
        
        addSubview(cellView)
        cellView.addSubview(nameLabel)
        cellView.addSubview(priceLabel)
        cellView.addSubview(addressLabel)
        cellView.addSubview(emailLabel)
        cellView.addSubview(orderTextField)
        cellView.addSubview(orderButton)
        
        cellView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
            $0.left.right.equalToSuperview().inset(15)
        }
        
        nameLabel.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview().inset(15)
        }
        
        addressLabel.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.top.equalTo(nameLabel.snp.bottom)
            $0.left.right.equalToSuperview().inset(15)
        }
        
        priceLabel.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.top.equalTo(addressLabel.snp.bottom)
            $0.left.right.equalToSuperview().inset(15)
        }
        
        emailLabel.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview().inset(15)
        }
        
        orderTextField.snp.makeConstraints {
            $0.height.equalTo(30)
            $0.width.equalTo(100)
            $0.top.equalTo(nameLabel.snp.bottom)
            $0.right.equalToSuperview().inset(15)
        }
        
        orderButton.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.width.equalTo(80)
            $0.top.equalTo(addressLabel.snp.bottom)
            $0.right.equalToSuperview().inset(15)
        }
    }
}
