//
//  EnemyStrongPlayer.swift
//  Osero_App
//
//  Created by t032fj on 2022/02/06.
//

import UIKit

class EnemyStrongPlayer {
    
    let enemyAvailableAreaArray: [[Int]]?
    var arrayCount: Int
    var boardCountSituation: [[Int]]?
    var countArray: [Int] = []
    //初期値を取得
    init(_availableAreaArray: [[Int]], _boardCountSituation: [[Int]]) {
        
        enemyAvailableAreaArray = _availableAreaArray
        arrayCount = enemyAvailableAreaArray!.count
        boardCountSituation = _boardCountSituation
    }
    
    func makingSetupPoint() -> [Int] {
        
        guard let enemyAvailableAreaArray = enemyAvailableAreaArray else {
            return []
        }
        guard let boardCountSituation = boardCountSituation else {
            return []
        }
        
        for array in enemyAvailableAreaArray {
            
            let count = boardCountSituation[array[0]][array[1]]
            countArray.append(count)
        }
        
        let maxCount: Int = (countArray.max())!
        let maxIndex: Int = (countArray.firstIndex(of: maxCount))!
        let selectPositon: [Int] = enemyAvailableAreaArray[maxIndex]
        
        return selectPositon
    }
}
