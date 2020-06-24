//
//  RootTableViewController.swift
//  YelpDemoExtended
//
//  Created by yeuchi on 6/24/20.
//  Copyright © 2020 yeuchi. All rights reserved.
//

import UIKit

class RootTableViewController: UITableViewController {

    static let ClientId = "Enter your Yelp Client ID here."
    static let ClientSecret = "Enter your Yelp Client Secret here."

    
    var yelpClient: YelpAPIClient!
    
    var businessList = [AnyObject]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YelpAPIClient.connectClient(id: RootTableViewController.ClientId, secret: RootTableViewController.ClientSecret) { (client, error) in
                guard error == nil else {
                    let alert = UIAlertController(title: "Connection Error", message: error?.localizedDescription ?? "Yelp connection error.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                self.yelpClient = client
            client?.locationSearch(term: "pizza", location: "university of toronto", completion: { (data, error) in
                    guard error == nil else {
                        let alert = UIAlertController(title: "Connection Error", message: error?.localizedDescription ?? "Yelp connection error.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    guard let unwrappedData = data as? Dictionary<String, AnyObject> else {
                        let alert = UIAlertController(title: "Connection Error", message: error?.localizedDescription ?? "Yelp data format error", preferredStyle: .alert)
                        alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    guard let businessList = unwrappedData["businesses"] as? Array<AnyObject> else {
                        let alert = UIAlertController(title: "Connection Error", message: error?.localizedDescription ?? "Yelp data format error", preferredStyle: .alert)
                        alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    self.businessList = businessList
                })
                
            }
        }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return businessList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        if let business = businessList[indexPath.row] as? Dictionary<String, AnyObject> {
                   let name = (business["name"] as? String) ?? "*No name.*"
                   let phoneNumber = (business["phone"] as? String) ?? "*No phone #.*"
                   cell.textLabel!.text = "\(name): \(phoneNumber)"
               } else {
                   cell.textLabel!.text = "*No name.*"
               }
               return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
