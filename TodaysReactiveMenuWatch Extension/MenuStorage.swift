//
//  MenuStorageMenuStorage.swift
//  TodaysReactiveMenu
//
//  Created by Steffen Damtoft Sommer on 28/10/15.
//  Copyright © 2015 steffendsommer. All rights reserved.
//

import WatchKit
import ObjectMapper


enum MenuError: ErrorType {
    case MenuNotReady
}

struct MenuStorage {

    private let storeKey = "latest_menu"

    func saveMenu(menu: [String : AnyObject]) {
    
        // Store menu.
        NSUserDefaults.standardUserDefaults().setObject(menu, forKey: storeKey)
    }
    
    func loadMenu() throws -> Menu {
    
        // Let's make sure that we can fetch a menu from the local storage.
        guard let menu = Mapper<Menu>().map(NSUserDefaults.standardUserDefaults().objectForKey(storeKey)) else {
            throw MenuError.MenuNotReady
        }
        
        // Making sure that the fetched menu is actually today's menu.
        guard menu.isTodaysMenu() else {
            throw MenuError.MenuNotReady
        }
    
        // All good.
        return menu
    }

}
