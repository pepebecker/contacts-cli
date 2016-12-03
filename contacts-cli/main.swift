//
//  main.swift
//  contacts-cli
//
//  Created by Pepe Becker on 01/12/2016.
//  Copyright © 2016 Pepe Becker. All rights reserved.
//

import Foundation
//import Contacts
import AddressBook

//@available(OSX 10.11, *)
//class Contacts1011: NSObject {
//    func getAllContacts(callback: @escaping ([[String: Any]]) -> Void) {
//        var contactsList = [[String: Any]]()
//
//        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactOrganizationNameKey, CNContactEmailAddressesKey, CNContactPhoneNumbersKey]
//        let fetchRequest = CNContactFetchRequest( keysToFetch: keysToFetch as [CNKeyDescriptor])
//        fetchRequest.sortOrder = .userDefault
//
//        do {
//            try CNContactStore().enumerateContacts(with: fetchRequest) { (contact, stop) -> Void in
//                var c = [String: Any]()
//
//                c["firstName"] = contact.givenName
//                c["lastName"] = contact.familyName
//                c["organization"] = contact.organizationName
//
//                var emails = [[String: String]]()
//                for email in contact.emailAddresses {
//                    let localizedLabel = CNLabeledValue<NSString>.localizedString(forLabel: email.label!)
//                    emails.append(["label": localizedLabel, "value": email.value as String])
//                }
//                c["emails"] = emails
//
//                var phones = [[String: String]]()
//                for phone in contact.phoneNumbers {
//                    let localizedLabel = CNLabeledValue<NSString>.localizedString(forLabel: phone.label!)
//                    phones.append(["label": localizedLabel, "value": phone.value.stringValue])
//                }
//                c["phones"] = phones
//
//                contactsList.append(c)
//            }
//        } catch {
//            fputs("not authorized\n", stderr)
//            exit(EXIT_FAILURE)
//        }
//
//        callback(contactsList)
//    }
//}

class Contacts1010: NSObject {
    func getAllContacts(callback: @escaping ([[String: Any]]) -> Void) {
        var peopleList = [[String: Any]]()
        
        if let book = ABAddressBook.shared() {
            let people = book.people() as! [ABPerson]
            for person in people {
                var p = [String: Any]()
                
                p["firstName"] = ABRecordCopyValue(person, kABFirstNameProperty as CFString!)?.takeRetainedValue() as? String
                
                p["lastName"] = ABRecordCopyValue(person, kABLastNameProperty as CFString!)?.takeRetainedValue() as? String
                
                p["organization"] = ABRecordCopyValue(person, kABOrganizationProperty as CFString!)?.takeRetainedValue() as? String
                
                if let emails = person.value(forProperty: kABEmailProperty) {
                    var emailList = [[String: String]]()
                    for i in 0 ..< ABMultiValueCount(emails as! ABMultiValueRef) {
                        var email = [String: String]()
                        let labelRef = ABMultiValueCopyLabelAtIndex(emails as! ABMultiValueRef, i)?.takeRetainedValue()
                        email["label"] = ABCopyLocalizedPropertyOrLabel(labelRef)?.takeRetainedValue() as? String
                        email["value"] = ABMultiValueCopyValueAtIndex(emails as! ABMultiValueRef, i)?.takeRetainedValue() as? String
                        emailList.append(email)
                    }
                    p["emails"] = emailList
                }
                
                if let phones = person.value(forProperty: kABPhoneProperty) {
                    var phoneList = [[String: String]]()
                    for i in 0 ..< ABMultiValueCount(phones as! ABMultiValueRef) {
                        var phone = [String: String]()
                        let labelRef = ABMultiValueCopyLabelAtIndex(phones as! ABMultiValueRef, i)?.takeRetainedValue()
                        phone["label"] = ABCopyLocalizedPropertyOrLabel(labelRef)?.takeRetainedValue() as? String
                        phone["value"] = ABMultiValueCopyValueAtIndex(phones as! ABMultiValueRef, i)?.takeRetainedValue() as? String
                        phoneList.append(phone)
                    }
                    p["phones"] = phoneList
                }
                
                peopleList.append(p)
            }
            callback(peopleList)
        } else {
            fputs("not authorized\n", stderr)
            exit(EXIT_FAILURE)
        }
    }
}

func getContacts(callback: @escaping ([[String: Any]]) -> Void) {
    //    if #available(OSX 10.11, *) {
    //        let contactsCLI = Contacts1011()
    //        contactsCLI.getAllContacts(callback: { contacts in
    //            callback(contacts)
    //        })
    //    } else {
    let contactsCLI = Contacts1010()
    contactsCLI.getAllContacts(callback: { contacts in
        callback(contacts)
    })
    //    }
}

getContacts(callback: { contacts in
    for contact in contacts {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: contact, options: [])
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as! String
            print(jsonString)
        } catch {
            print(error.localizedDescription)
        }
    }
})
