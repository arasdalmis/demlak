//
//  CreatePassword.swift
//  demlak
//
//  Created by Davut Dalmış on 29.03.2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreatePassword: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var NewPassword: UITextField!
    @IBOutlet weak var ConfirmPassword: UITextField!
    @IBOutlet weak var PasswordInformationConstraint: NSLayoutConstraint!
    @IBOutlet weak var confirmPasswordValidationLabel: UILabel!
    
    var passwordRequirementsView: UIView!
    var minLengthLabel: UILabel!
    var uppercaseLabel: UILabel!
    var numberLabel: UILabel!
    var checkmarkImages: [UIImageView] = []
    var passwordValidCheckmark: UIImageView!
    var confirmPasswordValidCheckmark: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        NewPassword.delegate = self
        ConfirmPassword.delegate = self
        confirmPasswordValidationLabel.isHidden = true
        setupNavigationBar()
        setupPasswordRequirementsView()
        setupPasswordValidCheckmark()
        setupConfirmPasswordValidCheckmark()
        setupTextFields()
    }
    private func setupTextFields() {
        let textFields = [NewPassword, ConfirmPassword]
        for textField in textFields {
            textField?.delegate = self
            textField?.layer.borderWidth = 1.0 / UIScreen.main.scale
            textField?.layer.borderColor = UIColor.gray.cgColor
            textField?.layer.cornerRadius = 11.0
            textField?.clipsToBounds = true
        }
    }
    private func setupConfirmPasswordValidCheckmark() {
           confirmPasswordValidCheckmark = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
           confirmPasswordValidCheckmark.tintColor = .link
           confirmPasswordValidCheckmark.isHidden = true
           view.addSubview(confirmPasswordValidCheckmark)
           
           confirmPasswordValidCheckmark.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               confirmPasswordValidCheckmark.trailingAnchor.constraint(equalTo: ConfirmPassword.trailingAnchor, constant: -8),
               confirmPasswordValidCheckmark.centerYAnchor.constraint(equalTo: ConfirmPassword.centerYAnchor),
               confirmPasswordValidCheckmark.widthAnchor.constraint(equalToConstant: 20),
               confirmPasswordValidCheckmark.heightAnchor.constraint(equalToConstant: 20)
           ])
       }
    private func setupPasswordValidCheckmark() {
        passwordValidCheckmark = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        passwordValidCheckmark.tintColor = .link
        passwordValidCheckmark.isHidden = true
        view.addSubview(passwordValidCheckmark)
        
        passwordValidCheckmark.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            passwordValidCheckmark.trailingAnchor.constraint(equalTo: NewPassword.trailingAnchor, constant: -8),
            passwordValidCheckmark.centerYAnchor.constraint(equalTo: NewPassword.centerYAnchor),
            passwordValidCheckmark.widthAnchor.constraint(equalToConstant: 20),
            passwordValidCheckmark.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    private func setupPasswordRequirementsView() {
        let viewHeight: CGFloat = 66
        
        passwordRequirementsView = UIView()
        passwordRequirementsView.backgroundColor = .white
        passwordRequirementsView.alpha = 0
        
        minLengthLabel = createLabel(withText: "En az 8 karakter uzunluğunda.")
        let minLengthImageView = createCheckmarkImageView(tintColor: minLengthLabel.textColor)
        let minLengthStackView = createRequirementStackView(label: minLengthLabel, imageView: minLengthImageView)
        
        uppercaseLabel = createLabel(withText: "Büyük/küçük harf.")
        let uppercaseImageView = createCheckmarkImageView(tintColor: uppercaseLabel.textColor)
        let uppercaseStackView = createRequirementStackView(label: uppercaseLabel, imageView: uppercaseImageView)
        
        numberLabel = createLabel(withText: "En az bir rakam içermeli.")
        let numberImageView = createCheckmarkImageView(tintColor: numberLabel.textColor)
        let numberStackView = createRequirementStackView(label: numberLabel, imageView: numberImageView)
        
        let requirementsStackView = UIStackView(arrangedSubviews: [minLengthStackView, uppercaseStackView, numberStackView])
        requirementsStackView.axis = .vertical
        requirementsStackView.spacing = 4
        
        passwordRequirementsView.addSubview(requirementsStackView)
        
        self.view.addSubview(passwordRequirementsView)
        
        passwordRequirementsView.translatesAutoresizingMaskIntoConstraints = false
        requirementsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            passwordRequirementsView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 82),
            passwordRequirementsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -82),
            passwordRequirementsView.topAnchor.constraint(equalTo: NewPassword.bottomAnchor, constant: 8),
            passwordRequirementsView.heightAnchor.constraint(equalToConstant: viewHeight),
            requirementsStackView.topAnchor.constraint(equalTo: passwordRequirementsView.topAnchor),
            requirementsStackView.bottomAnchor.constraint(equalTo: passwordRequirementsView.bottomAnchor),
            requirementsStackView.leadingAnchor.constraint(equalTo: passwordRequirementsView.leadingAnchor),
            requirementsStackView.trailingAnchor.constraint(equalTo: passwordRequirementsView.trailingAnchor)
        ])
    }
    
    private func createRequirementStackView(label: UILabel, imageView: UIImageView) -> UIStackView {
        imageView.tintColor = label.textColor
        checkmarkImages.append(imageView)
        
        let stackView = UIStackView(arrangedSubviews: [imageView, label])
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        return stackView
    }
    
    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }
    private func createCheckmarkImageView(tintColor: UIColor) -> UIImageView {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = tintColor
        return imageView
    }
    
    private func stackLabels(labels: [UILabel]) {
        let stackView = UIStackView(arrangedSubviews: labels)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        
        passwordRequirementsView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: passwordRequirementsView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: passwordRequirementsView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: passwordRequirementsView.leadingAnchor, constant: 82),
            stackView.trailingAnchor.constraint(equalTo: passwordRequirementsView.trailingAnchor, constant: -82)
        ])
    }
    private func setupNavigationBar() {
        let ileriButton = UIButton(type: .system)
        ileriButton.setTitle("Kaydol", for: .normal)
        ileriButton.setTitleColor(.link, for: .normal)
        ileriButton.backgroundColor = .systemBackground
        ileriButton.layer.cornerRadius = 15
        ileriButton.layer.borderWidth = 1.0
        ileriButton.layer.borderColor = UIColor.link.cgColor
        ileriButton.layer.masksToBounds = true
        ileriButton.addTarget(self, action: #selector(ileriButtonTapped), for: .touchUpInside)
        ileriButton.frame = CGRect(x: 0, y: 0, width: 69, height: 30)
        let ileriBarButtonItem = UIBarButtonItem(customView: ileriButton)
        self.navigationItem.rightBarButtonItem = ileriBarButtonItem
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if textField == NewPassword {
            updatePasswordValidationLabels(with: updatedText)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateConfirmPasswordValidation()
        }
        
        return true
    }
    private func updatePasswordValidationLabels(with password: String) {
        let isMinLengthValid = password.count >= 8
        let containsUppercase = password.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil
        let containsNumber = password.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
        
        let allValid = isMinLengthValid && containsUppercase && containsNumber
        passwordValidCheckmark.isHidden = !allValid
        passwordRequirementsView.isHidden = allValid
        PasswordInformationConstraint.constant = allValid ? 8 : 83
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        updateLabelAndCheckmark(label: minLengthLabel, imageView: checkmarkImages[0], isValid: isMinLengthValid)
        updateLabelAndCheckmark(label: uppercaseLabel, imageView: checkmarkImages[1], isValid: containsUppercase)
        updateLabelAndCheckmark(label: numberLabel, imageView: checkmarkImages[2], isValid: containsNumber)
    }
    private func updateLabelAndCheckmark(label: UILabel, imageView: UIImageView, isValid: Bool) {
        let color = isValid ? UIColor.link : UIColor.red
        label.textColor = color
        imageView.tintColor = color
    }
    
    private func containsUppercase(_ string: String) -> Bool {
        return string.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil
    }
    
    private func containsNumber(_ string: String) -> Bool {
        return string.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
    }
    
    @objc func ileriButtonTapped() {
        guard let newPassword = NewPassword.text, let confirmPassword = ConfirmPassword.text,
              newPassword == confirmPassword, !newPassword.isEmpty else {
            showAlert(message: "Şifreler uyuşmuyor veya boş.")
            return
        }
        
        // Burada direkt UserDefaults'dan verifiedPhoneNumber kullanıyoruz.
        guard let verifiedPhoneNumber = UserDefaults.standard.string(forKey: "verifiedPhoneNumber"),
              var userInfo = UserDefaults.standard.dictionary(forKey: "userInfo"),
              let email = userInfo["email"] as? String else {
            showAlert(message: "Kullanıcı bilgileri eksik veya telefon numarası doğrulanmamış.")
            return
        }
        
        userInfo["phoneNumber"] = verifiedPhoneNumber
        
        Auth.auth().createUser(withEmail: email, password: newPassword) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(message: "Kullanıcı oluşturma hatası: \(error.localizedDescription)")
                return
            }
            
            if let uid = authResult?.user.uid {
                self.saveUserToFirestore(uid: uid, userInfo: userInfo)
            }
        }
    }

    func saveUserToFirestore(uid: String, userInfo: [String: Any]) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData(userInfo) { error in
            if let error = error {
                self.showAlert(message: "Kullanıcı bilgilerini kaydederken hata oluştu: \(error.localizedDescription)")
            } else {
                self.goToMainApp()
            }
        }
    }
   
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Uyarı", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        self.present(alert, animated: true, completion: nil)
    }

    func goToMainApp() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return
        }
        let tabBarController = AppTabBarController()
        sceneDelegate.window?.rootViewController = tabBarController
        sceneDelegate.window?.makeKeyAndVisible()
        UIView.transition(with: sceneDelegate.window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == NewPassword {
            PasswordInformationConstraint.constant = 83
            UIView.animate(withDuration: 0.3) {
                self.passwordRequirementsView.alpha = 1
                self.view.layoutIfNeeded()
            }
            NSLayoutConstraint.activate([
                passwordRequirementsView.topAnchor.constraint(equalTo: NewPassword.bottomAnchor, constant: 8),
                passwordRequirementsView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
            ])
        }
        if textField == ConfirmPassword {
            confirmPasswordValidationLabel.isHidden = false
        }
    }
    private func updateConfirmPasswordValidation() {
        guard let newPassword = NewPassword.text, let confirmPassword = ConfirmPassword.text else { return }
        let isValid = !confirmPassword.isEmpty && (newPassword == confirmPassword)
        
        confirmPasswordValidationLabel.textColor = isValid ? .link : .red
        confirmPasswordValidationLabel.text = isValid ? "" : "Şifreler uyuşmuyor"
        confirmPasswordValidCheckmark.isHidden = !isValid
    }
}
