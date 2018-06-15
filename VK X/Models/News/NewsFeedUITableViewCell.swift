//
//  NewsFeedUITableViewCell.swift
//  VK X
//
//  Created by Artem Kufaev on 28.05.2018.
//  Copyright © 2018 Artem Kufaev. All rights reserved.
//

import UIKit
import Keychain

class NewsFeedUITableViewCell: UITableViewCell {
  var authorId = 0
  var postId = 0
  
  @IBOutlet weak var authorName: UILabel!
  @IBOutlet weak var authorPhoto: RoundUIImageView!
  
  @IBOutlet weak var postText: UILabel!
  
  @IBOutlet weak var likesCount: UILabel!
  @IBOutlet weak var repostsCount: UILabel!
  @IBOutlet weak var commentsCount: UILabel!
  @IBOutlet weak var viewsCount: UILabel!
  
  @IBOutlet weak var postPhoto: UIImageView!
  
  @IBOutlet weak var postPhotoHeight: NSLayoutConstraint!
  
  @IBOutlet weak var likesIcon: UIImageView!
  @IBOutlet weak var commentsIcon: UIImageView!
  
  override func awakeFromNib() {
    commentsIcon.image = nil
    commentsCount.text = nil
    likesIcon.image = #imageLiteral(resourceName: "LikesOffIcon")
    postPhotoHeight.constant = 0
  }
  
  @IBAction func LikesClick(_ sender: Any) {
    let isLike = likesIcon.image == #imageLiteral(resourceName: "LikesIcon")
    
    likesIcon.image = (isLike ? #imageLiteral(resourceName: "LikesOffIcon") : #imageLiteral(resourceName: "LikesIcon"))
    
    let parameters = ["type": "post", "item_id": String(postId), "owner_id": String(authorId)]
    VKService.shared.request(method: "likes." + (isLike ? "delete" : "add"), parameters: parameters)
    
    guard let likes = Int(likesCount.text!) else { return }
    
    likesCount.text = getShortCount(likes + (isLike ? -1 : 1))
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    commentsCount.text = nil
    commentsIcon.image = nil
    
    postPhotoHeight.constant = 0
    authorPhoto.image = nil
    
    likesIcon.image = #imageLiteral(resourceName: "LikesOffIcon")
  }
}

extension NewsFeedUITableViewCell {
  func setLikes(_ news: VKNewsModel) {
    guard news.likes.isUserLike else { return }
    
    likesIcon.image = #imageLiteral(resourceName: "LikesIcon")
  }
  
  func setCommentsCount(_ news: VKNewsModel) {
    guard news.comments.canPost && news.comments.count != 0 else { return }
    
    commentsCount.text = getShortCount(news.comments.count)
    commentsIcon.image = #imageLiteral(resourceName: "CommentsIcon")
  }
  
  func setAuthorData(_ news: VKNewsFeedModel, _ newsIndex: Int) {
    let sourceData = getSourceData(news, newsIndex)
    
    if let photoUrl = sourceData.photoUrl {
      authorPhoto.sd_setImage(with: photoUrl, completed: nil)
    } else {
      authorPhoto.image = (news.items[newsIndex].sourceId > 0 ? #imageLiteral(resourceName: "DefaultUserPhoto") : #imageLiteral(resourceName: "DefaultGroupPhoto"))
    }
    
    authorName.text = sourceData.name
  }
  
  func attachmentProcessing(_ attachments: [VKNewsModel.Attachments]) {
    for attachment in attachments {
      switch attachment.type {
      case "photo":
        let size = attachment.photo!.sizes.last!
        
        postPhotoHeight.constant = (frame.width - 30) * CGFloat(size.height) / CGFloat(size.width)
        postPhoto.sd_setImage(with: URL(string: size.url), completed: nil)
        
      default: break
      }
    }
  }
  
  func getSourceData(_ news: VKNewsFeedModel, _ newsIndex: Int) -> (name: String, photoUrl: URL?) {
    let name: String
    let photoUrl: URL?
    
    if news.items[newsIndex].sourceId > 0 {
      let source = news.profiles.filter { profile -> Bool in
        profile.id == news.items[newsIndex].sourceId
        }.first!
      
      photoUrl = URL(string: source.photo100)
      name = source.firstName + " " + source.lastName
    } else {
      let source = news.groups.filter { group -> Bool in
        -group.id == news.items[newsIndex].sourceId
        }.first!
      
      photoUrl = URL(string: source.photo100)
      name = source.name
    }
    
    return (name, photoUrl)
  }
}
