//
//  WriteNfcFactory.swift
//  NfcLib
//
//  Created by petros maliotis on 04/06/2020.
//  Copyright © 2020 petros maliotis. All rights reserved.
//

import Foundation
import UIKit

public class WriteNfcFactory: NfcFactory<WriteNfc> {
    override func getNfc(viewController: UIViewController) -> WriteNfc {
        return WriteNfc(viewController: viewController)
    }
    
}
