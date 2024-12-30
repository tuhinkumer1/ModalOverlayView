//
//  ViewController.swift
//  ModalOverlayView
//
//  Created by tuhin on 30/12/24.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {
    
    private var fullScreenButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Call setup methods
        setupButton()
        layoutButton()
    }
    
    // Method to initialize and configure the button
    private func setupButton() {
        fullScreenButton = UIButton(type: .system)
        fullScreenButton.setTitle("Tap Me", for: .normal)
        fullScreenButton.setTitleColor(.white, for: .normal)
        fullScreenButton.backgroundColor = .systemBlue
        fullScreenButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    // Method to set the button's layout
    private func layoutButton() {
        fullScreenButton.frame = view.bounds
        fullScreenButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(fullScreenButton)
    }
    
    // Action for the button
    @objc private func buttonTapped() {
        print("Full-screen button was tapped!")
        presentFeedbackView(identifier: "")
    }
}
extension ViewController {
    private func presentFeedbackView(identifier: String) {
        let feedbackView = FeedbackView(delegate: self)
        let hostingController = UIHostingController(rootView: feedbackView)
        hostingController.view.backgroundColor = .clear
        hostingController.modalPresentationStyle = .overCurrentContext
        present(hostingController, animated: true, completion: nil)
    }
}


extension ViewController: FeedbackDelegate {
    
    func didSubmitFeedback(option: FeedbackOption, comment: String?) {
        dismiss(animated: true, completion: {
            // Handle the feedback data as needed
            print("Feedback submitted: \(option.rawValue), comment: \(comment ?? "None")")
        })
    }
}

