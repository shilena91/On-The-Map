//
//  LocationTableViewController.swift
//  On The Map
//
//  Created by Hoang on 9.4.2020.
//  Copyright © 2020 Hoang. All rights reserved.
//

import UIKit

class LocationTableViewController: UIViewController {
    
    var studentResults = [Results]()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pinButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        LocationClient.getStudentLocations { (results, error) in
            self.studentResults = results
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        tableView.reloadData()
    }
    
    @IBAction func reloadPressed(_ sender: UIBarButtonItem) {
        setNetwork(true)
        LocationClient.getStudentLocations { (results, error) in
            self.setNetwork(false)
            if error != nil {
                self.createAlert(title: "Error", message: error!.localizedDescription)
            }
            else {
                self.studentResults = results
                self.tableView.reloadData()
            }
        }
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

//MARK: - TableView delegate functions

extension LocationTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "student")!
        
        let student = studentResults[indexPath.row]
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.detailTextLabel?.text = student.mediaURL
        cell.imageView?.image = UIImage(named: "icon_pin")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        let cell = tableView.cellForRow(at: indexPath)
        
        if let toOpen = cell?.detailTextLabel?.text {
            app.open(URL(string: toOpen) ?? URL(string: "https://udacity.com")!, options: [:], completionHandler: nil)
        }

    }
    
}
