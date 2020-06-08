//
//  ReadNfcProtocol.swift
//  NfcLib
//
//  Created by petros maliotis on 05/06/2020.
//  Copyright © 2020 petros maliotis. All rights reserved.
//

import Foundation
import CoreNFC

public protocol ReadNfcProtocol: NfcDelegate {
    /**
     Begin the Nfc Reader Session and call the callback closure to deliver the results
     back to the caller
     - parameter callback: Handle th results from reading the tag
     */
    func begin(callback: @escaping ([Any]) -> Void)
    
    /**
     Begin the Nfc Reader Session and call the callback closure to deliver the results
     back to the caller
     - parameter callback: Handle th results from reading the tag
     */
    func begin(callback: @escaping ([String]) -> Void)
    
    /**
     The message from the scanned NTAG
     */
    var message: NFCNDEFMessage? { get set }
    
    /**
     The records from the scanned NTAG
     */
    var records: [NFCNDEFPayload]? { get set }
}
