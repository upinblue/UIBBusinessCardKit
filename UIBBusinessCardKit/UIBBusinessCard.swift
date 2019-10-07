//MIT License
//
//Copyright (c) 2019 up in blue GmbH
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import UIKit
import Contacts

@available(iOS 13, *)
@objc public class UIBBusinessCard: NSObject, Codable {
    
    public var firstName: String?
    public var lastName: String?
    public var company: String?
    public var phone: String?
    public var mobilePhone: String?
    public var fax: String?
    public var mail: String?
    public var address: String?
    public var homePage: String?
    
    
    public var contact: CNContact {
        get {
            let mutableContact = CNMutableContact()
            mutableContact.givenName = firstName ?? ""
            mutableContact.familyName = lastName ?? ""
            mutableContact.organizationName = company ?? ""
            if let p = phone {
                let phoneNumber = CNPhoneNumber(stringValue: p)
                let phoneNumberLabel = CNLabeledValue(label: "Phone", value: phoneNumber)
                mutableContact.phoneNumbers.append(phoneNumberLabel)
            }
            if let m = mobilePhone {
                let phoneNumber = CNPhoneNumber(stringValue: m)
                let phoneNumberLabel = CNLabeledValue(label: "Mobile", value: phoneNumber)
                mutableContact.phoneNumbers.append(phoneNumberLabel)
            }
            if let 📧 = mail {
                let mailNSString = NSString(string: 📧)
                let mailLabel = CNLabeledValue(label: "work", value: mailNSString)
                
                mutableContact.emailAddresses.append(mailLabel)
            }
            if let hp = homePage {
                let hpNSString = NSString(string: hp)
                let homePageLabel = CNLabeledValue(label: "home page", value: hpNSString)
                mutableContact.urlAddresses.append(homePageLabel)
            }
            
            return mutableContact
        }
    }
    
    
}
