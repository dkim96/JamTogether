import UIKit
import Firebase
import CoreLocation

import MobileCoreServices
import AVFoundation

var fetchedNames = [String:String]()
var fetchedPics = [String:UIImage]()

class GroupViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.1686, green: 0.5412, blue: 0.9373, alpha: 1.0)
        inspectFaction(fid: factionId)
        //fetchFaction()
        observeServer()
        createSubviews()
        createGestures() // creates tap and swipe gestures
        setupKeyboardObservers()
        setupNavBar()
        layoutCollectionView()
    }
    var pageContent = Pages() // What is on the page.
    let cellId = "cellId"
    let cellId2 = "cellId2"
    let cellId3 = "cellId3"
    let cellId4 = "cellId4"
    
    var userPosition : String?
    var nickname : String?
    
    var factionId = ""
    var seconds = Int()
    var factions = [Faction]()
    var faction = Faction() // the controller's faction
    var distFromUser = [Double]()
    let locationManager = CLLocationManager()
    var imagePicker = UIImagePickerController()
    var selectedImage : UIImage!
    var imgLat : CLLocationDegrees? = nil
    var imgLon : CLLocationDegrees? = nil
    var connector: GroupTabController?
    var titleStr = "Forum"
    var currentPos = "1" // position of default chat might need to fix
    var logCheck = "Forum"
    
    var groupMembers = [GroupMember]() // group members listed in order of position
    var groupPositions = [String]() //hierarchy must be set in place.
    var gmLocation = [Int]() // location of where to find person in GroupMembers
    var groupIndex = [0]
    var gmDict = [[String:AnyObject]]() // "show": Position/Name, "gm" GroupMember
    //with n different levels/titles, and levels of seperation, must be in order.
    
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
        }
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
    
    lazy var followButton: UIBarButtonItem = {
        let follow = UIBarButtonItem.init(title: "Follow", style: .plain, target: self, action: #selector(handleFollow))
        follow.tintColor = UIColor.black
        return follow
    }()
    
    var calendarView: UIView = {
        let cal = CalendarViewController()
        cal.view.translatesAutoresizingMaskIntoConstraints = false
        return cal.view
    }()
    
    lazy var createForumButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Post", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleCreateForum), for: .touchUpInside)
        return button
    }()
    
    func handleCreateForum(){
        // page information send, etc
        // userid, page reference
        let dummySettingsViewController = ForumCreationController()
        dummySettingsViewController.factionId = factionId
        dummySettingsViewController.currentPos = currentPos
        dummySettingsViewController.controller = self
        navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    lazy var createQuestionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("ask Question", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleAskQuestion), for: .touchUpInside)
        return button
    }()
    
    func getMemberNames(){
        // partition members into subcategories, mark positions, and carry on.
        groupMembers = [GroupMember]()
        groupPositions = [String]() //hierarchy must be set in place.
        groupIndex = [0]
        
        var list = [String: [GroupMember] ]() // given a position, list all members
        for i in 0...faction.groupMembers!.count-1{
            //groupMembers.append(fetchedNames[faction.groupMembers![i]["id"] as! String]!)
            //if(pageContent.content![size-indexPath.row]["score"] != nil)
            let pos = faction.groupMembers?[i]["position"] as? String
            if(list[pos!] != nil){
                list[pos!]?.append(GroupMember(dictionary: faction.groupMembers![i]))
            }
            else{
                groupPositions.append(pos!)
                list[pos!] = [GroupMember(dictionary: faction.groupMembers![i])]
            }
        }
        print(list)
        var counter = 0
        for i in 0...groupPositions.count-1{
            gmDict.append(["show": groupPositions[i] as AnyObject])
            for j in 0...(list[groupPositions[i]]?.count)!-1{
                groupMembers.append(list[groupPositions[i]]![j])
                gmDict.append(["show": fetchedNames[list[groupPositions[i]]![j].id!] as AnyObject, "gm": list[groupPositions[i]]![j]])
                counter = counter + 1
            }
            counter = counter + 1
            groupIndex.append(counter)
        }
        print(groupIndex)
        print(gmDict)
        self.settingsLauncher2.home2Controller.groups = groupMembers
        self.settingsLauncher2.home2Controller.groupIndex = groupIndex
        self.settingsLauncher2.home2Controller.groupPositions = groupPositions
        self.settingsLauncher2.home2Controller.gmDict = gmDict
        
        //print("getMemberNames: \(groupMembers)")
    }
    
    func handleAskQuestion(){
        // page information send, etc
        // userid, page reference
        let dummySettingsViewController = QuestionCreationController()
        dummySettingsViewController.factionId = factionId
        dummySettingsViewController.currentPos = currentPos
        dummySettingsViewController.controller = self
        navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    func fetchFaction(){
        FIRDatabase.database().reference().child("faction").child(factionId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] { // fill in type with suspected type
                self.faction = Faction(dictionary: dictionary)
                self.pageContent = Pages(dictionary: self.faction.pages![Int(self.currentPos)!])
                DispatchQueue.main.async(execute: {
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                    // within followers, find their names and images
                    
                    for i in 0...(self.faction.groupMembers?.count)!-1{
                        //call func ref to that id
                        self.fetchNameandPic(id: self.faction.groupMembers![i]["id"] as! String)
                        if (i == (self.faction.groupMembers?.count)!-1){
                            self.tableView.reloadData()
                        }
                    }
                    
                    //print("page grabbed")
                    //self.navigationController?.title = self.self.faction.groupName // this sets tabbar to name!
                    self.navigationItem.title = self.self.faction.groupName
                    self.tableView.reloadData()
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                })
            }
        }, withCancel: nil)
    }
    
    func fetchNameandPic(id: String){
        FIRDatabase.database().reference().child("users").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot.value)
            if let dictionary = snapshot.value as? [String:AnyObject] { // fill in type with suspected type
                var ref = dictionary
                DispatchQueue.main.async(execute: {
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                    fetchedNames[id] = ref["name"] as! String
                    //cell.nameLabel.text = self.fetchedNames[id]
                    
                    let url = URL(string: ref["profileImageUrl"] as! String)
                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        let image: UIImage = UIImage(data: data!)!
                        //self.images.append(image)
                        
                        let watermarkImage = UIImage.roundedRectImageFromImage(image: image, imageSize: CGSize(width: 50, height: 50), cornerRadius: CGFloat(20))
                        let backgroundImage = UIImage(named: "bluepin")
                        
                        UIGraphicsBeginImageContextWithOptions(backgroundImage!.size, false, 0.0)
                        backgroundImage!.draw(in: CGRect(x: 0.0, y: 0.0, width: 58, height: 58))
                        watermarkImage.draw(in: CGRect(x: 3.8, y: 3.6, width: 49, height: 49))
                        
                        let result = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        fetchedPics[id] = result as! UIImage
                        //cell.profileImageView.image = result
                        //print(fetchedNames)
                    }
                    
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                })
            }
        }, withCancel: nil)
    }
    
    func fetchPage(){
        FIRDatabase.database().reference().child("faction").child(factionId).child("pages").child(currentPos).observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot.value)
            if let dictionary = snapshot.value as? [String:AnyObject] { // fill in type with suspected type
                self.pageContent = Pages(dictionary: dictionary)
                DispatchQueue.main.async(execute: {
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                    //print("page grabbed")
                    //print(self.pageContent.content)
                    self.tableView.reloadData()
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                })
            }
        }, withCancel: nil)
    }
    
    let alert: UIAlertController = {
        let at = UIAlertController(title: "Unable to continue", message: "User must be following to comment.", preferredStyle: .alert)
        at.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        return at
    }()
    
    func handleSend(){
        // quick ref
        if(self.navigationItem.rightBarButtonItem?.title == "Follow"){
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
                //print(nextPos)
                var backtrace = self.pageContent.backtrace
                backtrace?.append("content")
                backtrace?.append(nextPos)
                var values = ["date": Int(Date().timeIntervalSince1970), "user": (FIRAuth.auth()?.currentUser?.uid)!, "content": self.inputTextField.text , "score": ["value":"1", "users":[(FIRAuth.auth()?.currentUser?.uid)!:1]], "backtrace": backtrace] as [String : AnyObject]
                
                // Update Firebase with the potential new follower
                let ref = FIRDatabase.database().reference().child("faction").child(self.factionId).child("pages").child(self.self.currentPos).child("content")
                let childRef = ref.child(nextPos) // @FIX
                
                childRef.updateChildValues(values) { (error, ref) in
                    if error != nil {
                        //print(error!)
                        return
                    }
                    //print("success")
                    if(self.pageContent.content == nil){
                        self.pageContent.content = [values]
                    }
                    else{self.pageContent.content!.append(values)}
                    self.tableView.reloadData()
                    self.inputTextField.text = ""
                    
                }
                // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                //})
            }
        }, withCancel: nil)
        // create a content var that that is filled with details, input it inside of pages/<pos>/content
    }
    
    func handleFollow(){
        // first checks to make sure he isnt on the list.
        // adds follow request to list in group...
        // Groups -> Users -> Followers
        
        var followers = [[String:AnyObject]]()
        
        FIRDatabase.database().reference().child("faction").child(factionId).child("groupMembers").observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot.value)
            if let dictionary = snapshot.value as? [[String:AnyObject]] { // fill in type with suspected type
                let user = dictionary
                var followers = dictionary
                DispatchQueue.main.async(execute: { // Function after values are added
                    // more complicated, for each groupMember, search for matching id, if not found generate a new member
                    for i in 0...followers.count-1{
                        if(followers[i]["id"] as! String == (FIRAuth.auth()?.currentUser?.uid)!){
                            //print("this user is already following")
                            return
                        }
                    }
                    let newUser = ["time": Int(Date().timeIntervalSince1970), "id" : (FIRAuth.auth()?.currentUser?.uid)!, "groupScore":0, "position" : "none", "isFollower" : true, "isCreator" : false,"posts" : [""], "likes" : [""], "settings" : ["mute":false], "nickname": self.nickname, "backtrace": [self.factionId, "groupMembers", String(followers.count)] ] as [String : AnyObject]
                    var values = newUser
                    // Update Firebase with the potential new follower
                    let ref = FIRDatabase.database().reference().child("faction").child(self.factionId).child("groupMembers")
                    let childRef = ref.child(String(followers.count))
                    
                    childRef.updateChildValues(values) { (error, ref) in
                        if error != nil {
                            //print(error!)
                            return
                        }
                        print("user now following")
                        addFactionToUserProfile(uid: (FIRAuth.auth()?.currentUser?.uid)!, fid: self.factionId)
                        self.faction.groupMembers?.append(newUser)
                        self.getMemberNames()
                        self.settingsLauncher2.home2Controller.tableView.reloadData()
                        self.navigationItem.rightBarButtonItem?.title = "Following"
                    }
                })
            }
        }, withCancel: nil)
        
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(0, 0, view.frame.width, view.frame.height-250))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId2)
        tableView.register(ChatCell.self, forCellReuseIdentifier: cellId)
        tableView.register(ForumCell.self, forCellReuseIdentifier: cellId3)
        tableView.register(QuestionCell.self, forCellReuseIdentifier: cellId4)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi));
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
    
    //**********************************************************
    
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    fileprivate func setupCell(_ cell: ChatMessageCell, message: Message) {
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            //outgoing blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    
    func observeServer(){
        var followers = [String]()
        FIRDatabase.database().reference().child("faction").child(factionId).child("groupMembers").observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot.value)
            if let dictionary = snapshot.value as? [[String:AnyObject]] { // fill in type with suspected type
                let user = dictionary
                var followers = dictionary
                DispatchQueue.main.async(execute: {
                    for i in 0...followers.count-1{
                        //print(followers[i]["id"])
                        if(followers[i]["id"] as! String == (FIRAuth.auth()?.currentUser?.uid)!){
                            self.navigationItem.rightBarButtonItem?.title = "Following"
                            return
                        }
                    }
                })
            }
        }, withCancel: nil)
        
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
    
    func createGestures(){
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        leftSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe2))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(rightSwipe)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func handleSwipe(){
        handleSlide()
        dismissKeyboard()
    }
    
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    
    func setupNavBar(){
        let doneItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "archives"), style: .plain, target: self, action: #selector(handleSlide))
        doneItem.tintColor = UIColor.black
        navigationItem.leftBarButtonItem = doneItem;
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Slide", style: .plain, target: self, action: #selector(handleSlide))
        navigationItem.rightBarButtonItem = followButton
    }
    
    //func showControllerForSetting(setting: Setting) {
    //let dummySettingsViewController = UIViewController()
    //dummySettingsViewController.view.backgroundColor = UIColor.white
    // dummySettingsViewController.navigationItem.title = setting.name
    //navigationController?.navigationBar.tintColor = UIColor.white
    //navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    //navigationController?.pushViewController(dummySettingsViewController, animated: true)
    //}
    
    lazy var settingsLauncher: SettingsLauncher = {
        let launcher = SettingsLauncher()
        launcher.homeController = self
        launcher.factionId = factionId
        return launcher
    }()
    
    lazy var settingsLauncher2: SettingsLauncher2 = {
        let launcher = SettingsLauncher2()
        launcher.homeController = self
        launcher.factionId = factionId
        
        launcher.groupMembers = groupMembers
        launcher.groupPositions = groupPositions
        launcher.groupIndex = groupIndex
        return launcher
    }()
    
    func handleSlide()
    {
        settingsLauncher.showSettings()
    }
    
    func handleSwipe2()
    {
        settingsLauncher2.showSettings()
        dismissKeyboard()
    }
    
    func handleExit()
    {
        settingsLauncher.exit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        if(logCheck == titleStr){
            //basically do nothing
            return
        }
        self.pageContent = Pages(dictionary: self.faction.pages![Int(self.currentPos)!])
        if(logCheck != titleStr) // views have changed
        {
            createForumButton.removeFromSuperview()
            createQuestionButton.removeFromSuperview()
            calendarView.removeFromSuperview()
            createSubviews() // readds textfield and send
            logCheck = titleStr
            // remove all current messages, access new page, upload new info.
            fetchPage()
        }
        if(titleStr == "Forum"){
            logCheck = titleStr
            sendButton.removeFromSuperview()
            inputTextField.removeFromSuperview()
            view.addSubview(createForumButton)
            self.createForumButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
            self.createForumButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15).isActive = true
            self.createForumButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
            self.createForumButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            self.tableView.reloadData()
        }
        
        if(titleStr == "Questions"){
            logCheck = titleStr
            sendButton.removeFromSuperview()
            inputTextField.removeFromSuperview()
            view.addSubview(createQuestionButton)
            self.createQuestionButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
            self.createQuestionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15).isActive = true
            self.createQuestionButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
            self.createQuestionButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            self.tableView.reloadData()
        }
        
        if(titleStr == "Calendar"){
            // for now, just add the calendar on top
            logCheck = titleStr
            view.addSubview(calendarView)
            self.calendarView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            self.calendarView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            self.calendarView.topAnchor.constraint(equalTo: (navigationController?.topLayoutGuide.topAnchor)!, constant: 85).isActive = true
            self.calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        else{
            if(logCheck != titleStr) // views have changed
            {
                createForumButton.removeFromSuperview()
                createQuestionButton.removeFromSuperview()
                calendarView.removeFromSuperview()
                createSubviews() // readds textfield and send
                logCheck = titleStr
                // remove all current messages, access new page, upload new info.
                fetchPage()
            }
        }
    }
    
    func fetchUser() {
        FIRDatabase.database().reference().child("faction").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let faction = Faction(dictionary: dictionary)
                faction.id = snapshot.key
                //print(snapshot.key)
                self.factions.append(faction)
                
                var coord1 = CLLocation(latitude: faction.latitude!, longitude: faction.longitude!)
                var coord2 = CLLocation(latitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!)
                ////print("Distance from ")
                var VAL = coord1.distance(from: coord2)
                ////print(VAL)
                self.distFromUser.append(VAL)
                if(VAL < 1000){
                    //print("Group within radius", VAL)
                }
                else{
                    //print("Group outside radius", VAL)
                }
                DispatchQueue.main.async(execute: {
                    // self.tableView.reloadData()
                })
            }
            
        }, withCancel: nil)
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //
        //let pageContent = Pages(dictionary: self.faction.pages![Int(self.currentPos)!])
        
        if((pageContent.content?.count) == nil){
            return 0
        }
        else{
            return (pageContent.content?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //universal
        // forum and question mixed for now
        if(titleStr == "Forum"){
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId3, for: indexPath) as! ForumCell
            cell.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI));
            var size = (pageContent.content?.count)!-1
            cell.backtrace = pageContent.content![size-indexPath.row]["backtrace"] as! [String]
            cell.controller = self
            
            let time = pageContent.content![size-indexPath.row]["date"] as! AnyObject
            let timestampDate = Date(timeIntervalSince1970: TimeInterval(time as! NSNumber))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            cell.titleLabel.text = pageContent.content![size-indexPath.row]["title"] as! String
            cell.contentLabel.text = pageContent.content![size-indexPath.row]["content"] as! String
            
            cell.timeLabel.text = dateFormatter.string(from: timestampDate)
            if(pageContent.content![size-indexPath.row]["score"] != nil){
                cell.postValue.text = pageContent.content![size-indexPath.row]["score"]!["value"] as! String
            }
            var id = pageContent.content![size-indexPath.row]["user"] as! String
            if(id == ""){
                return cell
            }
            if(fetchedNames[id] != nil){ // check if this crashes
                cell.nameLabel.text = fetchedNames[id]
                cell.profileImageView.image = fetchedPics[id]
            }
            return cell
        }
        if(titleStr == "Questions"){
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId4, for: indexPath) as! QuestionCell
            cell.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI));
            var size = (pageContent.content?.count)!-1
            cell.backtrace = pageContent.content![size-indexPath.row]["backtrace"] as! [String]
            cell.controller = self
            if(pageContent.content![size-indexPath.row]["score"] != nil){
                cell.postValue.text = pageContent.content![size-indexPath.row]["score"]!["value"] as! String
            }
            let time = pageContent.content![size-indexPath.row]["date"] as! AnyObject
            let timestampDate = Date(timeIntervalSince1970: TimeInterval(time as! NSNumber))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            cell.titleLabel.text = pageContent.content![size-indexPath.row]["title"] as! String
            cell.contentLabel.text = pageContent.content![size-indexPath.row]["content"] as! String
            cell.solved = pageContent.content![size-indexPath.row]["solved"] as! Bool
            cell.timeLabel.text = dateFormatter.string(from: timestampDate)
            
            var id = pageContent.content![size-indexPath.row]["user"] as! String
            if(id == ""){
                return cell
            }
            if(fetchedNames[id] != nil){ // check if this crashes
                cell.nameLabel.text = fetchedNames[id]
                //cell.profileImageView.image = fetchedPics[id]
            }
            return cell
        }
        else{ // chat
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatCell
            cell.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI));
            var size = (pageContent.content?.count)!-1
            cell.backtrace = pageContent.content![size-indexPath.row]["backtrace"] as! [String]
            cell.controller = self
            if(pageContent.content![size-indexPath.row]["score"] != nil){
                cell.postValue.text = pageContent.content![size-indexPath.row]["score"]!["value"] as! String
            }
            let time = pageContent.content![size-indexPath.row]["date"] as! AnyObject
            let timestampDate = Date(timeIntervalSince1970: TimeInterval(time as! NSNumber))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            
            cell.contentLabel.text = pageContent.content![size-indexPath.row]["content"] as! String
            cell.timeLabel.text = dateFormatter.string(from: timestampDate)
            
            var id = pageContent.content![size-indexPath.row]["user"] as! String
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
        if(titleStr == "Forum"){
            return 200
        }
        if(titleStr == "Questions"){
            return 140
        }
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("clicked")
        tableView.deselectRow(at: indexPath, animated: true)
        if(titleStr == "Forum"){
            // send to fvc with variables
            var size = (pageContent.content?.count)!-1
            let ctr = ForumViewController()
            ctr.factionId = factionId
            ctr.pageContent = pageContent
            ctr.currentPos = currentPos
            ctr.forumPos = String(size-indexPath.row)
            ctr.forumContent = Content(dictionary: pageContent.content![size-indexPath.row])
            ctr.controller = self
            //print(pageContent.content![size-indexPath.row]["title"])
            navigationController?.pushViewController(ctr, animated: true)
        }
        if(titleStr == "Questions"){
            // send to fvc with variables
            var size = (pageContent.content?.count)!-1
            let ctr = QuestionViewController()
            ctr.factionId = factionId
            ctr.pageContent = pageContent
            ctr.currentPos = currentPos
            ctr.forumPos = String(size-indexPath.row)
            ctr.forumContent = Content(dictionary: pageContent.content![size-indexPath.row])
            ctr.controller = self
            //print(pageContent.content![size-indexPath.row]["title"])
            navigationController?.pushViewController(ctr, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
}





















