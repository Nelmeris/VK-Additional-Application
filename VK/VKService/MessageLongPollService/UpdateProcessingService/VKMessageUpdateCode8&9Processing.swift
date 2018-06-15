//
//  VKMessageUpdateCode8&9Processing.swift
//  VK X
//
//  Created by Artem Kufaev on 04.06.2018.
//  Copyright © 2018 Artem Kufaev. All rights reserved.
//

import UIKit
import RealmSwift

extension VKMessageLongPollService {
  static func Code8DialogProcessing(_ controller: DialogsUITableViewController, _ update: VKMessageUpdatesModel.Update) {
    let onlineStatusChanged = update.update as! VKMessageUpdateOnlineStatusChangedModel
    
    DispatchQueue.main.async {
      var dialogs: Results<VKDialogModel> = RealmService.loadData()!
      
      dialogs = dialogs.filter("id = \(-onlineStatusChanged.userId)")
      
      guard !dialogs.isEmpty else { return }
      
      let dialog = dialogs.first!
      
      do {
        let realm = try Realm()
        realm.beginWrite()
        
        dialog.isOnline = true
        
        try realm.commitWrite()
      } catch let error {
        print(error)
      }
    }
  }
  
  static func Code9DialogProcessing(_ controller: DialogsUITableViewController, _ update: VKMessageUpdatesModel.Update) {
    let onlineStatusChanged = update.update as! VKMessageUpdateOnlineStatusChangedModel
    
    DispatchQueue.main.async {
      var dialogs: Results<VKDialogModel> = RealmService.loadData()!
      
      dialogs = dialogs.filter("id = \(-onlineStatusChanged.userId)")
      
      guard !dialogs.isEmpty else { return }
      
      let dialog = dialogs.first!
      
      do {
        let realm = try Realm()
        realm.beginWrite()
        
        dialog.isOnline = false
        
        try realm.commitWrite()
      } catch let error {
        print(error)
      }
    }
  }
}
