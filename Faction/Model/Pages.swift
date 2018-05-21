
import UIKit
import CoreLocation

class Pages: NSObject {
    // Name, Date Created, Activity, Color, Coordinates, Created By,
    var pageName: String? // main
    var pageType: String?
    var content: [[String:AnyObject]]?
    var privacy: [String:String]?
    var permissions: [String:String]?
    var backtrace: [String]?
    
    init(dictionary: [String: AnyObject]) {
        self.pageName = dictionary["pageName"] as? String
        self.pageType = dictionary["pageType"] as? String
        self.content = dictionary["content"] as? [[String:AnyObject]]
        self.privacy = dictionary["privacy"] as? [String:String]
        self.permissions = dictionary["permissions"] as? [String:String]
        self.backtrace = dictionary["backtrace"] as? [String]
    }
    override init(){
        self.pageName = "name"
        self.pageType = ""
        self.content = [["content":"","date":-1,"user":"","likes":[""],"photoLink":"","urlLink":"","title":"","comments":[[
            "":""]] ]] as [[String : AnyObject]]
        self.privacy = ["style":"members+", "specific":""]
        self.permissions = ["style":"members+", "specific":""]
        self.backtrace = [""]
    }
    
}



