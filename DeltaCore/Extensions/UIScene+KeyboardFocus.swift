//
//  UIScene+KeyboardFocus.swift
//  DeltaCore
//
//  Created by Riley Testut on 7/19/22.
//  Copyright © 2022 Riley Testut. All rights reserved.
//

import UIKit

private var isTrackingKeyboardFocusKey: UInt8 = 0
private var keyboardFocusTimerKey: UInt8 = 0

@objc private protocol UIScenePrivate: NSObjectProtocol
{
    var _isTargetOfKeyboardEventDeferringEnvironment: Bool { get }
}

extension UIScene
{
    static let keyboardFocusDidChangeNotification: Notification.Name = .init("keyboardFocusDidChangeNotification")
    
    var hasKeyboardFocus: Bool {
        guard self.responds(to: #selector(getter: UIScenePrivate._isTargetOfKeyboardEventDeferringEnvironment)) else {
            // Default to true, or else emulation will never resume due to thinking we don't have keyboard focus.
            return true
        }
        
        guard !ProcessInfo.processInfo.isiOSAppOnMac && !ProcessInfo.processInfo.isRunningOnVisionPro else {
            // scene._isTargetOfKeyboardEventDeferringEnvironment always returns false when running on macOS and visionOS,
            // so return true instead to ensure everything continues working.
            return true
        }
        
        let scene = unsafeBitCast(self, to: UIScenePrivate.self)
        let hasKeyboardFocus = scene._isTargetOfKeyboardEventDeferringEnvironment
        return hasKeyboardFocus
    }
    
    private var isTrackingKeyboardFocus: Bool {
        get {
            let numberValue = objc_getAssociatedObject(self, &isTrackingKeyboardFocusKey) as? NSNumber
            return numberValue?.boolValue ?? false
        }
        set {
            let numberValue = newValue ? NSNumber(value: newValue) : nil
            objc_setAssociatedObject(self, &isTrackingKeyboardFocusKey, numberValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    private var keyboardFocusTimer: Timer? {
        get { objc_getAssociatedObject(self, &keyboardFocusTimerKey) as? Timer }
        set { objc_setAssociatedObject(self, &keyboardFocusTimerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func startTrackingKeyboardFocus()
    {
        guard !self.isTrackingKeyboardFocus else { return }
        self.isTrackingKeyboardFocus = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(UIScene.didReceiveKeyboardFocus(_:)), name: Notification.Name("_UISceneDidBecomeTargetOfKeyboardEventDeferringEnvironmentNotification"), object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(UIScene.didLoseKeyboardFocus(_:)), name: Notification.Name("_UISceneDidResignTargetOfKeyboardEventDeferringEnvironmentNotification"), object: self)
    }
}

private extension UIScene
{
    @objc func didReceiveKeyboardFocus(_ notification: Notification)
    {
        guard self.activationState == .foregroundActive else { return }
        
        // Ignore false positives when switching foreground applications.
        self.keyboardFocusTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] timer in
            guard let self = self, timer.isValid, self.hasKeyboardFocus else { return }
            NotificationCenter.default.post(name: UIScene.keyboardFocusDidChangeNotification, object: self)
        }
    }
    
    @objc func didLoseKeyboardFocus(_ notification: Notification)
    {
        if let windowScene = self as? UIWindowScene, windowScene.isStageManagerEnabled
        {
            // Stage Manager is enabled, so listen for all keyboard change notifications.
        }
        else
        {
            // Stage Manager is not enabled, so ignore keyboard change notifications unless we're active in foreground.
            guard self.activationState == .foregroundActive else { return }
        }
                
        if let timer = self.keyboardFocusTimer, timer.isValid
        {
            self.keyboardFocusTimer?.invalidate()
            self.keyboardFocusTimer = nil
        }
        else
        {
            NotificationCenter.default.post(name: UIScene.keyboardFocusDidChangeNotification, object: self)
        }
    }
}

import Foundation
import LocalAuthentication

public extension ProcessInfo {
    var isRunningOnVisionPro: Bool {
        return Self._isRunningOnVisionPro
    }

    // Somewhat expensive to calculate, which can result in dropped touch screen inputs unless we cache value.
    private static let _isRunningOnVisionPro: Bool = {
        // Returns true even when running on iOS :/
        // guard #available(visionOS 1, *) else { return false }
        // return true

        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) // Sets .biometryType when called.

        // Can't reference `.opticID` due to bug with #available, so check if .biometryType isn't one of the other types instead.
        let isRunningOnVisionPro = (context.biometryType != .faceID && context.biometryType != .touchID && context.biometryType != .none)
        return isRunningOnVisionPro
    }()
}
