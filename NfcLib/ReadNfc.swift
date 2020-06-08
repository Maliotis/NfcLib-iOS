//
//  ReadNfc.swift
//  NfcLib
//
//  Created by petros maliotis on 04/06/2020.
//  Copyright © 2020 petros maliotis. All rights reserved.
//

import Foundation
import CoreNFC
import UIKit

public class ReadNfc: ReadNfcProtocol {
        
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    public var nfcSession: NFCNDEFReaderSession?
    var nfcNdefReadSessionDelegate: ReadSessionHelper? = nil
    var viewController: UIViewController
    
    public var message: NFCNDEFMessage?
    
    public var records: [NFCNDEFPayload]?
    
    public var alertMessage: String? = nil
    
    public var errorMessage: String? = nil
    
    public var successMessage: String? = nil
    
    public var sessionInvalidated: ((NFCNDEFReaderSession, Error) -> Void)? = nil
    
    public var nfcNotSupported: (UIViewController) -> Void = { viewCtrl in
        let alertController = UIAlertController(
            title: "Scanning Not Supported",
            message: "This device doesn't support tag scanning.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewCtrl.present(alertController, animated: true, completion: nil)
    }

    
    /**
     Begin the Nfc session and get ready to scan NTAGs for reading only.
     - parameter callback: The callback given by the caller of this function to handle the results (content) of the NTAG.
     */
    public func begin(callback: @escaping ([Any]) -> Void) {
        
        // check the device for Nfc hardware support
        guard NFCNDEFReaderSession.readingAvailable else {
            nfcNotSupported(viewController)
            return
        }
        
        if sessionInvalidated == nil {
            initSessionInvalidated()
        }
        
        // unwrap closure
        let sessionInv = sessionInvalidated!
        // create delegate
        nfcNdefReadSessionDelegate = ReadSessionHelper(nfcDelegate: self, function: callback, invalidateFunction: sessionInv)
        
        // CoreNFC func to init Nfc functionality and show alert
        nfcSession = NFCNDEFReaderSession.init(delegate: nfcNdefReadSessionDelegate!, queue: nil, invalidateAfterFirstRead: false)
        if self.alertMessage != nil {
            nfcSession?.alertMessage = self.alertMessage!
        }
        nfcSession?.begin()
    }
    
    /**
     Begin the Nfc session and get ready to scan NTAGs for reading only.
     - parameter callback: The callback given by the caller of this function to handle the results (content) of the NTAG.
     */
    public func begin(callback: @escaping ([String]) -> Void) {
        // check the device for Nfc hardware support
        guard NFCNDEFReaderSession.readingAvailable else {
            nfcNotSupported(viewController)
            return
        }
        
        if sessionInvalidated == nil {
            initSessionInvalidated()
        }
        
        // unwrap closure
        let sessionInv = sessionInvalidated!
        // create delegate
        nfcNdefReadSessionDelegate = ReadSessionHelper(nfcDelegate: self, function: callback, invalidateFunction: sessionInv)
        
        // CoreNFC func to init Nfc functionality and show alert
        nfcSession = NFCNDEFReaderSession.init(delegate: nfcNdefReadSessionDelegate!, queue: nil, invalidateAfterFirstRead: false)
        if self.alertMessage != nil {
            nfcSession?.alertMessage = self.alertMessage!
        }
        nfcSession?.begin()
    }
    
    /**
     Initializes the [sessionInvalidated](self.sessionInvalidated) closure if it's nil
     */
    fileprivate func initSessionInvalidated() {
        self.sessionInvalidated = { [unowned self] (session, error) in
            if let readerError = error as? NFCReaderError {
            // Show an alert when the invalidation reason is not because of a
            // successful read during a single-tag read session, or because the
            // user canceled a multiple-tag read session from the UI or
            // programmatically using the invalidate method call.
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                let alertController = UIAlertController(
                    title: "Session Invalidated",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    DispatchQueue.main.async {
                        self.viewController.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    /**
     Show alert
     */
    @available(*, deprecated, message: "Use nfcNotSupported closure.")
    fileprivate func showNfcNotSupportedAlert() {
        let alertController = UIAlertController(
            title: "Scanning Not Supported",
            message: "This device doesn't support tag scanning.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    
}
