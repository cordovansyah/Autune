//
//  SceneObject.swift
//  Avatar
//
//  Created by Cordova Putra on 04/02/19.
//  Copyright © 2019 Cordova Putra. All rights reserved.
//

import Foundation
import SceneKit
import ARKit



class SceneObject: SCNNode {
    
    init(from file: String) {
        super.init()
        
        let nodesInFile = SCNNode.allNodes(from: file)
        nodesInFile.forEach { (node) in
            self.addChildNode(node)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Sphere: SceneObject {
    
    var animating: Bool = false
    
    func animate() {
        
        if animating { return }
        animating = true
        
        let rotateOne = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi * 10), z: 0, duration: 5.0)
        let repeatForever = SCNAction.repeatForever(rotateOne)
        
        runAction(repeatForever)
    }
    
    func stopAnimating() {
        removeAllActions()
        animating = false
    }
    
    init() {
        super.init(from: "sphere.dae")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
