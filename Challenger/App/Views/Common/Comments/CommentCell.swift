import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var userAvatar: UIButton!
    @IBOutlet weak var commentDetails: UILabel!
    @IBOutlet weak var commentContentView: UIView!
    
    var comment = Comment()
    var delegate: ProfileDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clearColor()
        // Initialization code
        commentContentView.layer.borderWidth = 0.5
        commentContentView.layer.cornerRadius = 3
        commentContentView.clipsToBounds = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func loadComment(c: Comment){
        
        self.comment = c
        
        self.commentDetails.sizeToFit()
        
        let url = NSURL(string: self.comment.userAvatar)
        let data = NSData(contentsOfURL: url!)
        userAvatar.setImage((data != nil) ? UIImage(data: data!) : UIImage(named: self.comment.userAvatar), forState: .Normal)
        
        userAvatar.addTarget(self, action: Selector("profileButtonAction"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func profileButtonAction() {
        delegate?.pushToProfile(comment.userId == User.currentUser.userId, userID: comment.userId)
    }
}
