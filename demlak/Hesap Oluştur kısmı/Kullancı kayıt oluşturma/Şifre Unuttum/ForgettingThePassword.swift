//
//  ForgettingThePassword.swift
//  demlak
//
//  Created by Davut Dalmış on 30.03.2024.
//

import UIKit
import FirebaseFirestoreInternal
import FirebaseAuth

class ForgettingThePassword: UIViewController {
    @IBOutlet weak var numberOrUsername: UITextField!
    let ileriButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberOrUsername.layer.borderWidth = 1.0 / UIScreen.main.scale
        numberOrUsername.layer.borderColor = UIColor.gray.cgColor
        numberOrUsername.layer.cornerRadius = 11.0
        numberOrUsername.clipsToBounds = true
        
        numberOrUsername.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        ileriButton.addTarget(self, action: #selector(ileriButtonTapped), for: .touchUpInside)
        
        setupNavigationBar()
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
        ileriButton.frame = CGRect(x: 0, y: 0, width: 54, height: 26)
        
        let ileriBarButtonItem = UIBarButtonItem(customView: ileriButton)
        self.navigationItem.rightBarButtonItem = ileriBarButtonItem
    }
    @objc func ileriButtonTapped() {
        guard let userInput = numberOrUsername.text, !userInput.isEmpty else {
            showAlert(message: "Lütfen kullanıcı adınızı veya telefon numaranızı girin.")
            return
        }
        
        var phoneNumberForVerification = userInput
        if userInput.hasPrefix("05") {
            phoneNumberForVerification = "+9" + userInput.dropFirst(1)
        } else if userInput.hasPrefix("5") {
            phoneNumberForVerification = "+90" + userInput
        }
        
        let usersRef = Firestore.firestore().collection("users")
        let field = userInput.hasPrefix("5") ? "phoneNumber" : "username"
        
        usersRef.whereField(field, isEqualTo: phoneNumberForVerification).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(message: "Hata: \(error.localizedDescription)")
                return
            }
            
            if let userDocument = querySnapshot?.documents.first, let phoneNumber = userDocument.data()["phoneNumber"] as? String {
                // Kullanıcı bulundu, telefon numarasına doğrulama kodu gönder
                self.sendVerificationCode(to: phoneNumber)
            } else {
                // Kullanıcı bulunamadı
                self.showAlert(message: "Kullanıcı adı veya telefon numarasıyla eşleşen bir kullanıcı bulunamadı.")
            }
        }
    }

    private func sendVerificationCode(to phoneNumber: String) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                self.showAlert(message: "Doğrulama kodu gönderilemedi: \(error.localizedDescription)")
            } else {
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                // Kullanıcıya onay ekranına yönlendir
                self.navigateToPasswordApproval()
            }
        }
    }

    private func navigateToPasswordApproval() {
        let passwordApprovalVC = PasswordApproval(nibName: "PasswordApproval", bundle: nil)
        navigationController?.pushViewController(passwordApprovalVC, animated: true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Uyarı", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        self.present(alert, animated: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            ileriButton.isEnabled = true
        } else {
            ileriButton.isEnabled = false
        }
    }
}
