//
//  NfcFactory.swift
//  NfcLib
//
//  Created by petros maliotis on 04/06/2020.
//  Copyright © 2020 petros maliotis. All rights reserved.
//

import Foundation
import UIKit

public class NfcFactory<T: NfcDelegate> {
    
    /**
     Meant to be overriden by subclasses.
     - parameter viewController: The viewController where the alert will show
     - returns: the correct Nfc type: ReadNfc, WriteNfc
     */
    func getNfc(viewController: UIViewController) -> T {
        // TODO
        return ReadNfc(viewController: viewController) as! T
    }
    
    /**
     Create Nfc reader or writer using the Factory deisgn pattern
     - parameters:
     - typeOf: The type of Nfc: ReadNfc or WriteNfc
     - viewController: The viewController where the alert will show
     */
    public static func create<T: NfcDelegate>(viewController: UIViewController) -> T {
        
        switch T.self {
        case is ReadNfc.Type:
            return ReadNfcFactory().getNfc(viewController: viewController) as! T
        case is WriteNfc.Type:
            return WriteNfcFactory().getNfc(viewController: viewController) as! T
        default:
            fatalError("None of the above")
        }
    }
    
    
}
