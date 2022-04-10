//
//  RangeTimeSlider.swift
//  Audio
//
//  Created by haiphan on 18/09/2021.
//

import Foundation

struct RangeTimeSlider {
    let start: Float64
    let end: Float64
    init(start: Float64, end: Float64) {
        self.start = start
        self.end = end
    }
    
    static let empty: RangeTimeSlider = RangeTimeSlider(start: 0, end: 0)
}
