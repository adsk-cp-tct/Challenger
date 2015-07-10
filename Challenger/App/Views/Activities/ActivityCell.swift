import UIKit

protocol ActivityCellDelegate {
    func showCommentTextField(index: Int, id: String, type: Config.eventType)
}

class ActivityCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate, CoupleButtonDelegate {

    @IBOutlet weak var subjectAvatar: UIButton!
    @IBOutlet weak var whatHappened: UILabel!
    @IBOutlet weak var when: UILabel!
    
    @IBOutlet weak var activityContent: UIView!
    var eventCell: EventCell?
    var ideaCell: IdeaCell?
    
    @IBOutlet weak var coupleButton: CoupleButton!
    
    @IBOutlet weak var commentList: UITableView!
    @IBOutlet weak var commentListHeight: NSLayoutConstraint!
    
    let EVENT_POSTED = "A new event has been posted"
    let IDEA_POSTED = " has posted an idea"
    
    var activity: Activity?
    var idea: Idea?
    var commentItems : [Comment] = []
    
    var profileDelegate: ProfileDelegate?
    var activityCellDelegate: ActivityCellDelegate?
    
    var index: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        coupleButton.setupButton(1, title: "Comment", imageName: "comment_blue")
        coupleButton.delegate = self
        
        commentList.dataSource = self
        commentList.delegate = self
        CommentController.initCommentTable(commentList)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadActivity(activity : Activity, contentCell: UITableViewCell, index: Int) {
        self.activity = activity
        if (self.eventCell != nil) {
            self.eventCell!.removeFromSuperview()
            self.eventCell = nil
        }
        
        if (self.ideaCell != nil) {
            self.ideaCell!.removeFromSuperview()
            self.ideaCell = nil
        }
        
        self.commentItems = []
        
        if (activity.objType == Config.eventType.Event.rawValue) {
            let likeButtonTitle = User.currentUser.doesUserLikeEvent(activity.objId) ? "Unlike" : "Like"
            coupleButton.setupButton(2, title: likeButtonTitle, imageName: "like_blue")
            
            subjectAvatar.setImage(UIImage(named: "event-avatar"), forState: .Normal)
            whatHappened.text = EVENT_POSTED
            when.text = activity.createdTime
            
            eventCell = contentCell as? EventCell
            
            // Load comments
            commentItems = Comment.getComments(Config.eventType.Event, targetId: activity.objId)
            
        } else if (activity.objType == Config.eventType.Idea.rawValue) {
            let likeButtonTitle = User.currentUser.doesUserLikeIdea(activity.objId) ? "Unlike" : "Like"
            coupleButton.setupButton(2, title: likeButtonTitle, imageName: "like_blue")
            
            let url = NSURL(string: idea!.createdAvatar)
            let data = NSData(contentsOfURL: url!)
            let image = (data != nil) ? UIImage(data: data!) : UIImage(named: idea!.createdAvatar)
            subjectAvatar.setImage(image, forState: .Normal)
            
            var ideaTitle = NSMutableAttributedString(string: idea!.createdUser + IDEA_POSTED, attributes: [NSFontAttributeName:UIFont(name: Config.fontFamilyLight, size: 15.0)!])
            ideaTitle.addAttribute(NSForegroundColorAttributeName, value: Config.textFieldBorderColor, range: NSRange(location:0, length:count(idea!.createdUser)))
            whatHappened.attributedText = ideaTitle
            
            when.text = activity.createdTime
            
            ideaCell = contentCell as? IdeaCell
            
            // Load comments
            commentItems = Comment.getComments(Config.eventType.Idea, targetId: activity.objId)
        }
        
        activityContent.addSubview(contentCell)
        commentList.reloadData()
        self.index = index
    }
    
    func buttonTapped(tag: Int) {
        switch tag {
        case 1: // Comment
            showCommentTextField()
            break
        case 2: // Like/unlike
            likeUnlike()
            break
        default:
            break
        }
    }
    
    private func likeUnlike() {
        if (activity!.objType == Config.eventType.Event.rawValue) {
            let previousLikeNum = eventCell!.likeNum.text!.toInt()!
            if User.currentUser.doesUserLikeEvent(activity!.objId) {
                if User.currentUser.unlikeEvent(activity!.objId) {
                    coupleButton.setupButton(2, title: "Like", imageName: "like_blue")
                    eventCell!.likeNum.text = "\(previousLikeNum-1)"
                }
            }
            else {
                if User.currentUser.likeEvent(activity!.objId, title: eventCell!.eventTitle.text!) {
                    coupleButton.setupButton(2, title: "Unlike", imageName: "like_blue")
                    eventCell!.likeNum.text = "\(previousLikeNum+1)"
                }
            }
        } else if (activity!.objType == Config.eventType.Idea.rawValue) {
            let previousLikeNum = ideaCell!.like.text!.toInt()!
            if User.currentUser.doesUserLikeIdea(activity!.objId) {
                if User.currentUser.unlikeIdea(activity!.objId) {
                    coupleButton.setupButton(2, title: "Like", imageName: "like_blue")
                    ideaCell!.like.text = "\(previousLikeNum-1)"
                }
            }
            else {
                if User.currentUser.likeIdea(activity!.objId, title: ideaCell!.title.text!) {
                    coupleButton.setupButton(2, title: "Unlike", imageName: "like_blue")
                    ideaCell!.like.text = "\(previousLikeNum+1)"
                }
            }
        }
    }
    
    private func showCommentTextField() {
        activityCellDelegate!.showCommentTextField(index!, id: activity!.objId, type: Config.eventType(rawValue: activity!.objType)!)
    }
    
    @IBAction func pushToProfile() {
        if (activity!.objType == Config.eventType.Idea.rawValue) {
            profileDelegate?.pushToProfile(idea!.createdBy == User.currentUser.userId, userID: idea!.createdBy)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentItems.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        commentListHeight.constant = tableView.contentSize.height
        self.updateConstraints()
        
        return CommentController.cell(tableView, atIndexPath: indexPath, fromCommentList: commentItems, profileDelegate: profileDelegate)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CommentController.cellHeight(tableView, atIndexPath: indexPath, fromCommentList: commentItems)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CommentController.headerFooterHeight()
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CommentController.headerFooterHeight()
    }
}
