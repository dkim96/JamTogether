
//
//  NewMessageController.swift
//  gameofchats
//
//  Created by Brian Voong on 6/29/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class GroupTabController: UITableViewController, CLLocationManagerDelegate {
    
    
    let cellId = "cellId"
    var seconds = Int()
    var factions = [Faction]()
    var distFromUser = [Double]()
    let locationManager = CLLocationManager()
    var imagePicker = UIImagePickerController()
    var selectedImage : UIImage!
    var imgLat : CLLocationDegrees? = nil
    var imgLon : CLLocationDegrees? = nil
    //var groups = ["Masthead", "General", "Questions","Chat","Calendar"]
    var groups = [String]()
    var connector: GroupViewController?
    var factionId: String?
    
    func handleSlide()
    {
        connector?.settingsLauncher.handleDismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        obtainPages()
        self.tableView.separatorStyle = .none
        view.backgroundColor = UIColor.darkGray
        navigationItem.title = "Factions"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(handleRefresh))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(handleCreateGroup))
        
        tableView.register(GroupTab.self, forCellReuseIdentifier: cellId)
        //setupNavBar()
        fetchUser()

        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation() // start location manager
        }
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(leftSwipe)
    }
    
    func obtainPages(){
        FIRDatabase.database().reference().child("faction").child(factionId!).child("pages").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.value)
            if let dictionary = snapshot.value as? [[String:AnyObject]] { // fill in type with suspected type
                var pages = dictionary
                DispatchQueue.main.async(execute: {
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                    for i in 0...pages.count-1
                    {
                        self.groups.append(pages[i]["pageType"] as! String)
                    }
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                })
            }
        }, withCancel: nil)
    }
    
    func handleSwipe(){
        print("swipe")
        handleSlide()
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
                    self.factions.append(faction)
                    self.distFromUser.append(VAL)
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
        
        print("fetched users")
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! GroupTab
        
        cell.mainLabel.text = groups[indexPath.row]
        
        /*let user = factions[indexPath.row]
        cell.distanceLabel.text = String(round(10*distFromUser[indexPath.row])/10) + " meters"
        
        // print(user.activity)
        if(distFromUser[indexPath.row] < 200){
            cell.mainLabel.text = user.groupName
            cell.photoImageView.image = UIImage(named: "ftn_blue")
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
        */
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // var messagesController: ViewController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /*
         print(FIRAuth.auth()?.currentUser?.uid)
         let ref = FIRDatabase.database().reference().child("users").child("4jFUvcByJnYVFKD5f92R1uXpo1S2")
         ref.observeSingleEvent(of: .value, with: { (snapshot) in
         guard let dictionary = snapshot.value as? [String: AnyObject] else {
         print("err")
         return
         }
         
         let user = User(dictionary: dictionary)
         //user.id = chatPartnerId
         print(user)
         let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
         chatLogController.user = user
         self.navigationController?.pushViewController(chatLogController, animated: true)
         
         }, withCancel: nil)*/
        
        
        
        //let dummySettingsViewController = GroupViewController()
        //dummySettingsViewController.navigationItem.title = self.factions[indexPath.row].groupName
        //navigationController?.navigationBar.tintColor = UIColor.white
        //navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        //navigationController?.pushViewController(dummySettingsViewController, animated: true)
        print("!")
        handleSlide()
        connector?.titleStr = groups[indexPath.row]
        connector?.currentPos = String(indexPath.row)
        connector?.viewDidAppear(true)
        print(groups[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
}








