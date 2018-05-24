

import UIKit
import Firebase
/*
 ATTENTION: Any changes to User should be changed within protocol afterwards!!!
 
 */

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func handleRegister() {
        //guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text, let profileImage = self.profileImageView.image else {
            print("Form is not valid")
            return
        //}
        //createNewUser(name: name, email: email, password: password, profileImage: profileImage, nickname: nicknameTextField.text!, controller: self)
    }
    
    
    func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            //profileImageView.image = selectedImage
            print("img selection turned off")
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
}
