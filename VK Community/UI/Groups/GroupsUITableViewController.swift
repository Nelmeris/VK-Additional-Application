//
//  GroupsUITableViewController.swift
//  VK Community
//
//  Created by Артем on 03.05.2018.
//  Copyright © 2018 NONE. All rights reserved.
//

import UIKit
import RealmSwift

class GroupsUITableViewController: UITableViewController, UISearchResultsUpdating {
    
    var groups: Results<VKGroupModel>!
    var filteredGroups: Results<VKGroupModel>!
    
    var notificationToken: NotificationToken!

    // Получение данных о группах пользователя
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        VKService.request(method: "groups.get", parameters: ["extended" : "1"]) { (response: VKItemsModel<VKGroupModel>) in
            RealmUpdateData(response.items)
        }
    }
    
    var searchController = UISearchController(searchResultsController: nil)
    
    // Настройки окна
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 75
        
        initSearchController()
        
        groups = RealmLoadData()
        filteredGroups = groups
        
        PairTableAndData(sender: tableView, token: &notificationToken, data: AnyRealmCollection(groups))
    }
    
    func initSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Искать..."
        
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
    }

    // Получение количества ячеек для групп пользователя
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }

    // Составление ячеек для групп пользователя
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let group = groups[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyGroup", for: indexPath) as! GroupsUITableViewCell

        cell.name.text = group.name
        
        setGroupPhoto(cell: cell, group: group)

        return cell
    }
    
    func setGroupPhoto(cell: GroupsUITableViewCell, group: VKGroupModel) {
        guard group.photo_100 != "" else { return }
        
        cell.photo.sd_setImage(with: URL(string: group.photo_100), completed: nil)
    }

    // Реализация присоединения к выбранной группе
    @IBAction func JoinGroup(_ sender: UIStoryboardSegue) {
        let allGroupsController = sender.source as! GroupsSearchUITableViewController
        let index = allGroupsController.tableView.indexPathForSelectedRow!.row
        let group = allGroupsController.groups[index]
        
        VKService.request(method: "groups.join", parameters: ["group_id" : String(group.id)]) { _ in
            VKService.request(method: "groups.get", parameters: ["extended" : "1"]) { (response: VKItemsModel<VKGroupModel>) in
                RealmUpdateData(response.items)
            }
        }
    }

    // Реализация удаления группы из списка групп пользователя
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Покинуть") { (action, indexPath) in
            let alert = UIAlertController(title: "Вы уверены, что хотите покинуть \"\(self.groups![indexPath.row].name)\"?", message: nil, preferredStyle: .actionSheet)
            var action = UIAlertAction(title: "Отмена", style: .cancel)
            alert.addAction(action)

            action = UIAlertAction(title: "Покинуть", style: .destructive) { (action) in
                VKService.request(method: "groups.leave", parameters: ["group_id" : String(self.groups![indexPath.row].id)]) { _ in
                    VKService.request(method: "groups.get", parameters: ["extended" : "1"]) { (response: VKItemsModel<VKGroupModel>) in
                        RealmUpdateData(response.items)
                    }
                }
            }
            alert.addAction(action)

            self.present(alert, animated: true, completion: nil)
        }
        return [deleteAction]
    }
    
    // Реализация поиска
    func updateSearchResults(for searchController: UISearchController) {
        guard searchController.searchBar.text != "" else {
            groups = filteredGroups
            tableView.reloadData()
            return
        }
        
        let searchText = searchController.searchBar.text!
        
        let predicate = "name contains[cd] '\(searchText)'"
        
        groups = filteredGroups.filter(predicate)
        
        tableView.reloadData()
    }

}
