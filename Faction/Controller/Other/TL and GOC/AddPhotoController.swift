
import UIKit
import Firebase
import MapKit
import CoreLocation
import MobileCoreServices
import AVFoundation

class AddPhotoController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            
            //observeMessages()
        }
    }
    
    var newInfo = [String : Any]()
    
    let locationManager = CLLocationManager()
    let mapView = MKMapView()
    var imagePicker = UIImagePickerController()
    var selectedImage : UIImage!
    var imgLat : CLLocationDegrees? = nil
    var imgLon : CLLocationDegrees? = nil
    
    //let imageTake: UIImageView! // need to impl
    
    let photoView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pin")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var takePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Take Photo", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        
        return button
    }()
    
    lazy var sendPhoto: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Send Photo", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(sendToFB), for: .touchUpInside)
        
        return button
    }()
    
    @objc func takePhoto(){
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
        } else {
            noCamera()
        }
    }
    
    @objc func sendToFB(){
        //add iteration to show only when photo taken : LATER
        // get referance to picture and location
        
        handleImageSelectedForInfo(newInfo as [String : AnyObject])
    }
    
    fileprivate func handleImageSelectedForInfo(_ info: [String: AnyObject]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(selectedImage, completion: { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl, image: selectedImage)
            })
        }
    }
    
    fileprivate func uploadToFirebaseStorageUsingImage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let imageName = UUID().uuidString
        let ref = FIRStorage.storage().reference().child("bubble_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Failed to upload image:", error!)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
                }
                
            })
        }
    }
    
    fileprivate func sendMessageWithImageUrl(_ imageUrl: String, image: UIImage) {
        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
        sendMessageWithProperties(properties)
    }
    
    fileprivate func sendMessageWithProperties(_ properties: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference().child("bubbles")
        let childRef = ref.childByAutoId()
        //let toId = user!.id!
        let latitude = imgLat
        let longitude = imgLon
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        print("instide send msg")
        print(imgLat)
        print(imgLon)
        
        var values: [String: AnyObject] = ["latitude": latitude as AnyObject, "longitude": longitude as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp as AnyObject]
        
        //append properties dictionary onto values somehow??
        //key $0, value $1
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            print("success")
            self.dismiss(animated: true, completion: nil)
            
            //self.inputContainerView.inputTextField.text = nil
            
            //let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
            
            //let messageId = childRef.key
            //userMessagesRef.updateChildValues([messageId: 1])
            
            //let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
            //recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
    
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(alertVC,
                              animated: true,
                              completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.allowsEditing = true
        
        view.backgroundColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        view.addSubview(sendPhoto)
        setupSendPhoto()
        view.addSubview(takePhotoButton)
        setupPhotoButton()
        view.addSubview(photoView)
        setupPhotoView()

        print("???????")
        print(imgLat)
        print(imgLon)
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation() // start location manager
                
            
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var locValue:CLLocationCoordinate2D = manager.location!.coordinate
        //print("ADDPHOTO !!!! locations = \(locValue.latitude) \(locValue.longitude)")
        imgLat = locValue.latitude
        imgLon = locValue.longitude
        //print(imgLat)
        //print(imgLon)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

        
       /* let leftMargin:CGFloat = 0
        let topMargin:CGFloat = 0
        let mapWidth:CGFloat = view.frame.size.width
        let mapHeight:CGFloat = view.frame.size.height - 300
        
        mapView.frame = CGRect(x: leftMargin, y: topMargin, width: mapWidth, height: mapHeight)
        
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        // Or, if needed, we can position map in the center of the view
        mapView.center = view.center
        
        view.addSubview(mapView)*/
        
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func setupSendPhoto(){
        sendPhoto.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sendPhoto.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        sendPhoto.widthAnchor.constraint(equalToConstant: 150).isActive = true
        sendPhoto.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setupPhotoButton() {
        //need x, y, width, height constraints
        takePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        takePhotoButton.bottomAnchor.constraint(equalTo: sendPhoto.topAnchor, constant: -1).isActive = true
        takePhotoButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        takePhotoButton.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setupPhotoView() {
        //need x, y, width, height constraints
        photoView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        photoView.bottomAnchor.constraint(equalTo: takePhotoButton.topAnchor, constant: -100).isActive = true
        photoView.widthAnchor.constraint(equalToConstant: view.frame.width-100).isActive = true
        photoView.heightAnchor.constraint(equalToConstant: view.frame.width-100).isActive = true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        imagePicker.dismiss(animated: true, completion: nil)
        self.selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        photoView.image = selectedImage
        newInfo = info
    }
    
    func getCoordinates(lat:CLLocationDegrees, lon:CLLocationDegrees){
        imgLat = lat 
        imgLon = lon 
    }
///////////////////////////////// ChatLogController reference ///////////////

    
    
}








