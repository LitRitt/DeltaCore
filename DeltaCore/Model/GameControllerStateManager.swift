//
//  GameControllerStateManager.swift
//  DeltaCore
//
//  Created by Riley Testut on 5/29/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

import Foundation

public class GameControllerStateManager
{
    internal var activatedInputs = Set<InputBox>()
    
    internal var receivers: [GameControllerReceiver]
    {
        var objects: [AnyObject]!
        
        self.dispatchQueue.sync {
            objects = self._receivers.allObjects
        }
        
        return objects.map({ $0 as! GameControllerReceiver })
    }

    fileprivate let _receivers = NSHashTable<AnyObject>.weakObjects()
    
    // Used to synchronize access to _receivers to prevent race conditions (yay ObjC)
    fileprivate let dispatchQueue = DispatchQueue(label: "com.rileytestut.Delta.GameControllerStateManager.dispatchQueue")
}

public extension GameControllerStateManager
{
    func addReceiver(_ receiver: GameControllerReceiver)
    {
        self.dispatchQueue.sync {
            self._receivers.add(receiver)
        }
    }
    
    func removeReceiver(_ receiver: GameControllerReceiver)
    {
        self.dispatchQueue.sync {
            self._receivers.remove(receiver)
        }
    }
}