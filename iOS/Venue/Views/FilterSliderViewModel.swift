/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// This class represents the view model for a slider filter view
class FilterSliderViewModel: NSObject {
    
    var filterTitle: String!
    private var unitLabel: String!
    var minimumValue: Int!
    var maximumValue: Int!
    private var stepAmount: Int!
    dynamic var currentValue: NSNumber!
    
    var minimumValueText: String { return String(minimumValue) + unitLabel }
    var maximumValueText: String { return String(maximumValue) + unitLabel }
    var currentValueText: String { return currentValue.stringValue + unitLabel }
    
    var acceptedValues : [Int] = []

    required init(filterTitle: String, unitLabel: String, minimumValue: Int, maximumValue: Int, stepAmount: Int, startingValue: Int) {
        super.init()
        
        self.filterTitle = filterTitle
        self.unitLabel = unitLabel
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.stepAmount = stepAmount
        self.currentValue = startingValue
        self.calculateAcceptedValues()
    }
    
    /**
    Based on the minimum, maximum, and step amount values, this calculates the number of accepted values on the slider
    */
    private func calculateAcceptedValues() {
        for var i = minimumValue; i <= maximumValue; i = i + self.stepAmount {
            acceptedValues.append(i)
        }
    }
    
    /**
    Based on the current amount, round to the nearest accepted value
    
    - parameter value: The current value of the slider
    */
    func updateCurrentAmount(value: Float) {
        let roundedValue = Int(floor(value))
        let remainder = roundedValue % stepAmount
        let middleValue = stepAmount / 2
        if remainder <= middleValue {
            currentValue = roundedValue - remainder
        } else {
            currentValue = roundedValue + stepAmount - remainder
        }
    }
}
