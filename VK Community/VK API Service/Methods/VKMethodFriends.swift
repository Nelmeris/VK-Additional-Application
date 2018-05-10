//
//  VKMethodFriends.swift
//  VK Community
//
//  Created by Артем on 09.05.2018.
//  Copyright © 2018 NONE. All rights reserved.
//

import Alamofire
import UIKit
import SwiftyJSON

// Методы friends
enum FriendMethods: String {
    case get = "friends.get"
}

extension VKService.Methods {
    
    // Метод friends без параметров
    static func Friends(sender: UIViewController, method: FriendMethods, completion: @escaping([ID]) -> Void) {
        
        // Составление URL запроса
        guard let url = VKService.RequestURL(sender, method.rawValue, .v5_74) else {
            return
        }
        
        // Выполнение запроса
        Alamofire.request(url).responseData { response in
            
            // Преобразование полученных данных в JSON
            let json = try? JSON(data: response.value!)
            
            // Сериализация JSON
            let friends = json!["response"]["items"].map({ ID(json: $0.1) })
            
            completion(friends)
            
        }
    }
    
    // Метод friends
    static func Friends(sender: UIViewController, method: FriendMethods, parameters: [String: String], completion: @escaping([Friend]) -> Void) {
        
        // Составление URL запроса
        guard let url = VKService.RequestURL(sender, method.rawValue, .v5_74, parameters) else {
            return
        }
        
        // Выполнение запроса
        Alamofire.request(url).responseData { response in
            
            // Преобразование полученных данных в JSON
            let json = try? JSON(data: response.value!)
            
            // Сериализация JSON
            let friends = json!["response"]["items"].map({ Friend(json: $0.1) })
            
            completion(friends)
            
        }
    }
}
