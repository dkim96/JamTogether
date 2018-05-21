// Used in GroupViewController Chat Pages
/*
import UIKit
import Firebase

class ForumCell: UITableViewCell {
    
    var seconds = Int()
    // array that backtraces towards the factionId
    var backtrace = [String]() // grab a backtrace reference to update any needed values.
    var controller = GroupViewController()
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
        imageView.image = UIImage(named: "kanye_profile")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "HH:MM AM"
        label.font = UIFont(name: "Raleway-Medium", size: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "John Smith"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.font = UIFont(name: "Raleway-Medium", size: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "What if they let you run the hubble"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.font = UIFont(name: "Raleway-ExtraBold", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /*let contentLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.darkGray
        label.text = "Far far away, behind the word mountains, far from the countries Vokalia and Consanatia there live the blind texts."
        label.font = UIFont(name: "Raleway-Medium", size: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()*/
    
    lazy var contentLabel : TopAlignedLabel = {
        let label = TopAlignedLabel()
        label.sizeToFit()
        label.numberOfLines = 5
        //label.backgroundColor = UIColor.darkGray
        label.text = "Far far away, behind the word mountains, far from the countries Vokalia and Consanatia there live the blind texts."
        label.font = UIFont(name: "Raleway-Medium", size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let numCommentsLabel: UILabel = {
        let label = UILabel()
        label.text = "0 comments"
        label.font = UIFont(name: "Raleway-Medium", size: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var upvoteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("^", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "Raleway-ExtraBold", size: 20)!
        //button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleUpvote), for: .touchUpInside)
        return button
    }()
    
    lazy var downvoteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("v", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "Raleway-ExtraBold", size: 20)!
        //button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleDownvote), for: .touchUpInside)
        return button
    }()
    
    let postValue: UILabel = {
        let label = UILabel()
        label.text = "5"
        label.font = UIFont(name: "Raleway-ExtraBold", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func handleUpvote(){
        handleScoreChange(bt: backtrace, val: 1, label: postValue, gvc: controller)
    }
    func handleDownvote(){
        handleScoreChange(bt: backtrace, val: -1, label: postValue, gvc: controller)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor(hex: "FFD93E")
        addSubview(profileImageView)
        addSubview(timeLabel)
        addSubview(nameLabel)
        addSubview(titleLabel)
        //addSubview(numCommentsLabel)
        addSubview(contentLabel)
        addSubview(upvoteButton)
        addSubview(downvoteButton)
        addSubview(postValue)
        
        
        // to the left
        profileImageView.leftAnchor.constraint(equalTo: upvoteButton.rightAnchor, constant: 10).isActive = true
        profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 25).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: nameLabel.widthAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: (nameLabel.heightAnchor)).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        timeLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor).isActive = true
        timeLabel.widthAnchor.constraint(equalTo: timeLabel.widthAnchor).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (timeLabel.heightAnchor)).isActive = true
        // changes
        
        titleLabel.leftAnchor.constraint(equalTo: profileImageView.leftAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: titleLabel.widthAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalTo: titleLabel.heightAnchor).isActive = true
        
        contentLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
        contentLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 10).isActive = true
        contentLabel.widthAnchor.constraint(equalToConstant: 300).isActive = true
        contentLabel.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        upvoteButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        upvoteButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        upvoteButton.widthAnchor.constraint(equalTo: upvoteButton.widthAnchor).isActive = true
        upvoteButton.heightAnchor.constraint(equalTo: (upvoteButton.heightAnchor)).isActive = true
        
        postValue.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        postValue.topAnchor.constraint(equalTo: upvoteButton.bottomAnchor, constant: -10).isActive = true
        postValue.widthAnchor.constraint(equalTo: postValue.widthAnchor).isActive = true
        postValue.heightAnchor.constraint(equalTo: (postValue.heightAnchor)).isActive = true
        
        downvoteButton.leftAnchor.constraint(equalTo: upvoteButton.leftAnchor).isActive = true
        downvoteButton.topAnchor.constraint(equalTo: postValue.bottomAnchor, constant: -5).isActive = true
        downvoteButton.widthAnchor.constraint(equalTo: downvoteButton.widthAnchor).isActive = true
        downvoteButton.heightAnchor.constraint(equalTo: (downvoteButton.heightAnchor)).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
*/
