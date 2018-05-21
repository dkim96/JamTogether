 
 /*
  GroupSearchView is the main view that allows users to search for new groups.
  
  Improvements:
  GroupDescriptionController should eventually be a ContainerView so that people can scroll down.
  */
 
 import UIKit
 import Firebase
 import CoreLocation
 
 class GroupSearchViewController: UITableViewController, CLLocationManagerDelegate { // AND GroupDescriptionController
    
    let cellId = "cellId"
    let cellId2 = "cellId2"
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
            fetchNameandPic(id: curId, np: -1, gvc: GroupViewController(), nav: self.navigationController!)
        inspectUser(uid: (FIRAuth.auth()?.currentUser?.uid)!)
        
        
        self.tableView.separatorStyle = .none
        navigationItem.title = "Local Factions"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(handleRefresh))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(handleCreateGroup))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId2)
        fetchUser()
        
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
        factions.removeAll()
        distFromUser.removeAll()
        vicinity.removeAll()
        general.removeAll()
        outskirts.removeAll()
        sizeRef = [0,1,2]
        fetchUser()
        refreshControl?.endRefreshing()
    }
    
    @objc func handleRefresh(){
        factions.removeAll()
        distFromUser.removeAll()
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
        if(curId != FIRAuth.auth()?.currentUser?.uid)
        {
            curId = (FIRAuth.auth()?.currentUser?.uid)!
            inspectUser(uid: (FIRAuth.auth()?.currentUser?.uid)!)
            factions.removeAll()
            distFromUser.removeAll()
            fetchUser()
        }
    }
    
    func fetchUser() {
        FIRDatabase.database().reference().child("faction").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let faction = Faction(dictionary: dictionary)
                faction.id = snapshot.key
                
                let coord1 = CLLocation(latitude: faction.latitude!, longitude: faction.longitude!)
                let coord2 = CLLocation(latitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!)
                let VAL = coord1.distance(from: coord2)
                
                // distinct group update
                if(VAL < self.vicinityDistance){
                    self.factions.append(faction)
                    self.distFromUser.append(VAL)
                    self.vicinity.append(faction)
                    self.distanceDict[faction.id!] = VAL
                    self.sizeRef[1] = self.sizeRef[1] + 1
                    self.sizeRef[2] = self.sizeRef[2] + 1
                }
                
                else if(VAL < self.generalDistance){
                    self.factions.append(faction)
                    self.distFromUser.append(VAL)
                    self.general.append(faction)
                    self.distanceDict[faction.id!] = VAL
                    self.sizeRef[2] = self.sizeRef[2] + 1
                }
                
                else if(VAL < self.outskirtDistance){
                    self.factions.append(faction)
                    self.distFromUser.append(VAL)
                    self.outskirts.append(faction)
                    self.distanceDict[faction.id!] = VAL
                }
                
                /*if(VAL < 200){
                    //print("Group within radius", VAL)
                    self.factions.append(faction)
                    self.distFromUser.append(VAL)
                }*/
                else{
                    //print("Group outside radius", VAL)
                }
                
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
        return factions.count + 3 // seperator cells
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // if indexpath is at a transition point, add a seperator cell
        //print(indexPath.row)
        if(factions.count == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId2, for: indexPath) as! UITableViewCell
            return cell
        }
        if(sizeRef.contains(indexPath.row)){
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId2, for: indexPath) as! UITableViewCell
            cell.textLabel?.font = UIFont(name: "Raleway-ExtraBold", size: 20)
            if(indexPath.row == sizeRef[0]){
                cell.textLabel?.text = "Vicinity"
            }
            if(indexPath.row == sizeRef[1]){
                cell.textLabel?.text = "General"
            }
            if(indexPath.row == sizeRef[2]){
                cell.textLabel?.text = "Outskirts"
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        // proximity -> general -> outskirts
        // determine from pos what to post.
        var user = Faction()
        if(sizeRef == [0,1,2]){
            return cell
        }
        if(indexPath.row >= sizeRef[2]+1){ // outskirts
            user = outskirts[indexPath.row-sizeRef[2]-1]
        }
        else if(indexPath.row >= sizeRef[1]+1){ // general
            user = general[indexPath.row-sizeRef[1]-1]
        }
        else{ // closeby
            user = vicinity[indexPath.row-1]
        }
        
        
        
        //let user = factions[indexPath.row]
        cell.distanceLabel.text = String(round(10*distanceDict[user.id!]!)/10) + " meters"
        
        if(distanceDict[user.id!]! < vicinityDistance){
            cell.mainLabel.text = user.groupName
            cell.photoImageView.image = UIImage(named: "ftn_blue")
        }
        else if(distanceDict[user.id!]! < generalDistance){
            cell.mainLabel.text = user.groupName!
            cell.photoImageView.image = UIImage(named: "ftn_red")
        }
        else{
            cell.mainLabel.text = user.groupName! + " (N/A)"
            cell.photoImageView.image = UIImage(named: "ftn_red")
        }
        
        cell.typeLabel.text = user.groupType
        self.seconds = user.timestamp!
        let timestampDate = Date(timeIntervalSince1970: TimeInterval(self.seconds))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a"
        cell.timeLabel.text = dateFormatter.string(from: timestampDate)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(sizeRef.contains(indexPath.row)){
            return 30
        }
        return 150
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(sizeRef.contains(indexPath.row)){
            return
        }
        var user = Faction()
        
        if(indexPath.row >= sizeRef[2]+1){ // outskirts
            user = outskirts[indexPath.row-sizeRef[2]-1]
        }
        else if(indexPath.row >= sizeRef[1]+1){ // general
            user = general[indexPath.row-sizeRef[1]-1]
        }
        else{ // closeby
            user = vicinity[indexPath.row-1]
        }
        
        if(user.color == ""){ // none found
            return
        }
        var pass = false
        // if already a follower, directly send.
        for i in 0...(user.groupMembers?.count)!-1{
            print(user.groupMembers![i]["id"] as! String)
            if( user.groupMembers![i]["id"] as! String == curId ){
                let gvc = GroupViewController()
                gvc.faction = user
                gvc.factionId = user.id!
                gvc.pageContent = Pages(dictionary: user.pages![Int(gvc.currentPos)!])
                assessNameLoad(members: user.groupMembers!, gvc: gvc, nav: self.navigationController!)
                
                //gvc.getMemberNames()
                //self.navigationController?.pushViewController(gvc, animated: true)
                pass = true
            }
        }
        if(pass == false){
        let dummySettingsViewController = GroupDescriptionController()
        dummySettingsViewController.titleLabel = user.groupName!
        dummySettingsViewController.styleLabel = user.groupType!
        dummySettingsViewController.factionId = user.id!
        dummySettingsViewController.userNickname = currentUser.defaultNickname!
        print(currentUser.defaultNickname)
        let gd = user.entrancePerm!
        if(gd == "Open") {
            dummySettingsViewController.entranceType = "View"
        }
        else if(gd == "Application") {
            dummySettingsViewController.entranceType = "Apply"
        }
        else { dummySettingsViewController.entranceType = gd }
        dummySettingsViewController.descriptionLabel = user.groupDescription!
        navigationController?.pushViewController(dummySettingsViewController, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
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
        // Join -> Adds the user into the group directory, transfers to groupviewcontroller
        // If already a member, this intro should not be shown and the user should be immediately redirected
        if(entranceType == "View"){
            let dummySettingsViewController = GroupViewController()
            dummySettingsViewController.navigationController?.title = titleField.text
            dummySettingsViewController.factionId = factionId
            dummySettingsViewController.nickname = nicknameTextField.text
            
            fetchFaction(gvc: dummySettingsViewController)
            //navigationController?.pushViewController(dummySettingsViewController, animated: true)
        }
        // Request -> Sends a request signal to an admin, updates button that says success!
        
        // Apply -> sends him to a new controller that presents the questions and then basically works as a req
    }
    
    func fetchFaction(gvc: GroupViewController){
        print(factionId)
        FIRDatabase.database().reference().child("faction").child(factionId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] { // fill in type with suspected type
                gvc.faction = Faction(dictionary: dictionary)
                gvc.pageContent = Pages(dictionary: gvc.faction.pages![Int(gvc.currentPos)!])
                DispatchQueue.main.async(execute: {
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                    //
                    //gvc.faction.groupMembers?.append(["id":(FIRAuth.auth()?.currentUser?.uid)! as AnyObject])
                    var newPeople = [String]()
                    for i in 0...(gvc.faction.groupMembers?.count)!-1{
                        var person = gvc.faction.groupMembers![i]["id"] as! String
                        if(fetchedNames[person] == nil){
                            newPeople.append(person)
                        }
                        if(i == (gvc.faction.groupMembers?.count)!-1 && newPeople.count == 0){
                            print("End by no new people")
                            newPeople = [String]()
                            gvc.getMemberNames()
                            self.navigationController?.pushViewController(gvc, animated: true)
                        }
                        //self.fetchNameandPic(id: gvc.faction.groupMembers![i]["id"] as! String, gvc:gvc, i:i)
                    }
                    self.counter = 0
                    if(newPeople.count != 0){
                        for i in 0...newPeople.count-1{
                            //print(gvc.faction.groupMembers![i]["id"])
                            self.fetchNameandPic(id: newPeople[i] as! String, gvc:gvc, i:i, np: newPeople.count-1, j: self.counter)
                        }
                    }
                    
                    //self.navigationController?.title = self.self.faction.groupName // this sets tabbar to name!
                    gvc.navigationItem.title = gvc.faction.groupName
                    //gvc.tableView.reloadData()
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                })
            }
        }, withCancel: nil)
    }
    
    
    
    func fetchNameandPic(id: String, gvc: GroupViewController, i: Int, np: Int, j: Int){
        FIRDatabase.database().reference().child("users").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] { // fill in type with suspected type
                var ref = dictionary
                //DispatchQueue.main.async(execute: {
                // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                let picName = ref["profileImageUrl"] as! String
                //print(picName)
                let store = FIRStorage.storage()
                let storeRef = store.reference(forURL: picName)
                
                storeRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("error: \(error.localizedDescription)")
                    } else {
                        let image = UIImage(data: data!)
                        fetchedPics[id] = image
                        //let url = URL(string: ref["profileImageUrl"] as! String)
                        //let data = try? Data(contentsOf: url!)
                        //let image: UIImage = UIImage(data: data!)!
                        fetchedNames[id] = (ref["name"] as! String)
                        print("loading \(ref["name"] as! String)")
                        //fetchedPics[id] = image
                    }
                    DispatchQueue.main.async {
                        self.counter = self.counter + 1
                        //print(self.counter)
                        if (self.counter-1 == np){
                            self.counter = 0
                            print("End by last loaded person")
                            gvc.getMemberNames()
                            self.navigationController?.pushViewController(gvc, animated: true)
                        }
                    }
                }

                // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                //})
            }
        }, withCancel: nil)
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
 
 
 
 
 
 
 
