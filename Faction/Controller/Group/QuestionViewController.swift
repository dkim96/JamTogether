 
 /*
  
  GroupSearchView is the main view that allows users to search for new groups.
  
  Improvements:
  GroupDescriptionController should eventually be a ContainerView so that people can scroll down.
  
  */
 
 import UIKit
 import Firebase
 import CoreLocation
 
 class QuestionViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource { // AND GroupDescriptionController
    
    // needed
    var factionId = String()
    var pageContent = Pages() // What is on the page.
    var forumContent = Content()
    var currentPos = String()
    var forumPos = String()
    var controller = GroupViewController() // backreference to update
    let cellId = "cellId"
    let cellId2 = "cellId2"
    let cellId3 = "cellId3"
    let cellId4 = "cellId4"
    var seconds = Int()
    
    let locationManager = CLLocationManager()
    var imagePicker = UIImagePickerController()
    var selectedImage : UIImage!
    var imgLat : CLLocationDegrees? = nil
    var imgLon : CLLocationDegrees? = nil
    var curId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        curId = (FIRAuth.auth()?.currentUser?.uid)!
        inspectUser(uid: (FIRAuth.auth()?.currentUser?.uid)!)
        view.backgroundColor = UIColor(red: 0.1686, green: 0.5412, blue: 0.9373, alpha: 1.0)
        layoutCollectionView()
        createSubviews()
        setupKeyboardObservers()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0);
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(0, 0, view.frame.width, view.frame.height-250))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId2)
        tableView.register(ChatCell.self, forCellReuseIdentifier: cellId)
        tableView.register(ForumCell.self, forCellReuseIdentifier: cellId3)
        tableView.register(QuestionCell.self, forCellReuseIdentifier: cellId4)
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi));
        tableView.backgroundColor = UIColor.cyan
        self.edgesForExtendedLayout = []
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        tableView.alwaysBounceVertical = true
        tableView.backgroundColor = UIColor(red: 0.1686, green: 0.6412, blue: 0.9573, alpha: 1.0)
        tableView.allowsSelection = true
        return tableView
    }()
    
    func layoutCollectionView(){
        //self.view.addSubview(collectionView)
        self.view.addSubview(tableView)
    }
    
    func handleSend(){
        // fetches the position of the next open spot.
        FIRDatabase.database().reference().child("faction").child(factionId).child("pages").child(currentPos).child("content").child(forumPos).observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot.value)
            if let dictionary = snapshot.value as? [String:AnyObject] { // fill in type with suspected type
                var followers = dictionary
                DispatchQueue.main.async(execute: {
                // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                var nextPos = String()
                if(followers["comments"] == nil){
                    nextPos = "0"
                }
                else{
                    nextPos = String((followers["comments"]?.count)!)
                }
                //print(nextPos)
                var backtrace = self.forumContent.backtrace
                backtrace?.append("comments")
                backtrace?.append(nextPos)
                
                var values = ["date": Int(Date().timeIntervalSince1970), "user": (FIRAuth.auth()?.currentUser?.uid)!, "content": self.inputTextField.text, "score": ["value":"1", "users":[(FIRAuth.auth()?.currentUser?.uid)!:1]], "backtrace":backtrace] as [String : AnyObject]
                
                // Update Firebase with the potential new follower
                let ref = FIRDatabase.database().reference().child("faction").child(self.factionId).child("pages").child(self.self.currentPos).child("content").child(self.forumPos).child("comments")
                let childRef = ref.child(nextPos) // @FIX
                
                childRef.updateChildValues(values) { (error, ref) in
                    if error != nil {
                        print(error!)
                        print("error")
                        return
                    }
                    print("success")
                    
                    var comment = Content(dictionary: values)
                    
                    if(self.forumContent.comments == nil){
                        self.forumContent.comments?.append(values)
                    }
                    else{self.forumContent.comments?.append(values)}
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                        self.controller.fetchPage()
                    })
                    self.inputTextField.text = ""
                }
                // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                })
            }
        }, withCancel: nil)
        // create a content var that that is filled with details, input it inside of pages/<pos>/content
    }
    
    func createSubviews(){
        view.addSubview(self.inputTextField)
        self.inputTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        self.inputTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -90).isActive = true
        self.inputTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(self.sendButton)
        self.sendButton.leftAnchor.constraint(equalTo: inputTextField.rightAnchor, constant: 15).isActive = true
        self.sendButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15).isActive = true
        self.sendButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        self.sendButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardWillShow(_ notification: Notification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        //self.inputTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 100).isActive = true
        //self.inputTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -keyboardFrame!.height + 70).isActive = true
        self.view.frame.origin.y = -160
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func handleKeyboardWillHide(_ notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        //self.inputTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        self.view.frame.origin.y = 88
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
    
    func refresh(sender:AnyObject) {
        //factions.removeAll()
        //distFromUser.removeAll()
        fetchUser()
        //refreshControl?.endRefreshing()
    }
    
    @objc func handleRefresh(){
        //factions.removeAll()
        //distFromUser.removeAll()
        fetchUser()
    }
    
    @objc func handleCreateGroup(){
        let dummySettingsViewController = GroupCreationController()
        navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        imgLat = locValue.latitude
        imgLon = locValue.longitude
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //fetchUser()
        /*if(curId != FIRAuth.auth()?.currentUser?.uid)
         {
         curId = (FIRAuth.auth()?.currentUser?.uid)!
         inspectUser(uid: (FIRAuth.auth()?.currentUser?.uid)!)
         factions.removeAll()
         distFromUser.removeAll()
         fetchUser()
         }*/
    }
    
    func fetchUser() {
        FIRDatabase.database().reference().child("faction").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let faction = Faction(dictionary: dictionary)
                faction.id = snapshot.key
                
                let coord1 = CLLocation(latitude: faction.latitude!, longitude: faction.longitude!)
                let coord2 = CLLocation(latitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!)
                let VAL = coord1.distance(from: coord2)
                
                if(VAL < 200){
                    //print("Group within radius", VAL)
                    //self.factions.append(faction)
                    //self.distFromUser.append(VAL)
                }
                else{
                    //print("Group outside radius", VAL)
                }
                
                //this will crash because of background thread, so lets use dispatch_async to fix
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                
                //                user.name = dictionary["name"]
            }
            
        }, withCancel: nil)
        
        
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //let pageContent = Pages(dictionary: self.faction.pages![Int(self.currentPos)!])
        // 1 forum page, the rest are comments.
        if(forumContent.comments == nil){
            return 1
        }
        else{
            return (forumContent.comments?.count)! + 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(forumContent.title == nil){
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId3, for: indexPath) as! ForumCell
            return cell
        }
        if(indexPath.row == 0){ // forum cell
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId4, for: indexPath) as! QuestionCell
            //var size = (pageContent.content?.count)!-1
            let time = forumContent.date as! AnyObject
            let timestampDate = Date(timeIntervalSince1970: TimeInterval(time as! NSNumber))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            cell.titleLabel.text = forumContent.title as! String
            cell.contentLabel.text = forumContent.content as! String
            cell.timeLabel.text = dateFormatter.string(from: timestampDate)
            cell.solved = forumContent.solved!
            if(forumContent.score != nil){
                cell.postValue.text = forumContent.score!["value"] as! String
            }
            
            var id = forumContent.user as! String
            if(id == ""){
                return cell
            }
            if(fetchedNames[id] != nil){ // check if this crashes
                cell.nameLabel.text = fetchedNames[id]
                cell.profileImageView.image = fetchedPics[id]
            }
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatCell
            cell.setupResponse()
            let time = forumContent.comments?[indexPath.row-1]["date"] as! AnyObject
            let timestampDate = Date(timeIntervalSince1970: TimeInterval(time as! NSNumber))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            cell.contentLabel.text = forumContent.comments?[indexPath.row-1]["content"] as! String
            cell.timeLabel.text = dateFormatter.string(from: timestampDate)
            
            var id = forumContent.comments?[indexPath.row-1]["user"] as! String
            if(id == ""){
                return cell
            }
            if(fetchedNames[id] != nil){ // check if this crashes
                cell.nameLabel.text = fetchedNames[id]
                cell.profileImageView.image = fetchedPics[id]
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 140
        }
        else{
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
 }
 
 ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
 class QuestionCreationController: UIViewController, UITextFieldDelegate, UITextViewDelegate{
    
    // receieve references for these values
    var questionNum = 1
    
    var factionId = String()
    var currentPos = String()
    var controller = GroupViewController()
    
    let alert: UIAlertController = {
        let at = UIAlertController(title: "Unable to continue", message: "Please fill in all fields.", preferredStyle: .alert)
        at.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        return at
    }()
    
    lazy var titleField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0);
        textField.placeholder = "Insert question here..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    lazy var contentField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0);
        textField.placeholder = "Explain your question more here..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
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
        // quick ref
        if(titleField.text == "" || contentField.text == "" ){ // empty fields
            self.present(alert, animated: true)
            return
        }
        FIRDatabase.database().reference().child("faction").child(factionId).child("pages").child(currentPos).observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot.value)
            if let dictionary = snapshot.value as? [String:AnyObject] { // fill in type with suspected type
                var followers = dictionary
                //DispatchQueue.main.async(execute: {
                // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                var nextPos = String()
                if(followers["content"] == nil){
                    nextPos = "0"
                }
                else{
                    nextPos = String((followers["content"]?.count)!)
                }
                var backtrace = self.controller.pageContent.backtrace
                backtrace?.append("content")
                backtrace?.append(nextPos)
                //print(nextPos)
                var values = ["date": Int(Date().timeIntervalSince1970), "user": (FIRAuth.auth()?.currentUser?.uid)!, "content": self.contentField.text, "title": self.titleField.text, "solved": false, "score": ["value":"1", "users":[(FIRAuth.auth()?.currentUser?.uid)!:1]],"backtrace": backtrace] as [String : AnyObject]
                
                // Update Firebase with the potential new follower
                let ref = FIRDatabase.database().reference().child("faction").child(self.factionId).child("pages").child(self.self.currentPos).child("content")
                let childRef = ref.child(nextPos) // @FIX
                
                childRef.updateChildValues(values) { (error, ref) in
                    if error != nil {
                        print(error!)
                        print("error")
                        return
                    }
                    print("success")
                    if(self.controller.pageContent.content == nil){
                        self.controller.pageContent.content = [values]
                    }
                    else{self.controller.pageContent.content!.append(values)}
                    self.controller.tableView.reloadData()
                    self.popBack(2) // Goes back n-1 controllers, 2->1 pop
                    //navigationController2!.popToRootViewController(animated: false)
                    
                }
                // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                //})
            }
        }, withCancel: nil)
        // create a content var that that is filled with details, input it inside of pages/<pos>/content
    }
    
    func popBack(_ nb: Int) {
        if let viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            guard viewControllers.count < nb else {
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - nb], animated: true)
                return
            }
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
        
        view.addSubview(titleField)
        view.addSubview(contentField)
        view.addSubview(confirmButton)
        
        titleField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleField.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        titleField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        titleField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        contentField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        contentField.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 20).isActive = true
        contentField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        contentField.heightAnchor.constraint(equalToConstant: 400).isActive = true
        
        confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        confirmButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        confirmButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
 }
 
 
 
