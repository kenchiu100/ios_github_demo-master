//
//  ViewController.swift
//  GithubDemo
//
//  Created by Nhan Nguyen on 5/12/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import UIKit
import MBProgressHUD
import AFNetworking

protocol SettingsPresentingViewControllerDelegate: class {
    func didSaveSettings(settings: GithubRepoSearchSettings)
    func didCancelSettings()
}

// Main ViewController
class RepoResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , SettingsPresentingViewControllerDelegate{

    @IBOutlet weak var tableView: UITableView!
    var searchBar: UISearchBar!
    var searchSettings = GithubRepoSearchSettings()
    
    var repos: [GithubRepo]!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        // Initialize the UISearchBar
        searchBar = UISearchBar()
        searchBar.delegate = self

        // Add SearchBar to the NavigationBar
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar

        // Perform the first search when the view controller first loads
        doSearch()

    }
    
    
    private func doSearch() {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        // Perform request to GitHub API to get the list of repositories
        GithubRepo.fetchRepos(searchSettings, successCallback: { (newRepos) -> Void in
            
            // Print the returned repositories to the output window
            for repo in newRepos {
                print(repo)
                self.repos = newRepos
                self.tableView.reloadData()
            }
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            }, error: { (error) -> Void in
                print(error)
        })
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("RepoCell", forIndexPath: indexPath) as! RepoCell
        let subRepo = repos![indexPath.row]
        
        cell.repoNameLabel.text = subRepo.name
        cell.userNameLabel.text = subRepo.ownerHandle
        
        //convert int to string
        let forkCount = subRepo.forks
        cell.forkLabel.text = String(format: "%d", forkCount!)
        
        let starsCount = subRepo.stars
        cell.starLabel.text = String(format: "%d", starsCount!)
        
        let avatarURL = NSURL(string: subRepo.ownerAvatarURL!)
        cell.userImage.setImageWithURL(avatarURL!)
        
        cell.descriptionLabel.text = subRepo.repoDescription
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let subRepo = repos {
            return subRepo.count
        }else{
            return 0
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navController = segue.destinationViewController as! UINavigationController
        let vc = navController.topViewController as! SearchSettingsViewController
        vc.settings = searchSettings// ... Search Settings ...
        vc.delegate = self
    }
}



// SearchBar methods
    extension RepoResultsViewController: UISearchBarDelegate {
        
        func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
            searchBar.setShowsCancelButton(true, animated: true)
            return true;
        }
        
        func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
            searchBar.setShowsCancelButton(false, animated: true)
            return true;
        }
        
        func searchBarCancelButtonClicked(searchBar: UISearchBar) {
            searchBar.text = ""
            searchBar.resignFirstResponder()
        }
        
        func searchBarSearchButtonClicked(searchBar: UISearchBar) {
            searchSettings.searchString = searchBar.text
            searchBar.resignFirstResponder()
            doSearch()
        }}


//override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    let navController = segue.destinationViewController as! UINavigationController
//    let vc = navController.topViewController as! SearchSettingsViewController
//    vc.settings = searchSettings// ... Search Settings ...
//    vc.delegate = self
//}

