//
//  File.swift
//  Faction
//
//  Created by Daniel Kim on 4/3/18.
//  Copyright © 2018 dk. All rights reserved.
//

import Foundation
import UIKit
import Firebase

var fetchedNames = [String:String]()
var fetchedPics = [String:UIImage]()

let ver = "0.3a" //added backtracing to factions

// these are general outlines for formatting, any actual implementation are inside the functions below

/*new commits 0.4 - group privacy features
 user- nickname
 faction- groupStyle - [Standard, Open, Nickname, Custom*]
 
 GSC - if already a member, skip to GVC
 GVC- ways for promotion, (leaders -> admins -> members)
 groupDescription - if Standard/Nickname, enter nickname for group
 */

let standardUserFormat =
    ["name": "",
     "email": "",
     "folllowers": [""],
     "following": [""],
     "photos": [""],
     "profileImageUrl": "",
     "profileImageUrl2": "",
     "factions": [""],
     "defaultNickname" : "pleb", // 0.4
     "userScoreValue":0,
     "socialMedia":["facebook":"","instagram":"","twitter":""],
     "caption": "hello there.",
     "ver": ver] as [String : AnyObject]

// Standard Pages
var standardPage = ["pageName": "",
                    "pageType": "",
                    "backtrace": ["", "pages", ""]] as [String : AnyObject]

var standardInstrument = ["instrument": "",
                    "user": "",
                    "skill": "",
                    "backtrace": ["", "pages", ""]] as [String : AnyObject]

let standardUser = ["time": "", // !
    "id": "", // !
    "groupScore":0,
    "position": "", // !
    "isFollower": true,
    "isCreator": false, // !
    "posts": [""],
    "likes": [""],
    "settings": ["mute":false] ] as [String : AnyObject]

let standardGenreFormat =
    ["latitude": "" as AnyObject, //!
        "longitude": "" as AnyObject, //!
        "creatorId": "" as AnyObject, // creator of group
        "timestamp": Int(Date().timeIntervalSince1970) as AnyObject, //test if it works properly
        "id" : "" as AnyObject, // id of group
        "sessionName": "" as AnyObject, //!
        "genre": "" as AnyObject, //!
        "eventDate": "" as AnyObject, // 0.4
        "instruments": [""] as AnyObject, //~
        "description": "" as AnyObject, // ~
        "groupMembers": [""] as AnyObject,
        "ver": ver] as [String : Any] // auto

func createNewUser(name: String, email: String, password: String, profileImage: UIImage, description: String, favInstrument: String, favGenre: String, controller: LoginController){
    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
        if error != nil {
            print(error!)
            return
        }
        guard let uid = user?.uid else {
            return
        }
        //successfully authenticated user
        let imageName = UUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
        let storageRef2 = FIRStorage.storage().reference().child("profile_imagesX").child("\(imageName).jpg")
        
        //if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.0) {
        
        let test2 = profileImage.resized(toWidth: 300.0) // 10(805B) 60(1.15KB), 150(2.17KB), 300(4.89KB)
        let uploadData = UIImageJPEGRepresentation(test2!, 0.0)
        
        let test3 = profileImage.resized(toWidth: 1000.0) // 10(805B) 60(1.15KB), 150(2.17KB), 300(4.89KB)
        let uploadData2 = UIImageJPEGRepresentation(test3!, 0.0)
        
        var image2url = String()
        
        storageRef2.put(uploadData2!, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print(error!)
                return
            }
            if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                image2url = profileImageUrl
            }
        })
        
        storageRef.put(uploadData!, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                print(error!)
                return
            }
            // personalfaction
            if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                
                let values = ["name": name,
                              "email": email,
                              "followers": [""],
                              "following": [""],
                              "profileImageUrl": profileImageUrl,
                              "profileImageUrl2": image2url,
                              "favInstrument" : favInstrument, // 0.4
                              "favGenre" : favGenre, // 0.4
                              "description": description,
                              "ver": ver] as [String : Any]
                
                let ref = FIRDatabase.database().reference()
                let usersReference = ref.child("users").child(uid)
                
                usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    
                    if err != nil {
                        print(err!)
                        return
                    }
                    let user = User(dictionary: values as [String : AnyObject])
                    
                    controller.dismiss(animated: true, completion: nil)
                })
            }
        })
        //} if let profile image
    })
}

