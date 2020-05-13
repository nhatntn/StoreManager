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
        
        self.items.removeAll()

        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        self.db.collection("users").document(uid).getDocument { (document, err) in
            if let document = document, document.exists {
                let user = try! DictionaryDecoder().decode(User.self, from: document.data() ?? [:])
                self.user = user
                
                self.outOfStock = user.outOfStock
                self.nearOutOfStock = user.nearOutOfStock
                
                self.db.collection("items").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        self.showAlert(alertText: "Get Items", alertMessage: "Something went wrong\nPlease try later" + err.localizedDescription)
                        return
                    }
                    
                    for document in querySnapshot!.documents {
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as? ItemViewCell,
            items.count != 0 else {
                return UITableViewCell()
        }
        
        let item: Item
        item = items[indexPath.row]
        cell.backgroundColor = UIColor.white
        if let count = item.count, let outOfStock = self.outOfStock, let nearOutOfStock = self.nearOutOfStock {
            let defaultColor = UIColor(r: 17, g: 45, b: 78)
            let nearOutOfStockColor = UIColor(r: 252, g: 191, b: 30)
            let outOfStockColor = UIColor(r: 228, g: 63, b: 90)
            
            cell.cellView.backgroundColor = count <= outOfStock ? outOfStockColor : defaultColor
            cell.cellView.backgroundColor = count <= nearOutOfStock ? nearOutOfStockColor : defaultColor
        }
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
        item = items[indexPath.row]
        detailVC.item = item
        detailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}

class ItemStatusViewCell: UITableViewCell {
    let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 17, g: 45, b: 78)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(cellView)
        cellView.addSubview(nameLabel)
        cellView.addSubview(priceLabel)
        cellView.addSubview(profileImageView)
        self.selectionStyle = .none
        
        cellView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.right.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.centerY.equalTo(cellView)
            $0.top.bottom.equalToSuperview().inset(10)
            $0.width.equalTo(cellView.snp.height).offset(-20)
        }
        
        nameLabel.snp.makeConstraints {
            $0.left.equalTo(profileImageView.snp.right).offset(20)
            $0.centerY.equalTo(cellView)
            $0.top.bottom.right.equalToSuperview().inset(10)
        }
        
        priceLabel.snp.makeConstraints {
            $0.right.equalToSuperview().inset(20)
            $0.centerY.equalTo(cellView)
            $0.top.bottom.left.equalToSuperview().inset(10)
        }
    }
}

