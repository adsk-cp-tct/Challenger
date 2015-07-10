import UIKit

/// Controller for rendering contacts UI
class ContactsTableViewController: BaseSubTabViewController {
    
    @IBOutlet var tableview: UITableView!
    
    var contacts: [Contact] = []
    var sortedContacts: [String : [Contact]] = [:]
    var contactSectionTitle: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prevent scroll the table view horizontally
        tableview.alwaysBounceHorizontal = false
        
        var nib = UINib(nibName: "ContactCell", bundle: nil)
        tableview.registerNib(nib, forCellReuseIdentifier: "ContactCell")
        
        tableview.sectionIndexColor = UIColor.blackColor()
        tableview.sectionIndexBackgroundColor = Config.baseBackgroundColor
        tableview.sectionIndexTrackingBackgroundColor = Config.baseBackgroundColor
        
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("refreshContactList"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshContactList()
    }
    
    func refreshContactList() {
        contacts = Contact.getContacts()
        sortContacts()
        
        tableview.reloadData()
        refreshControl?.endRefreshing()
    }
    
    func sortContacts() {
        sortedContacts = [:]
        contactSectionTitle = []
        
        contacts.sort({ $0.name.capitalizedString < $1.name.capitalizedString })
        
        for contact in contacts {
            let capital = String(Array(contact.name.capitalizedString)[0])
            if sortedContacts[capital] == nil {
                sortedContacts[capital] = []
            }
            sortedContacts[capital]?.append(contact)
        }
        
        contactSectionTitle = sorted(sortedContacts.keys.array, <)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return contactSectionTitle.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return contactSectionTitle[section]
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let title = contactSectionTitle[section]
        return sortedContacts[title]!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:ContactCell = tableView.dequeueReusableCellWithIdentifier("ContactCell") as! ContactCell
        let title = contactSectionTitle[indexPath.section]
        cell.loadContact(sortedContacts[title]![indexPath.row])
        return cell
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return contactSectionTitle
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        var tpIndex:Int = 0
        for character in contactSectionTitle {
            if character == title{
                return tpIndex
            }
            tpIndex++
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let title = contactSectionTitle[indexPath.section]
        let contact = sortedContacts[title]![indexPath.row]
        
        pushToProfile(false, userID: contact.id)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}

