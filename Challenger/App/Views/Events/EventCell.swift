import UIKit

class EventCell: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var follow: UIButton!
    @IBOutlet weak var likeNum: UILabel!
    @IBOutlet weak var joinNum: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var day: UILabel!
    
    @IBOutlet weak var eventCellBackground: UIView!
    @IBOutlet weak var eventType: UILabel!
    
    
    var event: Event = Event()
    
    @IBAction func followPressed(sender: AnyObject) {
        if User.currentUser.doesUserFollowEvent(event.eventId) {
            if User.currentUser.unfollowEvent(event.eventId) {
                follow.setTitle("+ Follow", forState: .Normal)
            }
        }
        else {
            if User.currentUser.followEvent(event.eventId, title: event.eventTitle) {
                follow.setTitle("- Unfollow", forState: .Normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        // Beautify it with shadow
        eventCellBackground.layer.shadowColor = UIColor.blackColor().CGColor
        eventCellBackground.layer.shadowOffset = CGSizeZero
        eventCellBackground.layer.shadowOpacity = 0.2
        eventCellBackground.layer.shadowRadius = 1.0
        
        // Beautify it with round boarder
        eventType.layer.cornerRadius = 3.0
        eventType.layer.borderWidth = Config.textFieldBorderWidth
        eventType.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadEvent(e: Event) {
        self.event = e
        
        self.eventTitle.text = self.event.eventTitle
        self.likeNum.text = self.event.like
        self.joinNum.text = self.event.join
        self.eventType.text = self.event.etype.capitalizedString
        self.eventType.backgroundColor = Utilities.eventTypeToColor(self.event.etype)
        self.eventType.layer.borderColor = Utilities.eventTypeToColor(self.event.etype).CGColor

        let url = NSURL(string: e.thumbnail)
        let data = NSData(contentsOfURL: url!)
        self.thumbnail.image = Utilities.cropToSquare(image: ((data != nil) ? UIImage(data: data!) : UIImage(named: e.thumbnail))!)
        var dtArr = e.date.componentsSeparatedByString("-")
        self.month.text = dtArr[1]
        self.day.text = dtArr[2]
        
        if User.currentUser.doesUserFollowEvent(e.eventId) {
            follow.setTitle("- Unfollow", forState: .Normal)
        }
        else {
            follow.setTitle("+ Follow", forState: .Normal)
        }
    }
    
}
