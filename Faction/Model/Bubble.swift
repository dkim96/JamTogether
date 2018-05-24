
import UIKit
import CoreLocation

class Bubble: NSObject {
    var id: String?
    var creatorId: String?
    var imageUrl: String?
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var timestamp: Int?
    
    var groupMembers: [[String:AnyObject]]?
    var desc: String?
    var instruments: [[String:AnyObject]]?
    var sessionName: String?
    var genre: String?
    var eventDate: String?
    var ver: String?
    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.creatorId = dictionary["creatorId"] as! String
        self.imageUrl = dictionary["imageUrl"] as? String
        self.latitude = dictionary["latitude"] as? CLLocationDegrees
        self.longitude = dictionary["longitude"] as? CLLocationDegrees
        self.timestamp = dictionary["timestamp"] as? Int
        
        self.groupMembers = dictionary["groupMembers"] as? [[String:AnyObject]]
        self.desc = dictionary["description"] as! String
        self.instruments = dictionary["instruments"] as? [[String:AnyObject]]
        self.sessionName = dictionary["sessionName"] as? String
        self.genre = dictionary["genre"] as? String
        self.eventDate = dictionary["eventDate"] as? String
        self.ver = dictionary["ver"] as? String
    }
    override init(){
        self.id = ""
        self.creatorId = ""
        self.imageUrl = ""
        self.latitude = -1
        self.longitude = -1
        self.timestamp = -1
        
        self.groupMembers = [["":""]] as [[String : AnyObject]]
        self.desc = ""
        self.instruments = [["":""]] as [[String : AnyObject]]
        self.sessionName = ""
        self.genre = ""
        self.eventDate = ""
        self.ver = ""
    }
    
}

