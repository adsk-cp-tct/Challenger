import Foundation
import UIKit

class Utilities {
    
    /// Alert pop-up
    static func showAlert(viewController: UIViewController, message: String, title: String = "Alert", buttonTitle: String = "OK") {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.Default, handler: nil))
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    static func parsedNSDataToDictionary(data: NSData) -> NSDictionary? {
        return NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary
    }
    
    /// Post device token and related userId to backend, for the Notification functionality
    static func postDeviceToken(userId: String, deviceToken: String) {
        println("Post device token: \(deviceToken)")
        
        let tokenBody=[
            "userId":userId,
            "deviceToken":deviceToken
        ]
        
        let (response, error, responseContent) = HttpRequest.sendSynchronousJsonContentRequest(Config.tokenEndpoint, method: "POST", body: tokenBody)
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (error != nil || statusCode != 200) {
            println("Http error")
        }
    }
    
    /// Delete device token when user sign out
    static func deleteDeviceToken(userId: String) {
        let url = Config.tokenEndpoint + "/" + userId
        let (response, error, responseContent) = HttpRequest.sendSynchronousRequest(url, method: "DELETE")
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (error != nil || statusCode != 200) {
            println("Http error")
        }
    }
    
    static func getMapValue(json: AnyObject, forKey: String, withDefault defaultVal: Dictionary<String, String> = [String: String]()) -> Dictionary<String, String> {
        
        if let map: Dictionary<String, String> = json[forKey] as? Dictionary<String, String> {
            if !map.isEmpty {
                return map
            }
        }
        return defaultVal
    }
    
    static func getStringValue(json: AnyObject, forKey: String, withDefault defaultVal: String = "") -> String {
        
        var value: String = defaultVal
        if let stringVal: String = json[forKey] as? String {
            if (!stringVal.isEmpty) {
                value = stringVal
            }
        }
        else if let intVal: Int = json[forKey] as? Int {
            value = "\(intVal)"
        }
        return value
    }
    
    static func getImagePath(json: AnyObject, forKey: String, withDefault defaultVal: String = "") -> String {
        var value: String = defaultVal
        if let stringVal: String = json[forKey] as? String {
            if (!stringVal.isEmpty) {
                value = Config.imageEndpoint + stringVal
            }
        }
        else if let intVal: Int = json[forKey] as? Int {
            value = Config.imageEndpoint + "\(intVal)"
        }
        return value
    }
    
    static func getArraySizeValue(json: AnyObject, forKey: String, withDefault defaultVal: Int = 0) -> String {
        return String((json[forKey] as? NSArray)?.count ?? defaultVal)
    }
    
    static func getStringArrayValue(json: AnyObject, forKey: String, withDefault defaultVal: [String] = []) -> [String] {
        
        var array: [String] = []
        if let arr = json[forKey] as? NSArray {
            for obj in arr {
                array.append(obj as! String)
            }
        }
        return array
    }
    
    static func getDictionarySizeValue(json: AnyObject, forKey: String, withDefault defaultVal: Int = 0) -> String {
        return String((json[forKey] as? NSDictionary)?.count ?? defaultVal)
    }
    
    /// Data time handling
    static func trimDateAsMonthDay(date: String) -> String {
        // Date example: 2015-08-01T00:00:00.000+08:00
        let tmpDate = date.componentsSeparatedByString("T")
        return tmpDate[0]
    }
    
    static func trimDateAsMonthDayHourMinute(date: String) -> String {
        // Date example: 2015-08-01T00:00:00.000+08:00
        println(date)
        let tmpDate = date.componentsSeparatedByString("T")
        let pureTime = tmpDate[1].componentsSeparatedByString(":")
        return tmpDate[0] + "-" + pureTime[0] + "-" + pureTime[1]
    }
    
    static func trimDateAsMonthDayHourMinuteWithourYear(date: String) -> String {
        // Date example: 2015-08-01T00:00:00.000+08:00
        println(date)
        let tmpDate = date.componentsSeparatedByString("T")
        let tmp1=tmpDate[0].componentsSeparatedByString("-")
        let tmp2=tmp1[1]+"-"+tmp1[2]
        let pureTime = tmpDate[1].componentsSeparatedByString(":")
        return tmp2 + " " + pureTime[0] + ":" + pureTime[1]
    }
    
    static func trimDatesAsTimeSpan(startDate: String, endDate: String) -> String {
        // Date example: 2015-08-01T00:00:00.000+08:00
        return trimDateAsMonthDayHourMinute(startDate) + ";" + trimDateAsMonthDayHourMinute(endDate)
    }
    
    static func trimDateInSlashStyle(date: String) -> String {
        // Date example: 2015-08-01T00:00:00.000+08:00
        println(date)
        let tmpDate = date.componentsSeparatedByString("T")
        let tmpSep = tmpDate[0].componentsSeparatedByString("-")
        return join("/", tmpSep)
    }
    
    static func eventTypeToColor(eventType: String) -> UIColor {
        switch eventType {
            case "brownbag": return UIColor.brownColor()
            case "competition": return UIColor.darkGrayColor()
            case "training": return UIColor.blueColor()
            case "groupbuying": return UIColor.magentaColor()
            default: return UIColor.blackColor()
        }
    }
    
    static func getScreenWidth() -> CGFloat {
        return UIScreen.mainScreen().nativeBounds.width
    }
    
    /// Crop the image to square
    static func cropToSquare(image originalImage: UIImage) -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage)!
        
        // Get the size of the contextImage
        let contextSize: CGSize = contextImage.size
        
        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        
        // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, width, height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)!
        
        return image
    }
}