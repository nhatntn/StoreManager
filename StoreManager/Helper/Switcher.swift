//
//  Switcher.swift
//  StoreManager
//
//  Created by nhatnt on 5/11/20.
//  Copyright © 2020 nhatnt. All rights reserved.
//

import Foundation
import UIKit

class Switcher {
    
    static func updateRootVC(){
        
        let status = UserDefaults.standard.bool(forKey: "LoginStatus")
        var rootVC : UIViewController?
        
        if(status == true){
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewControllerID") as! MainViewController
        }else{
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVCID") as! LoginVC
        }
        
        if let rootVC1 = rootVC, let topWindow = UIApplication.shared.windows.first,
            let rootVC2 = topWindow.rootViewController, type(of: rootVC1) == type(of: rootVC2) {
            return
        }
        UIApplication.shared.windows.first?.rootViewController = rootVC
        UIApplication.shared.windows.first?.makeKeyAndVisible()
        
    }
    
}