func createNewJamSession(latitude: Double, longitude: Double, fromId: String, timestamp: Int, sessionName: String, genre: String, eventDate: String, instruments: [String], description: String, groupMembers: [String]) -> Bool { // return bool doesn't work
    
    // given multiple instances
    let ref = FIRDatabase.database().reference().child("jamSession")
    let childRef = ref.childByAutoId()
    var fid = childRef.key
    var returnVal = false
    
    // we are editing files from the standard format to create the new unique user.
    var gms = [GroupMember]()
    var newUser = standardUser
    
    // testing to see if standard values are added aswell
    newUser = ["time": timestamp,
               "id": fromId,
               "position": "Admin",
               "backtrace": [fid, "groupMembers", "0"],
               "nickname": currentUser.defaultNickname,
               "isCreator": true,
               "settings": ["mute":false] ] as [String : AnyObject]
    
    var instrFormat = [[String:AnyObject]]()
    for i in 0 ... instruments.count-1{
        var standardInstrument = ["instrument": instruments[i],
                                  "user": "",
                                  "skill": "",
                                  "backtrace": [fid, "instruments", i]] as [String : AnyObject]
        instrFormat.append(standardInstrument)
    }
    
    var values = standardGenreFormat
    // THIS FORMAT OVERLOADS THE STANDARD, IF NEEDED, WHICH TO values["latitude"] = ...
    values = ["latitude": latitude as AnyObject,
        "longitude": longitude as AnyObject, //!
        "creatorId": fromId as AnyObject, // creator of group
        "timestamp": Int(Date().timeIntervalSince1970) as AnyObject, //test if it works properly
        "id" : fid as AnyObject, // id of group
        "sessionName": sessionName as AnyObject, //!
        "genre": genre as AnyObject, //!
        "eventDate": eventDate as AnyObject, // 0.4
        "instruments": instrFormat as AnyObject, //~
        "description": description as AnyObject, // ~
        "groupMembers": [newUser] as AnyObject,
        "ver": ver] as [String : Any] // auto
    
    childRef.updateChildValues(values) { (error, ref) in
        if error != nil {
            return
        }
        print("success")
        addFactionToUserProfile(uid: fromId, fid: childRef.key)
        returnVal = true
        //let dummySettingsViewController = GroupSearchViewController()
        //self.navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    return returnVal
}


let userTemp = User(dictionary: standardUserFormat)

func inspectUser(uid: String){
    var user = User()
    FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
            let user = User(dictionary: dictionary)
            //print(user)
            DispatchQueue.main.async(execute: { // Function after values are added
                // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                //check if the version numbers align.
                //for each value missing, update a default folder/value in replacement.
                if(user.ver == nil){ // must update
                    print("no ver found, will update")
                }
                else if(user.ver?.isEqual(ver))!
                {
                    print("The user is properly updated for ver \(ver)")
                    return
                }
                else{ // must update
                    print("outdated ver, will update")
                }
                ///////////// UPDATE PROCESS HERE
                // name, email, profileimage should be a given.. for now check for Followers, Following, Photos, Factions, userscore, socialmedia, caption, ver
                if(user.factions == nil){
                    user.factions = userTemp.factions
                }
                if(user.following == nil){
                    user.following = userTemp.following
                }
                if(user.followers == nil){
                    user.followers = userTemp.followers
                }
                if(user.photos == nil){
                    user.photos = userTemp.photos
                }
                if(user.userScore == nil){
                    user.userScore = userTemp.userScore
                }
                if(user.socialMedia == nil){
                    user.socialMedia = userTemp.socialMedia
                }
                if(user.caption == nil){
                    user.caption = userTemp.caption
                }
                if(user.profileImageUrl2 == nil){
                    user.profileImageUrl2 = userTemp.profileImageUrl2
                }
                
                let values = ["name": user.name, "email": user.email, "folllowers": user.followers, "following": user.following, "photos": user.photos, "profileImageUrl": user.profileImageUrl, "profileImageUrl2": user.profileImageUrl2, "factions": user.factions, "userScoreValue": user.userScore, "socialMedia":user.socialMedia, "caption": user.caption, "ver": ver] as [String : AnyObject]
                
                // RETURN: Update Firebase with the potential new follower
                let ref = FIRDatabase.database().reference().child("users")
                let childRef = ref.child(uid)
                childRef.updateChildValues(values) { (error, ref) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    print("user successfully updated to \(ver)")
                }
                // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            })
        }
        else{
            print("error")
        }
    }, withCancel: nil)
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

func inspectFaction(fid: String){
    var faction = Faction()
    FIRDatabase.database().reference().child("faction").child(fid).observeSingleEvent(of: .value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
            let faction = Faction(dictionary: dictionary)
            //print(faction)
            DispatchQueue.main.async(execute: { // Function after values are added
                // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                //check if the version numbers align.
                //for each value missing, update a default folder/value in replacement.
                if(faction.ver == nil){ // must update
                    print("no ver found, will update")
                }
                else if(faction.ver?.isEqual(ver))!
                {
                    print("The faction is properly updated for ver \(ver)")
                    return
                }
                else{ // must update
                    print("outdated ver, will update")
                }
                ///////////// UPDATE PROCESS HERE
                
                if(faction.pages![0]["backtrace"] == nil){
                    for i in 0...4{
                        faction.pages![i]["backtrace"] = [fid, "pages", String(i)] as AnyObject
                    }
                }
                
                let values = ["latitude": faction.latitude, "longitude": faction.longitude, "fromId": faction.fromId, "timestamp": faction.timestamp, "color": faction.color, "activity": faction.activity, "groupName": faction.groupName, "groupType": faction.groupType, "private": faction.privacy, "entrancePermission": faction.entrancePerm, "description": faction.groupDescription, "applicationQ": faction.appQ, "groupMembers": faction.groupMembers, "groupPhoto": faction.groupPhoto, "pages": faction.pages, "ver": ver, "backtrace": [fid], "id": fid] as [String : AnyObject]
                
                // RETURN: Update Firebase with the potential new follower
                let ref = FIRDatabase.database().reference().child("faction")
                let childRef = ref.child(fid)
                childRef.updateChildValues(values) { (error, ref) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    print("faction successfully updated to \(ver)")
                }
                // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            })
        }
        else{
            print("error")
        }
    }, withCancel: nil)
}
