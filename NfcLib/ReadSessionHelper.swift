//
//  ReadSessionHelper.swift
//  NfcLib
//
//  Created by petros maliotis on 04/06/2020.
//  Copyright © 2020 petros maliotis. All rights reserved.
//

import Foundation
import CoreNFC

class ReadSessionHelper: NSObject, NFCNDEFReaderSessionDelegate {
    
    var nfcDelegate: ReadNfc
    var function: (([Any]) -> Void)?
    var functionString: (([String]) -> Void)?
    var invalidateFunction: (NFCNDEFReaderSession, Error) -> Void
    
    init(nfcDelegate: ReadNfc, function: @escaping ([Any]) -> Void, invalidateFunction: @escaping (NFCNDEFReaderSession, Error) -> Void) {
        self.nfcDelegate = nfcDelegate
        self.function = function
        self.invalidateFunction = invalidateFunction
    }
    
    init(nfcDelegate: ReadNfc, function: @escaping ([String]) -> Void, invalidateFunction: @escaping (NFCNDEFReaderSession, Error) -> Void) {
        self.nfcDelegate = nfcDelegate
        self.functionString = function
        self.invalidateFunction = invalidateFunction
    }
    
    /**
     NFCNDEFReaderSessionDelegate callback for session invalidated
     */
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        invalidateFunction(session, error)
    }
    
    /**
     NFCNDEFReaderSessionDelegate callabck to deliver Ndef Messages
     */
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        var results = [Any]()
        var resultsStr = [String]()
        self.nfcDelegate.message = messages[0]
        self.nfcDelegate.records = messages[0].records
        
        for payload in messages[0].records {
            let tnf = payload.typeNameFormat
            let type = payload.type
            let pld = payload.payload
            
            // interpret accordingly
            let re = interpretRecord(tnf: tnf, type: type, payload: pld)
            if re != nil {
                if (function == nil) {
                    var str: String
                    if re is URL {
                        str = (re as! URL).absoluteString
                    } else {
                        str = (re as! String)
                    }
                    resultsStr.append(str)
                } else {
                    results.append(re!)
                }
            }
        }

        // Continue on main thread
        DispatchQueue.main.async {
            if self.function == nil {
                self.functionString!(resultsStr)
            } else {
                self.function!(results)
            }
        }
        
        session.alertMessage = self.nfcDelegate.successMessage ?? "Read NTAG successful."
        session.invalidate()
    }
    
    /**
     interpret record based on TNF type
     */
    func interpretRecord(tnf: NFCTypeNameFormat, type: Data, payload: Data) -> Any? {
        switch tnf {
        case .nfcWellKnown:
            return nfcWellKnownHelper(type: type, payload: payload)
        case .absoluteURI:
            return absoluteURIHelper(payload: payload)
        case .media:
            return mediaHelper(payload: payload)
        case .empty:
            return mediaHelper(payload: payload)
        case .nfcExternal:
            return mediaHelper(payload: payload)
        case .unchanged:
            return unchangedHelper(payload: payload)
        default:
            fatalError("None of the above")
        }
    }
    
    /**
     TNF_WELL_KNOWN has 3 most used recod types "T", "U", "Sp".
     Text, URI, Smart Poster.
     */
    func nfcWellKnownHelper(type: Data, payload: Data) -> Any {
        
        if payload.count < 3 {
            // Abort something went wrong
            return ""
        }
        
        let rtdText: [UInt8] = [0x54]
        let rtdUri: [UInt8] = [0x55]
        let rtdSmartPoster: [UInt8] = [0x53, 0x70]
        
        let rtdTextData = Data(_: rtdText)
        let rtdUriData = Data(_: rtdUri)
        let rtdSmartPosterData = Data(_: rtdSmartPoster)
        
        
        let encoding = payload[0] // 128 == utf16, 2 == utf8
        print(encoding)
        
        switch type {
        case rtdTextData:
            
            let range = 0..<3
            guard let lang = String.init(data: payload.subdata(in: range), encoding: .utf8)
                else {fatalError("lang was not found")}
            // Print lang
            debugPrint(lang)
            let content = String.init(data: payload.advanced(by: 3), encoding: .utf8) ?? ""
            debugPrint(content)
            return content
        case rtdUriData:
            let str = String(data: payload.advanced(by: 1), encoding: .utf8) ?? ""
            return URL(string: str) ?? ""
        case rtdSmartPosterData:
            return ""
        default:
            fatalError("None of the above")
        }
    }
    
    func absoluteURIHelper(payload: Data) -> Any? {
        let str = String(decoding: payload, as: UTF8.self)
        let url = URL(string: str)
        return url
    }
    
    func mediaHelper(payload: Data) -> String {
        // TODO
        return ""
    }
    
    func emptyHelper(payload: Data) -> String {
        return ""
    }
    
    func nfcExternalHelper(payload: Data) -> String {
        // TODO
        return ""
    }
    
    func unchangedHelper(payload: Data) -> String {
        // TODO
        return ""
    }
    
}
