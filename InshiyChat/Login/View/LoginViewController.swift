//
//  ViewController.swift
//  InshiyChat
//
//  Created by Denys Astapov on 04.12.2023.
//

import UIKit

class LoginViewController: UIViewController {
    
    let viewModel = LoginViewModel()
    
    private let mainLabel: UILabel = {
        CreateUIElements.makeBigLabel(
            text: "Sign Up",
            fontSize: 60,
            fontWeight: .heavy
        )
    }()
    
    private let nameTextField: UITextField = {
        CreateUIElements.makeTextField(placeholder: "Enter your Name")
    }()
    
    private let emailTextField: UITextField = {
        CreateUIElements.makeTextField(placeholder: "Enter your Email")
    }()
    
    private let passwordTextField : UITextField = {
        CreateUIElements.makeTextField(placeholder: "Enter your Password", isSecureTextEntry: true)
    }()
    
    private let makeHaveAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "Do you have an account?"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mainButton: UIButton = {
        CreateUIElements.makeButton(
            backgroundColor: UIColor(hex: "412dc4"),
            titleColor: .white,
            title: "Register Me")
    }()
    
    private let switchButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(hex: "412dc4"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Log In", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
        setUp()
        fieldActions()
        fieldsValidation()
        
        switchButton.addAction(UIAction(handler: { [weak self] _ in
            self?.switchButtonPressed()
        }), for: .touchUpInside)
        
        mainButton.addAction(UIAction(handler: { [weak self] _ in
            self?.mainButtonPressed()
        }), for: .touchUpInside)
    }
    
    private func setUp() {
        
        viewModel.navigationController = navigationController
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "background_inshiy_main")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
        
        let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.distribution = .fill
            stackView.alignment = .fill
            stackView.spacing = 20
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()
        
        stackView.addArrangedSubview(mainLabel)
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(passwordTextField)
        
        view.addSubview(stackView)
        view.addSubview(mainButton)
        view.addSubview(makeHaveAccountLabel)
        view.addSubview(switchButton)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            
            mainButton.widthAnchor.constraint(equalToConstant: 200),
            mainButton.heightAnchor.constraint(equalToConstant: 50),
            mainButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            makeHaveAccountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            makeHaveAccountLabel.topAnchor.constraint(equalTo: mainButton.bottomAnchor, constant: 50),
            
            switchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            switchButton.topAnchor.constraint(equalTo: makeHaveAccountLabel.bottomAnchor)
        ])
    }
    
    private var signUpState = false {
        willSet {
            if newValue {
                mainLabel.text = "Sign In"
                nameTextField.isHidden = true
                mainButton.setTitle("Start Chatting", for: .normal)
                makeHaveAccountLabel.text = "Do you want to register an account?"
                switchButton.setTitle("Registration", for: .normal)
            } else {
                mainLabel.text = "Sign Up"
                nameTextField.isHidden = false
                mainButton.setTitle("Register Me", for: .normal)
                makeHaveAccountLabel.text = "Do you have an account?"
                switchButton.setTitle("Log In", for: .normal)
            }
        }
    }
    
    private func switchButtonPressed() {
        signUpState = !signUpState
    }
    
    private func mainButtonPressed() {
        if signUpState {
            viewModel.autorizeUser()
        } else {
            if viewModel.isValidRegistration() {
                viewModel.registerUser()
            } else {
                let alert = UIAlertController(title: "Validation Error", message: "Please complete all fields", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func fieldActions() {
        nameTextField.addAction(UIAction(handler: { [ weak self ] _ in
            guard let self = self else { return }
            let newUserName = self.nameTextField.text ?? ""
            self.viewModel.setUpUserName(userFirstName: newUserName)
        }), for: .editingDidEnd)
        
        emailTextField.addAction(UIAction(handler: { [ weak self ] _ in
            guard let self = self else { return }
            let newUserEmail = self.emailTextField.text ?? ""
            self.viewModel.setUpUserEmail(userEmail: newUserEmail)
        }), for: .editingDidEnd)
        
        passwordTextField.addAction(UIAction(handler: { [ weak self ] _ in
            guard let self = self else { return }
            let newUserPassword = self.passwordTextField.text ?? ""
            self.viewModel.setUpUserPassword(userPassword: newUserPassword)
        }), for: .editingDidEnd)
    }
    
    private func fieldsValidation() {
        viewModel.isUserNameValid = { [ weak self ] isUserNameValid in
            if isUserNameValid {
                self?.nameTextField.layer.borderColor = UIColor(hex: "412dc4", alpha: 0.4).cgColor
            } else {
                self?.showAlert(message: "Invalid name. Please enter a valid name.")
                self?.nameTextField.layer.borderColor = UIColor.red.cgColor
                if self?.nameTextField.text?.isEmpty ?? true {
                    self?.nameTextField.layer.borderColor = UIColor(hex: "F6F6F6").cgColor
                }
            }
        }
        
        viewModel.isUserEmailValid = { [ weak self ] isUserEmailValid in
            if isUserEmailValid {
                self?.emailTextField.layer.borderColor = UIColor(hex: "412dc4", alpha: 0.4).cgColor
            } else {
                self?.emailTextField.layer.borderColor = UIColor.red.cgColor
                self?.showAlert(message: "Invalid email address. Please enter a valid email.")
                if self?.emailTextField.text?.isEmpty ?? true {
                    self?.emailTextField.layer.borderColor = UIColor(hex: "F6F6F6").cgColor
                }
            }
        }
        
        viewModel.isUserPasswordValid = { [ weak self ] isUserPasswordValid in
            if isUserPasswordValid {
                self?.passwordTextField.layer.borderColor = UIColor(hex: "412dc4", alpha: 0.4).cgColor
            } else {
                self?.passwordTextField.layer.borderColor = UIColor.red.cgColor
                self?.showAlert(message: "Invalid password. It must be at least 8 characters long, contain at least one capital letter, one number, and one special character.")
                if self?.passwordTextField.text?.isEmpty ?? true {
                    self?.passwordTextField.layer.borderColor = UIColor(hex: "F6F6F6").cgColor
                }
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Validation Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
