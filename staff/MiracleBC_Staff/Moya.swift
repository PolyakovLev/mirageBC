//
//  Moya.swift
//  MirageBC_Client
//
//  Created by LEV POLYAKOV on 15/06/2019.
//  Copyright © 2019 Lev Polyakov. All rights reserved.
//

import Foundation
import Moya

public enum UserActions {

    case registration(image: UIImage, name: String, number: String)
    case authorization(image: UIImage)
    case userInfo(userId: String)
    case addOrder(userId: String, order: String)
}

extension UserActions: TargetType {

    public var baseURL: URL {
        return URL(string: "http://35.180.156.31:80")!
    }
    
    public var path: String {
        switch self {
            
        case .registration(_,_,_):
            return "/registration"
        case .authorization(_):
            return "/autorization"
        case .userInfo(_):
            return "/userInfo"
        case .addOrder(_):
            return "/addOrder"
        @unknown default:
            print("Path error")
        }
    }
    
    public var method: Moya.Method {
        switch self {
        default:
            return.post
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
            
        case .registration(let image, let name, let number):
            var array: [MultipartFormData] = []
            let data = image.jpegData(compressionQuality: 0.5)!
            array.append(MultipartFormData(provider: .data(data), name: "imageFile", fileName: "image.jpg", mimeType: "image/jpeg"))
            array.append(MultipartFormData(provider: .data(name.data(using: .utf8)!), name: "name"))
            array.append(MultipartFormData(provider: .data(number.data(using: .utf8)!), name: "number"))
            return .uploadCompositeMultipart(array, urlParameters: [:])
            
        case .authorization(let image):
            let imageData = image.jpegData(compressionQuality: 0.8)!
            return .uploadMultipart([MultipartFormData.init(provider: .data(imageData), name: "image")])
        case .userInfo(let userId):
            return .requestParameters(parameters: ["userId": userId], encoding: URLEncoding(destination: .queryString))
        case .addOrder(let userId, let order):
            return .requestParameters(parameters: ["userId": userId, "order": order], encoding: URLEncoding(destination: .queryString))
        @unknown default:
            print("Task error")
        }
        return .requestPlain // TODO
    }
    
    
    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    public var validationType: ValidationType {
        return .successCodes
    }
}

