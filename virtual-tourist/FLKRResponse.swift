//
//  FLKRResponse.swift
//  virtual-tourist
//
//  Created by Danilo Gomes on 10/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

struct FLKRResponse {
    let success : Bool
    
    // Error mode.
    let errorMessage : String?
    
    // Success mode
    let pictures : [FLKRPicture]?
    let page : Int32
    let numberOfPages : Int32
    
    init(errorMessage : String) {
        self.errorMessage = errorMessage
        self.success = false
        self.pictures = nil
        self.page = 0
        self.numberOfPages = 0
    }
    
    init(pictures : [FLKRPicture], page: Int32, numberOfPages: Int32) {
        self.pictures = pictures
        self.success = true
        self.errorMessage = nil
        self.page = page
        self.numberOfPages = numberOfPages
    }
}
