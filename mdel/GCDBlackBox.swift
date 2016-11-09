//
//  GCDBlackBox.swift
//  OnTheMap
//
//  Created by Mohammed Ibrahim on 10/25/16.
//  Copyright © 2016 myw. All rights reserved.
//

import Foundation
func performUIUpdatesOnMain(updates: @escaping () -> Void)
{
    DispatchQueue.main.async {
        updates()
}
}
