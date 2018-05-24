//
//  ViewControllerExt.swift
//  Timelapse
//
//  Created by Daniel Kim on 9/28/17.
//  Copyright © 2017 dk. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation

extension ViewController { //functions related to the mapView
    
    /*
     regionWillChangeAnimated
     regionDidChangeAnimated
     didSelect
     didDeselect
     action(gestureRecognizer
     viewFor annotation
     didUpdateLocations
     zoomToFitMapAnnotations
     */
    
    func changeSpanAdd(){
        var _region = mapView.region;
        var _span = mapView.region.span;
        if(mapView.region.span.latitudeDelta*7 > 130){
            _span.latitudeDelta = 100
            _span.longitudeDelta = 100
            _region.span = _span;
            mapView.setRegion(_region, animated: true)
            return
        }
        
        if(mapView.camera.pitch < 0.5)
        {
            _span.latitudeDelta *= 7
            _span.longitudeDelta *= 7
        }
        _region.span = _span;
        mapView.setRegion(_region, animated: true)
        
        _span.latitudeDelta = 0.0062671007638712695
        _span.longitudeDelta = 0.003893124518441482
        
    }
    func changeSpanSub(){
        var _region = mapView.region;
        var _span = mapView.region.span;
        _span.latitudeDelta /= 7
        _span.longitudeDelta /= 7
        _region.span = _span;
        mapView.setRegion(_region, animated: true)
        if(_span.latitudeDelta < 0.01){
            let userCoordinate = CLLocationCoordinate2D(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
            //let eyeCoordinate = CLLocationCoordinate2D(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
            let mapCamera = MKMapCamera(lookingAtCenter: userCoordinate, fromDistance: 1000, pitch: 60, heading: 0)
            mapView.setCamera(mapCamera, animated: true)
        }
    }
    
    
    //mapView
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        longPressView.removeFromSuperview()
        multiPin1.removeFromSuperview()
        multiPin2.removeFromSuperview()
        multiPin3.removeFromSuperview()
        multiPin4.removeFromSuperview()
        multiPin5.removeFromSuperview()
        multiPin6.removeFromSuperview()
        //longPressView.isHidden = true
        //print("2")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        isColliding(curSpan: mapView.region.span.latitudeDelta)
        print(groups)
        //let userCoordinate = CLLocationCoordinate2D(latitude: 58.592725, longitude: 16.185962)
        //let eyeCoordinate = CLLocationCoordinate2D(latitude: 58.571647, longitude: 16.234660)
        //let mapCamera = MKMapCamera(lookingAtCenter: userCoordinate, fromEyeCoordinate: eyeCoordinate, eyeAltitude: 400.0)
        //MKMapCamera(lookingAtCenter: <#T##CLLocationCoordinate2D#>, fromDistance: <#T##CLLocationDistance#>, pitch: <#T##CGFloat#>, heading: <#T##CLLocationDirection#>)
        let mapCamera = mapView.camera
        print("latitude:", mapView.centerCoordinate.latitude, "longitude:", mapView.centerCoordinate.longitude)
        print("span:", mapView.region.span)
        print("")
        print("altitude:",mapCamera.altitude, "pitch:",mapCamera.pitch, "heading:", mapCamera.heading)
        //mapView.setCamera(mapCamera, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotationView: MKAnnotationView) {
        print("clicked annot")
        if annotationView.annotation is MKUserLocation{
            mapView.deselectAnnotation(annotationView.annotation, animated: false)
            return
        }
        var check = true
        mapView.deselectAnnotation(annotationView.annotation, animated: false)
        if(groups.count > 0){
            for i in 0...groups.count-1{
                for j in 0...groups[i].count-1{
                    if((annotationView.annotation?.title)! == String(pins[i][j])){
                        // access elements of groups[i], and position to create
                        print(pins[i])
                        print(annotationView.annotation?.title as Any)
                        
                        
                        if(groups[i].count > 6){
                            var _region = mapView.region;
                            _region.center.longitude = (annotationView.annotation?.coordinate.longitude)!
                            _region.center.latitude = (annotationView.annotation?.coordinate.latitude)!
                            var _span = mapView.region.span;
                            _span.latitudeDelta /= 100
                            _span.longitudeDelta /= 100
                            _region.span = _span;
                            mapView.setRegion(_region, animated: true)
                            return
                        }
                        view.addSubview(longPressView)
                        if(groups[i].count == 2){
                            enableImageUrls(groups: pins[i], annotationView: annotationView)
                            //////
                            longPressView.setImage(UIImage(named: "2"), for: .normal)
                            longPressView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x - 35).isActive = true
                        }
                        if(groups[i].count == 3){
                            enableImageUrls(groups: pins[i], annotationView: annotationView)
                            longPressView.setImage(UIImage(named: "3"), for: .normal)
                            longPressView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x - 60).isActive = true
                        }
                        if(groups[i].count == 4){
                            enableImageUrls(groups: pins[i], annotationView: annotationView)
                            longPressView.setImage(UIImage(named: "4"), for: .normal)
                            longPressView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x - 80).isActive = true
                        }
                        if(groups[i].count == 5){
                            enableImageUrls(groups: pins[i], annotationView: annotationView)
                            longPressView.setImage(UIImage(named: "5"), for: .normal)
                            longPressView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x - 100).isActive = true
                        }
                        if(groups[i].count == 6){
                            enableImageUrls(groups: pins[i], annotationView: annotationView)
                            longPressView.setImage(UIImage(named: "6"), for: .normal)
                            longPressView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x - 130).isActive = true
                        }
                        longPressView.topAnchor.constraint(equalTo: view.topAnchor, constant: annotationView.frame.origin.y - 25).isActive = true
                        longPressView.layer.zPosition = 4
                        longPressView.animation = "fadeIn"
                        longPressView.duration = 0.5
                        longPressView.curve = "easeIn"
                        longPressView.damping = 1
                        longPressView.animate()
                        check = false
                    }
                }
            }
        }
        if(check){
            /*
            print(annotationView.annotation?.title as Any)
            let photoviewController = PhotoViewController()
            photoviewController.photoId = ((annotationView.annotation?.title)!)!
            photoviewController.profilePic = images[((annotationView.annotation?.title)!)!]!
            present(photoviewController, animated: true, completion: nil)*/
            
            let controller = JoinSessionController()
            present(controller, animated: true, completion: nil)
        }
        
    }
    
    func enableImageUrls(groups: [String], annotationView: MKAnnotationView){
        bubblePos = groups
        for i in 0...groups.count-1{
            if(i == 0){
                view.addSubview(multiPin1)
                
                let image: UIImage = images[groups[i]]!
                let watermarkImage = UIImage.roundedRectImageFromImage(image: image, imageSize: CGSize(width: 40, height: 40), cornerRadius: CGFloat(20))
                multiPin1.setImage(watermarkImage, for: .normal)
                multiPin1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x - 19).isActive = true
                multiPin1.topAnchor.constraint(equalTo: view.topAnchor, constant: annotationView.frame.origin.y - 12).isActive = true
                multiPin1.layer.zPosition = 5
            }
            
            if(i == 1){
                view.addSubview(multiPin2)
                let image: UIImage = images[groups[i]]!
                let watermarkImage = UIImage.roundedRectImageFromImage(image: image, imageSize: CGSize(width: 40, height: 40), cornerRadius: CGFloat(20))
                multiPin2.setImage(watermarkImage, for: .normal)
                multiPin2.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x + 33).isActive = true
                multiPin2.topAnchor.constraint(equalTo: view.topAnchor, constant: annotationView.frame.origin.y - 12).isActive = true
                multiPin2.layer.zPosition = 5
            }
            
            if(i == 2){
                view.addSubview(multiPin3)
                let image: UIImage = images[groups[i]]!
                let watermarkImage = UIImage.roundedRectImageFromImage(image: image, imageSize: CGSize(width: 40, height: 40), cornerRadius: CGFloat(20))
                multiPin3.setImage(watermarkImage, for: .normal)

                multiPin1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x - 47).isActive = true
                multiPin2.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x + 5).isActive = true
                multiPin3.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x + 55).isActive = true
                
                
                multiPin3.topAnchor.constraint(equalTo: view.topAnchor, constant: annotationView.frame.origin.y - 12).isActive = true
                multiPin3.layer.zPosition = 5
            }
            
            if(i == 3){
                view.addSubview(multiPin4)
                let image: UIImage = images[groups[i]]!
                let watermarkImage = UIImage.roundedRectImageFromImage(image: image, imageSize: CGSize(width: 40, height: 40), cornerRadius: CGFloat(20))
                multiPin4.setImage(watermarkImage, for: .normal)
                
                multiPin1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x - 65).isActive = true
                multiPin2.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x - 15).isActive = true
                multiPin3.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x + 32).isActive = true
                multiPin4.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x + 82).isActive = true
                
                multiPin4.topAnchor.constraint(equalTo: view.topAnchor, constant: annotationView.frame.origin.y - 12).isActive = true
                multiPin4.layer.zPosition = 5
            }
            
            if(i == 4){
                view.addSubview(multiPin5)
                let image: UIImage = images[groups[i]]!
                let watermarkImage = UIImage.roundedRectImageFromImage(image: image, imageSize: CGSize(width: 40, height: 40), cornerRadius: CGFloat(20))
                multiPin5.setImage(watermarkImage, for: .normal)
                
                multiPin1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x - 90).isActive = true
                multiPin2.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x - 40).isActive = true
                multiPin3.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x + 13).isActive = true
                multiPin4.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x + 65).isActive = true
                multiPin5.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x + 114).isActive = true
                
                multiPin5.topAnchor.constraint(equalTo: view.topAnchor, constant: annotationView.frame.origin.y - 12).isActive = true
                multiPin5.layer.zPosition = 5
            }
            if(i == 5){
                view.addSubview(multiPin6)
                let image: UIImage = images[groups[i]]!
                let watermarkImage = UIImage.roundedRectImageFromImage(image: image, imageSize: CGSize(width: 40, height: 40), cornerRadius: CGFloat(20))
                multiPin6.setImage(watermarkImage, for: .normal)
                
                multiPin1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x - 120).isActive = true
                multiPin2.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x - 70).isActive = true
                multiPin3.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x - 20).isActive = true
                multiPin4.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x + 28).isActive = true
                multiPin5.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x + 78).isActive = true
                multiPin6.leftAnchor.constraint(equalTo: view.leftAnchor, constant: annotationView.frame.origin.x + 128).isActive = true
                
                multiPin6.topAnchor.constraint(equalTo: view.topAnchor, constant: annotationView.frame.origin.y - 12).isActive = true
                multiPin6.layer.zPosition = 5
            }
            
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect annotationView: MKAnnotationView) {
        //print("deselected annot")
        //mapView.removeGestureRecognizer(uilpgr)
        //longPressView.isHidden = true
        longPressView.removeFromSuperview()
        //mapView.isScrollEnabled = true
    }
    
    func action(gestureRecognizer: UIGestureRecognizer) {
        //print("?")
        if(gestureRecognizer.state == UIGestureRecognizerState.began) //YASSSS
        {
            print("uilpgr")
            longPressView.removeFromSuperview()
            // LONG PRESS -> NEW EXAMPLE PIN
            var annotationView:MKPinAnnotationView!
             var touchPoint = gestureRecognizer.location(in: self.mapView)
             var newCoordinate: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
             
             var pointAnnoation:CustomPointAnnotation!
             pointAnnoation = CustomPointAnnotation()
             pointAnnoation.pinCustomImageName = "pin"
             pointAnnoation.coordinate = newCoordinate
             pointAnnoation.customUIImage = UIImage(named: "pin")
             annotationView = MKPinAnnotationView(annotation: pointAnnoation, reuseIdentifier: "pin")
             self.mapView.addAnnotation(annotationView.annotation!)
             //zoomToFitMapAnnotations(aMapView: mapView)
            
            
            
        }
    }
    
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        
        let reuseIdentifier = "pin"
        
        var v = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        if v == nil {
            v = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            v!.canShowCallout = false // title subtitle show
        }
        else {
            v!.annotation = annotation
        }
        if annotation is MKUserLocation{
            return nil
        }

        let customPointAnnotation = annotation as! CustomPointAnnotation
        v!.image = customPointAnnotation.customUIImage
        
        //print("VIMAGE: \(v!.image)")
        

        return v
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //if(locationRepeat){
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        // print("locations = \(locValue.latitude) \(locValue.longitude)")
        locationRepeat = false
        myLatitude = locValue.latitude
        myLongitude = locValue.longitude
        xaddphotoController.getCoordinates(lat: locValue.latitude, lon: locValue.longitude)
        xaddphotoController.imgLat = myLatitude
        xaddphotoController.imgLon = myLongitude
        
        //let location = locations[0]
        
        //let _:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        //let _:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        //let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        //mapView.setRegion(region, animated: true)
        
        //print(location.altitude)
        //print(location.speed)
        
        //self.mapView.showsUserLocation = true
    }
    
    func zoomToFitMapAnnotations(aMapView: MKMapView) {
        if aMapView.annotations.count == 0 {
            return
        }
        var topLeftCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        topLeftCoord.latitude = -90
        topLeftCoord.longitude = 180
        var bottomRightCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        bottomRightCoord.latitude = 90
        bottomRightCoord.longitude = -180
        for annotation: MKAnnotation in mapView.annotations {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
        }
        
        var region: MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        
        let span1 = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 3
        let span2 = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 3
        print("\(span1) and \(span2)")
        if(span1 <= 180 && span2 <= 180)
        {
            region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 3
            region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 3
        }
        else{
            region.span.latitudeDelta = 180
            region.span.longitudeDelta = 180
        }
        region = aMapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }
    
}

