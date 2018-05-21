//
//  Useful Functions.swift
//  Faction
//
//  Created by Daniel Kim on 4/3/18.
//  Copyright © 2018 dk. All rights reserved.
//

import Foundation
import UIKit
import Firebase

var fetcherCount = 0
var currentUser = User()

func addFactionToUserProfile(uid: String, fid: String){
    FIRDatabase.database().reference().child("users").child(uid).child("factions").observeSingleEvent(of: .value, with: { (snapshot) in
        print(snapshot.value)
        if let dictionary = snapshot.value as? [String] { // fill in type with suspected type
            var ref = dictionary
            DispatchQueue.main.async(execute: {
                // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                if(ref.contains(fid)){
                    print("Faction already inside")
                    return
                }
                if(ref[0].isEqual("")) // empty faction
                {
                    ref[0] = fid
                }
                else{
                    ref.append(fid)
                }
                var values = [String:AnyObject]()
                for i in 0...ref.count-1{
                    values[String(i)] = ref[i] as AnyObject
                }
                print(values)
                // Update Firebase with the potential new follower
                let ref = FIRDatabase.database().reference().child("users").child(uid)
                let childRef = ref.child("factions")
                
                childRef.updateChildValues(values) { (error, ref) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    print("success")
                }
                // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            })
        }
        else{
            var values = ["0":uid]
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            let childRef = ref.child("factions")
            
            childRef.updateChildValues(values) { (error, ref) in
                if error != nil {
                    print(error!)
                    return
                }
                print("success")
            }
        }
    }, withCancel: nil)
}

func fetchUser(uid: String){
    FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String:AnyObject] { // fill in type with suspected type
            currentUser = User(dictionary: dictionary)
        }
    }, withCancel: nil)
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}




