/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/


import Foundation

/// ViewController to show the content of the onboarding tutorial
class OnboardingContentViewController: UIViewController {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var onboardingImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var itemIndex: Int = 0
    var titleText = "" {
        didSet {
            if let titleLabel = titleLabel {
                titleLabel.text = titleText
            }
        }
    }
    var descriptionText = "" {
        didSet {
            if let descriptionLabel = descriptionLabel {
                descriptionLabel.text = descriptionText
            }
        }
    }
    var imageName = "" {
        didSet {
            if let onboardingImageView = onboardingImageView {
                onboardingImageView.image = UIImage(named: imageName)
            }
        }
    }
    
    override func viewDidLoad() {
        titleLabel.text = titleText
        descriptionLabel.text = descriptionText
        onboardingImageView.image = UIImage(named: imageName)
    }
}