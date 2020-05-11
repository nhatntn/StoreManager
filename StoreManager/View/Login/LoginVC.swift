//
//  LoginVC.swift
//  StoreManager
//
//  Created by nhatnt on 5/11/20.
//  Copyright © 2020 nhatnt. All rights reserved.
//

import UIKit
import Firebase
import SnapKit

class LoginVC: UIViewController {
    fileprivate var handle: AuthStateDidChangeListenerHandle?
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Sign In", for: UIControl.State())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControl.State())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        
        return button
    }()
    
    lazy var forgetPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Forget Password", for: UIControl.State())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControl.State())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleForgetPassword), for: .touchUpInside)
        
        return button
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
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email Address"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let passwordSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let confirmPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Confirm Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let confirmPasswordSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 36)
        label.text = "Sign In"
        return label
    }()
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Sign In", "Sign Up"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    @objc func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: UIControl.State())
        
        let isSignInSegment = loginRegisterSegmentedControl.selectedSegmentIndex == 0
        titleLabel.text = isSignInSegment ? "Sign In" : "Sign Up"
        
        // change height of inputContainerView
        inputsContainerView.snp.updateConstraints {
            $0.height.equalTo(isSignInSegment ? 100 : 200)
        }
        
        // change height of nameTextField
        nameTextField.snp.updateConstraints {
            if isSignInSegment {
                $0.height.equalTo(0)
            } else {
                $0.height.equalTo(50)
            }
        }
        nameTextField.isHidden = isSignInSegment
        forgetPasswordButton.isHidden = !isSignInSegment
        
        // change height of nameTextField
        confirmPasswordTextField.snp.updateConstraints {
            if isSignInSegment {
                $0.height.equalTo(0)
            } else {
                $0.height.equalTo(50)
            }
        }
        confirmPasswordTextField.isHidden = isSignInSegment
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(forgetPasswordButton)
        view.addSubview(titleLabel)
        view.addSubview(loginRegisterSegmentedControl)
        
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupForgetPasswordButton()
        setupTitleLabel()
        setupLoginRegisterSegmentedControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Switcher.updateRootVC()
    }
    
    func setupLoginRegisterSegmentedControl() {
        loginRegisterSegmentedControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(inputsContainerView.snp.top).offset(-12)
            $0.width.equalTo(inputsContainerView.snp.width)
            $0.height.equalTo(36)
        }
    }
    
    func setupTitleLabel() {
        titleLabel.snp.makeConstraints {
            $0.centerX.left.right.equalToSuperview()
            $0.bottom.equalTo(loginRegisterSegmentedControl.snp.top).offset(-28)
        }
    }
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupInputsContainerView() {
        inputsContainerView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-120)
            $0.height.equalTo(100)
            $0.width.equalToSuperview().offset(-30)
        }
        
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        inputsContainerView.addSubview(passwordSeparatorView)
        inputsContainerView.addSubview(confirmPasswordTextField)
        inputsContainerView.addSubview(confirmPasswordSeparatorView)
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        
        emailTextField.snp.makeConstraints {
            $0.left.equalToSuperview().inset(12)
            $0.top.equalTo(inputsContainerView.snp.top)
            $0.width.equalTo(inputsContainerView.snp.width)
            $0.height.equalTo(50)
        }
        
        emailSeparatorView.snp.makeConstraints {
            $0.left.width.equalToSuperview()
            $0.top.equalTo(emailTextField.snp.bottom)
            $0.height.equalTo(1)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.left.equalToSuperview().inset(12)
            $0.top.equalTo(emailTextField.snp.bottom)
            $0.width.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        passwordSeparatorView.snp.makeConstraints {
            $0.left.width.equalToSuperview()
            $0.top.equalTo(passwordTextField.snp.bottom)
            $0.height.equalTo(1)
        }
    
        confirmPasswordTextField.snp.makeConstraints {
            $0.left.equalToSuperview().inset(12)
            $0.top.equalTo(passwordTextField.snp.bottom)
            $0.width.equalToSuperview()
            $0.height.equalTo(0)
        }
        
        confirmPasswordSeparatorView.snp.makeConstraints {
            $0.left.width.equalToSuperview()
            $0.top.equalTo(confirmPasswordTextField.snp.bottom)
            $0.height.equalTo(1)
        }
        
        nameTextField.snp.makeConstraints {
            $0.left.equalToSuperview().inset(12)
            $0.top.equalTo(confirmPasswordTextField.snp.bottom)
            $0.width.equalToSuperview()
            $0.height.equalTo(0)
        }
    }
    
    func setupLoginRegisterButton() {
        loginRegisterButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(inputsContainerView.snp.bottom).offset(12)
            $0.width.equalTo(inputsContainerView)
            $0.height.equalTo(50)
        }
    }
    
    func setupForgetPasswordButton() {
        forgetPasswordButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(loginRegisterButton.snp.bottom).offset(12)
            $0.width.equalTo(inputsContainerView)
            $0.height.equalTo(50)
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
