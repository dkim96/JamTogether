/*
import UIKit
import Firebase
import CoreLocation

import MobileCoreServices
import AVFoundation

class gvcCVtemp: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.1686, green: 0.5412, blue: 0.9373, alpha: 1.0)
        inspectFaction(fid: factionId)
        fetchFaction()
        observeServer()
        createSubviews()
        createGestures() // creates tap and swipe gestures
        setupKeyboardObservers()
        setupNavBar()
        layoutCollectionView()
    }
    var pageContent = Pages() // What is on the page.
    let cellId = "cellId"
    var factionId = ""
    var seconds = Int()
    var factions = [Faction]()
    var faction = Faction()
    var distFromUser = [Double]()
    let locationManager = CLLocationManager()
    var imagePicker = UIImagePickerController()
    var selectedImage : UIImage!
    var imgLat : CLLocationDegrees? = nil
    var imgLon : CLLocationDegrees? = nil
    var connector: GroupTabController?
    var titleStr = "Chat"
    var currentPos = "2" // position of default chat might need to fix
    var logCheck = "Chat"
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            
            //observeMessages()
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
    
    func fetchFaction(){
        FIRDatabase.database().reference().child("faction").child(factionId).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.value)
            if let dictionary = snapshot.value as? [String:AnyObject] { // fill in type with suspected type
                self.faction = Faction(dictionary: dictionary)
                self.pageContent = Pages(dictionary: self.faction.pages![Int(self.currentPos)!])
                DispatchQueue.main.async(execute: {
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                    print("page grabbed")
                    //self.navigationController?.title = self.self.faction.groupName // this sets tabbar to name!
                    self.navigationItem.title = self.self.faction.groupName
                    self.collectionView.reloadData()
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                })
            }
        }, withCancel: nil)
    }
    
    func fetchPage(){
        FIRDatabase.database().reference().child("faction").child(factionId).child("pages").child(currentPos).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.value)
            if let dictionary = snapshot.value as? [String:AnyObject] { // fill in type with suspected type
                self.pageContent = Pages(dictionary: dictionary)
                DispatchQueue.main.async(execute: {
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                    print("page grabbed")
                    self.collectionView.reloadData()
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                })
            }
        }, withCancel: nil)
    }
    
    func handleSend(){
        // quick ref
        FIRDatabase.database().reference().child("faction").child(factionId).child("pages").child(currentPos).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.value)
            if let dictionary = snapshot.value as? [String:AnyObject] { // fill in type with suspected type
                var followers = dictionary
                DispatchQueue.main.async(execute: {
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                    var nextPos = String()
                    if(followers["content"] == nil){
                        nextPos = "0"
                    }
                    else{
                        nextPos = String((followers["content"]?.count)!)
                    }
                    print(nextPos)
                    var values = ["date": Int(Date().timeIntervalSince1970), "user": (FIRAuth.auth()?.currentUser?.uid)!, "content": self.inputTextField.text] as [String : AnyObject]
                    
                    // Update Firebase with the potential new follower
                    let ref = FIRDatabase.database().reference().child("faction").child(self.factionId).child("pages").child(self.self.currentPos).child("content")
                    let childRef = ref.child(nextPos) // @FIX
                    
                    childRef.updateChildValues(values) { (error, ref) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        print("success")
                        if(self.pageContent.content == nil){
                            self.pageContent.content = [values]
                        }
                        else{self.pageContent.content!.append(values)}
                        self.collectionView.reloadData()
                        
                    }
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                })
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
            print(snapshot.value)
            if let dictionary = snapshot.value as? [[String:AnyObject]] { // fill in type with suspected type
                let user = dictionary
                var followers = dictionary
                DispatchQueue.main.async(execute: { // Function after values are added
                    // more complicated, for each groupMember, search for matching id, if not found generate a new member
                    for i in 0...followers.count-1{
                        if(followers[i]["id"] as! String == (FIRAuth.auth()?.currentUser?.uid)!){
                            print("this user is already following")
                            return
                        }
                    }
                    let newUser = ["time": Int(Date().timeIntervalSince1970), "id": (FIRAuth.auth()?.currentUser?.uid)!, "groupScore":0, "position":"none", "isFollower": true, "isCreator":false,"posts": [""], "likes":[""], "settings":["mute":false] ] as [String : AnyObject]
                    var values = newUser
                    // Update Firebase with the potential new follower
                    let ref = FIRDatabase.database().reference().child("faction").child(self.factionId).child("groupMembers")
                    let childRef = ref.child(String(followers.count))
                    
                    childRef.updateChildValues(values) { (error, ref) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        print("success")
                        addFactionToUserProfile(uid: (FIRAuth.auth()?.currentUser?.uid)!, fid: self.factionId)
                        self.navigationItem.rightBarButtonItem?.title = "Following"
                    }
                })
            }
        }, withCancel: nil)
        
    }
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        //let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        let collectionView = UICollectionView(frame: CGRect(0, 0, view.frame.width, view.frame.height-250), collectionViewLayout: flowLayout)
        //collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.cyan
        self.edgesForExtendedLayout = []
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor(red: 0.1686, green: 0.6412, blue: 0.9573, alpha: 1.0)
        return collectionView
    }()
    
    func layoutCollectionView(){
        self.view.addSubview(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if((pageContent.content?.count) == nil){
            return 0
        }
        else{
            return (pageContent.content?.count)!
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let message = Message(dictionary: ["text": pageContent.content![indexPath.row]["content"]])
        cell.message = message
        cell.textView.text = message.text
        setupCell(cell, message: message)
        if let text = message.text {
            //a text message
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            //fall in here if its an image message
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        cell.playButton.isHidden = message.videoUrl == nil
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        //let message = Message(dictionary: ["text": pageContent.content![indexPath.row].content])
        let message = Message(dictionary: ["text": pageContent.content![indexPath.row]["content"]])
        if let text = message.text {
            height = estimateFrameForText(text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            
            // h1 / w1 = h2 / w2
            // solve for h1
            // h1 = h2 / w2 * w1
            
            height = CGFloat(imageHeight / imageWidth * 200)
            
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 20, left: 50, bottom: 0, right: -220)
    }
    
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
            print(snapshot.value)
            if let dictionary = snapshot.value as? [[String:AnyObject]] { // fill in type with suspected type
                let user = dictionary
                var followers = dictionary
                DispatchQueue.main.async(execute: {
                    for i in 0...followers.count-1{
                        print(followers[i]["id"])
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
        view.addGestureRecognizer(tap)
    }
    
    func handleSwipe(){
        print("swipe")
        handleSlide()
        dismissKeyboard()
    }
    
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //
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
    
    func showControllerForSetting(setting: Setting) {
        //let dummySettingsViewController = UIViewController()
        //dummySettingsViewController.view.backgroundColor = UIColor.white
        // dummySettingsViewController.navigationItem.title = setting.name
        //navigationController?.navigationBar.tintColor = UIColor.white
        //navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        //navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
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
        //self.tableView.reloadData()
        print("reload")
        
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
                calendarView.removeFromSuperview()
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
                print(snapshot.key)
                self.factions.append(faction)
                
                var coord1 = CLLocation(latitude: faction.latitude!, longitude: faction.longitude!)
                var coord2 = CLLocation(latitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!)
                //print("Distance from ")
                var VAL = coord1.distance(from: coord2)
                //print(VAL)
                self.distFromUser.append(VAL)
                if(VAL < 1000){
                    print("Group within radius", VAL)
                }
                else{
                    print("Group outside radius", VAL)
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
    
}*/
