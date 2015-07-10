import UIKit

class IdeaCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var like: UILabel!
    @IBOutlet weak var follow: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var ideaCellBackground: UIView!
    
    var idea: Idea = Idea()
    
    @IBAction func followPress(sender: AnyObject) {
        if User.currentUser.doesUserFollowIdea(idea.id) {
            if User.currentUser.unfollowIdea(idea.id) {
                btnFollow.setTitle("+ Follow", forState: .Normal)
            }
        }
        else {
            if User.currentUser.followIdea(idea.id, title: idea.title) {
                btnFollow.setTitle("- Unfollow", forState: .Normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        // Beautify it with shadow
        ideaCellBackground.layer.shadowColor = UIColor.blackColor().CGColor
        ideaCellBackground.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        ideaCellBackground.layer.shadowOpacity = 0.2
        ideaCellBackground.layer.shadowRadius = 1.0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadIdea(i: Idea) {
        self.idea = i
        
        self.title.text = self.idea.title
        self.like.text = self.idea.likeUserCount
        self.follow.text = self.idea.followersCount
        
        let url = NSURL(string: i.thumbnails)
        let data = NSData(contentsOfURL: url!)
        self.thumbnail.image = Utilities.cropToSquare(image: ((data != nil) ? UIImage(data: data!) : UIImage(named: i.thumbnails))!)
        
        if User.currentUser.doesUserFollowIdea(i.id) {
            btnFollow.setTitle("- Unfollow", forState: .Normal)
        }
        else {
            btnFollow.setTitle("+ Follow", forState: .Normal)
        }
    }
    
}
