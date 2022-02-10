//
//  EnemyPlayer.swift
//  Osero_App
//
//  Created by t032fj on 2022/02/06.
//

import UIKit

class EnemyPlayer {
    
    let enemyAvailableAreaArray: [[Int]]?
    var arrayCount: Int
    //初期値を取得
    init(availableAreaArray: [[Int]]) {
        
        enemyAvailableAreaArray = availableAreaArray
        arrayCount = enemyAvailableAreaArray!.count
    }

    //置く場所を返す
    func Random() -> [Int] {
        
        let int = Int.random(in: 0..<arrayCount)
        return (enemyAvailableAreaArray?[int])!
    }
}
