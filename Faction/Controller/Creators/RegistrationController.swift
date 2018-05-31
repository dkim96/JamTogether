import UIKit
import Firebase
@objcMembers
class RegistrationController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //given values
    var name = ""
    var email = ""
    var password = ""
    var lc = LoginController()
    
    // receieve references for these values
    var ref : AnyObject?
    var childRef : AnyObject?
    var latitude : AnyObject?
    var longitude : AnyObject?
    var fromId : AnyObject?
    var timestamp = -1
    var color = "blue"
    var activity = 10
    var privateGroup = false
    var groupName = "nil"
    var groupType = "nil"
    var entrancePerm = "Open"
    var descript = "nil"
    var appQ = ["nil"]
    
    let alert: UIAlertController = {
        let at = UIAlertController(title: "Unable to continue", message: "Please add a profile picture!", preferredStyle: .alert)
        at.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        return at
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "avatar")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    let profdescriptionLabel : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        //lb.text = "Profile Picture"
        lb.textColor = UIColor.black
        lb.numberOfLines = 1
        lb.font = UIFont.boldSystemFont(ofSize: 15)
        return lb
    }()
    
    
    
    lazy var inputTextField: UITextView = {
        let textField = UITextView()
        textField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0);

        let myColor : UIColor = UIColor( red: 0.5, green: 0.5, blue:0, alpha: 1.0 )
        textField.layer.masksToBounds = true
        textField.layer.borderColor = myColor.cgColor
        textField.layer.borderWidth = 2.0
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    lazy var insButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Favorite Instrument", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleCheck), for: .touchUpInside)
        return button
    }()
    
    let insInput : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = "none"
        lb.textColor = UIColor.white
        lb.numberOfLines = 1
        lb.font = UIFont.systemFont(ofSize: 15)
        return lb
    }()
    
    lazy var genreButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Favorite Genre", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleCheck2), for: .touchUpInside)
        return button
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .left
        //button.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)
        //button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Back", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        //button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        return button
    }()
    
    let genreInput : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = "none"
        lb.textColor = UIColor.white
        lb.numberOfLines = 1
        lb.font = UIFont.systemFont(ofSize: 15)
        return lb
    }()
    
    let descriptionLabel : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = "Briefly describe yourself..."
        lb.textColor = UIColor.white
        lb.numberOfLines = 1
        lb.font = UIFont.boldSystemFont(ofSize: 15)
        return lb
    }()
    
    lazy var createGroupButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Register", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleCreateGroup), for: .touchUpInside)
        
        return button
    }()
    
    /////////////////
    @objc func handleBack(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleCheck() {
        let dummySettingsViewController = EntranceTVController()
        dummySettingsViewController.current = insInput.text!
        dummySettingsViewController.controller = self
        self.navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    @objc func handleCheck2() {
        let dummySettingsViewController = EntranceTV2Controller()
        dummySettingsViewController.current = insInput.text!
        dummySettingsViewController.controller = self
        self.navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    func handleCreateGroup() {
        // check for profile picture
        if(profileImageView.image == UIImage(named: "default-profile") || insInput.text == "none" || genreInput.text == "none")
        {
            self.present(alert, animated: true)
            return
        }
         
         //createNewFaction(latitude: latitude! as! Double, longitude: longitude! as! Double, fromId: fromId as! String, timestamp: timestamp, color: color, activity: activity, groupName: groupName, groupType: groupType, privateGroup: privateGroup, entrancePermission: entranceInput.text!, description: inputTextField.text, applicationQ: appQ, groupPhoto: "")
        createNewUser(name: name, email: email, password: password, profileImage: profileImageView.image!, description: inputTextField.text, favInstrument: insInput.text!, favGenre: genreInput.text!, controller: lc)
        
        dismiss(animated: true, completion: nil)
        
         //let dummySettingsViewController = GroupSearchViewController()
         //self.navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let background = UIImage(named: "2")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
        
        //Dismisses Keyboard when screen tapped
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleCancel))
        
        view.addSubview(inputTextField)
        view.addSubview(insButton)
        view.addSubview(insInput)
        view.addSubview(genreButton)
        view.addSubview(genreInput)
        view.addSubview(descriptionLabel)
        view.addSubview(createGroupButton)
        view.addSubview(profileImageView)
        view.addSubview(profdescriptionLabel)
        view.addSubview(backButton)
        
        backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        profileImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 110).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 75).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        profdescriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        profdescriptionLabel.topAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: 10).isActive = true
        profdescriptionLabel.widthAnchor.constraint(equalToConstant: 130).isActive = true
        profdescriptionLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        inputTextField.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 50).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        inputTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        //inputTextField.widthAnchor.constraint(equalToConstant: 300).isActive = true
        inputTextField.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        descriptionLabel.centerXAnchor.constraint(equalTo: inputTextField.centerXAnchor, constant: 0).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: 0).isActive = true
        descriptionLabel.widthAnchor.constraint(equalToConstant: 300).isActive = true
        descriptionLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        insButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        insButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20).isActive = true
        insButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        insButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        insInput.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 40).isActive = true
        insInput.topAnchor.constraint(equalTo: insButton.topAnchor).isActive = true
        insInput.widthAnchor.constraint(equalToConstant: 200).isActive = true
        insInput.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        genreButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        genreButton.topAnchor.constraint(equalTo: insInput.bottomAnchor, constant: 20).isActive = true
        genreButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        genreButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        genreInput.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 40).isActive = true
        genreInput.topAnchor.constraint(equalTo: insInput.bottomAnchor, constant: 20).isActive = true
        genreInput.widthAnchor.constraint(equalToConstant: 200).isActive = true
        genreInput.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        createGroupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        createGroupButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        createGroupButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        createGroupButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
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
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

