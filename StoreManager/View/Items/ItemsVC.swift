//
//  ItemsVC.swift
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

class ItemsVC: UIViewController {
    let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = UIColor.white
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let db = Firestore.firestore()
    var items: [Item] = []
    let searchController = UISearchController(searchResultsController: nil)
    var filteredItems: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.title = "Items"
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Items"
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
        tableView.register(ItemViewCell.self, forCellReuseIdentifier: "cellId")
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
    
    private func loadData() {
        self.db.collection("items").addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                self.showAlert(alertText: "Get Items", alertMessage: "Something went wrong\nPlease try later" + err.localizedDescription)
                return
            }

            self.items.removeAll()
            for document in querySnapshot!.documents {
                let item = try! DictionaryDecoder().decode(Item.self, from: document.data())
                self.items.append(item)
            }
            self.tableView.reloadData()
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
        filteredItems = items.filter { (item: Item) -> Bool in
            if !isSearchBarEmpty {
                return item.name.lowercased().contains(searchText.lowercased())
            }
            return true
        }
        
        tableView.reloadData()
    }

}

extension ItemsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredItems.count
        }
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as? ItemViewCell,
            items.count != 0 else {
                return UITableViewCell()
        }
        
        let item: Item
        if isFiltering {
            item = filteredItems[indexPath.row]
        } else {
            item = items[indexPath.row]
        }
        
        cell.backgroundColor = UIColor.white
        cell.nameLabel.text = item.name
        cell.priceLabel.text = "\(item.price) $"
        if let urlString = item.imageUrl {
            let image = UIImage(named: "default-product")!
            cell.profileImageView.imageFromServerURL(urlString: urlString, PlaceHolderImage: image)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard items.count != 0 else {
            return
        }
        
        let detailVC = DetailItemVC()
        let item: Item
        if isFiltering {
            item = filteredItems[indexPath.row]
        } else {
            item = items[indexPath.row]
        }
        detailVC.item = item
        detailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}

extension ItemsVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}

extension ItemsVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }
}
