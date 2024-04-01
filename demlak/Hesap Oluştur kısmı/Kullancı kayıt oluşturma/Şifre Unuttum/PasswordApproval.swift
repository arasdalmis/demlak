//
//  PasswordApproval.swift
//  demlak
//
//  Created by Davut Dalmış on 30.03.2024.
//

import UIKit
import FirebaseAuth

class PasswordApproval: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var verifyTextField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    
    let ileriButton = UIButton(type: .system)
    
    var countdownTimer: Timer?
    var totalTime = 100
    let shapeLayer = CAShapeLayer()
    var resendCount = 0
    var lastResendTime: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextField()
        setupTimer()
        setupRing()
        setupNavigationBar()
        verifyTextField.delegate = self
        verifyTextField.keyboardType = .numberPad
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if countdownTimer != nil {
            countdownTimer?.invalidate()
            countdownTimer = nil
        }
    }
    deinit {
        countdownTimer?.invalidate()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 6
    }
    
    func setupTextField() {
        verifyTextField?.layer.borderWidth = 1.0 / UIScreen.main.scale
        verifyTextField?.layer.borderColor = UIColor.gray.cgColor
        verifyTextField?.layer.cornerRadius = 11.0
        verifyTextField?.clipsToBounds = true
    }
    
    func setupTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func setupRing() {
        let centerPoint = CGPoint(x: timeLabel.frame.midX, y: timeLabel.frame.midY)
        let radius = min(timeLabel.frame.width, timeLabel.frame.height) / 2 - 5
        let circlePath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: -(.pi / 2), endAngle: 2 * .pi, clockwise: true)
        
        shapeLayer.path = circlePath.cgPath
        shapeLayer.lineWidth = 2
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 1
        shapeLayer.strokeColor = UIColor.green.cgColor
        timeLabel.superview?.layer.addSublayer(shapeLayer)
    }
    @objc func updateTime() {
        if totalTime != 0 {
            totalTime -= 1
            timeLabel.text = "\(totalTime)"
            let percentage = CGFloat(totalTime) / 100
            shapeLayer.strokeEnd = percentage
            
            if totalTime <= 33 {
                shapeLayer.strokeColor = UIColor.red.cgColor
            } else if totalTime <= 77 {
                shapeLayer.strokeColor = UIColor.orange.cgColor
            }
            
        } else {
            endTimer()
        }
    }
    
    func endTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        showCodeNotReceivedAlert()
    }
    
    @IBAction func helpTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Bilgi", message: nil, preferredStyle: .actionSheet)
        if let lastResendTime = lastResendTime, Date().timeIntervalSince(lastResendTime) < 3600, resendCount >= 3 {
            alert.message = "SMS sınırını aştınız, 1 saat sonra tekrar deneyiniz."
        } else if totalTime > 0 {
            alert.message = "\(totalTime) saniye sonra tekrar kod gönderebileceksiniz."
        } else {
            alert.message = "Kodu şimdi tekrar gönderebilirsiniz."
        }
        
        let resendAction = UIAlertAction(title: "Kodu Tekrar Gönder", style: .default) { [weak self] _ in
            self?.resetTimer()
        }
        resendAction.isEnabled = resendCount < 2 && totalTime <= 0
        let helpAction = UIAlertAction(title: "Yardım", style: .default)
        let cancelAction = UIAlertAction(title: "İptal", style: .cancel)
        alert.addAction(resendAction)
        alert.addAction(helpAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func resetTimer() {
        print("resetTimer çağrıldı")
        let currentTime = Date()
        if resendCount < 2 {
            if let lastResendTime = lastResendTime, currentTime.timeIntervalSince(lastResendTime) < 3600 {
                showLimitExceededAlert()
                return
            }
            
            countdownTimer?.invalidate()
            totalTime = 100
            updateTime()
            setupTimer()
            resendCount += 1
            lastResendTime = currentTime
            
            if let phoneNumber = UserDefaults.standard.string(forKey: "userPhoneNumber") {
                print("Telefon numarası: \(phoneNumber)")
                PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                    if let error = error {
                        print("Doğrulama kodu gönderme hatası: \(error.localizedDescription)")
                        self.showAlert(message: "Doğrulama kodu gönderilemedi: \(error.localizedDescription)")
                        return
                    }
                    UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                    print("Doğrulama kodu başarıyla gönderildi.")
                }
            }
        } else {
            showLimitExceededAlert()
            print("Telefon numarası UserDefaults'ta bulunamadı.")
        }
    }
    func showCodeNotReceivedAlert() {
        if let lastResendTime = lastResendTime, Date().timeIntervalSince(lastResendTime) < 3600, resendCount >= 2 {
            showLimitExceededAlert()
        } else if resendCount < 2 {
            let alert = UIAlertController(title: "Kod Gelmedi Mi?", message: "Eğer kodu almadıysanız, tekrar gönderme seçeneğini kullanabilirsiniz.", preferredStyle: .alert)
            let resendAction = UIAlertAction(title: "Kod Gönder", style: .default) { [weak self] _ in
                self?.resetTimer()
            }
            let cancelAction = UIAlertAction(title: "İptal", style: .cancel)
            alert.addAction(resendAction)
            alert.addAction(cancelAction)
            present(alert, animated: true)
        } else {
            showLimitExceededAlert()
        }
    }
    
    func showLimitExceededAlert() {
        let alert = UIAlertController(title: "Limit Aşıldı", message: "SMS sınırını aştınız, 1 saat sonra tekrar deneyiniz.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    private func setupNavigationBar() {
        ileriButton.setTitle("İleri", for: .normal)
        ileriButton.setTitleColor(.link, for: .normal)
        ileriButton.backgroundColor = .systemBackground
        ileriButton.layer.cornerRadius = 15
        ileriButton.layer.borderWidth = 1.0
        ileriButton.layer.borderColor = UIColor.link.cgColor
        ileriButton.layer.masksToBounds = true
        ileriButton.isEnabled = true
        ileriButton.frame = CGRect(x: 0, y: 0, width: 54, height: 26)
        let ileriBarButtonItem = UIBarButtonItem(customView: ileriButton)
        self.navigationItem.rightBarButtonItem = ileriBarButtonItem
        ileriButton.addTarget(self, action: #selector(ileriButtonTapped), for: .touchUpInside)
    }
    @objc func ileriButtonTapped() {
           guard let verificationCode = verifyTextField.text, !verificationCode.isEmpty,
                 let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {
               showAlert(message: "Doğrulama kodu girilmelidir.")
               return
           }
           
           let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
           
           Auth.auth().signIn(with: credential) { [weak self] _, error in
               if let error = error {
                   self?.showAlert(message: "Doğrulama hatası: \(error.localizedDescription)")
               } else {
                   // Doğrulama başarılı, şifre oluşturma ekranına geçiş yap
                   self?.navigateToCreatePassword()
               }
           }
       }

       func navigateToCreatePassword() {
           DispatchQueue.main.async {
               let createAPasswordVC = CreateAPassword(nibName: "CreateAPassword", bundle: nil)
               self.navigationController?.pushViewController(createAPasswordVC, animated: true)
           }
       }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Uyarı", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        self.present(alert, animated: true)
    }
}
