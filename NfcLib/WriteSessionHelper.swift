//
//  WriteSessionHelper.swift
//  NfcLib
//
//  Created by petros maliotis on 05/06/2020.
//  Copyright © 2020 petros maliotis. All rights reserved.
//

import Foundation
import CoreNFC

class WriteSessionHelper: NSObject, NFCNDEFReaderSessionDelegate {
    
    var nfcDelegate: WriteNfc
    var ndefMessage: NFCNDEFMessage
    var function: (Bool) -> Void
    var invalidateFunction: (NFCNDEFReaderSession, Error) -> Void
    var errorMessage: String?
    var successMessage: String?
    
    init(nfcDelegate: WriteNfc, ndefMessage: NFCNDEFMessage, function: @escaping (Bool) -> Void, invalidateFunction: @escaping (NFCNDEFReaderSession, Error) -> Void) {
        self.nfcDelegate = nfcDelegate
        self.ndefMessage = ndefMessage
        self.invalidateFunction = invalidateFunction
        self.function = function
        self.errorMessage = self.nfcDelegate.errorMessage
        self.successMessage = self.nfcDelegate.successMessage
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        invalidateFunction(session, error)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // empty
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        // Make sure we only scanned one tag.
        if tags.count > 1 {
            // Restart polling in 500 milliseconds.
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than 1 tag is detected. Please remove all tags and try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }
        
        // Connect to the found tag and wrtie an NDEF message to it.
        let tag = tags.first!
        session.connect(to: tag, completionHandler: { (error: Error?) in
            if nil != error {
                session.alertMessage = self.errorMessage ?? "Unable to connect to tag."
                session.invalidate()
                self.callFunctionFromMain(false)
            }
            
            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                guard error == nil else {
                    session.alertMessage = self.errorMessage ?? "Unable to query the NDEF status of tag."
                    session.invalidate()
                    self.callFunctionFromMain(false)
                    return
                }

                switch ndefStatus {
                case .notSupported:
                    session.alertMessage = self.errorMessage ?? "Tag is not NDEF compliant."
                    session.invalidate()
                    self.callFunctionFromMain(false)
                case .readOnly:
                    session.alertMessage = "Tag is read only."
                    session.invalidate()
                    self.callFunctionFromMain(false)
                case .readWrite:
                    tag.writeNDEF(self.ndefMessage, completionHandler: { (error: Error?) in
                        if nil != error {
                            session.alertMessage = self.errorMessage ?? "Write NDEF message fail: \(error!)"
                            self.callFunctionFromMain(false)
                        } else {
                            session.alertMessage = self.successMessage ?? "Write NDEF message successful."
                            self.callFunctionFromMain(true)
                        }
                        session.invalidate()
                    })
                @unknown default:
                    session.alertMessage = self.errorMessage ?? "Unknown NDEF tag status."
                    session.invalidate()
                    self.callFunctionFromMain(false)
                }
            })
        })
    }
    
    private func callFunctionFromMain(_ b: Bool) {
        DispatchQueue.main.async {
            self.function(b)
        }
    }
    
    
}
