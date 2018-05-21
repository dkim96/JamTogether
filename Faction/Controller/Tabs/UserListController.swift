 
 /*
  GroupSearchView is the main view that allows users to search for new groups.
  
  Improvements:
  GroupDescriptionController should eventually be a ContainerView so that people can scroll down.
  */
 
 import UIKit
 import Firebase
 import CoreLocation
 
 class UserListController: UITableViewController, CLLocationManagerDelegate { // AND GroupDescriptionController
    // will receive input for var
    // access user's factions, for each faction, grab an instance to update it to factions[]
    var userFactions = [String]()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Handling no user
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        curId = (FIRAuth.auth()?.currentUser?.uid)!
        inspectUser(uid: (FIRAuth.auth()?.currentUser?.uid)!)
        
        //self.tableView.separatorStyle = .none
        navigationItem.title = "My Factions"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(handleRefresh))
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(handleCreateGroup))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId2)
        showUserFactions(uid: (FIRAuth.auth()?.currentUser?.uid)!)
        
        // Location Services
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

        refreshControl = UIRefreshControl()
        refreshControl?.clipsToBounds = true
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            //print(logoutError)
        }
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
    
    func refresh(sender:AnyObject) {
        showUserFactions(uid: (FIRAuth.auth()?.currentUser?.uid)!)
        refreshControl?.endRefreshing()
    }
    
    @objc func handleRefresh(){
        showUserFactions(uid: (FIRAuth.auth()?.currentUser?.uid)!)
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
            showUserFactions(uid: curId)
        }
    }
    
    func showUserFactions(uid: String){
        
        FIRDatabase.database().reference().child("users").child(uid).child("factions").observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot.value)
            if let dictionary = snapshot.value as? [String] { // fill in type with suspected type
                self.userFactions = dictionary
                DispatchQueue.main.async(execute: {
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                    self.factions.removeAll()
                    self.distFromUser.removeAll()
                    if(self.userFactions[0] == ""){
                        self.tableView.reloadData()
                        return
                    }
                    for i in 0...self.userFactions.count-1{
                        self.fetchUser(fid: self.userFactions[i], i:i) // Might crash if [] isnt recognized
                    }
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                })
            }
        }, withCancel: nil)
    }
    
    func fetchUser(fid: String, i: Int) {
        FIRDatabase.database().reference().child("faction").child(fid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let faction = Faction(dictionary: dictionary)
                faction.id = snapshot.key
                let coord1 = CLLocation(latitude: faction.latitude!, longitude: faction.longitude!)
                let coord2 = CLLocation(latitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!)
                let VAL = coord1.distance(from: coord2)

                    self.factions.append(faction)
                    self.distFromUser.append(VAL)

                //this will crash because of background thread, so lets use dispatch_async to fix
                if (i == self.userFactions.count-1){
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                }
            }
        }, withCancel: nil)
        //print("fetched users")
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return factions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        ////print("error checker: \(indexPath.row) \(factions.count)")
        if(factions[indexPath.row] == nil){
            print("error on 161")
            return cell
        }
        let user = factions[indexPath.row] // error cause
        cell.distanceLabel.text = String(round(10*distFromUser[indexPath.row])/10) + " meters"
        if(distFromUser[indexPath.row] < 200){
            cell.mainLabel.text = user.groupName
            cell.photoImageView.image = UIImage(named: "ftn_blue")
        }
        else{
            cell.mainLabel.text = user.groupName!
            cell.photoImageView.image = UIImage(named: "ftn_red")
        }
        cell.typeLabel.text = user.groupType
        self.seconds = user.timestamp!
        let timestampDate = Date(timeIntervalSince1970: TimeInterval(self.seconds))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a"
        cell.timeLabel.text = dateFormatter.string(from: timestampDate)
        
        return cell*/
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId2, for: indexPath) as! UITableViewCell
        if(factions[indexPath.row] == nil){
            print("error on 161")
            return cell
        }
        let user = factions[indexPath.row] // error cause
        cell.textLabel?.text = user.groupName
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dummySettingsViewController = GroupDescriptionController()
        dummySettingsViewController.titleLabel = factions[indexPath.row].groupName!
        dummySettingsViewController.styleLabel = factions[indexPath.row].groupType!
        dummySettingsViewController.factionId = factions[indexPath.row].id!
        dummySettingsViewController.userNickname = currentUser.defaultNickname!
        print(currentUser.defaultNickname)
        let gd = factions[indexPath.row].entrancePerm!
        if(gd == "Open") {
            dummySettingsViewController.entranceType = "View"
        }
        else if(gd == "Application") {
            dummySettingsViewController.entranceType = "Apply"
        }
        else { dummySettingsViewController.entranceType = gd }
        dummySettingsViewController.descriptionLabel = factions[indexPath.row].groupDescription!
        navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
 }
 
 /////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////////////////////////////////////
