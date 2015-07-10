import Foundation
import UIKit

class HttpRequest {
    
    /// Make http call
    static func sendSynchronousRequest(url: String, method: String, headers: [String: String] = [:], body: AnyObject? = nil) -> (resonse: NSURLResponse?, error: NSError?, content: NSData?) {
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.HTTPMethod = method
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        var bodyContent: NSData?
        if let bodyData = (body as? NSData) {
            bodyContent = bodyData
        }
        else if let bodyString = (body as? String) {
            if (!bodyString.isEmpty) {
                bodyContent = bodyString.dataUsingEncoding(NSASCIIStringEncoding)
            }
        }
        else if let bodyDictionary = (body as? [String: String]) {
            bodyContent = NSJSONSerialization.dataWithJSONObject(bodyDictionary, options: .allZeros, error: nil)
        }
        request.HTTPBody = bodyContent
        
        var returningResponse: NSURLResponse?
        var responseError: NSError?
        let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &returningResponse, error: &responseError)
        
        return (returningResponse, responseError, data)
    }
    
    static func sendSynchronousJsonContentRequest(url: String, method: String, headers: [String: String] = [:], body: AnyObject) -> (resonse: NSURLResponse?, error: NSError?, content: NSData?) {
        var appendedHeaders = headers
        appendedHeaders["Content-Type"] = "application/json"
        
        var data = NSJSONSerialization.dataWithJSONObject(body, options: .allZeros, error: nil)
        return sendSynchronousRequest(url, method: method, headers: appendedHeaders, body: data)
    }
    
    /// Image uploading
    static func uploadImage(url: String, parameters: Dictionary<String,AnyObject>?, filename: String, image: UIImage,
        success:((String) -> Void)! /*, failed:((NSDictionary) -> Void)!, errord:((NSError) -> Void)!*/) {
            var TWITTERFON_FORM_BOUNDARY:String = "AaB03x"
            let url = NSURL(string: url)!
            var request:NSMutableURLRequest = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 10)
            var MPboundary:String = "--\(TWITTERFON_FORM_BOUNDARY)"
            var endMPboundary:String = "\(MPboundary)--"
            //convert UIImage to NSData
            var data:NSData = UIImagePNGRepresentation(image)
            var body:NSMutableString = NSMutableString();
            // with other params
            if parameters != nil {
                for (key, value) in parameters! {
                    body.appendFormat("\(MPboundary)\r\n")
                    body.appendFormat("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                    body.appendFormat("\(value)\r\n")
                }
            }
            // set upload image, name is the key of image
            body.appendFormat("%@\r\n",MPboundary)
            body.appendFormat("Content-Disposition: form-data; name=\"\(filename)\"; filename=\"pen111.png\"\r\n")
            body.appendFormat("Content-Type: image/png\r\n\r\n")
            var end:String = "\r\n\(endMPboundary)"
            var myRequestData:NSMutableData = NSMutableData();
            myRequestData.appendData(body.dataUsingEncoding(NSUTF8StringEncoding)!)
            myRequestData.appendData(data)
            myRequestData.appendData(end.dataUsingEncoding(NSUTF8StringEncoding)!)
            var content:String = "multipart/form-data; boundary=\(TWITTERFON_FORM_BOUNDARY)"
            request.setValue(content, forHTTPHeaderField: "Content-Type")
            request.setValue("\(myRequestData.length)", forHTTPHeaderField: "Content-Length")
            request.HTTPBody = myRequestData
            request.HTTPMethod = "POST"
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
                data, response, error in
                if error != nil {
                    println(error)
                    return
                }
                if let resultString = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    success(resultString as String)
                } else {
                    println("Error in get result.")
                }
            })
            task.resume()
    }
}