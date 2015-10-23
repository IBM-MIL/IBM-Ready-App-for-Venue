/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// This class represents a UISlider that is used as a filter
class FilterSliderView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var sliderTitleLabel: UILabel!
    @IBOutlet weak var minimumSliderLabel: UILabel!
    @IBOutlet weak var maximumSliderLabel: UILabel!
    @IBOutlet weak var currentSliderLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var currentLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var middleTickMark: UIView!
    
    let largeTickHeight: CGFloat = 12
    private var tickMarks: [UIView] = []
    
    weak var viewModel: FilterSliderViewModel? {
        didSet {
            self.updateFilterSettings()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Load the view and set constraints
        NSBundle.mainBundle().loadNibNamed("FilterSliderView", owner: self, options: nil)
        self.addSubview(self.view)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["view": self, "newView": self.view]
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[newView]|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views)
        self.addConstraints(horizontalConstraints)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[newView]|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: views)
        self.addConstraints(verticalConstraints)
        
        self.setupFilterView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Make sure everything is aligned correctly
        self.viewModel!.updateCurrentAmount(self.slider.value)
        self.updateCurrentSliderLabel()
    }
    
    /**
    Updates the slider label and subscribes to a change in the slider value
    */
    func setupFilterView() {
        updateCurrentSliderLabel()
        
        slider.continuous = true
        slider.rac_signalForControlEvents(UIControlEvents.ValueChanged).subscribeNext() { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            // When the slider updates, update the current value in the view model and update the current label
            strongSelf.viewModel!.updateCurrentAmount(self!.slider.value)
            strongSelf.updateCurrentSliderLabel()
        }
    }
    
    /**
    Update slider label position based on the position of the tracking thumb image
    */
    func updateCurrentSliderLabel() {
        self.currentLabelLeftConstraint.constant = self.xPositionSliderThumbImage(self.slider)
        self.view.updateConstraints()
    }
    
    /**
    Calculates the x position of the thumb tracking image on the slider
    
    - returns: The x coordinate
    */
    func xPositionSliderThumbImage(slider : UISlider) -> CGFloat {
        let thumbWidth = slider.currentThumbImage!.size.width
        let sliderRange = slider.frame.size.width - thumbWidth
        let percentage = (slider.value - slider.minimumValue) / (slider.maximumValue - slider.minimumValue)
        let thumbOrigin = slider.frame.origin.x  - ((thumbWidth / 2) * CGFloat((1.0 - percentage)))
        let centerValue = ((percentage) * Float(sliderRange)) + Float(thumbOrigin) + 3
        
        return CGFloat(centerValue)
    }
    
    /**
    Updates all of the text and views on the slider view
    */
    func updateFilterSettings() {
        guard let vm = viewModel else {
            return
        }
        
        sliderTitleLabel.text = vm.filterTitle
        minimumSliderLabel.text = NSLocalizedString("Off", comment: "")
        maximumSliderLabel.text = vm.maximumValueText
        currentSliderLabel.text = vm.currentValueText
        slider.minimumValue = Float(vm.minimumValue)
        slider.maximumValue = Float(vm.maximumValue)
        slider.setValue(Float(vm.currentValue), animated: true)
        
        let numTickMarks = self.viewModel!.acceptedValues.count
        // Determine if there is a no middle mark, hide it
        if (numTickMarks % 2) == 0 {
            middleTickMark.hidden = true
        }
        
        // Observe when the current value of the view model changes and updates labels accordingly.
        RACObserve(self.viewModel!, keyPath: "currentValue").subscribeNextAs() { [weak self] (currentValue : NSNumber) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.slider.setValue(currentValue.floatValue, animated: true)
            
            if vm.currentValue.integerValue <= vm.minimumValue {
                strongSelf.currentSliderLabel.text = NSLocalizedString("Off", comment: "")
            } else {
                strongSelf.currentSliderLabel.text = self!.viewModel!.currentValueText
            }
        }
    }
}
