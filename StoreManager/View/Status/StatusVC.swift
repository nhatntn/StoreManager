//
//  StatusVC.swift
//  StoreManager
//
//  Created by nhatnt on 5/10/20.
//  Copyright © 2020 nhatnt. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import FirebaseFirestoreSwift

class StatusVC: UIViewController {
    private let db = Firestore.firestore()

    let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = UIColor.white
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    var items: [Item] = []
    private var user: User?
    private var outOfStock: Int?
    private var nearOutOfStock: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        DispatchQueue.main.async {
            self.loadData()
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ItemStatusViewCell.self, forCellReuseIdentifier: "cellId")
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
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        self.db.collection("users").document(uid).addSnapshotListener { (document, err) in
            if let document = document, document.exists {
                let user = try! DictionaryDecoder().decode(User.self, from: document.data() ?? [:])
                self.user = user
                self.outOfStock = user.outOfStock
                self.nearOutOfStock = user.nearOutOfStock
                
                self.db.collection("items").addSnapshotListener { (querySnapshot, err) in
                    if let err = err {
                        self.showAlert(alertText: "Get Items", alertMessage: "Something went wrong\nPlease try later" + err.localizedDescription)
                        return
                    }
                    
                    guard let snapshot = querySnapshot else {
                        return
                    }
                    
                    self.items.removeAll()
                    for document in snapshot.documents {
                        let item = try! DictionaryDecoder().decode(Item.self, from: document.data())
                        if let nearOutOfStock = user.nearOutOfStock, item.count ?? 0 > nearOutOfStock {
                            continue
                        }
                        self.items.append(item)
                    }
                    self.tableView.reloadData()
                }
                
            } else {
                self.showAlert(alertText: "Get Settings", alertMessage: "Something went wrong\nPlease try later" + (err?.localizedDescription ?? ""))
            }
        }
    }
    
}

extension StatusVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as? ItemStatusViewCell,
            items.count != 0 else {
                return UITableViewCell()
        }
        
        let item: Item
        item = items[indexPath.row]
        cell.backgroundColor = UIColor.white
        if let count = item.count, let outOfStock = self.outOfStock, let nearOutOfStock = self.nearOutOfStock {
            let nearOutOfStockColor = UIColor(r: 252, g: 191, b: 30)
            let outOfStockColor = UIColor(r: 228, g: 63, b: 90)
            
            if count <= outOfStock {
                cell.cellView.backgroundColor = outOfStockColor
            } else if count <= nearOutOfStock {
                cell.cellView.backgroundColor = nearOutOfStockColor
            }
        }
        cell.nameLabel.text = item.name
        cell.countLabel.text = "\(item.count ?? 0) items"
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
        item = items[indexPath.row]
        detailVC.item = item
        detailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}
