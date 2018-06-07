 
 /*
  GroupSearchView is the main view that allows users to search for new groups.
  
  Improvements:
  GroupDescriptionController should eventually be a ContainerView so that people can scroll down.
  */
 // topcell, background, ppic, title, hosted, date, main genre:
 // 2. instruments, 3. all needed instruments.
 
 import UIKit
 import Firebase
 import CoreLocation
 
 // main: connecting names and photos to this controller
 // instruments properly shown
 // joining event by taking up an instrument.
 
 class JoinSessionController: UITableViewController, CLLocationManagerDelegate { // AND GroupDescriptionController
    
    // actually, all information is given in the back with first initial step, extract the data, download necessary profile photos, and enter. 
    
    var sessionInfo = Bubble() // given by the viewcontroller
    
    var val = -1
    let cellId = "cellId"
    let cellId2 = "cellId2"
    let cellId3 = "cellId3"
    var seconds = Int()
    var factions = [Faction]()
    var distFromUser = [Double]()
    let locationManager = CLLocationManager()
    var imagePicker = UIImagePickerController()
    var selectedImage : UIImage!
    var imgLat : CLLocationDegrees? = nil
    var imgLon : CLLocationDegrees? = nil
    var curId = String()
    
    // further seperate factions based on location.
    var vicinityDistance = 250.0
    var generalDistance = 700.0
    var outskirtDistance = 1500.0
    
    var vicinity = [Faction]()
    var general = [Faction]()
    var outskirts = [Faction]()
    var distanceDict = [String:Double]()
    
    var sizeRef = [0,1,2] // amount of factions in each group
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("")
        print("--------------")
        // Handling no user
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            //handleLogout()
        }
        else{
            curId = (FIRAuth.auth()?.currentUser?.uid)!
            //fetchNameandPic(id: curId, np: -1, gvc: GroupViewController(), nav: self.navigationController!)
            //inspectUser(uid: (FIRAuth.auth()?.currentUser?.uid)!)
            
            
            self.tableView.separatorStyle = .none
            navigationItem.title = "Local Factions"
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(handleRefresh))
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(handleCreateGroup))
            tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
            tableView.register(UserCell2.self, forCellReuseIdentifier: cellId3)
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId2)
            //fetchUser()
            
            // Location Services
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.requestWhenInUseAuthorization()
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            }
            /////
            refreshControl = UIRefreshControl()
            refreshControl?.clipsToBounds = true
            refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
            refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
            
        }
        
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
    
    @objc func refresh(sender:AnyObject) {
        /*factions.removeAll()
        distFromUser.removeAll()
        vicinity.removeAll()
        general.removeAll()
        outskirts.removeAll()
        sizeRef = [0,1,2]
        fetchUser()*/
        dismiss(animated: true, completion: nil)
        refreshControl?.endRefreshing()
    }
    
    @objc func handleRefresh(){
        print("!")
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleCreateGroup(){
        //let dummySettingsViewController = GroupCreationController()
        //navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        imgLat = locValue.latitude
        imgLon = locValue.longitude
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //fetchUser()
        if(curId != FIRAuth.auth()?.currentUser?.uid)
        {
            //curId = (FIRAuth.auth()?.currentUser?.uid)!
            //inspectUser(uid: (FIRAuth.auth()?.currentUser?.uid)!)
            factions.removeAll()
            distFromUser.removeAll()
            //fetchUser()
        }
    }
    
    func fetchUser() {
        FIRDatabase.database().reference().child("faction").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let faction = Faction(dictionary: dictionary)
                faction.id = snapshot.key
                
                //this will crash because of background thread, so lets use dispatch_async to fix
                DispatchQueue.main.async(execute: {
                    //print(self.sizeRef)
                    self.tableView.reloadData()
                })
                
                //                user.name = dictionary["name"]
            }
            
        }, withCancel: nil)
        
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return factions.count + 3 // seperator cells
        return 2 + (sessionInfo.instruments?.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if(indexPath.row == 0){
            var cell3 = UserCell()
            cell3 = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
            cell3.layer.zPosition = 0
            
            cell3.mainLabel.text = sessionInfo.sessionName
            cell3.typeLabel.text = "Hosted by \(fetchedNames[sessionInfo.creatorId!] as! String)"
            cell3.genreLabel.text = "Genre:   \(sessionInfo.genre as! String)"
            cell3.timeLabel.text = "Time:   \(sessionInfo.eventDate as! String)"
            cell3.descriptionLabel.text = sessionInfo.desc
            cell3.profileImageView.image = fetchedPics[sessionInfo.creatorId!]
            
            return cell3
        }
        if(indexPath.row == 1){
            cell = tableView.dequeueReusableCell(withIdentifier: cellId2, for: indexPath) as! UITableViewCell
            cell.textLabel?.text = "Instruments"
            cell.layer.zPosition = 1
            return cell
        }
        
        var cell2 = tableView.dequeueReusableCell(withIdentifier: cellId3, for: indexPath) as! UserCell2
        cell2.layer.zPosition = 1
        cell2.photoImageView.image = UIImage(named: "whitebg")
        cell2.mainLabel.text = sessionInfo.instruments?[indexPath.row-2]["instrument"] as! String
        if(sessionInfo.instruments?[indexPath.row-2]["user"] as! String != ""){
            cell2.profileImageView.image = fetchedPics[sessionInfo.instruments?[indexPath.row-2]["user"] as! String]
            cell2.photoImageView.image = UIImage(named: "bluebg")
            
            cell2.typeLabel.text = "Name: \(fetchedNames[sessionInfo.instruments?[indexPath.row-2]["user"] as! String] as! String)"
        }
        
        return cell2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 300
        }
        if(indexPath.row == 1){
            return 30
        }
        return 150
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if instrument is selected and is not taken, present alert to join as this instrument.
        let alert = UIAlertController(title: "Error", message: "This instrument is already taken by another user", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if(indexPath.row > 1){
            if(sessionInfo.instruments![indexPath.row-2]["user"]! as! String == ""){
                // fill in space for current user.. send to fb
                val = indexPath.row-2
                let alert2 = UIAlertController(title: "You want to play \(sessionInfo.instruments![indexPath.row-2]["instrument"]! as! String) for this event", message: "Are you sure you want to play this instrument?", preferredStyle: UIAlertControllerStyle.alert)
                alert2.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert2, animated: true, completion: nil)
                alert2.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.cancel, handler: { action in
                    self.handleAlert()
                }))
            }
            else{
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func handleAlert(){
        handleNewUser(i: val, id: (FIRAuth.auth()?.currentUser?.uid)!)
        // update the userinformation in this current instance.
        sessionInfo.instruments![val]["user"]! = (FIRAuth.auth()?.currentUser?.uid)! as AnyObject
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    func handleNewUser(i: Int, id: String){
        // first checks to make sure he isnt on the list.
        // adds follow request to list in group...
        // Groups -> Users -> Followers
        
        var followers = [[String:AnyObject]]()
        
        FIRDatabase.database().reference().child("jamSession").child(sessionInfo.id!).observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot.value)
            if let dictionary = snapshot.value as? [String:AnyObject] { // fill in type with suspected type
                var user = dictionary as [String:AnyObject]
                var followers = dictionary["groupMembers"] as! [[String:AnyObject]]
                var instr = dictionary["instruments"] as! [[String:AnyObject]]
                DispatchQueue.main.async(execute: {
                    /*for i in 0...(followers.count)-1{
                        if(followers[i]["id"] as! String == (FIRAuth.auth()?.currentUser?.uid)!){
                            print("this user is already following/ can only apply for one instrument")
                            return
                        }
                    }*/
                    let newUser = ["time": Int(Date().timeIntervalSince1970),
                                   "id" : (FIRAuth.auth()?.currentUser?.uid)!,
                                   "groupScore":0,
                                   "position" : "none",
                                   "isFollower" : true,
                                   "isCreator" : false,
                                   "posts" : [""],
                                   "likes" : [""],
                                   "settings" : ["mute":false],
                                   "backtrace": [self.sessionInfo.id!,"groupMembers", String(followers.count)] ] as [String : Any]
                    followers.append(newUser as [String : AnyObject])
                    
                    instr[i]["user"] = id as AnyObject
                    
                    user["instruments"] = instr as AnyObject
                    user["groupMembers"] = followers as AnyObject
                    
                    var values = user
                    
                    // Update Firebase with the potential new follower
                    let ref = FIRDatabase.database().reference().child("jamSession")
                    let childRef = ref.child(self.sessionInfo.id!)
                    
                    childRef.updateChildValues(values) { (error, ref) in
                        if error != nil {
                            //print(error!)
                            return
                        }

                    }
                })
            }
        }, withCancel: nil)
        
    }
    
 }
 
 class GroupDescriptionController: UIViewController, UITextFieldDelegate, UITextViewDelegate{
    // given a reference to the group from searchview, upload the description label and entrance type for use.
    // decision: send data or load data on this controller. will implement send data for now.
    var titleLabel : String = ""
    var styleLabel : String = ""
    var descriptionLabel : String = ""
    var entranceType : String = "" // Join, Request, Apply
    var factionId : String = ""
    var userNickname = ""
    var counter = 0
    
    lazy var titleField : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = titleLabel
        lb.textColor = UIColor.white
        lb.numberOfLines = 1
        lb.font = UIFont.boldSystemFont(ofSize: 40)
        return lb
    }()
    
    lazy var styleField : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = styleLabel
        lb.textColor = UIColor.white
        lb.numberOfLines = 1
        lb.font = UIFont.boldSystemFont(ofSize: 20)
        return lb
    }()
    
    lazy var descField : TopAlignedLabel = {
        let lb = TopAlignedLabel()
        lb.sizeToFit()
        lb.translatesAutoresizingMaskIntoConstraints = false
        //lb.textAlignment = .left
        lb.text = descriptionLabel
        lb.textColor = UIColor.white
        //lb.backgroundColor = UIColor.darkGray
        lb.numberOfLines = 1
        lb.font = UIFont.systemFont(ofSize: 20)
        return lb
    }()
    
    let nicknameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "<default nickname>"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor.white
        //tf.isSecureTextEntry = true
        return tf
    }()
    
    
    lazy var joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle(entranceType, for: UIControlState()) // Will be set by group entrance type
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleConfirm(){
        
    }

    
    func refreshProfileImage(){
        let store = FIRStorage.storage()
        let storeRef = store.reference().child("images//profile_photo.jpg")
        
        storeRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("error: \(error.localizedDescription)")
            } else {
                let image = UIImage(data: data!)
                //self.myImageView.image = image
            }
        }
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(userNickname != ""){
            nicknameTextField.text = userNickname
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(joinButton)
        joinButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        joinButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        joinButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        joinButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(titleField)
        titleField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleField.topAnchor.constraint(equalTo: view.topAnchor, constant: 110).isActive = true
        titleField.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        titleField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(styleField)
        styleField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        styleField.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 10).isActive = true
        styleField.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        styleField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        view.addSubview(nicknameTextField)
        nicknameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nicknameTextField.topAnchor.constraint(equalTo: styleField.bottomAnchor, constant: 10).isActive = true
        nicknameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        nicknameTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(descField)
        descField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        descField.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 10).isActive = true
        descField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50).isActive = true
        descField.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }
    
    func popBack(_ nb: Int) {
        if let viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            guard viewControllers.count < nb else {
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - nb], animated: true)
                return
            }
        }
    }
    
    func dismissKeyboard() {view.endEditing(true)}
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
 }
 
 class TopAlignedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        let textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        super.drawText(in: textRect)
    }
 }
 
 
 
 
 
 
 
