//
//  VendorsVC.swift
//  StoreManager
//
//  Created by nhatnt on 5/12/20.
//  Copyright © 2020 nhatnt. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestoreSwift
import SnapKit

class VendorsVC: UIViewController {
    let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = UIColor.white
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let db = Firestore.firestore()
    var vendors: [Vendor] = []
    let searchController = UISearchController(searchResultsController: nil)
    var filteredVendors: [Vendor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.title = "Vendors"
            
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Vendors"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        
        DispatchQueue.main.async {
            self.loadData()
        }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(VendorViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.separatorStyle = .none
        tableView.separatorColor = .white
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredVendors = vendors.filter { (vendor: Vendor) -> Bool in
            if !isSearchBarEmpty {
                return vendor.name.lowercased().contains(searchText.lowercased())
            }
            return true
        }
        
        tableView.reloadData()
    }
    
    private func loadData() {
        self.db.collection("vendors").addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                self.showAlert(alertText: "Get Vendors", alertMessage: "Something went wrong\nPlease try later" + err.localizedDescription)
                return
            }

            self.vendors.removeAll()
            for document in querySnapshot!.documents {
                let vendor = try! DictionaryDecoder().decode(Vendor.self, from: document.data())
                self.vendors.append(vendor)
            }
            self.tableView.reloadData()
        }
    }
}

extension VendorsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredVendors.count
        }
        return vendors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as? VendorViewCell,
            vendors.count != 0 else {
                return UITableViewCell()
        }
        
        let vendor: Vendor
        if isFiltering {
            vendor = filteredVendors[indexPath.row]
        } else {
            vendor = vendors[indexPath.row]
        }
        
        cell.backgroundColor = UIColor.white
        cell.nameLabel.text = vendor.name
        if let urlString = vendor.imageUrl {
            let image = UIImage(named: "default-profile")!
            cell.profileImageView.imageFromServerURL(urlString: urlString, PlaceHolderImage: image)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard vendors.count != 0 else {
            return
        }
        
        let detailVC = DetailVendorVC()
        let vendor: Vendor
        if isFiltering {
            vendor = filteredVendors[indexPath.row]
        } else {
            vendor = vendors[indexPath.row]
        }
        detailVC.vendor = vendor
        detailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}

extension VendorsVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}

extension VendorsVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }
}
