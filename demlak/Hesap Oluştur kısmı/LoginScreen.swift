//
//  LoginScreen.swift
//  demlak
//
//  Created by Davut Dalmış on 28.03.2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import GoogleSignIn

class LoginScreen: UIViewController {
    
    @IBOutlet weak var kullaniciAdiTextField: UITextField!
    @IBOutlet weak var sifreTextField: UITextField!
    @IBOutlet weak var LoginTapped: UIButton!
    
    var sifreGosterGizleButonu: UIButton!
    var handle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        configurePasswordTextField()
        kullaniciAdiTextField.layer.borderWidth = 0.7
        kullaniciAdiTextField.layer.borderColor = UIColor.systemGray4.cgColor
        sifreTextField.layer.borderWidth = 0.7
        sifreTextField.layer.borderColor = UIColor.systemGray4.cgColor
        kullaniciAdiTextField.layer.cornerRadius = 12.0
        kullaniciAdiTextField.clipsToBounds = true
        sifreTextField.layer.cornerRadius = 12.0
        sifreTextField.clipsToBounds = true
        let titleLabel = UILabel()
        titleLabel.text = "d"
        titleLabel.font = UIFont.systemFont(ofSize: 48)
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.goToMainApp()
            } else {
                self.showLoginScreen()
            }
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          if let handle = handle {
              Auth.auth().removeStateDidChangeListener(handle)
          }
      }
    func showLoginScreen() {
        goToMainApp()
        
    }

    
    private func configurePasswordTextField() {
        sifreGosterGizleButonu = UIButton(type: .custom)
        sifreGosterGizleButonu.setImage(UIImage(named: "eye.slash"), for: .normal)
        sifreGosterGizleButonu.setImage(UIImage(named: "eye"), for: .selected)
        sifreGosterGizleButonu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        sifreGosterGizleButonu.addTarget(self, action: #selector(sifreGosterGizleTapped), for: .touchUpInside)
        sifreTextField.rightView = sifreGosterGizleButonu
        sifreTextField.rightViewMode = .always
        sifreTextField.isSecureTextEntry = true
    }
    
    @objc func sifreGosterGizleTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sifreTextField.isSecureTextEntry = !sender.isSelected
    }
    
    @IBAction func hesapOlusturunClicked(_ sender: Any) {
        let createAccountVC = AccountController(nibName: "AccountController", bundle: nil)
          createAccountVC.title = "Hesap Oluştur"
          let navController = UINavigationController(rootViewController: createAccountVC)
          createAccountVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "İptal", style: .plain, target: self, action: #selector(dismissCreateAccountVC))
          navController.modalPresentationStyle = .fullScreen
          self.present(navController, animated: true, completion: nil)
      }

      @objc func dismissCreateAccountVC() {
          self.dismiss(animated: true, completion: nil)
      }
    @IBAction func yardımClicked(_ sender: Any) {
    }
    @IBAction func sifremiUnuttumClicked(_ sender: Any) {
        let createForgettingVC = ForgettingThePassword(nibName: "ForgettingThePassword", bundle: nil)
          let navController = UINavigationController(rootViewController: createForgettingVC)
        createForgettingVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "İptal", style: .plain, target: self, action: #selector(dismissCreateAccountVC))
          navController.modalPresentationStyle = .fullScreen
          self.present(navController, animated: true, completion: nil)
      }
    @IBAction func girisYapClicked(_ sender: Any) {
        guard let kullaniciAdiVeyaTelefon = kullaniciAdiTextField.text, !kullaniciAdiVeyaTelefon.isEmpty,
                 let sifre = sifreTextField.text, !sifre.isEmpty else {
               showAlert(message: "Kullanıcı adı/telefon ve şifre girilmelidir.")
               return
           }

           let db = Firestore.firestore()
           var query: Query
           if kullaniciAdiVeyaTelefon.isPhoneNumber {
               query = db.collection("users").whereField("phoneNumber", isEqualTo: "+90\(kullaniciAdiVeyaTelefon)")
           } else {
               query = db.collection("users").whereField("username", isEqualTo: kullaniciAdiVeyaTelefon)
           }
           
           query.getDocuments { [weak self] (querySnapshot, error) in
               if let error = error {
                   self?.showAlert(message: "Bir hata oluştu: \(error.localizedDescription)")
                   return
               }

               guard let document = querySnapshot?.documents.first else {
                   self?.showAlert(message: "Girilen bilgiler yanlış veya kullanıcı bulunamadı.")
                   return
               }

               if let email = document.data()["email"] as? String {
                   Auth.auth().signIn(withEmail: email, password: sifre) { (authResult, error) in
                       if error != nil {
                           self?.showAlert(message: "Girilen bilgiler yanlış veya kullanıcı bulunamadı.")
                       } else {
                           self?.goToMainApp()
                       }
                   }
               } else {
                   self?.showAlert(message: "Bir hata oluştu, lütfen tekrar deneyin.")
               }
           }
       }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true)
    }
    @IBAction func googleSignIn(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
          let config = GIDConfiguration(clientID: clientID)
          GIDSignIn.sharedInstance.configuration = config
          GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
              guard let _ = result, error == nil else { return }
              guard let user = result?.user, let idToken = user.idToken?.tokenString else { return }
              self?.signInWithGoogle(idtoken: idToken, accessToken: user.accessToken.tokenString)
          }
      }

    func signInWithGoogle(idtoken: String, accessToken: String) {
        let credential = GoogleAuthProvider.credential(withIDToken: idtoken, accessToken: accessToken)
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                print("Google ile giriş yapılamadı: \(error.localizedDescription)")
                self.showAlert(message: "Google ile giriş yapılamadı: \(error.localizedDescription)")
            } else if let authResult = authResult {
                let fullName = authResult.user.displayName ?? ""
                let email = authResult.user.email ?? ""
                let username = email.components(separatedBy: "@").first?.replacingOccurrences(of: ".", with: "_").lowercased() ?? ""

                let userProfile = [
                    "fullName": fullName,
                    "email": email,
                    "username": username
                ]

                let db = Firestore.firestore()
                db.collection("users").document(authResult.user.uid).setData(userProfile, merge: true) { error in
                    if let error = error {
                        print("Firestore kullanıcı profili güncelleme sırasında hata oluştu: \(error)")
                    } else {
                        print("Kullanıcı profili başarıyla güncellendi.")
                        // Kullanıcı girişi başarılı olduysa AppTabBarController'a yönlendir
                        DispatchQueue.main.async {
                            self.goToMainApp()
                        }
                    }
                }
            }
        }
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
    @IBAction func appleSignIn(_ sender: Any) {
    }
}
extension String {
    var isPhoneNumber: Bool {
        let types: NSTextCheckingResult.CheckingType = .phoneNumber
        do {
            let detector = try NSDataDetector(types: types.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count && self.count == 10
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}