class EntranceTVController: UITableViewController {
    
    let cellId = "cellId"
    var groups = ["Guitar", "Piano", "Drums", "Bass", "Trumpet", "Violin", "Saxophone"]
    var current = "none"
    var controller = RegistrationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.separatorStyle = .none
        //view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    override func viewDidAppear(_ animated: Bool) {
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UITableViewCell
        cell.textLabel?.text = groups[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(groups[indexPath.row] == "Application"){
            let dummySettingsViewController = ApplicationController()
            dummySettingsViewController.controller = controller
            self.navigationController?.pushViewController(dummySettingsViewController, animated: true)
        }
        else{
            // Add a checkmark to the tableview cell, send label back to mainframe
            self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            self.controller.insInput.text = groups[indexPath.row]
            _ = navigationController?.popViewController(animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    }
    
}

class EntranceTV2Controller: UITableViewController {
    
    let cellId = "cellId"
    var groups = ["Pop", "Rock", "Country", "Jazz", "Hip hop", "Folk", "Classical"]
    var current = "none"
    var controller = RegistrationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.separatorStyle = .none
        //view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    override func viewDidAppear(_ animated: Bool) {
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UITableViewCell
        cell.textLabel?.text = groups[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(groups[indexPath.row] == "Application"){
            let dummySettingsViewController = ApplicationController()
            dummySettingsViewController.controller = controller
            self.navigationController?.pushViewController(dummySettingsViewController, animated: true)
        }
        else{
            // Add a checkmark to the tableview cell, send label back to mainframe
            self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            self.controller.genreInput.text = groups[indexPath.row]
            _ = navigationController?.popViewController(animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    }
    
}

class ApplicationController: UIViewController, UITextFieldDelegate, UITextViewDelegate{
    
    // receieve references for these values
    var questionNum = 1
    var controller = RegistrationController()
    
    let alert: UIAlertController = {
        let at = UIAlertController(title: "Unable to continue", message: "Please fill in all questions.", preferredStyle: .alert)
        at.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        return at
    }()
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0);
        textField.placeholder = "Question \(questionNum)..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    lazy var inputTextField2: UITextField = {
        let textField = UITextField()
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0);
        textField.placeholder = "Question \(questionNum)..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    lazy var inputTextField3: UITextField = {
        let textField = UITextField()
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0);
        textField.placeholder = "Question \(questionNum)..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    lazy var inputTextField4: UITextField = {
        let textField = UITextField()
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0);
        textField.placeholder = "Question \(questionNum)..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    lazy var inputTextField5: UITextField = {
        let textField = UITextField()
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0);
        textField.placeholder = "Question \(questionNum)..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    lazy var entranceButton: UIButton = {
        let button = UIButton(type: .system)
        //button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Add Question", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(addQuestion), for: .touchUpInside)
        return button
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Confirm", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
        
        return button
    }()
    
    /////////////////
    @objc func handleConfirm(){
        controller.insInput.text = "Application"
        var questions = [String]()
        for i in 1...questionNum{
            if(i == 1) {
                questions.append(inputTextField.text!)
                if(inputTextField.text?.isEmpty)!{
                    self.present(alert, animated: true)
                    return
                }
            }
            if(i == 2) { questions.append(inputTextField2.text!)
                if(inputTextField2.text?.isEmpty)!{
                    self.present(alert, animated: true)
                    return
                }
            }
            if(i == 3) { questions.append(inputTextField3.text!)
                if(inputTextField3.text?.isEmpty)!{
                    self.present(alert, animated: true)
                    return
                }
            }
            if(i == 4) { questions.append(inputTextField4.text!)
                if(inputTextField4.text?.isEmpty)!{
                    self.present(alert, animated: true)
                    return
                }
            }
            if(i == 5) { questions.append(inputTextField5.text!)
                if(inputTextField5.text?.isEmpty)!{
                    self.present(alert, animated: true)
                    return
                }
            }
        }
        
        if(inputTextField.text?.isEmpty)!{
            self.present(alert, animated: true)
            return
        }
        
        controller.appQ = questions
        print(questions)
        self.popBack(3)
    }
    
    func popBack(_ nb: Int) {
        if let viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            guard viewControllers.count < nb else {
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - nb], animated: true)
                return
            }
        }
    }
    
    
    @objc func addQuestion() {
        questionNum = questionNum + 1
        
        if(questionNum == 2)
        {
            view.addSubview(inputTextField2)
            inputTextField2.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            inputTextField2.topAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: 15).isActive = true
            inputTextField2.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
            inputTextField2.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            //entranceButton.topAnchor.constraint(equalTo: inputTextField2.bottomAnchor, constant: 20).isActive = true
        }
        if(questionNum == 3)
        {
            view.addSubview(inputTextField3)
            inputTextField3.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            inputTextField3.topAnchor.constraint(equalTo: inputTextField2.bottomAnchor, constant: 15).isActive = true
            inputTextField3.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
            inputTextField3.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            //entranceButton.topAnchor.constraint(equalTo: inputTextField3.bottomAnchor, constant: 20).isActive = true
        }
        if(questionNum == 4)
        {
            view.addSubview(inputTextField4)
            inputTextField4.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            inputTextField4.topAnchor.constraint(equalTo: inputTextField3.bottomAnchor, constant: 15).isActive = true
            inputTextField4.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
            inputTextField4.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            //entranceButton.topAnchor.constraint(equalTo: inputTextField4.bottomAnchor, constant: 20).isActive = true
        }
        if(questionNum == 5)
        {
            view.addSubview(inputTextField5)
            inputTextField5.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            inputTextField5.topAnchor.constraint(equalTo: inputTextField4.bottomAnchor, constant: 15).isActive = true
            inputTextField5.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
            inputTextField5.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            entranceButton.removeFromSuperview()
        }
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Dismisses Keyboard when screen tapped
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputTextField)
        view.addSubview(entranceButton)
        view.addSubview(confirmButton)
        
        inputTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        inputTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        entranceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        entranceButton.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -20).isActive = true
        entranceButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        entranceButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        confirmButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        confirmButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
























