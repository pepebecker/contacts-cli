//
//  main.swift
//  contacts-cli
//
//  Created by Pepe Becker on 01/12/2016.
//  Copyright © 2016 Pepe Becker. All rights reserved.
//

import Foundation
import Contacts

func createField(key: String, value: String, quoted: Bool = true) -> String {
    var field = ""
    if !key.isEmpty && !value.isEmpty {
        if quoted {
            field = "\"\(key)\": \"\(value)\""
        } else {
            field = "\"\(key)\": \(value)"
        }
    }
    return field
}

func addField(fields: inout [String], field: String) -> Void {
    if !field.isEmpty {
        fields.append(field)
    }
}

func outputAllContacts(store: CNContactStore) -> Void {
    let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactOrganizationNameKey, CNContactEmailAddressesKey, CNContactPhoneNumbersKey]
    
    var allContainers: [CNContainer] = []
    do {
        allContainers = try store.containers(matching: nil)
    } catch {
        print("Error fetching containers", error)
    }
    
    for container in allContainers {
        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
        
        do {
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as [CNKeyDescriptor])
            
            for contact in contacts {
                var fields = [String]()
                
                addField(fields: &fields, field: createField(key: "firstName", value: contact.givenName))
                addField(fields: &fields, field: createField(key: "lastName", value: contact.familyName))
                addField(fields: &fields, field: createField(key: "organization", value: contact.organizationName))
                
                // Emails
                
                var emails = [String]()
                for email in contact.emailAddresses {
                    var emailFields = [String]()
                    let localizedLabel = CNLabeledValue<NSString>.localizedString(forLabel: email.label!)
                    addField(fields: &emailFields, field: createField(key: "label", value: localizedLabel))
                    addField(fields: &emailFields, field: createField(key: "value", value: email.value as String))
                    let emailLine = "{\(emailFields.joined(separator: ", "))}"
                    emails.append(emailLine)
                }
                
                if emails.count > 0 {
                    addField(fields: &fields, field: createField(key: "emails", value: "[\(emails.joined(separator: ", "))]", quoted: false))
                }
                
                // Phone Numbers
                
                var phoneNumbers = [String]()
                for number in contact.phoneNumbers {
                    var numberFields = [String]()
                    let localizedLabel = CNLabeledValue<NSString>.localizedString(forLabel: number.label!)
                    addField(fields: &numberFields, field: createField(key: "label", value: localizedLabel))
                    addField(fields: &numberFields, field: createField(key: "value", value: number.value.stringValue))
                    let numberLine = "{\(numberFields.joined(separator: ", "))}"
                    phoneNumbers.append(numberLine)
                }
                
                if phoneNumbers.count > 0 {
                    addField(fields: &fields, field: createField(key: "phones", value: "[\(phoneNumbers.joined(separator: ", "))]", quoted: false))
                }
                
                let line = "{\(fields.joined(separator: ", "))}"
                print(line)
            }
        } catch {
            print("Error fetching contacts", error)
        }
    }
}

let store = CNContactStore()

switch CNContactStore.authorizationStatus(for: .contacts){
case .authorized:
    outputAllContacts(store: store)
case .notDetermined:
    store.requestAccess(for: .contacts){succeeded, err in
        guard err == nil && succeeded else {
            return
        }
        outputAllContacts(store: store)
    }
default:
    print("not authorized")
}
