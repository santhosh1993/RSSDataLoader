//
//  ServiceRequest.swift
//  RSSDataLoader
//
//  Created by Santhosh Nampally on 08/07/19.
//  Copyright © 2019 Santhosh Nampally. All rights reserved.
//

import Foundation

enum ServiceRequestError: Error {
    case urlError
}

protocol ServiceRequestCallBack {
    func completion(_ response:(Data?,URLResponse?,Error?))
}

class ServiceRequest {
    let urlSession = URLSession.shared
    var callBack:ServiceRequestCallBack?
    let parser = RSSDataParser()
    func request(urlStr:String) {
        if let url = URL.init(string: urlStr){
            parser.startParsingWithContentsOfUrl(rssUrl: url) { (status) in
                print(parser.parsedData)
            }
        }
        else {
            callBack?.completion((nil,nil,ServiceRequestError.urlError))
        }
    }
}
