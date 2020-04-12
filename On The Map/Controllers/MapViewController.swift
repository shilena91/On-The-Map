//
//  MapViewController.swift
//  On The Map
//
//  Created by Hoang on 9.4.2020.
//  Copyright © 2020 Hoang. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var pinButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        LocationClient.getStudentLocations(completionHandler: handleStudentLocationResponse(results:error:))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func reloadPressed(_ sender: UIBarButtonItem) {
        setNetwork(true)
        LocationClient.getStudentLocations(completionHandler: handleStudentLocationResponse(results:error:))
    }
    
    @IBAction func pinPressed(_ sender: UIBarButtonItem) {
        
        handlePinPressed(objectId: LocationClient.objectId)
    }
        
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        
        createAlert(title: "Are you sure?", message: "you want to log out?", deletingSession: true)
    }
    
    
//MARK: - Helping Functions
    
    func handlePinPressed(objectId: String?) {
        
       if objectId == nil {
            performSegue(withIdentifier: "goToAddLocation", sender: self)

        }
        else {
            createAlert(title: "You already pinned your location", message: "Do you want to update it?", performSegue: true)
        }
    }
    
    func handleLogOutPressed() {
        let alert = UIAlertController(title: "Are you sure?", message: "you want to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            [weak self] (action) in
            UdacityClient.deletingSession()
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true)
    }
    
    // Create alert
    func createAlert(title: String, message: String, deletingSession: Bool? = false, performSegue: Bool? = false) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (action) in
            if performSegue == true {
                self?.performSegue(withIdentifier: "goToAddLocation", sender: self)
            }
            else if deletingSession == true {
                UdacityClient.deletingSession()
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        }))
        if deletingSession == true || performSegue == true {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }
        present(alert, animated: true)
    }
    
    func handleStudentLocationResponse(results: [Results], error: Error?) {
        setNetwork(false)
        if error != nil {
            self.createAlert(title: "Error", message: error!.localizedDescription)
        }
        else {
            mapView.removeAnnotations(mapView.annotations)
            for info in results {
                let data = Student(name: "\(info.firstName) \(info.lastName)", coordinate: CLLocationCoordinate2D(latitude: info.latitude, longitude: info.longitude), mediaURL: info.mediaURL)
                self.mapView.addAnnotation(data)
            }
        }
    }
    
    func setNetwork(_ network: Bool) {
        if network {
            activityIndicator.startAnimating()
        }
        else {
            activityIndicator.stopAnimating()
        }
        reloadButton.isEnabled = !network
        pinButtonOutlet.isEnabled = !network
        logoutButton.isEnabled = !network
    }
    
}

//MARK: - MKMapView delegate functions

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is Student else { return nil }
        let identifier = "Student"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
        }
        else {
            annotationView?.annotation = annotation
            
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle {
                app.open(URL(string: toOpen!) ?? URL(string: "https://udacity.com")! , options: [:], completionHandler: nil)
            }
        }
    }
}
