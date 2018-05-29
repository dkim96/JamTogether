
import UIKit
import Firebase
import MapKit
import CoreLocation
import MobileCoreServices
import AVFoundation

// groupname, time*, location*, instruments***, genre

class CreateJamSessionController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var coordinate = CLLocationCoordinate2D()
    var date = Date()
    var instruments = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        imagePicker.allowsEditing = true
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        createSubviews()
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        //Dismisses Keyboard when screen tapped
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func datePickerValueChanged(_ sender: UIDatePicker){
        
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: sender.date)
        
        print("Selected value \(selectedDate)")
    }
    
    func createSubviews(){
        view.addSubview(nameTextField)
        view.addSubview(genreTextField)
        view.addSubview(descTextField)
        //view.addSubview(instrumentTextField)
        
        view.addSubview(genreButton)
        view.addSubview(genreInput)
        view.addSubview(dateButton)
        view.addSubview(dateInput)
        view.addSubview(instrButton)
        view.addSubview(instrInput)
        view.addSubview(sendButton)
        
        nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 120).isActive = true
        nameTextField.widthAnchor.constraint(equalToConstant: 300).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        genreTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        genreTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20).isActive = true
        genreTextField.widthAnchor.constraint(equalToConstant: 300).isActive = true
        genreTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        descTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        descTextField.topAnchor.constraint(equalTo: genreTextField.bottomAnchor, constant: 20).isActive = true
        descTextField.widthAnchor.constraint(equalToConstant: 300).isActive = true
        descTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        genreButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        genreButton.topAnchor.constraint(equalTo: descTextField.bottomAnchor, constant: 20).isActive = true
        genreButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        genreButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        genreInput.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 40).isActive = true
        genreInput.topAnchor.constraint(equalTo: descTextField.bottomAnchor, constant: 20).isActive = true
        genreInput.widthAnchor.constraint(equalToConstant: 200).isActive = true
        genreInput.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        dateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dateButton.topAnchor.constraint(equalTo: genreInput.bottomAnchor, constant: 20).isActive = true
        dateButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        dateButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        dateInput.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        dateInput.topAnchor.constraint(equalTo: genreInput.bottomAnchor, constant: 20).isActive = true
        dateInput.widthAnchor.constraint(equalToConstant: 200).isActive = true
        dateInput.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        instrButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        instrButton.topAnchor.constraint(equalTo: dateInput.bottomAnchor, constant: 20).isActive = true
        instrButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        instrButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        instrInput.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 40).isActive = true
        instrInput.topAnchor.constraint(equalTo: dateInput.bottomAnchor, constant: 20).isActive = true
        instrInput.widthAnchor.constraint(equalToConstant: 200).isActive = true
        instrInput.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        sendButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    lazy var genreButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Set location", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleCheck2), for: .touchUpInside)
        return button
    }()
    
    let genreInput : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = ""
        lb.textColor = UIColor.white
        lb.numberOfLines = 1
        lb.font = UIFont.systemFont(ofSize: 15)
        return lb
    }()
    
    lazy var dateButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Set date", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleCheck3), for: .touchUpInside)
        return button
    }()
    
    let dateInput : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = ""
        lb.textColor = UIColor.white
        lb.numberOfLines = 1
        lb.font = UIFont.systemFont(ofSize: 15)
        return lb
    }()
    
    lazy var instrButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Instruments", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleCheck4), for: .touchUpInside)
        return button
    }()
    
    var instrInput : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = "0"
        lb.textColor = UIColor.white
        lb.numberOfLines = 1
        lb.font = UIFont.systemFont(ofSize: 15)
        return lb
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "What is the name of your jam session?"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor.white
        //tf.isSecureTextEntry = true
        return tf
    }()
    
    let genreTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Genre"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor.white
        //tf.isSecureTextEntry = true
        return tf
    }()
    
    let descTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Give a short description"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor.white
        //tf.isSecureTextEntry = true
        return tf
    }()
    
    let instrumentTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Instruments needed"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor.white
        //tf.isSecureTextEntry = true
        return tf
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        //button.contentHorizontalAlignment = .left
        //button.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Create Jam Session", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
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
    
    @objc func handleCheck2() {
        let dummySettingsViewController = MapController()
        dummySettingsViewController.cjsc = self
        present(dummySettingsViewController, animated: true, completion: nil)
        //self.navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    @objc func handleCheck3() {
        let dummySettingsViewController = TimeController()
        dummySettingsViewController.cjsc = self
        present(dummySettingsViewController, animated: true, completion: nil)
        //self.navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    @objc func handleCheck4() {
        let dummySettingsViewController = InstrController()
        dummySettingsViewController.cjsc = self
        present(dummySettingsViewController, animated: true, completion: nil)
        //self.navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    let alert: UIAlertController = {
        let at = UIAlertController(title: "Unable to continue", message: "Please fill in all spaces.", preferredStyle: .alert)
        at.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        return at
    }()
    
    @objc func handleSend() { // check for set stuff, and create
        print("!")
        if(genreInput.text! == "none" || dateInput.text == "" || instrInput.text == "0" || (genreTextField.text?.isEmpty)! || (nameTextField.text?.isEmpty)! ){
            self.present(alert, animated: true)
            return
        }
        
        createNewJamSession(latitude: coordinate.latitude, longitude: coordinate.longitude, fromId: (FIRAuth.auth()?.currentUser?.uid)!, timestamp: Int(Date().timeIntervalSince1970), sessionName: nameTextField.text!, genre: genreTextField.text!, eventDate: dateInput.text!, instruments: instruments, description: descTextField.text!, groupMembers: [(FIRAuth.auth()?.currentUser?.uid)!])
        
        let dummySettingsViewController = ViewController()
        //dummySettingsViewController.cjsc = self
        //present(dummySettingsViewController, animated: true, completion: nil)
        self.navigationController?.pushViewController(dummySettingsViewController, animated: true)
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

//
//
//
//
//


@objcMembers
class MapController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            
            //observeMessages()
        }
    }
    
    var cjsc = CreateJamSessionController()
    
    var newInfo = [String : Any]()
    var annot = CustomPointAnnotation()
    let locationManager = CLLocationManager()
    let mapView = MKMapView()
    var imagePicker = UIImagePickerController()
    var selectedImage : UIImage!
    var imgLat : CLLocationDegrees? = nil
    var imgLon : CLLocationDegrees? = nil
    
    let holdInput : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = "Press and hold a location on the map."
        lb.textColor = UIColor.black
        lb.numberOfLines = 1
        lb.font = UIFont.systemFont(ofSize: 15)
        return lb
    }()
    
    lazy var sendLocation: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Set Location", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.isHidden = true
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        return button
    }()

    
    func goBack(){
        cjsc.coordinate = annot.coordinate
        cjsc.genreInput.text = "finished"
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.allowsEditing = true
        
        view.backgroundColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        view.addSubview(sendLocation)
        view.addSubview(holdInput)
        setupSubviews()
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(action))
        uilpgr.minimumPressDuration = 0.2
        mapView.addGestureRecognizer(uilpgr)
        mapView.delegate = self

        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation() // start location manager
        }
        

    }

    
    func action(gestureRecognizer: UIGestureRecognizer) {
        if(gestureRecognizer.state == UIGestureRecognizerState.began) //YASSSS
        {
            print("uilpgr")
            //longPressView.removeFromSuperview()
            // LONG PRESS -> NEW EXAMPLE PIN
            var annotationView:MKPinAnnotationView!
            var touchPoint = gestureRecognizer.location(in: self.mapView)
            var newCoordinate: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            
            annot.pinCustomImageName = "pin"
            annot.coordinate = newCoordinate
            annot.customUIImage = UIImage(named: "pin")
            annotationView = MKPinAnnotationView(annotation: annot, reuseIdentifier: "pin")
            self.mapView.addAnnotation(annotationView.annotation!)
            sendLocation.isHidden = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var locValue:CLLocationCoordinate2D = manager.location!.coordinate
        //print("ADDPHOTO !!!! locations = \(locValue.latitude) \(locValue.longitude)")
        imgLat = locValue.latitude
        imgLon = locValue.longitude
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
         let leftMargin:CGFloat = 0
         let topMargin:CGFloat = 0
         let mapWidth:CGFloat = view.frame.size.width
         let mapHeight:CGFloat = view.frame.size.height - 300
         
         mapView.frame = CGRect(x: leftMargin, y: topMargin, width: mapWidth, height: mapHeight)
         
         mapView.mapType = MKMapType.standard
         mapView.isZoomEnabled = true
         mapView.isScrollEnabled = true
         
         // Or, if needed, we can position map in the center of the view
         mapView.center = view.center
        let location = CLLocationCoordinate2D(latitude: 34.0715, longitude: -118.4456)
        let span = MKCoordinateSpanMake(0.0342671007638712695, 0.022689312458441482)
        let region = MKCoordinateRegion (center:  location,span: span)
        
        //let mapCamera = MKMapCamera(lookingAtCenter: location, fromDistance: 1200, pitch: 28, heading: 360)
        mapView.setRegion(region, animated: true)
         view.addSubview(mapView)
        
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func setupSubviews(){
        sendLocation.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sendLocation.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        sendLocation.widthAnchor.constraint(equalToConstant: 300).isActive = true
        sendLocation.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        holdInput.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        holdInput.topAnchor.constraint(equalTo: view.topAnchor, constant: 70).isActive = true
        holdInput.widthAnchor.constraint(equalToConstant: 300).isActive = true
        holdInput.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        imagePicker.dismiss(animated: true, completion: nil)
        self.selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        //photoView.image = selectedImage
        newInfo = info
    }
    
    func getCoordinates(lat:CLLocationDegrees, lon:CLLocationDegrees){
        imgLat = lat
        imgLon = lon
    }
}

@objcMembers
class TimeController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            
            //observeMessages()
        }
    }
    
    var cjsc = CreateJamSessionController()
    
    var newInfo = [String : Any]()
    var annot = CustomPointAnnotation()
    let locationManager = CLLocationManager()
    let mapView = MKMapView()
    var imagePicker = UIImagePickerController()
    var selectedImage : UIImage!
    var imgLat : CLLocationDegrees? = nil
    var imgLon : CLLocationDegrees? = nil
    
    var selectedDate = String()
    var dateData = Date()
    
    let holdInput : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = "Select the date of the session."
        lb.textColor = UIColor.black
        lb.numberOfLines = 1
        lb.font = UIFont.systemFont(ofSize: 15)
        return lb
    }()
    
    lazy var sendLocation: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Set Time", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.isHidden = true
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        return button
    }()
    
    
    func goBack(){
        cjsc.date = dateData
        cjsc.dateInput.text = selectedDate
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        view.addSubview(sendLocation)
        view.addSubview(holdInput)
        
        setupSubviews()
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        // Create a DatePicker
        let datePicker: UIDatePicker = UIDatePicker()
        
        // Posiiton date picket within a view
        datePicker.frame = CGRect(x: 10, y: 300, width: self.view.frame.width, height: 200)
        
        // Set some of UIDatePicker properties
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.white
        
        // Add an event to call onDidChangeDate function when value is changed.
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        // Add DataPicker to the view
        self.view.addSubview(datePicker)
        
    }
    
    func datePickerValueChanged(_ sender: UIDatePicker){
        
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"

        // Apply date format
        selectedDate = dateFormatter.string(from: sender.date)
        dateData = sender.date
        print("Selected value \(selectedDate)")
        sendLocation.isHidden = false
    }
    
    
    func action(gestureRecognizer: UIGestureRecognizer) {
        if(gestureRecognizer.state == UIGestureRecognizerState.began) //YASSSS
        {
            print("uilpgr")
            //longPressView.removeFromSuperview()
            // LONG PRESS -> NEW EXAMPLE PIN
            var annotationView:MKPinAnnotationView!
            var touchPoint = gestureRecognizer.location(in: self.mapView)
            var newCoordinate: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            
            annot.pinCustomImageName = "pin"
            annot.coordinate = newCoordinate
            annot.customUIImage = UIImage(named: "pin")
            annotationView = MKPinAnnotationView(annotation: annot, reuseIdentifier: "pin")
            self.mapView.addAnnotation(annotationView.annotation!)
            sendLocation.isHidden = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var locValue:CLLocationCoordinate2D = manager.location!.coordinate
        //print("ADDPHOTO !!!! locations = \(locValue.latitude) \(locValue.longitude)")
        imgLat = locValue.latitude
        imgLon = locValue.longitude
    }
    

    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func setupSubviews(){
        sendLocation.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sendLocation.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        sendLocation.widthAnchor.constraint(equalToConstant: 300).isActive = true
        sendLocation.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        holdInput.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        holdInput.topAnchor.constraint(equalTo: view.topAnchor, constant: 70).isActive = true
        holdInput.widthAnchor.constraint(equalToConstant: 300).isActive = true
        holdInput.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        imagePicker.dismiss(animated: true, completion: nil)
        self.selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        //photoView.image = selectedImage
        newInfo = info
    }
    
    func getCoordinates(lat:CLLocationDegrees, lon:CLLocationDegrees){
        imgLat = lat
        imgLon = lon
    }
}

