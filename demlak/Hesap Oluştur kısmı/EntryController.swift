//
//  EntryController.swift
//  demlak
//
//  Created by Davut Dalmış on 28.03.2024.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import AuthenticationServices
import FirebaseFirestoreInternal

class EntryController: UIViewController, ASAuthorizationControllerDelegate {
    @IBOutlet weak var googleSignIn: UIButton!
    @IBOutlet weak var appleSignIn: UIButton!
    @IBOutlet weak var loginIn: UIButton!
    var handle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleSignIn.layer.borderWidth = 1.0
        googleSignIn.layer.borderColor = UIColor.lightGray.cgColor
        googleSignIn.layer.cornerRadius = 22.0
        googleSignIn.layer.masksToBounds = true
        googleSignIn.backgroundColor = .systemBackground
        googleSignIn.setTitleColor(UIColor.label, for: .normal)
        
        appleSignIn.layer.borderWidth = 1.0
        appleSignIn.layer.borderColor = UIColor.lightGray.cgColor
        appleSignIn.layer.cornerRadius = 22.0
        appleSignIn.layer.masksToBounds = true
        appleSignIn.backgroundColor = .systemBackground
        
        loginIn.layer.borderWidth = 1.0
        loginIn.layer.borderColor = UIColor.lightGray.cgColor
        loginIn.layer.cornerRadius = 18.0
        loginIn.layer.masksToBounds = true
        loginIn.backgroundColor = .systemBackground
        loginIn.setTitleColor(UIColor.label, for: .normal)
        
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
    @IBAction func girisYapClicked(_ sender: Any) {
        let loginScreenVC = LoginScreen(nibName: "LoginScreen", bundle: nil)
           let navController = UINavigationController(rootViewController: loginScreenVC)
           navController.modalPresentationStyle = .fullScreen
           self.present(navController, animated: true, completion: nil)
       }
    
    @IBAction func googleGirisClicked(_ sender: UIButton) {
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
       func convertToEnglishCharacters(_ text: String) -> String {
           let turkishCharacters = ["ç", "ş", "ğ", "ü", "ö", "ı"]
           let englishCharacters = ["c", "s", "g", "u", "o", "i"]
           var newText = text
           
           for (index, turkishChar) in turkishCharacters.enumerated() {
               newText = newText.replacingOccurrences(of: turkishChar, with: englishCharacters[index])
               newText = newText.replacingOccurrences(of: turkishChar.uppercased(), with: englishCharacters[index].uppercased())
           }
           
           return newText
       }
    func checkUsernameUnique(username: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").whereField("username", isEqualTo: username).getDocuments { snapshot, error in
            if let error = error {
                print("Firestore kullanıcı adı kontrolü sırasında hata oluştu: \(error)")
                completion(false)
            } else if let snapshot = snapshot, snapshot.documents.isEmpty {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func updateUserProfile(authResult: AuthDataResult, fullName: String, email: String, username: String) {
        let db = Firestore.firestore()
        let userProfile = [
            "fullName": fullName,
            "email": email,
            "username": username
        ]
        db.collection("users").document(authResult.user.uid).setData(userProfile) { error in
            if let error = error {
                print("Firestore kullanıcı profili güncelleme sırasında hata oluştu: \(error)")
            } else {
                print("Kullanıcı profili başarıyla güncellendi.")
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    @IBAction func appleGirisClicked(_ sender: Any) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    }

    @IBAction func gizlilikPolitikasiClicked(_ sender: Any) {
        performSegue(withIdentifier: "gizPolİdentifier", sender: nil)
    }
}
