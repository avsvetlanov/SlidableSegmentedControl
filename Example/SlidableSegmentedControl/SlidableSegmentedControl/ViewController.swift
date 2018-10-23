//
//  ViewController.swift
//  SlidableSegmentedControl
//
//  Created by Владимир Светланов on 23/10/2018.
//  Copyright © 2018 Svetlanov Vladimir. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SlidableSegmentedControlDelegate {

    @IBOutlet weak var segmentedControl: SlidableSegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.delegate = self
        segmentedControl.insertSegment(withTitle: "First", at: 0)
        segmentedControl.insertSegment(withTitle: "Second", at: 1)
        segmentedControl.insertSegment(withTitle: "Third", at: 2)
    }

    @IBAction func didClickInsert(_ sender: Any) {
        segmentedControl.insertSegment(withTitle: "New", at: 0)
    }
    
    @IBAction func didClickRemove(_ sender: Any) {
        segmentedControl.removeSegment(at: 0)
    }
    
    // MARK: SlidableSegmentedControlDelegate
    func didSelectSegment(sender: SlidableSegmentedControl) {
        print("Selected segment: ", sender.selectedSegmentIndex)
    }
}

