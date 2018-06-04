//
//  VKServiceSizes.swift
//  VK Community
//
//  Created by Артем on 31.05.2018.
//  Copyright © 2018 NONE. All rights reserved.
//

import SwiftyJSON
import RealmSwift

class VKSizes: Object {
    
    @objc dynamic var type = ""
    @objc dynamic var url = ""
    @objc dynamic var width = 0
    @objc dynamic var height = 0
    
    required convenience init(_ json: JSON) {
        self.init()
        
        type = json["type"].stringValue
        url = json["url"].stringValue
        width = json["width"].intValue
        height = json["height"].intValue
    }
    
    func isEqual (_ object: VKSizes) -> Bool {
        return (type == object.type) &&
            (url == object.url) &&
            (width == object.width) &&
            (height == object.height)
    }
    
}
