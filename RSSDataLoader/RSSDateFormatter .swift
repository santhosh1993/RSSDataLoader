//
//  RSSDateFormatter .swift
//  RSSDataLoader
//
//  Created by Santhosh Nampally on 10/07/19.
//  Copyright © 2019 Santhosh Nampally. All rights reserved.
//

import Foundation

enum FormatterStyle:String {
    case descriptiveDate = "E, dd MMM yyyy hh:mm:ss zzz"
}

enum FormattingError:Error {
    case errorOccuredWhileStringToDateTransformation
}

class RSSDateFormatter {
    static let shared = RSSDateFormatter()
    let dateFormatter:DateFormatter = DateFormatter()
    
    private init(){
        
    }
    
    func stringToDate(for type:FormatterStyle, dateStr:String) throws -> Date {
        dateFormatter.dateFormat = type.rawValue
        
        if let date = dateFormatter.date(from: dateStr){
            return date
        }
        else{
            throw FormattingError.errorOccuredWhileStringToDateTransformation
        }
    }
}
