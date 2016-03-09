//
//  TouchDownGestureRecognizer.swift
//  Treader
//
//  Created by Derik Flanary on 3/7/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass

class TouchDownGestureRecognizer: UIGestureRecognizer
{
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        if self.state == .Possible
        {
            self.state = .Recognized
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        self.state = .Failed
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        self.state = .Failed
    }
}