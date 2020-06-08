//
//  NfcDelegate.swift
//  NfcLib
//
//  Created by petros maliotis on 04/06/2020.
//  Copyright © 2020 petros maliotis. All rights reserved.
//

import Foundation
import UIKit
import CoreNFC

public protocol NfcDelegate {
    /**
     Use this variable to change the Nfc alert message
     */
    var alertMessage: String? { get set }
    
    var errorMessage: String? { get set }
    var successMessage: String? { get set }
    
    var nfcSession: NFCNDEFReaderSession? { get set }
    
    /**
    Override [sessionInvalidated](self.sessionInvalidated) to implement your own behavior
    when the session invalidates.
    */
    var sessionInvalidated: ((NFCNDEFReaderSession, Error) -> Void)? { get set }
    
    /**
     Override [nfcNotSupported](self.nfcNotSupported) to implement your own behavior when the device
     doesn't support Nfc capabilities.
     */
    var nfcNotSupported: (UIViewController) -> Void { get set }
    
    /**
    End the Nfc session
    */
    func end()
    
    /**
     End the Nfc Session
     - parameter message: Message to appear in alert
     */
    func end(message: String, delay: Double)
    
    
}
