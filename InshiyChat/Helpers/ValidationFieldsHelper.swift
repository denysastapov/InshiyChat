//
//  ValidationFieldsHelper.swift
//  InshiyChat
//
//  Created by Denys Astapov on 05.12.2023.
//

import Foundation

struct ValidationFieldsHelper {
    
    static func isValidName(_ name: String) -> Bool {
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z ]+$")
        let isLengthValid = name.count >= 3
        return namePredicate.evaluate(with: name) && isLengthValid
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        return emailPredicate.evaluate(with: email)
    }
    
    static func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
        let passwordPredicate = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
}
