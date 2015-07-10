import UIKit

class UserAvatarCell: UICollectionViewCell {

    @IBOutlet weak var userAvatar: UIButton!
    var delegate: ProfileDelegate?
    var userID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func loadUser(userID: String, avatar: String) {
        let userAvatarUrl = NSURL(string: avatar)
        let userAvatarData = NSData(contentsOfURL: userAvatarUrl!)
        self.userID = userID
        userAvatar.setImage((userAvatarData != nil) ? UIImage(data: userAvatarData!) : UIImage(named: avatar), forState: .Normal)
        userAvatar.addTarget(self, action: Selector("profileButtonAction"), forControlEvents: UIControlEvents.TouchUpInside)
    }

    func profileButtonAction() {
        delegate?.pushToProfile(userID == User.currentUser.userId, userID: userID!)
    }
}
