
import UIKit
import Firebase

class TrendViewController: UIViewController {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Notifications")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Trending"
        view.addSubview(profileImageView)
        setupNavBar()
        setupProfileImageView()
    }
    
    func setupNavBar(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Slide", style: .plain, target: self, action: #selector(handleSlide))
        let logo = UIImage(named: "tl")
        let imageView = UIImageView(image:logo)
        navigationItem.titleView = imageView
        let searchx = UIImage(named: "search")
        let imageView2 = UIImageView(image:searchx)
        let doneItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "search"), style: .plain, target: nil, action: #selector(getter: UIAccessibilityCustomAction.selector))
        doneItem.tintColor = UIColor.black
        navigationItem.rightBarButtonItem = doneItem;
    }
    
    func showControllerForSetting(setting: Setting) {
        //let dummySettingsViewController = UIViewController()
        //dummySettingsViewController.view.backgroundColor = UIColor.white
       // dummySettingsViewController.navigationItem.title = setting.name
        //navigationController?.navigationBar.tintColor = UIColor.white
        //navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        //navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    lazy var settingsLauncher: SettingsLauncher = {
        let launcher = SettingsLauncher()
        //launcher.homeController = self
        return launcher
    }()
    
    func handleSlide()
    {
        settingsLauncher.showSettings()
    }

    
    func setupProfileImageView() {
        //need x, y, width, height constraints
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        //profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

}








