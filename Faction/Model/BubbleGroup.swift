
import UIKit
import CoreLocation

class BubbleGroup: NSObject {
    var bubbles: [Bubble]
    var positions: [Int]
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?

    
    init(dictionary: [String: AnyObject]) {
        self.latitude = dictionary["latitude"] as? CLLocationDegrees
        self.longitude = dictionary["longitude"] as? CLLocationDegrees
        self.bubbles = (dictionary["bubbles"] as? [Bubble])!
        self.positions = (dictionary["positions"] as? [Int])!
    }
}


