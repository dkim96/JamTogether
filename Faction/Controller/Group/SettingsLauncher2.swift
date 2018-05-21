import UIKit
class SettingsLauncher2: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let blackView = UIView()
    var homeController: GroupViewController?
    var home2Controller = GroupListController()
    var factionId: String?
    
    var groupMembers = [GroupMember]()
    var groupPositions = [String]()
    var groupIndex = [Int]()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    var controller: UITableViewController = {
        var cv = GroupListController()
        
        return cv
    }()
    
    lazy var tableView: UITableView = {
        var cv = home2Controller
        cv.connector = homeController
        cv.factionId = factionId
        
        cv.groups = groupMembers
        cv.groupPositions = groupPositions
        cv.groupIndex = groupIndex
        //cv.connectedSL = self
        return cv.tableView
    }()
    
    
    let cellId = "cellId"
    let cellHeight: CGFloat = 50
    
    let settings: [Setting] = {
        return [Setting(name: "Settings", imageName: "settings"), Setting(name: "Terms & privacy policy", imageName: "privacy"), Setting(name: "Send Feedback", imageName: "feedback"), Setting(name: "Help", imageName: "help"), Setting(name: "Switch Account", imageName: "switch_account"), Setting(name: "Cancel", imageName: "cancel")]
    }()
    
    func showSettings() {
        //show menu
        
        if let window = UIApplication.shared.keyWindow {
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleDismiss))
            leftSwipe.direction = UISwipeGestureRecognizerDirection.right
            blackView.addGestureRecognizer(leftSwipe)
            
            window.addSubview(blackView)
            window.addSubview(tableView)
            
            let width: CGFloat = CGFloat(settings.count) * cellHeight
            tableView.frame = CGRect(400, 0, window.frame.width, window.frame.height)
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1
                
                self.tableView.frame = CGRect(200, 0, self.tableView.frame.width/2, self.tableView.frame.height)
                
            }, completion: nil)
        }
    }
    
    @objc func handleDismiss(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                self.tableView.frame = CGRect(400, 0, window.frame.width, window.frame.height)
            }
            
        }) { (completed: Bool) in
            // if setting.name != "" && setting.name != "Cancel" {
            //    self.homeController?.showControllerForSetting(setting: setting)
            //}
            self.tableView.reloadData()
            //print("!")
        }
    }
    
    func exit(){
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                self.tableView.frame = CGRect(400, 0, window.frame.width, window.frame.height)
            }
            
        }) { (completed: Bool) in
            //print(":O")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SettingCell
        
        let setting = settings[indexPath.item]
        cell.setting = setting
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(collectionView.frame.width, cellHeight)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let setting = self.settings[indexPath.item]
        handleDismiss()
    }
    
    override init() {
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SettingCell.self, forCellWithReuseIdentifier: cellId)
        
    }
    
}







