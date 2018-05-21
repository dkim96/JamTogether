
import UIKit
import CoreLocation

class Bubble: NSObject {
    var id: String?
    var fromId: String?
    var imageHeight: CGFloat?
    var imageUrl: String?
    var imageWidth: CGFloat?
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var timestamp: Int?
    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.fromId = dictionary["fromId"] as! String
        self.imageHeight = dictionary["imageHeight"] as? CGFloat
        self.imageUrl = dictionary["imageUrl"] as? String
        self.imageWidth = dictionary["imageWidth"] as? CGFloat
        self.latitude = dictionary["latitude"] as? CLLocationDegrees
        self.longitude = dictionary["longitude"] as? CLLocationDegrees
        self.timestamp = dictionary["timestamp"] as? Int
    }
    override init(){
        self.id = ""
        self.fromId = ""
        self.imageHeight = -1
        self.imageUrl = ""
        self.imageWidth = -1
        self.latitude = -1
        self.longitude = -1
        self.timestamp = -1
    }
    
}

