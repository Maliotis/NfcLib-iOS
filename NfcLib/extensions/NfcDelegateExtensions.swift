//
//  NfcDelegateExtensions.swift
//  NfcLib
//
//  Created by petros maliotis on 05/06/2020.
//  Copyright © 2020 petros maliotis. All rights reserved.
//

import Foundation
import UIKit
import CoreNFC

extension NfcDelegate {
    
    public func end() {
        nfcSession?.invalidate()
    }
    
    public func end(message: String, delay: Double) {
        nfcSession?.alertMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.nfcSession?.invalidate()
        }
    }
    
}
