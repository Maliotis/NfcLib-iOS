//
//  ReadNfcFactory.swift
//  NfcLib
//
//  Created by petros maliotis on 04/06/2020.
//  Copyright © 2020 petros maliotis. All rights reserved.
//

import Foundation
import UIKit

public class ReadNfcFactory: NfcFactory<ReadNfc> {
    
    override func getNfc(viewController: UIViewController) -> ReadNfc? {
        return ReadNfc(viewController: viewController)
    }
}
