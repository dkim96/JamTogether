
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

class GroupListController: UITableViewController, CLLocationManagerDelegate {
    // 4/21
    // change purpose to list out users (for now)
    
    // received from controller
    var groups = [GroupMember]() // list of all members in this group.
    var groupPositions = [String]()
    var groupIndex = [Int]() // this should accurately index category points, and then the rest can fill in the gaps.
    var gmDict = [[String:AnyObject]]()
    /*
     0. Admins
     1. -Hyewon
     2. Followers
     3. -Jhin
     */
    
    let cellId = "cellId"
    var seconds = Int()
    var factions = [Faction]()
    var distFromUser = [Double]()
    let locationManager = CLLocationManager()
    var imagePicker = UIImagePickerController()
    var selectedImage : UIImage!
    var imgLat : CLLocationDegrees? = nil
    var imgLon : CLLocationDegrees? = nil
    //var groups = ["Groups", "Users"]
    var connector: GroupViewController?
    var factionId: String?
    var counter = 0
    
    func handleSlide()
    {
        connector?.settingsLauncher.handleDismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .none
        view.backgroundColor = UIColor.darkGray
        navigationItem.title = "Factions"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(handleRefresh))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(handleCreateGroup))
        
        tableView.register(GroupTab.self, forCellReuseIdentifier: cellId)
        //setupNavBar()
        fetchUser()
        //setupNavBar()
        //navigationItem.title = "Facebook Feed"
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
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
    
    /*
     0. Admins
     1. -Hyewon
     2. Followers
     3. -Jhin
     */
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupIndex[groupIndex.count-1]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("glc: \(groups)")
        if(groupIndex.contains(indexPath.row)){ // positional
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! GroupTab
            if(groupPositions[groupIndex.index(of: indexPath.row)!] == "none"){
                cell.mainLabel.text = "Followers"
                return cell
            }
            cell.mainLabel.text = groupPositions[groupIndex.index(of: indexPath.row)!]
            return cell
        } // given a pos, if pos < indexpos, then it belongs to the previous category,
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! GroupTab
        // if it is not an pos, then keep counting off
        cell.mainLabel.text = fetchedNames[groups[counter].id!]
        cell.mainLabel.font = UIFont(name: "Raleway-ExtraLight", size: 20)
        counter = counter + 1
        if(counter > groups.count-1)
        {
            counter = 0
        }
        /*for i in 0...groupIndex.count-1{
         if(indexPath.row < groupIndex[i]){
         print(indexPath.row)
         print(groupIndex[i])
         cell.mainLabel.text = groups[counter]
         counter = counter + 1
         //print(groups[indexPath.row - groupIndex[i-1] - 1])
         return cell
         }
         }*/
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // var messagesController: ViewController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(gmDict[indexPath.row]["show"])
        
        // check if the user is an admin.
        for i in 0...(connector?.faction.groupMembers?.count)!-1{
            if(connector?.faction.groupMembers![i]["id"] as! String == FIRAuth.auth()?.currentUser?.uid){
                if(connector?.faction.groupMembers![i]["position"] as! String == "Admin" ){
                    
                    if(gmDict[indexPath.row]["gm"]! != nil){
                        //if user is admin, update lower class member to member, then to admin.
                        var gm = (gmDict[indexPath.row]["gm"]) as! GroupMember
                        
                        if(gm.position == "none"){
                            handleGMPositionChange(bt: gm.backtrace!, val: "Member", gvc: connector!)
                            print("\(fetchedNames[gm.id!]) promoted to Member!")
                        }
                        
                        if(gm.position == "Member"){
                            handleGMPositionChange(bt: gm.backtrace!, val: "Admin", gvc: connector!)
                            print("\(fetchedNames[gm.id!]) promoted to Admin!")
                        }
                    }
                    
                    
                    
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
}









