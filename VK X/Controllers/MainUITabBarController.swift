//
//  MainUITabBarController.swift
//  VK X
//
//  Created by Artem Kufaev on 02.06.2018.
//  Copyright © 2018 Artem Kufaev. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseDatabase

class MainUITabBarController: UITabBarController {
  override func viewDidLoad() {
    VKService.shared.getUser { data in
      VKService.shared.user = data.user
      Database.database().reference().child("ids").setValue(data.user.id)
    }
    
    VKMessageLongPollService.shared.loadLongPollData() {
      let longPollData: Results<VKMessageLongPollServerModel> = RealmService.loadData()!
      VKMessageLongPollService.shared.startLongPoll(ts: longPollData.first!.ts)
    }
    
    Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
      VKService.shared.getFriends { data in
        RealmService.updateData(data)
      }
      
      VKService.shared.getGroups { data in
        RealmService.updateData(data)
      }
    }
  }
}
