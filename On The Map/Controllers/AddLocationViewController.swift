//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Hoang on 9.4.2020.
//  Copyright © 2020 Hoang. All rights reserved.
//

import UIKit
import CoreLocation

class AddLocationViewController: UIViewController {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var userLinkTextField: UITextField!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    lazy var geocoder = CLGeocoder()
    var userCoordinates = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationTextField.delegate = self
        userLinkTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func findLocationPressed(_ sender: UIButton) {
        setNetwork(true)
        guard let location = locationTextField.text else { return }
        
        geocoder.geocodeAddressString(location, completionHandler: processResponse(withPlacemarks:error:))
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? FinishAddLocationViewController
        
        if segue.identifier == "goToFinishAddLocationView" {
            guard let userLink = userLinkTextField.text else { return }
            vc?.mediaURL = userLink
            vc?.userCoordinates = userCoordinates
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
  
    
    //MARK: - Helping Functions
    
    func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        
        setNetwork(false)
        if error != nil {
            let alert = UIAlertController(title: "Can't get your location", message: "please enter valid location", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        var location: CLLocation?
        
        if let placemarks = placemarks, placemarks.count > 0 {
            location = placemarks.first?.location
        }
        if let location = location {
            userCoordinates = location.coordinate
            performSegue(withIdentifier: "goToFinishAddLocationView", sender: self)
            
        }
    }

    func setNetwork(_ network: Bool) {
        if network {
            activityIndicator.startAnimating()
        }
        else {
            activityIndicator.stopAnimating()
        }
        locationTextField.isEnabled = !network
        userLinkTextField.isEnabled = !network
        findLocationButton.isEnabled = !network
    }
}

//MARK: - TextField delegate functions

extension AddLocationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true

    }
        
    
}
