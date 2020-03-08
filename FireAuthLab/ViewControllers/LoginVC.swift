//
//  LoginVC.swift
//  FireAuthLab
//
//  Created by Tsering Lama on 3/2/20.
//  Copyright © 2020 Tsering Lama. All rights reserved.
//


import UIKit
import Comets
import Gradients
import TransitionButton

enum AccountState {
    case existingUser
    case newUser
}

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    let backgroundLayer = Gradients.amourAmour.layer
    
    private var authSession = AuthenticationSession()
    
    private var accountState: AccountState = .existingUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startComets()
        emailTF.delegate = self
        passwordTF.delegate = self
    }
    
    private func startComets() {
        
        // Customize your comet
        let width = view.bounds.width
        let height = view.bounds.height
        let comets = [Comet(startPoint: CGPoint(x: 100, y: 0),
                            endPoint: CGPoint(x: 0, y: 100),
                            lineColor: UIColor.white.withAlphaComponent(0.2),
                            cometColor: UIColor.black),
                      Comet(startPoint: CGPoint(x: 0.4 * width, y: 0),
                            endPoint: CGPoint(x: width, y: 0.8 * width),
                            lineColor: UIColor.white.withAlphaComponent(0.2),
                            cometColor: UIColor.black),
                      Comet(startPoint: CGPoint(x: 0.8 * width, y: 0),
                            endPoint: CGPoint(x: width, y: 0.2 * width),
                            lineColor: UIColor.white.withAlphaComponent(0.2),
                            cometColor: UIColor.black),
                      Comet(startPoint: CGPoint(x: width, y: 0.2 * height),
                            endPoint: CGPoint(x: 0, y: 0.25 * height),
                            lineColor: UIColor.white.withAlphaComponent(0.2),
                            cometColor: UIColor.black),
                      Comet(startPoint: CGPoint(x: 0, y: height - 0.8 * width),
                            endPoint: CGPoint(x: 0.6 * width, y: height),
                            lineColor: UIColor.white.withAlphaComponent(0.2),
                            cometColor: UIColor.black),
                      Comet(startPoint: CGPoint(x: width - 100, y: height),
                            endPoint: CGPoint(x: width, y: height - 100),
                            lineColor: UIColor.white.withAlphaComponent(0.2),
                            cometColor: UIColor.black),
                      Comet(startPoint: CGPoint(x: 0, y: 0.8 * height),
                            endPoint: CGPoint(x: width, y: 0.75 * height),
                            lineColor: UIColor.white.withAlphaComponent(0.2),
                            cometColor: UIColor.black),
                      Comet(startPoint: CGPoint(x: 0, y: 100),
                            endPoint: CGPoint(x: 100, y: 0),
                            lineColor: UIColor.white.withAlphaComponent(0.2),
                            cometColor: UIColor.black),
                      Comet(startPoint: CGPoint(x: 0, y: 0.4 * width),
                            endPoint: CGPoint(x: width, y: 0.8 * width),
                            lineColor: UIColor.white.withAlphaComponent(0.2),
                            cometColor: UIColor.black),
                      Comet(startPoint: CGPoint(x: 0, y: 0.8 * width),
                            endPoint: CGPoint(x: width, y: 0.2 * width),
                            lineColor: UIColor.white.withAlphaComponent(0.2),
                            cometColor: UIColor.black),
                      Comet(startPoint: CGPoint(x: 0.2 * height, y: width),
                            endPoint: CGPoint(x: 0, y: 0.25 * height),
                            lineColor: UIColor.white.withAlphaComponent(0.2),
                            cometColor: UIColor.black),
                      Comet(startPoint: CGPoint(x: 0, y: height - 0.8 * width),
                            endPoint: CGPoint(x: 0.6 * width, y: height),
                            lineColor: UIColor.white.withAlphaComponent(0.2),
                            cometColor: UIColor.black),
                      Comet(startPoint: CGPoint(x: width - 100, y: height),
                            endPoint: CGPoint(x: width, y: height - 100),
                            lineColor: UIColor.white.withAlphaComponent(0.2),
                            cometColor: UIColor.black),
                      Comet(startPoint: CGPoint(x: 0, y: 0.8 * height),
                            endPoint: CGPoint(x: width, y: 0.75 * height),
                            lineColor: UIColor.white.withAlphaComponent(0.2),
                            cometColor: UIColor.black)]
        
        // draw track and animate
        for comet in comets {
            view.layer.addSublayer(comet.drawLine())
            view.layer.addSublayer(comet.animate())
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundLayer.frame = view.bounds
    }
    
    
    @IBAction func loginButton(_ sender: TransitionButton) {
        sender.startAnimation()
        guard let email = emailTF.text, !email.isEmpty, let password = passwordTF.text, !password.isEmpty else {
            showStatusAlert(withImage: UIImage(systemName: "exclamationmark.triangle.fill"), title: "Fail", message: "Please fill all both fields")
            sender.stopAnimation()
            return
        }
        
        authSession.signExistingUser(email: email, password: password) { [weak self](result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorLabel.text = "Error:\(error)"
                    sender.stopAnimation()
                }
            case .success(_):
                DispatchQueue.main.async {
                    sender.stopAnimation(animationStyle: .expand, completion: {
                        self?.navigateToMainView()
                    })
                }
            }
        }
        
    }
    
    
    @IBAction func signUpButton(_ sender: TransitionButton) {
        guard let email = emailTF.text, !email.isEmpty, let password = passwordTF.text, !password.isEmpty else {
            showStatusAlert(withImage: UIImage(systemName: "exclamationmark.triangle.fill"), title: "Fail", message: "Please fill all both fields")
            sender.stopAnimation()
            return
        }
        authSession.createNewUser(email: email, password: password) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorLabel.text = "Error: \(error)"
                    self?.errorLabel.textColor = .systemRed
                }
            case .success(_):
                DispatchQueue.main.async {
                    self?.showStatusAlert(withImage: UIImage(systemName: "star.fill"), title: "Success", message: "Account created")
                }
            }
        }
        
    }
    
    private func navigateToMainView() {
        UIViewController.showVC(storyboard: "Main", VCid: "MainVC")
    }
    
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
