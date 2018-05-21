/*
Get the code,
specifically, use id to get user, 
 
 
 */


import UIKit
import Firebase

class PhotoViewController: UIViewController, UINavigationControllerDelegate {
    
    //give the bubble
    var photoId = String()
    var profilePic = UIImage()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.image = UIImage(named: "Home")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    let userImageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.image = UIImage(named: "Home")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    let nameField : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .left
        lb.text = "username"
        //lb.textColor = UIColor.white
        lb.numberOfLines = 1
        lb.font = UIFont.boldSystemFont(ofSize: 20)
        return lb
    }()
    let locationField : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .left
        lb.text = "UCLA"
        lb.textColor = UIColor.gray
        lb.numberOfLines = 1
        lb.font = UIFont.systemFont(ofSize: 18)
        return lb
    }()
    
    let likesField : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .left
        lb.text = "99 likes"
        //lb.textColor = UIColor.white
        lb.numberOfLines = 1
        lb.font = UIFont.boldSystemFont(ofSize: 20)
        return lb
    }()
    let captionField : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .left
        lb.text = "insert caption here!"
        //lb.textColor = UIColor.gray
        lb.numberOfLines = 1
        lb.font = UIFont.systemFont(ofSize: 18)
        return lb
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: view.frame.size.width, height: 180))
        self.view.addSubview(navBar);
        let navItem = UINavigationItem(title: "Photo");
        navItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleCancel))
        //let logo = UIImage(named: "tl")
        //let imageView = UIImageView(image:logo)
        //navItem.titleView = imageView
        navBar.layer.zPosition = 3
        navBar.setItems([navItem], animated: false);
        
        
        print(photoId)
        
        fetchUser()
        
        view.addSubview(imageView)
        view.addSubview(userImageView)
        view.addSubview(nameField)
        view.addSubview(locationField)
        view.addSubview(likesField)
        view.addSubview(captionField)
        
        setupImageView()
        setupUserImageView()
        
        NSLayoutConstraint.activate([
            nameField.centerXAnchor.constraint(equalTo: userImageView.centerXAnchor, constant: 160),
            nameField.topAnchor.constraint(equalTo: userImageView.topAnchor, constant: 5),
            nameField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            nameField.heightAnchor.constraint(equalToConstant: 20)])
       
        NSLayoutConstraint.activate([
            locationField.centerXAnchor.constraint(equalTo: userImageView.centerXAnchor, constant: 160),
            locationField.topAnchor.constraint(equalTo: userImageView.topAnchor, constant: 25),
            locationField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            locationField.heightAnchor.constraint(equalToConstant: 20)])
        
        NSLayoutConstraint.activate([
            likesField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            likesField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            likesField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            likesField.heightAnchor.constraint(equalToConstant: 20)])
        
        NSLayoutConstraint.activate([
            captionField.topAnchor.constraint(equalTo: likesField.bottomAnchor, constant: 5),
            captionField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            captionField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            captionField.heightAnchor.constraint(equalToConstant: 20)])
        

    }
    
    
    func setupImageView() {
        //need x, y, width, height constraints
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }
    
    func setupUserImageView() {
        //need x, y, width, height constraints
        userImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -150).isActive = true
        userImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 75).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        userImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func fetchUser() {
        
        let messagesRef = FIRDatabase.database().reference().child("bubbles").child(photoId)
        messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let bubble = Bubble(dictionary: dictionary)
                let url = URL(string: bubble.imageUrl!)
                let data = try? Data(contentsOf: url!)
                let image: UIImage = UIImage(data: data!)!
                self.imageView.image = image
                self.userImageView.image = self.profilePic

                DispatchQueue.main.async(execute: {
                })
            }
            
        }, withCancel: nil)
        
    }

}









