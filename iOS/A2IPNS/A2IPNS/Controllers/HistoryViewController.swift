//
//  HistoryViewController.swift
//  A2IPNS
//
//  Created by billgateshxk on 2019/08/04.
//  Copyright © 2019 bi119aTe5hXk. All rights reserved.
//

import UIKit

class HistoryViewController: UITableViewController,UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var notifyarr = UserDefaults.standard.array(forKey: "notification_history")
    var filteredList: [Any]!
    
    let notFirstTimeBoot = UserDefaults.standard.bool(forKey: "not_first_time")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.
        
        self.searchBar.delegate = self
        self.tableView.delegate = self
        
        let refreshControl = UIRefreshControl.init()
        refreshControl.addTarget(self, action: #selector(self.onRefresh), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
        
        if !notFirstTimeBoot {
            //boot at first time
            let initView = self.storyboard?.instantiateViewController(withIdentifier: "InitSettingsNavViewController")
            self.present(initView!, animated: true, completion: nil)
            
        }else{
            self.resetToNormalList()
            NotificationCenter.default.addObserver(self, selector: #selector(resetToNormalList), name: NSNotification.Name(rawValue: "update_history_list"), object: nil)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.resetToNormalList()
    }
    @objc func onRefresh() {
        self.refreshControl?.endRefreshing()
        if (self.searchBar.text?.lengthOfBytes(using: .utf8))! > 0{
            //refresh for keyword search
        }else{
            //refresh for normal list
            self.resetToNormalList()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.lengthOfBytes(using: .utf8) > 0 {
            self.searchFor(keyword: searchText)
        }else{
            self.resetToNormalList()
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchFor(keyword: searchBar.text!)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchFor(keyword:String) {
        //print(keyword)
        if notifyarr!.count > 0 {
            filteredList = notifyarr?.filter({ (item) -> Bool in
                //print(item as! [Dictionary<String,Any>])
                
                let dicarr = item as! [Dictionary<String,Any>]
                let dic = dicarr[0]
                
                let titlestr = dic["title"] as! String
                let subtitlestr = dic["subtitle"] as! String
                let bodystr = dic["body"] as! String
                return titlestr.range(of: keyword, options: .caseInsensitive, range: nil, locale: nil) != nil || subtitlestr.range(of: keyword, options: .caseInsensitive, range: nil, locale: nil) != nil || bodystr.range(of: keyword, options: .caseInsensitive, range: nil, locale: nil) != nil
                //return false
            })
            self.tableView.reloadData()
        }
    }
    
    @objc func resetToNormalList() {
        self.refreshControl?.endRefreshing()
        notifyarr = UserDefaults.standard.array(forKey: "notification_history")
        notifyarr?.reverse()
        filteredList = notifyarr
        //print(notifyarr)
        self.tableView.reloadData()
    }
    
    @IBAction func clearList(_ sender: Any) {
        notifyarr = []
        UserDefaults.standard.set([], forKey: "notification_history")
        self.resetToNormalList()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredList!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        let row = indexPath.row
        let theArr = filteredList![row] as! Array<Any>
        let dicInRow:Dictionary = theArr[0] as! Dictionary<String, Any>
        cell.textLabel?.text = dicInRow["body"] as? String
        //cell.textLabel?.numberOfLines = 0
        cell.textLabel?.numberOfLines = cell.textLabel?.numberOfLines == 0 ? 1 : 0
        
        let subtitletext = (dicInRow["time"] as! String) + "\n" + (dicInRow["subtitle"] as! String) + " - " + (dicInRow["title"] as! String)
        cell.detailTextLabel?.text = subtitletext
        cell.detailTextLabel?.numberOfLines = 3
        

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) {
            let label = cell.textLabel
            tableView.beginUpdates()
            label!.numberOfLines = label!.numberOfLines == 0 ? 1 : 0
            tableView.endUpdates()
        }
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
