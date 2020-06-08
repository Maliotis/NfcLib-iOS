//
//  WriteNFCProtocol.swift
//  NfcLib
//
//  Created by petros maliotis on 05/06/2020.
//  Copyright © 2020 petros maliotis. All rights reserved.
//

import Foundation
import CoreNFC

public protocol WriteNfcProtocol: NfcDelegate {
        
    /**
     Write the [message](message) with type name format TNF_WELL_KNOWN and record type
     RTD_TEXT to the scanned NTAG  and return the result
     to the caller with the closure [result](result)
     
     Tnf and record type will default to the above values if they are not overriden.
     */
    func begin(message: String, result: @escaping (Bool) -> Void)
    
    /**
     Write the [message](message) with type name format TNF_WELL_KNOWN and record type
     RTD_URI to the scanned NTAG  and return the result
     to the caller with the closure [result](result)
     
     Note: only override tnf to AbsoluteURI
     */
    func begin(message: URL, result: @escaping (Bool) -> Void)
    
    /**
     Write the [message](message) with type name format TNF_WELL_KNOWN and record type
     RTD_TEXT to the scanned NTAG and return the result
     to the caller with the closure [result](result)
     
     Tnf and record type will default to the above values if they are not overriden.
     */
    func begin(message: Data, result: @escaping (Bool) -> Void)
    
    /**
     Write [ndefMessage](ndefMessage) to the scanned NTAG
     
     Note: all records have to be defined with the correct values
     */
    func begin(ndefMessage: NFCNDEFMessage, result: @escaping (Bool) -> Void)
    
}
