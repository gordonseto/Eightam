//
//  User.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-23.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import Foundation

class User {
    private var _uid: String!
    
    var uid: String! {
        return _uid
    }
    
    init(uid: String!) {
        _uid = uid
    }
}