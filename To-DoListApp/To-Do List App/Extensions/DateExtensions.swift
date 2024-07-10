//
//  DateExtension.swift
//  Zoho Task
//
//  Created by prathap on 08/07/24.
//

import Foundation

extension Date {
    
    func userFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateString = dateFormatter.string(from: self)
        return "\(dateString)"
    }
}
