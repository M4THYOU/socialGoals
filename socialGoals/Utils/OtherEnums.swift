//
//  OtherEnums.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-25.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit

enum InviteButtonStatus {
    case pending // invitation has been sent
    case circle // already in the same circle
    case none // no invitation has been sent and not in circle.
    case unknown // still waiting for the db request to finish
}
