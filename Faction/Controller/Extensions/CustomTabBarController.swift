import UIKit
import Firebase

class CustomTabBarController: UITabBarController {

    let viewController = ViewController()
    let profviewController = ProfileViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()


        //let viewController = ViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        //secondNavigationController.title = "Requests"
        navigationController.tabBarItem.image = UIImage(named: "pack")

        
        //let profviewController = ProfileViewController()
        let fifthNavigationController = UINavigationController(rootViewController: profviewController)
        //messengerNavigationController.title = "Messenger"
        fifthNavigationController.tabBarItem.image = UIImage(named: "profile")
        
        viewControllers = [navigationController, fifthNavigationController]
        
        tabBar.isTranslucent = false
        
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: 1000, height: 0.5)
        //topBorder.backgroundColor = UIColor.rgb(229, green: 231, blue: 235).cgColor
        
        tabBar.layer.addSublayer(topBorder)
        tabBar.clipsToBounds = true
        self.selectedIndex = 0 // Chooses middle tab

        //self.selectedIndex
        if FIRAuth.auth()?.currentUser?.uid != nil {
        fetchUser(uid: (FIRAuth.auth()?.currentUser?.uid)!)
        }
        
        if FIRAuth.auth()?.currentUser?.uid == nil {
            do {
                try FIRAuth.auth()?.signOut()
            } catch let logoutError {
                print(logoutError)
            }
            
            let loginController = LoginController()
            present(loginController, animated: true, completion: nil)
        }

    }
    

    
    
}

