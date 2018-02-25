//
//  ViewContainer.swift
//  iPhoneDragAndDropApp
//
//  Created by Imanou on 24/02/2018.
//  Copyright © 2018 Imanou. All rights reserved.
//

import MobileCoreServices
import UIKit

enum ViewContainerError: Error {
    case invalidType, unarchiveFailure
}

class ViewContainer: NSObject {
    
    let view: UIView
    
    required init(view: UIView) {
        self.view = view
    }
    
}

extension ViewContainer: NSItemProviderReading {
    
    static var readableTypeIdentifiersForItemProvider = [kUTTypeData as String]
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        if typeIdentifier == kUTTypeData as String {
            guard let view = NSKeyedUnarchiver.unarchiveObject(with: data) as? UIView else { throw ViewContainerError.unarchiveFailure }
            return self.init(view: view)
        } else {
            throw ViewContainerError.invalidType
        }
    }
    
}

extension ViewContainer: NSItemProviderWriting {
    
    static var writableTypeIdentifiersForItemProvider = [kUTTypeData as String]
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        if typeIdentifier == kUTTypeData as String {
            let data = NSKeyedArchiver.archivedData(withRootObject: view)
            completionHandler(data, nil)
        } else {
            completionHandler(nil, ViewContainerError.invalidType)
        }
        return nil
    }
    
}
