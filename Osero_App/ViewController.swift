//
//  ViewController.swift
//  Osero_App
//
//  Created by t032fj on 2022/01/26.
//

import UIKit
import SceneKit
import ARKit
import SnapKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    private let uiButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .lightGray
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.setTitle("Setup", for: .normal)
        button.titleLabel?.tintColor = .black
        return button
    }()
    
    private let othelloButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .lightGray
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.setTitle("othello", for: .normal)
        button.titleLabel?.tintColor = .black
        return button
    }()
    
    let tagetPlane: SCNPlane = {
        let plane = SCNPlane(width: 0.02, height: 0.02)
        plane.cornerRadius = 1
        plane.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.8)
        return plane
    }()
    
    var targetNode: SCNNode?
    var currentPos = float3(0, 0, 0)
    
    var screenCenter: CGPoint {
        let bounds = sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    let boardscene = SCNScene(named: "art.scnassets/board.scn")
    var boardNode = SCNNode()
    
    let othelloScene = SCNScene(named: "art.scnassets/othello.scn")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        setupLayout()
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    private func setupLayout() {
        
        sceneView.addSubview(uiButton)
        sceneView.addSubview(othelloButton)
        
        uiButton.addTarget(self, action: #selector(self.tapButton(_ :)), for: .touchUpInside)
        uiButton.snp.makeConstraints { make in
            
            make.size.equalTo(100)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(sceneView.snp.bottom).offset(-100)
        }
        
        othelloButton.snp.makeConstraints { make in
            
            make.size.equalTo(100)
            make.right.equalTo(uiButton.snp.left).offset(-30)
            make.bottom.equalTo(sceneView.snp.bottom).offset(-100)
        }
        
        boardNode = (self.boardscene?.rootNode.childNode(withName: "board", recursively: false))!
        boardNode.name = "board"
        
        targetNode = SCNNode(geometry: tagetPlane)
        targetNode?.name = "target"
        targetNode?.isHidden = true
        targetNode?.eulerAngles.x = -Float.pi / 4
        
        sceneView.scene.rootNode.addChildNode(targetNode!)
    }
    
    @objc func tapButton(_ sender: UIButton){
            
        boardNode = (boardscene?.rootNode.childNode(withName: "board", recursively: false))!
        boardNode.position = SCNVector3(self.currentPos.x, self.currentPos.y, self.currentPos.z)
        boardNode.eulerAngles.y = -Float.pi / 2
        
        sceneView.scene.rootNode.addChildNode(boardNode)
    }

    private func addTable(hitResult: ARHitTestResult) {

        let (min, max) = (boardNode.boundingBox)
        let w = CGFloat(max.x - min.x)
        //        let magnification = 0.1 / w // 幅を1.5mにした場合の縮尺を計算
        //        boardNode.scale = SCNVector3(magnification, magnification, magnification)
//        boardNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,
//                                        hitResult.worldTransform.columns.3.y,
//                                        hitResult.worldTransform.columns.3.z)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        
        let touchPos = touch.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(touchPos, types: .existingPlaneUsingExtent)
        
        if !hitTestResult.isEmpty {
            
            if let hitResult = hitTestResult.first {
                
                addTable(hitResult: hitResult)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        targetNode?.isHidden = false
        
        //        guard let planeAnchor = anchor as? ARPlaneAnchor else {fatalError()}
        //        // ノード作成
        //        let planeNode = SCNNode()
        //        // ジオメトリの作成する
        //        let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x),
        //                                height: CGFloat(planeAnchor.extent.z))
        //        geometry.materials.first?.diffuse.contents = UIColor.red.withAlphaComponent(0.8)
        //
        //        // ノードにGeometryとTransformを指定
        //        planeNode.geometry = geometry
        //        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        //
        //        node.addChildNode(planeNode)
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        DispatchQueue.main.async {
            
            let results = self.sceneView.hitTest(self.screenCenter, types: [.existingPlaneUsingGeometry])
            
            if let exisitingPlaneUsingGeometryResult = results.first(where: {$0.type == .existingPlaneUsingGeometry}) {
                
                let result = exisitingPlaneUsingGeometryResult
                self.currentPos = float3(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
                self.targetNode?.position = SCNVector3(self.currentPos.x, self.currentPos.y, self.currentPos.z)
            }
        }
    }
}
