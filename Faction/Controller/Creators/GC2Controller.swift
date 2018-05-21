

import UIKit
import Firebase

class GC2Controller: UIViewController, UITextFieldDelegate, UITextViewDelegate{
    
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
    // will fill these values
    var entrancePerm = "Open"
    var descript = "nil"
    var appQ = ["nil"]
    
    let alert: UIAlertController = {
        let at = UIAlertController(title: "Unable to continue", message: "Please add a short description of your group.", preferredStyle: .alert)
        at.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        return at
    }()
    
    lazy var inputTextField: UITextView = {
        let textField = UITextView()
        textField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0);
        //textField.layer.border
        //textField.borderStyle = UITextBorderStyle.roundedRect
        //textField.placeholder = "Enter description of group..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    lazy var entranceButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Entrance Limit", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleCheck), for: .touchUpInside)
        return button
    }()
    
    let entranceInput : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = "Open"
        lb.textColor = UIColor.white
        lb.numberOfLines = 1
        lb.font = UIFont.systemFont(ofSize: 15)
        return lb
    }()
    
    let descriptionLabel : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = "Briefly describe the group..."
        lb.textColor = UIColor.white
        lb.numberOfLines = 1
        lb.font = UIFont.boldSystemFont(ofSize: 15)
        return lb
    }()
    
    lazy var createGroupButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Create Group", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleCreateGroup), for: .touchUpInside)
        
        return button
    }()
    
    /////////////////
    
    @objc func handleCheck() {
        let dummySettingsViewController = EntranceTVController()
        dummySettingsViewController.current = entranceInput.text!
        dummySettingsViewController.controller = self
        self.navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    func handleCreateGroup() {
        
        if((inputTextField.text?.isEmpty)!){
            self.present(alert, animated: true)
            return
        }
        
        if(entranceInput.text != "Application"){
            appQ = ["nil"]
        }
        
        createNewFaction(latitude: latitude! as! Double, longitude: longitude! as! Double, fromId: fromId as! String, timestamp: timestamp, color: color, activity: activity, groupName: groupName, groupType: groupType, privateGroup: privateGroup, entrancePermission: entranceInput.text!, description: inputTextField.text, applicationQ: appQ, groupPhoto: "")
        
        let dummySettingsViewController = GroupSearchViewController()
        self.navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Dismisses Keyboard when screen tapped
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputTextField)
        view.addSubview(entranceButton)
        view.addSubview(entranceInput)
        view.addSubview(descriptionLabel)
        view.addSubview(createGroupButton)
        
        inputTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        inputTextField.widthAnchor.constraint(equalToConstant: 300).isActive = true
        inputTextField.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        descriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: inputTextField.topAnchor, constant: 0).isActive = true
        descriptionLabel.widthAnchor.constraint(equalToConstant: 300).isActive = true
        descriptionLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        entranceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        entranceButton.topAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: 20).isActive = true
        entranceButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        entranceButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        entranceInput.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 40).isActive = true
        entranceInput.topAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: 20).isActive = true
        entranceInput.widthAnchor.constraint(equalToConstant: 200).isActive = true
        entranceInput.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
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
}



class EntranceTVController: UITableViewController {
    
    let cellId = "cellId"
    var groups = ["Open", "Request", "Application"]
    var current = "Open"
    var controller = GC2Controller()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.separatorStyle = .none
        //view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    override func viewDidAppear(_ animated: Bool) {
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
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
            self.controller.entranceInput.text = groups[indexPath.row]
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
    var controller = GC2Controller()
    
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
    func handleConfirm(){
        controller.entranceInput.text = "Application"
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

















