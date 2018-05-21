
import UIKit
import CoreLocation

class Content: NSObject {
    // Name, Date Created, Activity, Color, Coordinates, Created By,
    var date: Int?
    var user: String?
    var content: String?
    var likes: [String]?
    var photoLink: String?
    var urlLink: String?
    
    // For Forums and Questions
    var comments: [[String:AnyObject]]?
    var title: String?
    // For Questions
    var solved: Bool? // is this question solved? // is this question the solution? // nil == ?
    // Scoring
    var score: [String:AnyObject]? // value, users[dict]
    var backtrace: [String]?
    
    init(dictionary: [String: AnyObject]) {
        self.date = dictionary["date"] as? Int
        self.user = dictionary["user"] as? String
        self.content = dictionary["content"] as? String
        self.likes = dictionary["likes"] as? [String]
        self.photoLink = dictionary["photoLink"] as? String
        self.urlLink = dictionary["urlLink"] as? String
        self.comments = dictionary["comments"] as? [[String:AnyObject]]
        self.title = dictionary["title"] as? String
        self.solved = dictionary["solved"] as? Bool
        self.score = dictionary["score"] as? [String:AnyObject]
        self.backtrace = dictionary["backtrace"] as? [String]
    }
    override init(){
        self.date = 1
        self.user = "tempname"
        self.content = "test"
        self.likes = [""]
        self.photoLink = ""
        self.urlLink = ""
        self.comments = [["":""]] as [[String : AnyObject]]
        self.title = ""
        self.solved = false
        self.score = ["value":"0"] as [String : AnyObject]
        self.backtrace = [""]
    }
    
}




