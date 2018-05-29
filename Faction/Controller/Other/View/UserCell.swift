

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var seconds = Int()
    
    
    var message: Message? {
        didSet {
            setupNameAndProfileImage()
            
            detailTextLabel?.text = message?.text
            
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestampDate)
            }
            
            
        }
    }
    
    fileprivate func setupNameAndProfileImage() {
        
        if let id = message?.chatPartnerId() {
            let ref = FIRDatabase.database().reference().child("faction").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dictionary["groupName"] as? String
                    
                    self.seconds = (dictionary["timestamp"] as? Int)!
                    let timestampDate = Date(timeIntervalSince1970: TimeInterval(self.seconds))
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "hh:mm:ss a"
                    self.timeLabel.text = dateFormatter.string(from: timestampDate)
                    print(self.timeLabel.text)
                    
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                    }
                }
                
            }, withCancel: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "kanye_profile")
        imageView.layer.cornerRadius = 45
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "Time:   Jul 26, 2018 - 9:00 PM"
        label.font = UIFont(name: "Raleway-Medium", size: 16)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let genreLabel: UILabel = {
        let label = UILabel()
        label.text = "Genre:   Hip-hop"
        label.font = UIFont(name: "Raleway-Medium", size: 16)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Come and join us!"
        label.font = UIFont(name: "Raleway-Medium", size: 16)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let distanceLabel: UILabel = { // X
        let label = UILabel()
        label.text = "-1"
        label.font = UIFont(name: "Raleway-Medium", size: 13)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let mainLabel: UILabel = { // nameLabel
        let label = UILabel()
        label.text = "Maroon 6"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.font = UIFont(name: "Raleway-ExtraBold", size: 30)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let typeLabel: UILabel = { //hosted by
        let label = UILabel()
        label.text = "Hosted by Ryan Wang"
        label.font = UIFont(name: "Raleway-Medium", size: 18)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "2")
        //imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        // editing for jamtogether
        addSubview(photoImageView) // blue background overlay
        addSubview(profileImageView) // creator profile img on top right
        addSubview(timeLabel) // showing the time
        //addSubview(distanceLabel) // X
        addSubview(mainLabel) // change to nameLabel, name of session
        addSubview(typeLabel) // change to Hosted by creator
        addSubview(genreLabel)
        addSubview(descriptionLabel)
        // needed labels: genrelabel description label
        //addSubview(textLabel!)
        photoImageView.layer.zPosition = 0
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        
        photoImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        photoImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        //photoImageView.widthAnchor.constraint(equalToConstant: 505).isActive = true
        //photoImageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 25).isActive = true
        profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 50).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        mainLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 30).isActive = true
        mainLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5).isActive = true
        //mainLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        //mainLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
        typeLabel.leftAnchor.constraint(equalTo: mainLabel.leftAnchor).isActive = true
        typeLabel.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 10).isActive = true
        //typeLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        //typeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
        //need x,y,width,height anchors
        timeLabel.leftAnchor.constraint(equalTo: profileImageView.leftAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 50).isActive = true
        genreLabel.leftAnchor.constraint(equalTo: profileImageView.leftAnchor).isActive = true
        genreLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 10).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: profileImageView.leftAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 10).isActive = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
