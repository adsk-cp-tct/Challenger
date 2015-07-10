import UIKit

class ContactCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func loadContact(contact: Contact) {
        name.text = contact.name
        title.text = contact.title
        email.text = contact.email
        
        let url = NSURL(string: contact.avatar)
        let data = NSData(contentsOfURL: url!)
        avatar.image = (data != nil) ? UIImage(data: data!) : UIImage(named: contact.avatar)
    }
}
