//
//  FinishAddLocationViewController.swift
//  On The Map
//
//  Created by Hoang on 9.4.2020.
//  Copyright © 2020 Hoang. All rights reserved.
//

import UIKit
import MapKit

class FinishAddLocationViewController: UIViewController {

    @IBOutlet weak var finishMapView: MKMapView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var annotation = MKPointAnnotation()
    lazy var geocoder = CLGeocoder()
    
    var userCoordinates: CLLocationCoordinate2D?
    var mediaURL: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        finishMapView.delegate = self
        
        if let location = userCoordinates {
            annotation.coordinate = location
            let convertLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            geocoder.reverseGeocodeLocation(convertLocation, completionHandler: processResponse(withPlacemarks:error:))
            
            let region = MKCoordinateRegion(center: location, latitudinalMeters: CLLocationDistance(exactly: 5000)!, longitudinalMeters: CLLocationDistance(exactly: 5000)!)
            finishMapView.setRegion(finishMapView.regionThatFits(region), animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        finishButton.isHidden = false
        tabBarController?.tabBar.isHidden = true
    }
        
    @IBAction func finishButtonPressed(_ sender: UIButton) {
        
        setNetwork(true)
        if LocationClient.objectId == nil {
            LocationClient.postingStudentLocation(firstName: UdacityClient.firstName, lastName: UdacityClient.lastName, mediaURL: mediaURL ?? "", coordinates: userCoordinates!, completionHandler: handleStudentLocationResponse(response:error:))
        }
        else {
            LocationClient.puttingStudentLocation(firstName: UdacityClient.firstName, lastName: UdacityClient.lastName, mediaURL: mediaURL ?? "", coordinates: userCoordinates!, completionHandler: handleStudentLocationResponse(response:error:))
        }
            
    }
    
    //MARK: - Helping Functions
    
    func handleStudentLocationResponse(response: Bool, error: Error?) {
        setNetwork(false)
        if error != nil {
            createAlert(title: "Failed!", message: error!.localizedDescription)
            return
        }
        if LocationClient.objectId == nil {
            createAlert(title: "Success", message: "Your location and link are added", success: true)
        }
        else {
            createAlert(title: "Success", message: "Your location and link are updated", success: true)
        }
    }
    
    func createAlert(title: String, message: String, success: Bool? = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
        if success == true {
            finishButton.isHidden = true
        }
    }
    
    // Process Response for CLGeocoder
    
    func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if error != nil {
            print(error!)
            return
        }
        if let placemarks = placemarks {
            let placemark = placemarks.first
            annotation.title = (placemark?.locality)! + ", " + (placemark?.country)!
            finishMapView.addAnnotation(annotation)
        }
    }

    func setNetwork(_ network: Bool) {
        if network {
            activityIndicator.startAnimating()
        }
        else {
            activityIndicator.stopAnimating()
        }
        finishButton.isEnabled = !network
        navigationItem.backBarButtonItem?.isEnabled = !network
    }
}
    
    

//MARK: - MKMapView delegate functions

extension FinishAddLocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
}
