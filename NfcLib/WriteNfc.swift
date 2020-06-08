//
//  WriteNfc.swift
//  NfcLib
//
//  Created by petros maliotis on 04/06/2020.
//  Copyright © 2020 petros maliotis. All rights reserved.
//

import Foundation
import UIKit
import CoreNFC

public class WriteNfc: WriteNfcProtocol {
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    var viewController: UIViewController
    public var nfcSession: NFCNDEFReaderSession?
    var nfcNdefWriteSessionDelegate: WriteSessionHelper?
    
    public var errorMessage: String? = nil
    
    public var successMessage: String? = nil
    
    /**
     # Recomended use
     Show an alert when the invalidation reason is not because of a
     successful read during a single-tag read session, or because the
     user canceled a multiple-tag read session from the UI or
     programmatically using the invalidate method call.
     */
    public var sessionInvalidated: ((NFCNDEFReaderSession, Error) -> Void)? = nil
    
    /**
     # Recomended use
     Show an alert when  the device doesn't support Nfc capabilities to inform the user
     */
    public var nfcNotSupported: (UIViewController) -> Void = { viewCtrl in
        let alertController = UIAlertController(
            title: "Scanning Not Supported",
            message: "This device doesn't support tag scanning.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewCtrl.present(alertController, animated: true, completion: nil)
    }
    
    public var alertMessage: String? = nil
    
    public func begin(message: String, result: @escaping (Bool) -> Void) {
        var payload = Data([0x02, 0x65, 0x6E]) // 0x02 + 'en' (0x02 utf8)
        payload.append(message.data(using: .utf8)!)
        
        let record = NFCNDEFPayload.init(format: NFCTypeNameFormat.nfcWellKnown, type: "T".data(using: .utf8)!, identifier: Data.init(count: 0), payload: payload, chunkSize: 0)
    
        let records = [record]
        let ndefMessage = NFCNDEFMessage(records: records)
        prereqCheck(ndefMssg: ndefMessage, callback: result)
        
    }
    
    public func begin(message: URL, result: @escaping (Bool) -> Void) {
        
        var payload = Data([0x02]) // (0x02 utf8)
        
        payload.append(message.absoluteString.data(using: .utf8)!)
            
        let record = NFCNDEFPayload.init(format: NFCTypeNameFormat.nfcWellKnown, type: "U".data(using: .utf8)!, identifier: Data.init(count: 0), payload: payload, chunkSize: 0)
        
        let records = [record]
        let ndefMessage = NFCNDEFMessage(records: records)
        prereqCheck(ndefMssg: ndefMessage, callback: result)
        
//        guard let record = NFCNDEFPayload.wellKnownTypeURIPayload(url: message) else {
//            result(false)
//            return
//        }
//        let records = [record]
//        let ndefMessage = NFCNDEFMessage(records: records)
//        prereqCheck(ndefMssg: ndefMessage, callback: result)
    }
    
    public func begin(message: Data, result: @escaping (Bool) -> Void) {
        guard let ndefMessage = NFCNDEFMessage(data: message) else {
            result(false)
            return
        }
        prereqCheck(ndefMssg: ndefMessage, callback: result)
    }
    
    public func begin(ndefMessage: NFCNDEFMessage, result: @escaping (Bool) -> Void) {
        prereqCheck(ndefMssg: ndefMessage, callback: result)
    }
    
    
    
    func prereqCheck(ndefMssg: NFCNDEFMessage, callback: @escaping (Bool) -> Void) {
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
        nfcNdefWriteSessionDelegate = WriteSessionHelper(nfcDelegate: self, ndefMessage: ndefMssg, function: callback, invalidateFunction: sessionInv)
        
        // CoreNFC func to init Nfc functionality and show alert
        nfcSession = NFCNDEFReaderSession.init(delegate: nfcNdefWriteSessionDelegate!, queue: nil, invalidateAfterFirstRead: false)
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
    
}
