//
//  ChipInModel.swift
//  ChipInCalculator
//
//  Created by igor Kovrizhkin on 6/16/14.
//  Copyright (c) 2014 IgorKovrizhkin. All rights reserved.
//

import Foundation


class ChipInModel {
    var time    : Double
    var hourCost: Double

    init(time :Double , hourCost:Double){
        self.time = time
        self.hourCost = hourCost
    }

    var total: Double {
        get {
            return time * hourCost;
        }
    }

    func splitFor(personNumber:Int) -> Double {
        return (total / Double(personNumber))
    }
    
}
