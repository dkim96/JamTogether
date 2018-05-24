
import UIKit
import Firebase
@objcMembers
class JoinSessionController: UIViewController {
    
    
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "event")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationItem.title = "Trending"
        view.addSubview(profileImageView)
        //setupNavBar()
        setupProfileImageView()
        //Dismisses Keyboard when screen tapped
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    func setupNavBar(){
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Slide", style: .plain, target: self, action: #selector(handleSlide))
        let logo = UIImage(named: "tl")
        let imageView = UIImageView(image:logo)
        navigationItem.titleView = imageView
        let searchx = UIImage(named: "search")
        let imageView2 = UIImageView(image:searchx)
        let doneItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "search"), style: .plain, target: nil, action: #selector(getter: UIAccessibilityCustomAction.selector))
        doneItem.tintColor = UIColor.black
        navigationItem.rightBarButtonItem = doneItem;
    }

    
    
    func setupProfileImageView() {
        //need x, y, width, height constraints
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        //profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
}








