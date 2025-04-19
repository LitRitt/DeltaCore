//
//  ControllerSkinProtocol.swift
//  DeltaCore
//
//  Created by Riley Testut on 10/13/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

import UIKit

public protocol ControllerSkinProtocol
{
    var name: String { get }
    var identifier: String { get }
    var gameType: GameType { get }
    var isDebugModeEnabled: Bool { get }
    var hasAltRepresentations: Bool { get }
    
    func supports(_ traits: ControllerSkin.Traits, alt: Bool) -> Bool
    
    func image(for traits: ControllerSkin.Traits, preferredSize: ControllerSkin.Size, alt: Bool) -> UIImage?
    func anyImage(for traits: ControllerSkin.Traits, preferredSize: ControllerSkin.Size, alt: Bool) -> UIImage?
    func thumbstick(for item: ControllerSkin.Item, traits: ControllerSkin.Traits, preferredSize: ControllerSkin.Size, alt: Bool) -> (UIImage, CGSize)?
    
    func items(for traits: ControllerSkin.Traits, alt: Bool) -> [ControllerSkin.Item]?
    
    func isTranslucent(for traits: ControllerSkin.Traits, alt: Bool) -> Bool?
    
    func gameScreenFrame(for traits: ControllerSkin.Traits, alt: Bool) -> CGRect?
    func screens(for traits: ControllerSkin.Traits, alt: Bool) -> [ControllerSkin.Screen]?
    
    func aspectRatio(for traits: ControllerSkin.Traits, alt: Bool) -> CGSize?
    
    func contentSize(for traits: ControllerSkin.Traits, alt: Bool) -> CGSize?
    
    func previewSize(for traits: ControllerSkin.Traits, alt: Bool) -> CGSize?
    func anyPreviewSize(for traits: ControllerSkin.Traits, alt: Bool) -> CGSize?
    
    func supportedTraits(for traits: ControllerSkin.Traits, alt: Bool) -> ControllerSkin.Traits?
    
    func unsafeArea(for traits: ControllerSkin.Traits, alt: Bool) -> CGFloat?
}

public extension ControllerSkinProtocol
{
    func supportedTraits(for traits: ControllerSkin.Traits, alt: Bool) -> ControllerSkin.Traits?
    {
        var traits = traits
        
        while !self.supports(traits, alt: alt)
        {
            if traits.device == .iphone && traits.displayType == .edgeToEdge
            {
                traits.displayType = .standard
            }
            else if traits.device == .ipad
            {
                traits.device = .iphone
                traits.displayType = .edgeToEdge
            }
            else
            {
                return nil
            }
        }
        
        return traits
    }
    
    func gameScreenFrame(for traits: DeltaCore.ControllerSkin.Traits, alt: Bool) -> CGRect?
    {
        return self.screens(for: traits, alt: alt)?.first?.outputFrame
    }
}

public func ==(lhs: ControllerSkinProtocol?, rhs: ControllerSkinProtocol?) -> Bool
{
    return lhs?.identifier == rhs?.identifier
}

public func !=(lhs: ControllerSkinProtocol?, rhs: ControllerSkinProtocol?) -> Bool
{
    return !(lhs == rhs)
}

public func ~=(pattern: ControllerSkinProtocol?, value: ControllerSkinProtocol?) -> Bool
{
    return pattern == value
}
