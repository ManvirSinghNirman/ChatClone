//
//  ViewController.swift
//  SimpleChat
//
//  Created by Manvir Singh on 03/05/20.
//  Copyright © 2020 Manvir Singh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var tableView :UITableView!
    
    lazy  var searchController:UISearchController =  UISearchController()
    
    var arrayUsers = [User]()


    override func viewDidLoad() {
        super.viewDidLoad()
        setSearch()
        addUsers()
        
    }
    
    

    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode =  .always

        if let indexPath = tableView.indexPathForSelectedRow {
            
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
    }
    
    func addUsers(){
        
        for i in 0...20 {
            
            if let image = UIImage(named: "dummyUser") {
                navigationController?.navigationBar.prefersLargeTitles = true
                arrayUsers.append(User(image: image,
                                       name: "Dummy User \(i + 1)",
                                       lastMessage: ""))
                
            }
            
        }
        
        tableView.reloadData()
        
    }
    
    
    func setSearch(){

            navigationItem.searchController = searchController
            searchController.searchBar.placeholder = "Search"
            searchController.searchBar.delegate = self
            navigationItem.hidesSearchBarWhenScrolling = true
            searchController.hidesNavigationBarDuringPresentation = true
            searchController.isActive = false
            searchController.obscuresBackgroundDuringPresentation = false
            
        }
    
}


//MARK :  SearchBar Delegate Methods

extension ViewController :UISearchBarDelegate {
    
    
    
}


//MARK : Tableview Datasource Methods

extension ViewController :UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? UserCell else{
            return UserCell()
        }
        cell.configCell(data: arrayUsers[indexPath.row])
        return cell
    }
    
    
    
    
}


//MARK : Tableview Delegate Methods
extension ViewController :UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "CollectionViewChatVC") as? CollectionViewChatVC {
            vc.userInfo = arrayUsers[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
        
    }
    
}

class UserCell: UITableViewCell {
    
    @IBOutlet weak var imgViewUser :UIImageView!
    @IBOutlet weak var lblUserName :UILabel!
    @IBOutlet weak var lblLastMessage :UILabel!
    
    
    func configCell(data:User){
        imgViewUser.image = data.image
        lblUserName.text = data.name
        lblLastMessage.text = data.lastMessage

    }
    
    
}
