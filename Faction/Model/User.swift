
import UIKit

class User: NSObject {
    var id: String?
    var name: String?
    var email: String?
    var profileImageUrl: String?
    var profileImageUrl2: String?
    
    var followers: [String]?
    var following: [String]?
    var photos: [String]?
    
    var factions: [String]?
    var userScore: Int?
    var socialMedia: [String:String]?
    var caption: String?
    var ver: String?
    var defaultNickname: String?
    
    var descript: String?
    var favGenre: String?
    var favInstrument: String?
    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
        self.profileImageUrl2 = dictionary["profileImageUrl2"] as? String
        self.followers = dictionary["followers"] as? [String]
        self.following = dictionary["following"] as? [String]
        self.photos = dictionary["photos"] as? [String]
        self.factions = (dictionary["factions"] as? [String])
        self.userScore = (dictionary["userScoreValue"] as? Int)
        self.socialMedia = dictionary["socialMedia"] as? [String:String]
        self.caption = dictionary["caption"] as? String
        self.ver = dictionary["ver"] as? String
        self.defaultNickname = dictionary["defaultNickname"] as? String
        
        self.descript = dictionary["description"] as? String
        self.favGenre = dictionary["favGenre"] as? String
        self.favInstrument = dictionary["favInstrument"] as? String
    }
    
    override init() {
        self.id = ""
        self.name = ""
        self.email = ""
        self.profileImageUrl = ""
        self.profileImageUrl2 = ""
        self.factions = [""]
        self.userScore = -1
        self.socialMedia = ["":""]
        self.caption = ""
        self.ver = ""
        self.defaultNickname = ""
    }
}
