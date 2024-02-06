//
//  ViewController.swift
//  InshiyChat
//
//  Created by Denys Astapov on 04.12.2023.
//

import UIKit

class LoginViewController: UIViewController {
    
    var viewModel: LoginViewModel!
    
    private let mainLabel: UILabel = {
        CreateUIElements.makeBigLabel(
            text: "Sign Up",
            fontSize: 60,
            fontWeight: .heavy
        )
    }()
    
    private let registrationNameTextField: UITextField = {
        CreateUIElements.makeTextField(placeholder: "Enter your Name")
    }()
    
    private let registrationEmailTextField: UITextField = {
        CreateUIElements.makeTextField(placeholder: "Enter your Email")
    }()
    
    private let registrarionPasswordTextField : UITextField = {
        CreateUIElements.makeTextField(placeholder: "Enter your Password", isSecureTextEntry: true)
    }()
    
    private let loginEmailTextField: UITextField = {
        CreateUIElements.makeTextField(placeholder: "Enter your Email")
    }()
    
    private let loginPasswordTextField : UITextField = {
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
    
    private let registrationButton: UIButton = {
        CreateUIElements.makeButton(
            backgroundColor: UIColor(hex: "412dc4"),
            titleColor: .white,
            title: "Register Me")
    }()
    
    private let loginButton: UIButton = {
        CreateUIElements.makeButton(
            backgroundColor: UIColor(hex: "412dc4"),
            titleColor: .white,
            title: "Start chatting")
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
    
    let registrationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
        setUp()
        fieldActions()
        fieldsValidation()
        
        setUpViewModel()
        
        mainLabelAnimation()
        
        switchButton.addAction(UIAction(handler: { [weak self] _ in
            self?.switchButtonPressed()
        }), for: .touchUpInside)
        
        registrationButton.addAction(UIAction(handler: { [weak self] _ in
            self?.mainButtonPressed()
        }), for: .touchUpInside)
        
        loginButton.addAction(UIAction(handler: { [weak self] _ in
            self?.loginButtonPressed()
        }), for: .touchUpInside)
    }
    
    func setUpViewModel() {
        viewModel.showAlert = { [weak self] message in
            if let message = message {
                self?.showAlert(message: message)
            } else {
                let databaseManager = DatabaseManager()
                let friendsModel = FriendsModel(databaseManager: databaseManager)
                let friendsViewModel = FriendsViewModel(friendsModel: friendsModel)
                self?.navigationController?.pushViewController(
                    FriendsViewController(viewModel: friendsViewModel),
                    animated: true
                )
            }
        }
    }
    
    private func setUp() {
        viewModel.navigationController = navigationController
        
        registrationNameTextField.delegate = self
        registrationEmailTextField.delegate = self
        registrarionPasswordTextField.delegate = self
        loginEmailTextField.delegate = self
        loginPasswordTextField.delegate = self
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "background_inshiy_main")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
        
        loginEmailTextField.isHidden = true
        loginPasswordTextField.isHidden = true
        loginButton.isHidden = true
        
        registrationStackView.addArrangedSubview(mainLabel)
        registrationStackView.addArrangedSubview(registrationNameTextField)
        registrationStackView.addArrangedSubview(registrationEmailTextField)
        registrationStackView.addArrangedSubview(registrarionPasswordTextField)
        registrationStackView.addArrangedSubview(loginEmailTextField)
        registrationStackView.addArrangedSubview(loginPasswordTextField)
        
        view.addSubview(registrationStackView)
        view.addSubview(registrationButton)
        view.addSubview(loginButton)
        view.addSubview(makeHaveAccountLabel)
        view.addSubview(switchButton)
        
        NSLayoutConstraint.activate([
            
            registrationStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            registrationStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            registrationStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            
            registrationButton.widthAnchor.constraint(equalToConstant: 200),
            registrationButton.heightAnchor.constraint(equalToConstant: 50),
            registrationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registrationButton.topAnchor.constraint(equalTo: registrationStackView.bottomAnchor, constant: 20),
            
            loginButton.widthAnchor.constraint(equalToConstant: 200),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: registrationStackView.bottomAnchor, constant: 20),
            
            registrationNameTextField.heightAnchor.constraint(equalToConstant: 50),
            registrationEmailTextField.heightAnchor.constraint(equalToConstant: 50),
            registrarionPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            loginEmailTextField.heightAnchor.constraint(equalToConstant: 50),
            loginPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            makeHaveAccountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            makeHaveAccountLabel.topAnchor.constraint(equalTo: registrationButton.bottomAnchor, constant: 50),
            makeHaveAccountLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 50),
            
            switchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            switchButton.topAnchor.constraint(equalTo: makeHaveAccountLabel.bottomAnchor)
        ])
    }
    
    private var signUpState = false {
        willSet {
            if newValue {
                mainLabelAnimation()
                mainLabel.text = "Sign In"
                registrationNameTextField.isHidden = true
                registrationEmailTextField.isHidden = true
                registrarionPasswordTextField.isHidden = true
                registrationButton.isHidden = true
                loginEmailTextField.isHidden = false
                loginPasswordTextField.isHidden = false
                loginButton.isHidden = false
                makeHaveAccountLabel.text = "Do you want to register an account?"
                switchButton.setTitle("Registration", for: .normal)
            } else {
                mainLabelAnimation()
                mainLabel.text = "Sign Up"
                registrationNameTextField.isHidden = false
                registrationEmailTextField.isHidden = false
                registrarionPasswordTextField.isHidden = false
                registrationButton.isHidden = false
                loginEmailTextField.isHidden = true
                loginPasswordTextField.isHidden = true
                loginButton.isHidden = true
                makeHaveAccountLabel.text = "Do you have an account?"
                switchButton.setTitle("Log In", for: .normal)
            }
        }
    }
    
    private func mainLabelAnimation() {
        mainLabel.alpha = 0.0
        mainLabel.transform = CGAffineTransform(translationX: 30, y: 0)
        
        UIView.animate(withDuration: 0.7, delay: 0.3, options: [.curveEaseInOut], animations: {
            self.mainLabel.alpha = 1.0
            self.mainLabel.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    private func switchButtonPressed() {
        signUpState = !signUpState
    }
    
    private func loginButtonPressed() {
        guard let email = self.loginEmailTextField.text, let password = self.loginPasswordTextField.text else { return }
        viewModel.navigationController = navigationController
        viewModel.autorizeUser(email: email, password: password)
    }
    
    private func mainButtonPressed() {
        if viewModel.isValidRegistration() {
            viewModel.registerUser()
        } else {
            let alert = UIAlertController(title: "Validation Error", message: "Please complete all fields", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func fieldActions() {
        registrationNameTextField.addAction(UIAction(handler: { [ weak self ] _ in
            guard let self = self else { return }
            let newUserName = self.registrationNameTextField.text ?? ""
            self.viewModel.setUpUserName(userFirstName: newUserName)
        }), for: .editingDidEnd)
        
        registrationEmailTextField.addAction(UIAction(handler: { [ weak self ] _ in
            guard let self = self else { return }
            let newUserEmail = self.registrationEmailTextField.text ?? ""
            self.viewModel.setUpUserEmail(userEmail: newUserEmail)
        }), for: .editingDidEnd)
        
        registrarionPasswordTextField.addAction(UIAction(handler: { [ weak self ] _ in
            guard let self = self else { return }
            let newUserPassword = self.registrarionPasswordTextField.text ?? ""
            self.viewModel.setUpUserPassword(userPassword: newUserPassword)
        }), for: .editingDidEnd)
    }
    
    private func fieldsValidation() {
        viewModel.isUserNameValid = { [ weak self ] isUserNameValid in
            if isUserNameValid {
                self?.registrationNameTextField.layer.borderColor = UIColor(hex: "412dc4", alpha: 0.4).cgColor
            } else {
                self?.showAlert(message: "Invalid name. Please enter a valid name.")
                self?.registrationNameTextField.layer.borderColor = UIColor.red.cgColor
                if self?.registrationNameTextField.text?.isEmpty ?? true {
                    self?.registrationNameTextField.layer.borderColor = UIColor(hex: "F6F6F6").cgColor
                }
            }
        }
        
        viewModel.isUserEmailValid = { [ weak self ] isUserEmailValid in
            if isUserEmailValid {
                self?.registrationEmailTextField.layer.borderColor = UIColor(hex: "412dc4", alpha: 0.4).cgColor
            } else {
                self?.registrationEmailTextField.layer.borderColor = UIColor.red.cgColor
                self?.showAlert(message: "Invalid email address. Please enter a valid email.")
                if self?.registrationEmailTextField.text?.isEmpty ?? true {
                    self?.registrationEmailTextField.layer.borderColor = UIColor(hex: "F6F6F6").cgColor
                }
            }
        }
        
        viewModel.isUserPasswordValid = { [ weak self ] isUserPasswordValid in
            if isUserPasswordValid {
                self?.registrarionPasswordTextField.layer.borderColor = UIColor(hex: "412dc4", alpha: 0.4).cgColor
            } else {
                self?.registrarionPasswordTextField.layer.borderColor = UIColor.red.cgColor
                self?.showAlert(message: "Invalid password. It must be at least 8 characters long, contain at least one capital letter, one number, and one special character.")
                if self?.registrarionPasswordTextField.text?.isEmpty ?? true {
                    self?.registrarionPasswordTextField.layer.borderColor = UIColor(hex: "F6F6F6").cgColor
                }
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Validation Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
}