class InstrController: UIViewController, UITextFieldDelegate, UITextViewDelegate{
    
    // receieve references for these values
    var questionNum = 1
    var cjsc = CreateJamSessionController()
    
    let alert: UIAlertController = {
        let at = UIAlertController(title: "Unable to continue", message: "Please fill in all questions.", preferredStyle: .alert)
        at.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        return at
    }()
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0);
        textField.placeholder = "Instrument \(questionNum)..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    lazy var inputTextField2: UITextField = {
        let textField = UITextField()
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0);
        textField.placeholder = "Instrument \(questionNum)..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    lazy var inputTextField3: UITextField = {
        let textField = UITextField()
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0);
        textField.placeholder = "Instrument \(questionNum)..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    lazy var inputTextField4: UITextField = {
        let textField = UITextField()
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0);
        textField.placeholder = "Instrument \(questionNum)..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    lazy var inputTextField5: UITextField = {
        let textField = UITextField()
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0);
        textField.placeholder = "Instrument \(questionNum)..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    lazy var entranceButton: UIButton = {
        let button = UIButton(type: .system)
        //button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Add Instrument", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(addQuestion), for: .touchUpInside)
        return button
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Confirm", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
        
        return button
    }()
    
    /////////////////
    @objc func handleConfirm(){
        //controller.entranceInput.text = "Application"
        var instruments = [String]()
        for i in 1...questionNum{
            if(i == 1) {
                instruments.append(inputTextField.text!)
                if(inputTextField.text?.isEmpty)!{
                    self.present(alert, animated: true)
                    return
                }
            }
            if(i == 2) { instruments.append(inputTextField2.text!)
                if(inputTextField2.text?.isEmpty)!{
                    self.present(alert, animated: true)
                    return
                }
            }
            if(i == 3) { instruments.append(inputTextField3.text!)
                if(inputTextField3.text?.isEmpty)!{
                    self.present(alert, animated: true)
                    return
                }
            }
            if(i == 4) { instruments.append(inputTextField4.text!)
                if(inputTextField4.text?.isEmpty)!{
                    self.present(alert, animated: true)
                    return
                }
            }
            if(i == 5) { instruments.append(inputTextField5.text!)
                if(inputTextField5.text?.isEmpty)!{
                    self.present(alert, animated: true)
                    return
                }
            }
        }
        
        if(inputTextField.text?.isEmpty)!{
            self.present(alert, animated: true)
            return
        }
        
        cjsc.instruments = instruments
        cjsc.instrInput.text = String(instruments.count)
        print(instruments)
        //self.popBack(3)
        dismiss(animated: true, completion: nil)
    }
    
    func popBack(_ nb: Int) {
        if let viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            guard viewControllers.count < nb else {
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - nb], animated: true)
                return
            }
        }
    }
    
    
    @objc func addQuestion() {
        questionNum = questionNum + 1
        
        if(questionNum == 2)
        {
            view.addSubview(inputTextField2)
            inputTextField2.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            inputTextField2.topAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: 15).isActive = true
            inputTextField2.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
            inputTextField2.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            //entranceButton.topAnchor.constraint(equalTo: inputTextField2.bottomAnchor, constant: 20).isActive = true
        }
        if(questionNum == 3)
        {
            view.addSubview(inputTextField3)
            inputTextField3.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            inputTextField3.topAnchor.constraint(equalTo: inputTextField2.bottomAnchor, constant: 15).isActive = true
            inputTextField3.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
            inputTextField3.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            //entranceButton.topAnchor.constraint(equalTo: inputTextField3.bottomAnchor, constant: 20).isActive = true
        }
        if(questionNum == 4)
        {
            view.addSubview(inputTextField4)
            inputTextField4.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            inputTextField4.topAnchor.constraint(equalTo: inputTextField3.bottomAnchor, constant: 15).isActive = true
            inputTextField4.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
            inputTextField4.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            //entranceButton.topAnchor.constraint(equalTo: inputTextField4.bottomAnchor, constant: 20).isActive = true
        }
        if(questionNum == 5)
        {
            view.addSubview(inputTextField5)
            inputTextField5.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            inputTextField5.topAnchor.constraint(equalTo: inputTextField4.bottomAnchor, constant: 15).isActive = true
            inputTextField5.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
            inputTextField5.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            entranceButton.removeFromSuperview()
        }
        
    }


    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Dismisses Keyboard when screen tapped
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputTextField)
        view.addSubview(entranceButton)
        view.addSubview(confirmButton)
        
        inputTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        inputTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        entranceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        entranceButton.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -20).isActive = true
        entranceButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        entranceButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        confirmButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        confirmButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}


