//
//  User+ProfileEdit.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/27.
//  Copyright © 2017年 moelove. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


extension User {
    
    
    // MARK: - Profile edit
    static func submitLatestProfile() {
    }
    
    // MARK: - Avatar upload
    static func avatarUpload(_ image: UIImage,
                                completionHandler: @escaping (Bool, String) -> ()) {
        
        func compress(_ image: UIImage, newSize size: CGSize) -> UIImage {
            UIGraphicsBeginImageContext(size);
            image.draw(in: CGRect(x:0,y:0,width:size.width,height:size.height))
            let newImage: UIImage =                   UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return newImage
        }
        
        func urlRequestWithComponents(url: URL,
                                      parameters:Dictionary<String, String>,
                                      imageData:Data) -> (data: Data, request: URLRequestConvertible) {
            
            // create url request to send
            var mutableURLRequest = URLRequest(url: url)
            mutableURLRequest.httpMethod = "POST"
            let boundaryConstant = "myRandomBoundary12345";
            let contentType = "multipart/form-data;boundary="+boundaryConstant
            mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
            
            // create upload data to send
            let uploadData = NSMutableData()
            
            // add image
            uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
            uploadData.append("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".data(using: String.Encoding.utf8)!)
            uploadData.append("Content-Type: image/png\r\n\r\n".data(using: String.Encoding.utf8)!)
            uploadData.append(imageData as Data)
            
            // add parameters
            for (key, value) in parameters {
                uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
                uploadData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".data(using: String.Encoding.utf8)!)
            }
            uploadData.append("\r\n--\(boundaryConstant)--\r\n".data(using: String.Encoding.utf8)!)

            return (uploadData as Data, mutableURLRequest as URLRequestConvertible)
        }

        let url = signedInUrl(forUrlType: .avatarUpload, actType: .avatarUpload)!
        
        let uploadImage = compress(image, newSize: CGSize(width: 300, height: 300))
        let imgData = UIImageJPEGRepresentation(uploadImage, 0.3)
        let parameters = ["uid": User.shared.uid]
        
        let dataRequest = urlRequestWithComponents(url: url,
                                                   parameters: parameters,
                                                   imageData: imgData!)
        
        Alamofire.upload(dataRequest.data, with: dataRequest.request).responseJSON { (response) in
            switch response.result {
            case .success(let jsonResponse):
                let json = JSON(jsonResponse)
                printX(json)
                let info = json["info"].stringValue
                let status = json["status"].intValue
                completionHandler(status == 1, info)
            case .failure(let error):
                completionHandler(false, "发生错误")
                printX("error: \(error)")
            }
        }
        
    }
    
       
}
