//
//  RequestManager.swift
//  PerpetualizeV2
//
//  Created by Michael Xu on 4/23/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import Foundation
import MobileCoreServices

//let host : NSString = "log.haus";
let host : NSString = "one.haus";

class RequestManager {

    /// Create request
    ///
    /// :param: userid   The userid to be passed to web service
    /// :param: password The password to be passed to web service
    /// :param: email    The email address to be passed to web service
    ///
    /// :returns:         The NSURLRequest that was created

    func createRequest (fileURL : NSURL) -> NSURLRequest {
        let param : [String : String] = [
            "user_id"  : "placeholder",
            "email"    : "placeholder@mit.edu",
            "password" : "placeholder"]  // build your dictionary however appropriate
        
        let boundary = generateBoundaryString()
        println(boundary);
        
        let url = NSURL(string: "http://\(host)/video")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
//        let path1 = NSBundle.mainBundle().pathForResource("image1", ofType: "png") as String!
//        let path2 = NSBundle.mainBundle().pathForResource("image2", ofType: "jpg") as String!
        request.HTTPBody = createBodyWithParameters(param, filePathKey: "uploadVideo", paths: [fileURL.path!], boundary: boundary)
//        request.HTTPBody = stringToNSData("HELLO THERE MY FRIEND")
//        String(
//        println(String(initstringInterpolationSegment: request.HTTPBody))
        return request
    }

    /// Create body of the multipart/form-data request
    ///
    /// :param: parameters   The optional dictionary containing keys and values to be passed to web service
    /// :param: filePathKey  The optional field name to be used when uploading files. If you supply paths, you must supply filePathKey, too.
    /// :param: paths        The optional array of file paths of the files to be uploaded
    /// :param: boundary     The multipart/form-data boundary
    ///
    /// :returns:           The NSData of the body of the request

    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, paths: [String]?, boundary: String) -> NSData {
        let body = NSMutableData()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendData(stringToNSData("--\(boundary)\r\n"))
                body.appendData(stringToNSData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"))
                body.appendData(stringToNSData("\(value)\r\n"))
            }
        }
        
        if paths != nil {
            for path in paths! {
                let filename = path.lastPathComponent
                println("FILE IS: \(path)")
                let data = NSData(contentsOfFile: path)
                let mimetype = mimeTypeForPath(path)
                
                body.appendData(stringToNSData("--\(boundary)\r\n"))
                body.appendData(stringToNSData("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n"))
                body.appendData(stringToNSData("Content-Type: \(mimetype)\r\n\r\n"))
                body.appendData(data!)
                body.appendData(stringToNSData("\r\n"))
            }
        }
        
        body.appendData(stringToNSData("--\(boundary)--\r\n"))
        return body
    }

    /// Create boundary string for multipart/form-data request
    ///
    /// :returns:            The boundary string that consists of "Boundary-" followed by a UUID string.

    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }

    /// Determine mime type on the basis of extension of a file.
    ///
    /// This requires MobileCoreServices framework.
    ///
    /// :param: path         The path of the file for which we are going to determine the mime type.
    ///
    /// :returns:            Returns the mime type if successful. Returns application/octet-stream if unable to determine mime type.

    func mimeTypeForPath(path: String) -> String {
        let pathExtension = path.pathExtension
        
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as NSString as String
            }
        }
        return "application/octet-stream";
    }
    
    func uploadMovie(fileURL : NSURL, handler : (getURL: NSString?, error: NSString?) -> Void) {
        var request = createRequest(fileURL);
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
            data, response, error in
            
            if error != nil {
                println("ERROR: \(error)")
                // handle error here
                return
            }
            
            // if response was JSON, then parse it
            
            var err: NSError?
            
            if let jsonResult : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary {
                if(err != nil) {
                    // If there is an error parsing JSON, print it to the console
                    println("JSON Error \(err!.localizedDescription)")
                    return;
                }
                if (jsonResult["error"] != nil) {
                    println(jsonResult["error"]);
                    dispatch_async(dispatch_get_main_queue(), {
                        handler(getURL: nil, error: jsonResult["error"] as? NSString);
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                         handler(getURL: jsonResult["url"] as? NSString, error: nil);
                    })
                }
            } else {
                println("FAILED")
                dispatch_async(dispatch_get_main_queue(), {
                    handler(getURL: nil, error: "no result!");
                })
            }
        })
        task.resume()
    }
    
    func stringToNSData(string: NSString) -> NSData {
        return string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
    }
}