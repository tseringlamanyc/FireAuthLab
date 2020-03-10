//
//  ViewController.swift
//  FireAuthLab
//
//  Created by Tsering Lama on 3/2/20.
//  Copyright © 2020 Tsering Lama. All rights reserved.
//

import UIKit
import FirebaseAuth

class MainVC: UIViewController {
    
    @IBOutlet weak var userPIc: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var email: UILabel!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userPIc.isUserInteractionEnabled = true
        userPIc.addGestureRecognizer(longPressGesture)
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
    
    
    @IBAction func signOut(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            UIViewController.showVC(storyboard: "Login", VCid: "LoginVC")
        } catch {
            DispatchQueue.main.async {
                self.showStatusAlert(withImage: UIImage(systemName: "exclamationmark.triangle.fill"), title: "Fail", message: "Couldnt sign out")
            }
        }
    }



@IBAction func update(_ sender: UIBarButtonItem) {
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

