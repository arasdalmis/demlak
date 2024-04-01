//
//  AccountController.swift
//  demlak
//
//  Created by Davut Dalmış on 29.03.2024.
//

import UIKit
import Firebase
import FirebaseAuth

class AccountController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var dateBirthTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userConstraint: NSLayoutConstraint!
    
    var isNameValid: Bool = false
    var isSurnameValid: Bool = false
    var isDateOfBirthValid: Bool = false
    var isPhoneNumberValid: Bool = false
    var isUserNameValid: Bool = false
    var isUsernameUnique: Bool = false
    var userNameWarningLabel: UILabel!
    let datePicker = UIDatePicker()
    let ileriButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextFields()
        setupNavigationBar()
        setupCancelButton()
        createDatePicker()
        setupUserNameWarningLabel()
        updateIleriButtonState()
        
        nameTextField.delegate = self
        surnameTextField.delegate = self
        scrollView.alwaysBounceVertical = true
        
        nameLabel.isHidden = true
        surnameLabel.isHidden = true
        dateOfBirthLabel.isHidden = true
        phoneNumberLabel.isHidden = true
        userNameLabel.isHidden = true
        ileriButton.alpha = 0.5
        
      
    }
    func setupUserNameWarningLabel() {
        userNameWarningLabel = UILabel()
        userNameWarningLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameWarningLabel.text = "Bu kullanıcı adı zaten alınmış."
        userNameWarningLabel.textColor = .red
        userNameWarningLabel.textAlignment = .left
        userNameWarningLabel.font = UIFont.systemFont(ofSize: 12)
        userNameWarningLabel.isHidden = true
        view.addSubview(userNameWarningLabel)
        
        NSLayoutConstraint.activate([
            userNameWarningLabel.topAnchor.constraint(equalTo: userNameTextField.bottomAnchor, constant: 8),
            userNameWarningLabel.leadingAnchor.constraint(equalTo: userNameTextField.leadingAnchor),
            userNameWarningLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -22),
            userNameWarningLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateIleriButtonState()
        if textField.text?.isEmpty ?? true {
            switch textField {
            case nameTextField:
                nameLabel.isHidden = true
            case surnameTextField:
                surnameLabel.isHidden = true
            case dateBirthTextField:
                dateOfBirthLabel.isHidden = true
            case numberTextField:
                phoneNumberLabel.isHidden = true
            case userNameTextField:
                userNameLabel.isHidden = true
            default:
                break
            }
        }
    }
    private func setupTextFields() {
        let textFields = [nameTextField, surnameTextField, dateBirthTextField, numberTextField, userNameTextField]
        for textField in textFields {
            textField?.delegate = self
            textField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            textField?.layer.borderWidth = 1.0 / UIScreen.main.scale
            textField?.layer.borderColor = UIColor.gray.cgColor
            textField?.layer.cornerRadius = 11.0
            textField?.clipsToBounds = true
            textField?.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
            textField?.rightViewMode = .always
            numberTextField.keyboardType = .numberPad
        }
    }
    
    private func setupNavigationBar() {
        ileriButton.setTitle("İleri", for: .normal)
        ileriButton.setTitleColor(.link, for: .normal)
        ileriButton.backgroundColor = .systemBackground
        ileriButton.layer.cornerRadius = 15
        ileriButton.layer.borderWidth = 1.0
        ileriButton.layer.borderColor = UIColor.link.cgColor
        ileriButton.layer.masksToBounds = true
        ileriButton.isEnabled = false
        ileriButton.addTarget(self, action: #selector(ileriButtonTapped), for: .touchUpInside)
        ileriButton.frame = CGRect(x: 0, y: 0, width: 54, height: 26)
        
        let ileriBarButtonItem = UIBarButtonItem(customView: ileriButton)
        self.navigationItem.rightBarButtonItem = ileriBarButtonItem
    }
    func checkUsernameUniqueness(username: String, completion: @escaping (Bool) -> Void) {
        
        let usersRef = Firestore.firestore().collection("users")
        usersRef.whereField("username", isEqualTo: username).getDocuments { [weak self] (querySnapshot, error) in
            DispatchQueue.main.async {
                
                if error != nil {
                    self?.isUsernameUnique = false
                } else if querySnapshot!.documents.isEmpty {
                    self?.isUsernameUnique = true
                } else {
                    self?.isUsernameUnique = false
                }
                self?.userNameWarningLabel.isHidden = self?.isUsernameUnique ?? false
                self?.userConstraint.constant = self?.isUsernameUnique ?? false ? 8 : 33
                UIView.animate(withDuration: 0.3) {
                    self?.view.layoutIfNeeded()
                }
                self?.updateIleriButtonState()
                
                completion(self?.isUsernameUnique ?? false)
            }
        }
    }
    
    @objc func ileriButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
                   let surname = surnameTextField.text, !surname.isEmpty,
                   let birthDate = dateBirthTextField.text, !birthDate.isEmpty,
                   let username = userNameTextField.text, !username.isEmpty,
                   var phoneNumber = numberTextField.text, !phoneNumber.isEmpty else {
                 showAlert(message: "Lütfen tüm alanları doldurun.")
                 return
             }
             
             if !phoneNumber.starts(with: "+") {
                 phoneNumber = "+90\(phoneNumber)"
             }
        let email = "\(username)@demlak.com"
             
             let userInfo: [String: Any] = [
                 "name": name,
                 "surname": surname,
                 "birthDate": birthDate,
                 "phoneNumber": phoneNumber,
                 "username" : username,
                 "email": email
             ]
             UserDefaults.standard.setValue(userInfo, forKey: "userInfo")
             
             PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                 if let error = error {
                     self.showAlert(message: "Doğrulama hatası: \(error.localizedDescription)")
                     return
                 }
                 UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                 DispatchQueue.main.async {
                     let numberApproveVC = NumberApprove(nibName: "NumberApprove", bundle: nil)
                     self.navigationController?.pushViewController(numberApproveVC, animated: true)
                 }
             }
         }

    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Uyarı", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        self.present(alert, animated: true)
    }
    
    private func setupCancelButton() {
        let cancelButton = UIBarButtonItem(title: "İptal", style: .plain, target: self, action: #selector(cancelAction))
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc func cancelAction() {
        self.dismiss(animated: true, completion: nil)
    }
    func isValidUsername(_ username: String) -> Bool {
        return !username.isEmpty && username.count >= 3
    }
 
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if textField == userNameTextField {
            guard let username = userNameTextField.text, !username.isEmpty else { return }
            
            checkUsernameUniqueness(username: username) { isUnique in
                DispatchQueue.main.async {
                    self.updateValidationIcon(textField: self.userNameTextField, isValid: isUnique)
                }
            }
        }
        if textField == numberTextField {
            guard let number = numberTextField.text, !number.isEmpty else {
                phoneNumberLabel.isHidden = true
                numberTextField.rightView = nil
                return
            }
            
            let isValidNumber = isValidTurkishPhoneNumber(number)
            phoneNumberLabel.isHidden = !isValidNumber
            updatePhoneNumberValidationIcon(textField: numberTextField)
        }
        
        let textIsNotEmpty = !(textField.text?.isEmpty ?? true)
        
        switch textField {
        case nameTextField:
            nameLabel.isHidden = !textIsNotEmpty
            updateValidationIcon(textField: nameTextField, isValid: textIsNotEmpty && (nameTextField.text?.allSatisfy({ $0.isLetter }) ?? false))
        case surnameTextField:
            surnameLabel.isHidden = !textIsNotEmpty
            updateValidationIcon(textField: surnameTextField, isValid: textIsNotEmpty && (surnameTextField.text?.allSatisfy({ $0.isLetter }) ?? false))
        case dateBirthTextField:
            dateOfBirthLabel.isHidden = !textIsNotEmpty
        case numberTextField:
            phoneNumberLabel.isHidden = !textIsNotEmpty
        case userNameTextField:
            userNameLabel.isHidden = !textIsNotEmpty
            updatePhoneNumberValidationIcon(textField: numberTextField)
        default:
            break
        }
        
        updateIleriButtonState()
        guard let text = textField.text, !text.isEmpty else {
            textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
            return
        }
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.contentMode = .scaleAspectFit
        
        if textField == nameTextField || textField == surnameTextField {
            if !text.allSatisfy({ $0.isLetter }) {
                imageView.image = UIImage(systemName: "xmark.circle.fill")
                imageView.tintColor = .red
            } else {
                imageView.image = UIImage(systemName: "checkmark.circle.fill")
                imageView.tintColor = .link
            }
            
            UIView.transition(with: imageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                let paddingView = UIView(frame: CGRect(x: -10, y: 0, width: 30, height: 20))
                paddingView.addSubview(imageView)
                textField.rightView = paddingView
            }, completion: nil)
        }
    }
    func updateValidationIcon(textField: UITextField, isValid: Bool) {
        let imageName = isValid ? "checkmark.circle.fill" : "xmark.circle.fill"
        let imageColor = isValid ? UIColor.link : UIColor.red
        
        let imageView = UIImageView(image: UIImage(systemName: imageName))
        imageView.tintColor = imageColor
        
        let paddingView = UIView(frame: CGRect(x: -10, y: 0, width: 30, height: 20))
        paddingView.addSubview(imageView)
        
        UIView.transition(with: imageView, duration: 0.25, options: .transitionCrossDissolve, animations: {
            textField.rightView = paddingView
        }, completion: nil)
    }
    
    func isValidTurkishPhoneNumber(_ number: String) -> Bool {
        let cleanedNumber = number.replacingOccurrences(of: "[\\s.-]", with: "", options: .regularExpression)
        
        let regex = "^(5\\d{2}\\d{7}|05\\d{2}\\d{7})$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: cleanedNumber)
    }
    func updatePhoneNumberValidationIcon(textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else {
            textField.rightView = nil
            return
        }
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.contentMode = .scaleAspectFit
        
        if isValidTurkishPhoneNumber(text) {
            imageView.image = UIImage(systemName: "checkmark.circle.fill")
            imageView.tintColor = .link
        } else {
            imageView.image = UIImage(systemName: "xmark.circle.fill")
            imageView.tintColor = .red
        }
        
        let paddingView = UIView(frame: CGRect(x: -10, y: 0, width: 30, height: 20))
        paddingView.addSubview(imageView)
        textField.rightView = paddingView
    }
    private func updateAgeValidationIcon() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.contentMode = .scaleAspectFit
        
        if isValidDateOfBirth(date: datePicker.date) {
            imageView.image = UIImage(systemName: "checkmark.circle.fill")
            imageView.tintColor = .link
        } else {
            imageView.image = UIImage(systemName: "xmark.circle.fill")
            imageView.tintColor = .red
        }
        
        let paddingView = UIView(frame: CGRect(x: -10, y: 0, width: 30, height: 20)) // Padding ayarınız burada
        paddingView.addSubview(imageView)
        
        UIView.transition(with: imageView, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.dateBirthTextField.rightView = paddingView
        }, completion: nil)
        
        dateBirthTextField.rightViewMode = .always
    }
    func isValidDateOfBirth(date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: date, to: now)
        if let age = ageComponents.year, age >= 12 {
            return true
        }
        return false
    }
    
    private func calculateAge(birthday: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
        return ageComponents.year ?? 0
    }
    
    @objc func dismissDatePicker() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "tr_TR")
        dateBirthTextField.text = formatter.string(from: datePicker.date)
        view.endEditing(true)
        updateAgeValidationIcon()
        updateIleriButtonState()
    }
    
    func createDatePicker() {
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        datePicker.locale = Locale(identifier: "tr_TR")
        datePicker.datePickerMode = .date
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Tamam", style: .plain, target: self, action: #selector(dismissDatePicker))
        toolbar.setItems([doneButton], animated: true)
        dateBirthTextField.inputAccessoryView = toolbar
        dateBirthTextField.inputView = datePicker
    }
    private func updateIleriButtonState() {
        let isNameValid = isFieldValid(nameTextField)
        let isSurnameValid = isFieldValid(surnameTextField)
        let isDateOfBirthValid = isFieldValid(dateBirthTextField)
        let isPhoneNumberValid = isFieldValid(numberTextField)
        let isUsernameValid = isUsernameUnique
        
        let allFieldsAreValid = isNameValid && isSurnameValid && isDateOfBirthValid && isPhoneNumberValid && isUsernameValid
        ileriButton.isEnabled = allFieldsAreValid
        ileriButton.alpha = allFieldsAreValid ? 1.0 : 0.5
    }
    
    private func isFieldValid(_ textField: UITextField) -> Bool {
        if textField != userNameTextField {
            guard let imageView = textField.rightView?.subviews.first as? UIImageView else {
                return false
            }
            return imageView.image == UIImage(systemName: "checkmark.circle.fill")
        } else {
            return isUserNameValid
        }
    }
}
