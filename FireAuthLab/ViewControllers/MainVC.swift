//
//  ViewController.swift
//  FireAuthLab
//
//  Created by Tsering Lama on 3/2/20.
//  Copyright © 2020 Tsering Lama. All rights reserved.
//

import UIKit
import FirebaseAuth
import Kingfisher

class MainVC: UIViewController {
    
    @IBOutlet weak var userPIc: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var userTF: UITextField!
    
    private lazy var imagePickerController: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.delegate = self
        return ip
    }()
    
    private lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer()
        gesture.addTarget(self, action: #selector(showPhotoOptions))
        return gesture
    }()
    
    
    private var selectedImage: UIImage? {
        didSet {
            userPIc.image = selectedImage
        }
    }
    
    private let storageService = StorageServices()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userPIc.isUserInteractionEnabled = true
        userPIc.addGestureRecognizer(longPressGesture)
        userTF.delegate = self 
        updateUI()
    }
    
    private func updateUI() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        // user - displayName, email, phonenumber, photoURL
        email.text = user.email
        userName.text = user.displayName
        userPIc.kf.setImage(with: user.photoURL)
    }
    
    @objc
    private func showPhotoOptions() {
        let alertController = UIAlertController(title: "Choose option", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { alertAction in
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true)
        }
        
        let photoLibrary = UIAlertAction(title: "Library", style: .default) { alertAction in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(cameraAction)
        }
        
        alertController.addAction(photoLibrary)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    
    @IBAction func signOut(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            UIViewController.showVC(storyboard: "LoginStoryboard", VCid: "LoginVC")
        } catch {
            DispatchQueue.main.async {
                self.showStatusAlert(withImage: UIImage(systemName: "exclamationmark.triangle.fill"), title: "Fail", message: "Couldnt sign out")
            }
        }
    }
    
    
    
    @IBAction func update(_ sender: UIButton) {
        guard let displayName = userTF.text, !displayName.isEmpty, let selectedImage = selectedImage else {
            showStatusAlert(withImage: UIImage(systemName: "exclamationmark.triangle.fill"), title: "Fail", message: "Missing Fields")
            return
        }
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let resizeImage = UIImage.resizeImage(originalImage: selectedImage, rect: userPIc.bounds)
        
        storageService.uploadPhoto(userId: user.uid, image: resizeImage) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showStatusAlert(withImage: UIImage(systemName: "exclamationmark.triangle.fill"), title: "Fail", message: "Error upload:\(error.localizedDescription)")
                }
            case .success(let url):
                let request = Auth.auth().currentUser?.createProfileChangeRequest()
                
                request?.displayName = displayName
                
                request?.photoURL = url
                
                request?.commitChanges(completion: { [unowned self] (error) in
                    if let error = error {
                        DispatchQueue.main.async {
                            self?.showStatusAlert(withImage: UIImage(systemName: "exclamationmark.triangle.fill"), title: "Fail", message: "Couldnt commit changes:\(error.localizedDescription)")
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.showStatusAlert(withImage: UIImage(systemName: "star.fill"), title: "Success", message: "Changes made")
                        }
                    }
                })
            }
        }
    }
    
    
    @IBAction func deletePressed(_ sender: UIButton) {
        
        print("deleted")
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        user.delete(completion: { [weak self] (error) in
            if let error = error {
                self?.showStatusAlert(withImage: UIImage(systemName: "exclamationmark.triangle.fill"), title: "Error", message: error.localizedDescription)
            } else {
                self?.showStatusAlert(withImage: UIImage(systemName: "star.fill"), title: "Success", message: "Changes made")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    UIViewController.showVC(storyboard: "LoginStoryboard", VCid: "LoginVC")
                }
                
            }
        })
        
    }
    
    
}

extension MainVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError()
        }
        selectedImage = image
        dismiss(animated: true)
    }
}

extension MainVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

