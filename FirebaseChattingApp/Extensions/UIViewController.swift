//
//  UIViewController.swift
//  FirebaseChattingApp
//
//  Created by Sidra Jabeen on 18/08/2021.
//

import Foundation
import UIKit

let spinnerView = SpinnerViewController()

extension UIViewController {
    
    func startAnimation() {
        
        addChild(spinnerView)
        spinnerView.view.frame = view.frame
        view.addSubview(spinnerView.view)
        spinnerView.didMove(toParent: self)
    }
    
//    func stopAnimation() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            spinnerView.willMove(toParent: nil)
//            spinnerView.view.removeFromSuperview()
//            spinnerView.removeFromParent()
//        }
//    }
}
