
import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    // requires a user
    
    var user: User? {
        didSet {
            navigationItem.title = "A"
        }
    }
    
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    let overlayView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "overlay")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "2")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    var moreB: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.white
        button.setImage(UIImage(named: "more"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    var followB: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.white
        button.setImage(UIImage(named: "follow"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        //button.addTarget(self, action: #selector(changeSpanSub), for: .touchUpInside)
        return button
    }()
    
    let subMenuView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Sub menu")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    /*let avatarView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "avatar")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()*/
    
    let avatarView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "avatar")
        //imageView.image = UIImage(named: "kanye_profile")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        //imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var instagramView: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(named: "instagramgray"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(handleInstagram), for: .touchUpInside)
        return button
    }()
    

    
    var facebookView: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(named: "facebookgray"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(handleInstagram), for: .touchUpInside)
        return button
    }()
    
    var twitterView: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(named: "twittergray"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(handleInstagram), for: .touchUpInside)
        return button
    }()
    
    let imagesView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "images")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let nameField : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = "username"
        lb.textColor = UIColor.black
        lb.numberOfLines = 1
        lb.font = UIFont.boldSystemFont(ofSize: 30)
        return lb
    }()
    
    let captionField : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = "Instruments"
        lb.textColor = UIColor.black
        lb.numberOfLines = 1
        lb.font = UIFont.boldSystemFont(ofSize: 15)
        return lb
    }()
    

    
    let postField : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = "Favorite Instrument"
        lb.textColor = UIColor.black
        lb.numberOfLines = 1
        lb.font = UIFont(name: "Raleway-ExtraBold", size: 30)
        return lb
    }()
    
    let npostField : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = "---"
        lb.textColor = UIColor.black
        lb.numberOfLines = 1
        lb.font = UIFont(name: "Raleway-ExtraLight", size: 25)
        return lb
    }()
    
    let followerField : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = "Favorite Genre"
        lb.textColor = UIColor.black
        lb.numberOfLines = 1
        lb.font = UIFont(name: "Raleway-ExtraBold", size: 30)
        return lb
    }()
    
    let nfollowerField : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = "--"
        lb.textColor = UIColor.black
        lb.numberOfLines = 1
        lb.font = UIFont(name: "Raleway-ExtraLight", size: 25)
        return lb
    }()
    
    let followingField : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = "Description"
        lb.textColor = UIColor.black
        lb.numberOfLines = 1
        lb.font = UIFont(name: "Raleway-ExtraBold", size: 30)
        return lb
    }()
    
    let nfollowingField : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = "---"
        lb.textColor = UIColor.black
        lb.numberOfLines = 1
        lb.font = UIFont(name: "Raleway-ExtraLight", size: 25)
        return lb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(handleRefresh))
        navigationItem.title = "Profile"
        // Update User into Profile
        if(FIRAuth.auth()?.currentUser?.uid != nil){ // as long as their is a user
            var id = FIRAuth.auth()?.currentUser?.uid
            fetchUser(id: id!)
        }
        if(user == nil){
            var id = FIRAuth.auth()?.currentUser?.uid
            fetchUser(id: id!)
        }
        view.backgroundColor = UIColor.white
        setupOverlay()
    }
    
    func handleRefresh(){
        //remove set annotations, bubbles, etc
        // refetch
        fetchUser(id: (FIRAuth.auth()?.currentUser?.uid)!)
    }
    
    func viewDidAppear() {
        super.viewDidAppear(false)
        navigationItem.title = "Profile"
        // Update User into Profile
        if(FIRAuth.auth()?.currentUser?.uid != nil){ // as long as their is a user
            var id = FIRAuth.auth()?.currentUser?.uid
            fetchUser(id: id!)
        }
        if(user == nil){
            var id = FIRAuth.auth()?.currentUser?.uid
            fetchUser(id: id!)
        }
        view.backgroundColor = UIColor.white
        setupOverlay()
        
    }
    
    func handleInstagram(){
        
    }
    
    func fetchUser(id: String){
        FIRDatabase.database().reference().child("users").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot.value)
            if let dictionary = snapshot.value as? [String: AnyObject] { // fill in type with suspected type
                let user = User(dictionary: dictionary)
                DispatchQueue.main.async(execute: {
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                    self.captionField.text = user.caption
                    self.nameField.text = user.name
                    self.npostField.text = user.favInstrument
                    self.nfollowerField.text = user.favGenre
                    self.nfollowingField.text = user.descript
                    //self.followingField.text = String(user.following!.count)
                    //self.followerField.text = String(user.factions!.count)
                    //self.postField.text = String(user.userScore!)
                    /*
                    if(user.socialMedia!["facebook"] != ""){
                        self.facebookView.setImage(UIImage(named: "facebook"), for: .normal)
                    }
                    if(user.socialMedia!["instagram"] != ""){
                        //self.instagramView.image = UIImage(named: "instagram")
                        self.instagramView.setImage(UIImage(named: "instagram"), for: .normal)
                    }
                    if(user.socialMedia!["twitter"] != ""){
                        self.twitterView.setImage(UIImage(named: "twitter"), for: .normal)
                    }
                    
                    if(user.following![0] == ""){
                        self.followingField.text = "0"
                    }
                    
                    if(user.factions![0] == ""){
                        self.followerField.text = "0"
                    }*/
                    
                    if(fetchedPics[id] != nil){
                        self.avatarView.image = fetchedPics[id]
                        self.avatarView.layer.cornerRadius = self.self.avatarView.frame.height / 2
                    }
                    else{ // fetch the pic
                        let url = URL(string: user.profileImageUrl as! String)
                        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                        let image: UIImage = UIImage(data: data!)!
                        fetchedPics[id] = image
                        self.avatarView.image = fetchedPics[id]
                        self.avatarView.layer.cornerRadius = self.self.avatarView.frame.height / 2
                        fetchedNames[id] = user.name
                    }
                    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                })
            }
        }, withCancel: nil)
    }
    
    func setupOverlay() {
        view.addSubview(backgroundView)
        //view.addSubview(overlayView)
        view.addSubview(nameField)
        //view.addSubview(captionField)
        //view.addSubview(moreB)
        //view.addSubview(followB)
        //view.addSubview(subMenuView)
        view.addSubview(avatarView)
        //view.addSubview(imagesView)
        view.addSubview(postField)
        view.addSubview(npostField)
        view.addSubview(followerField)
        view.addSubview(followingField)
        view.addSubview(nfollowerField)
        view.addSubview(nfollowingField)
        
        //view.addSubview(instagramView)
        //view.addSubview(facebookView)
        //view.addSubview(twitterView)
        
        //overlayView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //overlayView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).isActive = true
        
        backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        backgroundView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        backgroundView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        avatarView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50).isActive = true
        avatarView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        avatarView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        avatarView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        NSLayoutConstraint.activate([
            nameField.leftAnchor.constraint(equalTo: avatarView.rightAnchor, constant: 20),
            nameField.topAnchor.constraint(equalTo: avatarView.topAnchor, constant: 30)])
        
        NSLayoutConstraint.activate([
            postField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            postField.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 60)])
        
        NSLayoutConstraint.activate([
            npostField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            npostField.topAnchor.constraint(equalTo: postField.bottomAnchor, constant: 20)])
        
        NSLayoutConstraint.activate([
            followerField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            followerField.topAnchor.constraint(equalTo: npostField.bottomAnchor, constant: 20)])
        
        NSLayoutConstraint.activate([
            nfollowerField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            nfollowerField.topAnchor.constraint(equalTo: followerField.bottomAnchor, constant: 20)])
        
        NSLayoutConstraint.activate([
            followingField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            followingField.topAnchor.constraint(equalTo: nfollowerField.bottomAnchor, constant: 20)])
        
        NSLayoutConstraint.activate([
            nfollowingField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            nfollowingField.topAnchor.constraint(equalTo: followingField.bottomAnchor, constant: 20)])
        
        /*moreB.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        moreB.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 35).isActive = true
        
        instagramView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        instagramView.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 35).isActive = true
        instagramView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        instagramView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        facebookView.rightAnchor.constraint(equalTo: instagramView.rightAnchor).isActive = true
        facebookView.topAnchor.constraint(equalTo: instagramView.bottomAnchor, constant: 10).isActive = true
        facebookView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        facebookView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        twitterView.rightAnchor.constraint(equalTo: facebookView.rightAnchor).isActive = true
        twitterView.topAnchor.constraint(equalTo: facebookView.bottomAnchor, constant: 10).isActive = true
        twitterView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        twitterView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        subMenuView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        subMenuView.topAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: 15).isActive = true
        
        
        imagesView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imagesView.topAnchor.constraint(equalTo: subMenuView.bottomAnchor, constant: 15).isActive = true
        
        NSLayoutConstraint.activate([
            captionField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captionField.topAnchor.constraint(equalTo: nameField.bottomAnchor),
            captionField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            captionField.heightAnchor.constraint(equalToConstant: 20)])
        */
    }
    
        override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
}

extension UIImage {
    var noir: UIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
}






