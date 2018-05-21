
import UIKit
import CoreLocation

class GroupMember: NSObject {
    // Name, Date Created, Activity, Color, Coordinates, Created By,
    var time: Int?
    var id: String?
    //var name: String?
    var groupScore: Int?
    var position: String? // member, admin, etc
    var isFollower: Bool?
    var isCreator: Bool?
    var posts: [String]? //reference to content
    var likes: [String]? //reference to content
    var settings: [String: String]?
    var backtrace: [String]?

    //  groupMember: id, name, time, groupScore, position, posts, likes, settings
    
    init(dictionary: [String: AnyObject]) {
        self.time = dictionary["time"] as? Int
        self.id = dictionary["id"] as? String
        //self.name = dictionary["name"] as? String
        self.groupScore = dictionary["groupScore"] as? Int
        self.position = dictionary["position"] as? String
        self.isFollower = dictionary["isFollower"] as? Bool
        self.isCreator = dictionary["isCreator"] as? Bool
        self.posts = dictionary["posts"] as? [String]
        self.likes = dictionary["likes"] as? [String]
        self.settings = dictionary["settings"] as? [String:String]
        self.backtrace = dictionary["backtrace"] as? [String]
        
    }
    override init(){
        self.time = -1
        self.id = ""
        //self.name = ""
        self.groupScore = -1
        self.position = ""
        self.isFollower = false
        self.isCreator = false
        self.posts = [""]
        self.likes = [""]
        self.settings = ["mute": ""]
        self.backtrace = [""]
    }
}





