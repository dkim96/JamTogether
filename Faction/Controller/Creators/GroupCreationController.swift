

import UIKit
import Firebase
import CoreLocation

/*
 ATTENTION: Any changes to Faction should be changed within protocol afterwards!!!
 
 */

class GroupCreationController: UIViewController, CLLocationManagerDelegate {
    
    //var messagesController: MessagesController? // optional to add to view screen line 55 fetchUserAndSetupNavBarTitle()
    
    let locationManager = CLLocationManager()
    var imagePicker = UIImagePickerController()
    var selectedImage : UIImage!
    var imgLat : CLLocationDegrees? = nil
    var imgLon : CLLocationDegrees? = nil
    var privateGroup = false
    
    let alert: UIAlertController = {
        let at = UIAlertController(title: "Unable to continue", message: "Please enter values in Group Name and Group Type.", preferredStyle: .alert)
        at.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        return at
    }()
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Quick Create Group", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        
        return button
    }()
    
    lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Continue", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleLoginRegister() {
        
        handleLogin()
        
    }
    
    @objc func handleContinue() {
        
        // Fill in blanks to next container. Move to next controller.
        if((emailTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)!) {
            self.present(alert, animated: true)
            return
        }
        
        let dummySettingsViewController = GC2Controller()
        
        dummySettingsViewController.ref = FIRDatabase.database().reference().child("faction")
        dummySettingsViewController.childRef = FIRDatabase.database().reference().child("faction").childByAutoId()
        dummySettingsViewController.latitude = imgLat as AnyObject
        dummySettingsViewController.longitude = imgLon as AnyObject
        dummySettingsViewController.fromId = FIRAuth.auth()!.currentUser!.uid as AnyObject
        dummySettingsViewController.timestamp = Int(Date().timeIntervalSince1970)
        dummySettingsViewController.color = "blue"
        dummySettingsViewController.activity = 10
        dummySettingsViewController.groupName = emailTextField.text!
        dummySettingsViewController.groupType = passwordTextField.text!
        dummySettingsViewController.privateGroup = privateGroup
        
        self.navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    func handleLogin() {
        if((emailTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)!) {
            self.present(alert, animated: true)
            return
        }
        guard let groupName = emailTextField.text, let groupType = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        let latitude = imgLat
        let longitude = imgLon
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        let color = "blue"
        let activity = 10
        
        createNewFaction(latitude: latitude!, longitude: longitude!, fromId: fromId, timestamp: timestamp, color: color, activity: activity, groupName: emailTextField.text!, groupType: passwordTextField.text!, privateGroup: privateGroup, entrancePermission: "Open", description: "", applicationQ: [""], groupPhoto: "")
        let dummySettingsViewController = GroupSearchViewController()
        self.navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Group Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Group Type"
        tf.translatesAutoresizingMaskIntoConstraints = false
        //tf.isSecureTextEntry = true
        return tf
    }()
    
    let privacyField : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = "Private Group"
        lb.textColor = UIColor.white
        lb.numberOfLines = 1
        lb.font = UIFont.boldSystemFont(ofSize: 15)
        return lb
    }()
    
    
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "gameofthrones_splash")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    lazy var controlSwitch: UISwitch = {
        let mySwitch = UISwitch(frame:CGRect(x: 300, y: 313, width: 0, height: 0))
        //let mySwitch = UISwitch()
        //let switchDemo=UISwitch(frame:CGRect(x: 150, y: 150, width: 0, height: 0))
        mySwitch.setOn(false, animated: false)
        //mySwitch.tintColor = UIColor.blue
        //mySwitch.onTintColor = UIColor.cyan
        //mySwitch.thumbTintColor = UIColor.red
        //mySwitch.backgroundColor = UIColor.yellow
        mySwitch.addTarget(self, action: #selector(switchChanged(sender:)), for: UIControlEvents.valueChanged)
        return mySwitch
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(continueButton)
        view.addSubview(privacyField)
        view.addSubview(controlSwitch)
        
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupProfileImageView()
        // setupLoginRegisterSegmentedControl()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation() // start location manager
        }
        /////
        
    }
    
    
    
    func switchChanged(sender: UISwitch!) {
        print("Switch value is \(sender.isOn)")
        if(sender.isOn){
            privateGroup = true
        }
        else{
            privateGroup = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var locValue:CLLocationCoordinate2D = manager.location!.coordinate
        //print("ADDPHOTO !!!! locations = \(locValue.latitude) \(locValue.longitude)")
        imgLat = locValue.latitude
        imgLon = locValue.longitude
        //print(imgLat)
        //print(imgLon)
        
    }
    
    func setupProfileImageView() {
        //need x, y, width, height constraints
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupInputsContainerView() {
        //need x, y, width, height constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        
        //need x, y, width, height constraints
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2)
        emailTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    func setupLoginRegisterButton() {
        //need x, y, width, height constraints
        
        privacyField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: -12).isActive = true
        privacyField.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        privacyField.widthAnchor.constraint(equalToConstant: 140).isActive = true
        privacyField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //controlSwitch.leftAnchor.constraint(equalTo: privacyField.rightAnchor).isActive = true
        //controlSwitch.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        //controlSwitch.widthAnchor.constraint(equalToConstant: 40).isActive = true
        //controlSwitch.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: privacyField.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        continueButton.topAnchor.constraint(equalTo: loginRegisterButton.bottomAnchor, constant: 12).isActive = true
        continueButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        continueButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}










