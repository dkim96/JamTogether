
import UIKit
import CoreLocation

class Faction: NSObject {
    // Name, Date Created, Activity, Color, Coordinates, Created By,
    var id: String? // main
    var fromId: String? // creator
    var groupName: String?
    var groupType: String?
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var timestamp: Int?
    var color: String?
    var activity: Int?
    var appQ: [String]?
    var entrancePerm: String?
    var privacy: Bool?
    var groupDescription: String?
    
    var groupMembers: [[String:AnyObject]]?
    var groupPhoto : String?
    var pages : [[String:AnyObject]]?
    var ver : String?
    
    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.fromId = dictionary["fromId"] as! String
        self.groupName = dictionary["groupName"] as? String
        self.groupType = dictionary["groupType"] as! String
        self.latitude = dictionary["latitude"] as? CLLocationDegrees
        self.longitude = dictionary["longitude"] as? CLLocationDegrees
        self.timestamp = dictionary["timestamp"] as? Int
        self.color = dictionary["color"] as? String
        self.activity = dictionary["activity"] as? Int
        self.appQ = dictionary["applicationQ"] as? [String]
        self.entrancePerm = dictionary["entrancePermission"] as? String
        self.privacy = dictionary["private"] as? Bool
        self.groupDescription = dictionary["description"] as? String
        //self.followers = dictionary["followers"] as? [String]
        //self.members = dictionary["members"] as? [String]
        //self.admins = dictionary["admins"] as? [String]
        self.groupMembers = dictionary["groupMembers"] as? [[String:AnyObject]]
        self.groupPhoto = dictionary["groupPhoto"] as? String
        self.pages = (dictionary["pages"] as? [[String:AnyObject]])
        self.ver = dictionary["ver"] as? String
    }
    override init(){
        self.id = ""
        self.fromId = ""
        self.latitude = -1
        self.longitude = -1
        self.timestamp = -1
        self.color = ""
        self.activity = -1
        self.appQ = [""]
        self.entrancePerm = ""
        self.privacy = false
        self.groupDescription = ""
        self.groupPhoto = ""
    }
    
}


