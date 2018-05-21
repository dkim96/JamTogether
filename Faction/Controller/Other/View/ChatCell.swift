// Used in GroupViewController Chat Pages

import UIKit
import Firebase

class ChatCell: UITableViewCell {
    
    var seconds = Int()
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
        //imageView.image = UIImage(named: "kanye_profile")
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
        label.font = UIFont(name: "Raleway-ExtraBold", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let contentLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello"
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
    
    lazy var checkmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("O", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "Raleway-ExtraBold", size: 30)!
        //button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.tintColor = UIColor.green
        button.addTarget(self, action: #selector(handleCheck), for: .touchUpInside)
        return button
    }()
    
    lazy var XButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("X", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "Raleway-ExtraBold", size: 30)!
        button.tintColor = UIColor.red
        //button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleX), for: .touchUpInside)
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
    
    func handleCheck(){
        self.backgroundColor = UIColor.green
    }
    
    func handleX(){
        self.backgroundColor = UIColor.red
    }
    
    func setupResponse(){ // the user decides if the answer is good or bad
        addSubview(checkmarkButton) // o for now
        addSubview(XButton)
        checkmarkButton.leftAnchor.constraint(equalTo: timeLabel.rightAnchor, constant: 10).isActive = true
        checkmarkButton.topAnchor.constraint(equalTo: timeLabel.topAnchor, constant: 5).isActive = true
        checkmarkButton.widthAnchor.constraint(equalTo: checkmarkButton.widthAnchor).isActive = true
        checkmarkButton.heightAnchor.constraint(equalTo: (checkmarkButton.heightAnchor)).isActive = true
        XButton.leftAnchor.constraint(equalTo: checkmarkButton.rightAnchor, constant: 10).isActive = true
        XButton.topAnchor.constraint(equalTo: checkmarkButton.topAnchor, constant: 5).isActive = true
        XButton.widthAnchor.constraint(equalTo: XButton.widthAnchor).isActive = true
        XButton.heightAnchor.constraint(equalTo: (XButton.heightAnchor)).isActive = true
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        addSubview(nameLabel)
        addSubview(contentLabel)
        addSubview(upvoteButton)
        addSubview(downvoteButton)
        addSubview(postValue)
        //addSubview(textLabel!)
        
        //photoImageView.layer.zPosition = 0
        
        // to the left
        profileImageView.leftAnchor.constraint(equalTo: upvoteButton.rightAnchor, constant: 10).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: nameLabel.widthAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: (nameLabel.heightAnchor)).isActive = true
        
        timeLabel.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 10).isActive = true
        timeLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor, constant: 5).isActive = true
        timeLabel.widthAnchor.constraint(equalTo: timeLabel.widthAnchor).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (timeLabel.heightAnchor)).isActive = true
        
        contentLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
        contentLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 10).isActive = true
        contentLabel.widthAnchor.constraint(equalTo: contentLabel.widthAnchor).isActive = true
        contentLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
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
        
        /*NSLayoutConstraint.activate([
         textLabel?.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 10),
         textLabel?.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10)
         ])*/
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
