//
//  othelloModel.swift
//  Osero_App
//
//  Created by t032fj on 2022/01/28.
//

import Foundation
import UIKit
import ARKit

class OthelloModel: SCNNode {
    
    override init() {
        super.init()
        
        self.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        self.name = "othello"
        self.scale = SCNVector3(0.007, 0.0007, 0.007)
        self.eulerAngles.z = -Float.pi
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
