import UIKit


class PictureCell : UITableViewCell{
    @IBOutlet weak var pictureView: UIImageView!
    
    func loadPicture(uri:String){
        let url = NSURL(string:uri)
        let data = NSData(contentsOfURL: url!)
        self.pictureView.contentMode = UIViewContentMode.ScaleAspectFit
        self.pictureView.image = UIImage(data: data!) 
    }
}