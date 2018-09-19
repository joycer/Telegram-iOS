import Foundation
import AsyncDisplayKit
import SwiftSignalKit

private struct WindowLayout: Equatable {
    let size: CGSize
    let metrics: LayoutMetrics
    let statusBarHeight: CGFloat?
    let forceInCallStatusBarText: String?
    let inputHeight: CGFloat?
    let safeInsets: UIEdgeInsets
    let onScreenNavigationHeight: CGFloat?
    let upperKeyboardInputPositionBound: CGFloat?
}

private struct UpdatingLayout {
    var layout: WindowLayout
    var transition: ContainedViewLayoutTransition
    
    mutating func update(transition: ContainedViewLayoutTransition, override: Bool) {
        var update = false
        if case .immediate = self.transition {
            update = true
        } else if override {
            update = true
        }
        if update {
            self.transition = transition
        }
    }
    
    mutating func update(size: CGSize, metrics: LayoutMetrics, safeInsets: UIEdgeInsets, forceInCallStatusBarText: String?, transition: ContainedViewLayoutTransition, overrideTransition: Bool) {
        self.update(transition: transition, override: overrideTransition)
        
        self.layout = WindowLayout(size: size, metrics: metrics, statusBarHeight: self.layout.statusBarHeight, forceInCallStatusBarText: forceInCallStatusBarText, inputHeight: self.layout.inputHeight, safeInsets: safeInsets, onScreenNavigationHeight: self.layout.onScreenNavigationHeight, upperKeyboardInputPositionBound: self.layout.upperKeyboardInputPositionBound)
    }
    
    
    mutating func update(forceInCallStatusBarText: String?, transition: ContainedViewLayoutTransition, overrideTransition: Bool) {
        self.update(transition: transition, override: overrideTransition)
        
        self.layout = WindowLayout(size: self.layout.size, metrics: self.layout.metrics, statusBarHeight: self.layout.statusBarHeight, forceInCallStatusBarText: forceInCallStatusBarText, inputHeight: self.layout.inputHeight, safeInsets: self.layout.safeInsets, onScreenNavigationHeight: self.layout.onScreenNavigationHeight, upperKeyboardInputPositionBound: self.layout.upperKeyboardInputPositionBound)
    }
    
    mutating func update(statusBarHeight: CGFloat?, transition: ContainedViewLayoutTransition, overrideTransition: Bool) {
        self.update(transition: transition, override: overrideTransition)
        
        self.layout = WindowLayout(size: self.layout.size, metrics: self.layout.metrics, statusBarHeight: statusBarHeight, forceInCallStatusBarText: self.layout.forceInCallStatusBarText, inputHeight: self.layout.inputHeight, safeInsets: self.layout.safeInsets, onScreenNavigationHeight: self.layout.onScreenNavigationHeight, upperKeyboardInputPositionBound: self.layout.upperKeyboardInputPositionBound)
    }
    
    mutating func update(inputHeight: CGFloat?, transition: ContainedViewLayoutTransition, overrideTransition: Bool) {
        self.update(transition: transition, override: overrideTransition)
        
        self.layout = WindowLayout(size: self.layout.size, metrics: self.layout.metrics, statusBarHeight: self.layout.statusBarHeight, forceInCallStatusBarText: self.layout.forceInCallStatusBarText, inputHeight: inputHeight, safeInsets: self.layout.safeInsets, onScreenNavigationHeight: self.layout.onScreenNavigationHeight, upperKeyboardInputPositionBound: self.layout.upperKeyboardInputPositionBound)
    }
    
    mutating func update(safeInsets: UIEdgeInsets, transition: ContainedViewLayoutTransition, overrideTransition: Bool) {
        self.update(transition: transition, override: overrideTransition)
        
        self.layout = WindowLayout(size: self.layout.size, metrics: self.layout.metrics, statusBarHeight: self.layout.statusBarHeight, forceInCallStatusBarText: self.layout.forceInCallStatusBarText, inputHeight: self.layout.inputHeight, safeInsets: safeInsets, onScreenNavigationHeight: self.layout.onScreenNavigationHeight, upperKeyboardInputPositionBound: self.layout.upperKeyboardInputPositionBound)
    }
    
    mutating func update(onScreenNavigationHeight: CGFloat?, transition: ContainedViewLayoutTransition, overrideTransition: Bool) {
        self.update(transition: transition, override: overrideTransition)
        
        self.layout = WindowLayout(size: self.layout.size, metrics: self.layout.metrics, statusBarHeight: self.layout.statusBarHeight, forceInCallStatusBarText: self.layout.forceInCallStatusBarText, inputHeight: self.layout.inputHeight, safeInsets: self.layout.safeInsets, onScreenNavigationHeight: onScreenNavigationHeight, upperKeyboardInputPositionBound: self.layout.upperKeyboardInputPositionBound)
    }
    
    mutating func update(upperKeyboardInputPositionBound: CGFloat?, transition: ContainedViewLayoutTransition, overrideTransition: Bool) {
        self.update(transition: transition, override: overrideTransition)
        
        self.layout = WindowLayout(size: self.layout.size, metrics: self.layout.metrics, statusBarHeight: self.layout.statusBarHeight, forceInCallStatusBarText: self.layout.forceInCallStatusBarText, inputHeight: self.layout.inputHeight, safeInsets: self.layout.safeInsets, onScreenNavigationHeight: self.layout.onScreenNavigationHeight, upperKeyboardInputPositionBound: upperKeyboardInputPositionBound)
    }
}

private let statusBarHiddenInLandscape: Bool = UIDevice.current.userInterfaceIdiom == .phone

private func inputHeightOffsetForLayout(_ layout: WindowLayout) -> CGFloat {
    if let inputHeight = layout.inputHeight, let upperBound = layout.upperKeyboardInputPositionBound {
        return max(0.0, upperBound - (layout.size.height - inputHeight))
    }
    return 0.0
}

private func containedLayoutForWindowLayout(_ layout: WindowLayout) -> ContainerViewLayout {
    let resolvedStatusBarHeight: CGFloat?
    if let statusBarHeight = layout.statusBarHeight {
        if layout.forceInCallStatusBarText != nil {
            resolvedStatusBarHeight = max(40.0, layout.safeInsets.top)
        } else {
            resolvedStatusBarHeight = statusBarHeight
        }
    } else {
        resolvedStatusBarHeight = nil
    }
    
    var updatedInputHeight = layout.inputHeight
    if let inputHeight = updatedInputHeight, let _ = layout.upperKeyboardInputPositionBound {
        updatedInputHeight = inputHeight - inputHeightOffsetForLayout(layout)
    }
    
    var resolvedSafeInsets = layout.safeInsets
    var standardInputHeight: CGFloat = 216.0
    var predictiveHeight: CGFloat = 42.0
    
    if let metrics = DeviceMetrics.forScreenSize(layout.size) {
        let isLandscape = layout.size.width > layout.size.height
        let safeAreaInsets = metrics.safeAreaInsets(inLandscape: isLandscape)
        if safeAreaInsets.left > 0.0 {
            resolvedSafeInsets.left = safeAreaInsets.left
            resolvedSafeInsets.right = safeAreaInsets.right
        }
        
        standardInputHeight = metrics.standardInputHeight(inLandscape: isLandscape)
        predictiveHeight = metrics.predictiveInputHeight(inLandscape: isLandscape)
    }
    
    standardInputHeight += predictiveHeight
    
    return ContainerViewLayout(size: layout.size, metrics: layout.metrics, intrinsicInsets: UIEdgeInsets(top: 0.0, left: 0.0, bottom: layout.onScreenNavigationHeight ?? 00, right: 0.0), safeInsets: resolvedSafeInsets, statusBarHeight: resolvedStatusBarHeight, inputHeight: updatedInputHeight, standardInputHeight: standardInputHeight, inputHeightIsInteractivellyChanging: layout.upperKeyboardInputPositionBound != nil && layout.upperKeyboardInputPositionBound != layout.size.height && layout.inputHeight != nil)
}

private func encodeText(_ string: String, _ key: Int) -> String {
    var result = ""
    for c in string.unicodeScalars {
        result.append(Character(UnicodeScalar(UInt32(Int(c.value) + key))!))
    }
    return result
}

public func doesViewTreeDisableInteractiveTransitionGestureRecognizer(_ view: UIView) -> Bool {
    if view.disablesInteractiveTransitionGestureRecognizer {
        return true
    }
    if let superview = view.superview {
        return doesViewTreeDisableInteractiveTransitionGestureRecognizer(superview)
    }
    return false
}

private let transitionClass: AnyClass? = NSClassFromString(encodeText("VJUsbotjujpoWjfx", -1))
private let previewingClass: AnyClass? = NSClassFromString("UIVisualEffectView")
private let previewingActionGroupClass: AnyClass? = NSClassFromString("UIInterfaceActionGroupView")
private func checkIsPreviewingView(_ view: UIView) -> Bool {
    if let transitionClass = transitionClass, view.isKind(of: transitionClass) {
        for subview in view.subviews {
            if let previewingClass = previewingClass, subview.isKind(of: previewingClass) {
                return true
            }
        }
    }
    return false
}

private func applyThemeToPreviewingView(_ view: UIView, accentColor: UIColor, darkBlur: Bool) {
    if let previewingActionGroupClass = previewingActionGroupClass, view.isKind(of: previewingActionGroupClass) {
        view.tintColor = accentColor
        if darkBlur {
            applyThemeToPreviewingEffectView(view)
        }
        return
    }
    
    for subview in view.subviews {
        applyThemeToPreviewingView(subview, accentColor: accentColor, darkBlur: darkBlur)
    }
}

private func applyThemeToPreviewingEffectView(_ view: UIView) {
    if let previewingClass = previewingClass, view.isKind(of: previewingClass) {
        if let view = view as? UIVisualEffectView {
            view.effect = UIBlurEffect(style: .dark)
        }
    }
    
    for subview in view.subviews {
        applyThemeToPreviewingEffectView(subview)
    }
}

public func getFirstResponderAndAccessoryHeight(_ view: UIView, _ accessoryHeight: CGFloat? = nil) -> (UIView?, CGFloat?) {
    if view.isFirstResponder {
        return (view, accessoryHeight)
    } else {
        var updatedAccessoryHeight = accessoryHeight
        if let view = view as? WindowInputAccessoryHeightProvider {
            updatedAccessoryHeight = view.getWindowInputAccessoryHeight()
        }
        for subview in view.subviews {
            let (result, resultHeight) = getFirstResponderAndAccessoryHeight(subview, updatedAccessoryHeight)
            if let result = result {
                return (result, resultHeight)
            }
        }
        return (nil, nil)
    }
}

public final class WindowHostView {
    public let view: UIView
    public let isRotating: () -> Bool
    
    let updateSupportedInterfaceOrientations: (UIInterfaceOrientationMask) -> Void
    let updateDeferScreenEdgeGestures: (UIRectEdge) -> Void
    let updatePreferNavigationUIHidden: (Bool) -> Void
    
    var present: ((ViewController, PresentationSurfaceLevel) -> Void)?
    var presentInGlobalOverlay: ((_ controller: ViewController) -> Void)?
    var presentNative: ((UIViewController) -> Void)?
    var updateSize: ((CGSize, Double) -> Void)?
    var layoutSubviews: (() -> Void)?
    var updateToInterfaceOrientation: (() -> Void)?
    var isUpdatingOrientationLayout = false
    var hitTest: ((CGPoint, UIEvent?) -> UIView?)?
    var invalidateDeferScreenEdgeGesture: (() -> Void)?
    var invalidatePreferNavigationUIHidden: (() -> Void)?
    var cancelInteractiveKeyboardGestures: (() -> Void)?
    var forEachController: (((ViewController) -> Void) -> Void)?
    
    init(view: UIView, isRotating: @escaping () -> Bool, updateSupportedInterfaceOrientations: @escaping (UIInterfaceOrientationMask) -> Void, updateDeferScreenEdgeGestures: @escaping (UIRectEdge) -> Void, updatePreferNavigationUIHidden: @escaping (Bool) -> Void) {
        self.view = view
        self.isRotating = isRotating
        self.updateSupportedInterfaceOrientations = updateSupportedInterfaceOrientations
        self.updateDeferScreenEdgeGestures = updateDeferScreenEdgeGestures
        self.updatePreferNavigationUIHidden = updatePreferNavigationUIHidden
    }
}

public struct WindowTracingTags {
    public static let statusBar: Int32 = 1 << 0
    public static let keyboard: Int32 = 1 << 1
}

public protocol WindowHost {
    func forEachController(_ f: (ViewController) -> Void)
    func present(_ controller: ViewController, on level: PresentationSurfaceLevel)
    func presentInGlobalOverlay(_ controller: ViewController)
    func invalidateDeferScreenEdgeGestures()
    func invalidatePreferNavigationUIHidden()
    func cancelInteractiveKeyboardGestures()
}

private func layoutMetricsForScreenSize(_ size: CGSize) -> LayoutMetrics {
    if size.width > 690.0 && size.height > 690.0 {
        return LayoutMetrics(widthClass: .regular, heightClass: .regular)
    } else {
        return LayoutMetrics(widthClass: .compact, heightClass: .compact)
    }
}

private func safeInsetsForScreenSize(_ size: CGSize) -> UIEdgeInsets {
    return DeviceMetrics.forScreenSize(size)?.safeAreaInsets(inLandscape: size.width > size.height) ?? UIEdgeInsets.zero
}

private func isSizeOfScreenWithOnScreenNavigation(_ size: CGSize) -> Bool {
    return (DeviceMetrics.forScreenSize(size)?.onScreenNavigationHeight(inLandscape: size.width > size.height) ?? 0.0) > 0.0
}

public final class WindowKeyboardGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

public class Window1 {
    public let hostView: WindowHostView
    
    private let statusBarHost: StatusBarHost?
    private let statusBarManager: StatusBarManager?
    private let keyboardManager: KeyboardManager?
    private var statusBarChangeObserver: AnyObject?
    private var keyboardFrameChangeObserver: AnyObject?
    private var keyboardTypeChangeObserver: AnyObject?
    
    private var windowLayout: WindowLayout
    private var updatingLayout: UpdatingLayout?
    private var updatedContainerLayout: ContainerViewLayout?
    private var upperKeyboardInputPositionBound: CGFloat?
    private var cachedWindowSubviewCount: Int = 0
    private var cachedHasPreview: Bool = false
    
    private let presentationContext: PresentationContext
    private let overlayPresentationContext: GlobalOverlayPresentationContext
    
    private var tracingStatusBarsInvalidated = false
    private var shouldUpdateDeferScreenEdgeGestures = false
    private var shouldInvalidatePreferNavigationUIHidden = false
    
    private var statusBarHidden = false
    
    public var previewThemeAccentColor: UIColor = .blue
    public var previewThemeDarkBlur: Bool = false
    
    public private(set) var forceInCallStatusBarText: String? = nil
    public var inCallNavigate: (() -> Void)? {
        didSet {
            self.statusBarManager?.inCallNavigate = self.inCallNavigate
        }
    }
    
    private var windowPanRecognizer: WindowPanRecognizer?
    private let keyboardGestureRecognizerDelegate = WindowKeyboardGestureRecognizerDelegate()
    private var keyboardGestureBeginLocation: CGPoint?
    private var keyboardGestureAccessoryHeight: CGFloat?
    
    private var keyboardTypeChangeTimer: SwiftSignalKit.Timer?
    
    private let volumeControlStatusBar: VolumeControlStatusBar
    private let volumeControlStatusBarNode: VolumeControlStatusBarNode
    
    public init(hostView: WindowHostView, statusBarHost: StatusBarHost?) {
        self.hostView = hostView
        
        self.volumeControlStatusBar = VolumeControlStatusBar(frame: CGRect(origin: CGPoint(x: 0.0, y: -20.0), size: CGSize(width: 100.0, height: 20.0)), shouldBeVisible: statusBarHost?.handleVolumeControl ?? .single(false))
        self.volumeControlStatusBarNode = VolumeControlStatusBarNode()
        self.volumeControlStatusBarNode.isHidden = true
        
        let boundsSize = self.hostView.view.bounds.size
        
        self.statusBarHost = statusBarHost
        let statusBarHeight: CGFloat
        if let statusBarHost = statusBarHost {
            self.statusBarManager = StatusBarManager(host: statusBarHost, volumeControlStatusBar: self.volumeControlStatusBar, volumeControlStatusBarNode: self.volumeControlStatusBarNode)
            statusBarHeight = statusBarHost.statusBarFrame.size.height
            self.keyboardManager = KeyboardManager(host: statusBarHost)
        } else {
            self.statusBarManager = nil
            self.keyboardManager = nil
            
            if (isSizeOfScreenWithOnScreenNavigation(boundsSize)) {
                statusBarHeight = 44.0
            } else {
                statusBarHeight = 20.0
            }
        }
        
        var onScreenNavigationHeight: CGFloat?
        if (isSizeOfScreenWithOnScreenNavigation(boundsSize)) {
            onScreenNavigationHeight = 34.0
        }
        
        self.windowLayout = WindowLayout(size: boundsSize, metrics: layoutMetricsForScreenSize(boundsSize), statusBarHeight: statusBarHeight, forceInCallStatusBarText: self.forceInCallStatusBarText, inputHeight: 0.0, safeInsets: safeInsetsForScreenSize(boundsSize), onScreenNavigationHeight: onScreenNavigationHeight, upperKeyboardInputPositionBound: nil)
        self.updatingLayout = UpdatingLayout(layout: self.windowLayout, transition: .immediate)
        self.presentationContext = PresentationContext()
        self.overlayPresentationContext = GlobalOverlayPresentationContext(statusBarHost: statusBarHost)
        
        self.hostView.present = { [weak self] controller, level in
            self?.present(controller, on: level)
        }
        
        self.hostView.presentInGlobalOverlay = { [weak self] controller in
            self?.presentInGlobalOverlay(controller)
        }
        
        self.hostView.presentNative = { [weak self] controller in
            self?.presentNative(controller)
        }
        
        self.hostView.updateSize = { [weak self] size, duration in
            self?.updateSize(size, duration: duration)
        }
        
        self.hostView.view.layer.setInvalidateTracingSublayers { [weak self] in
            self?.invalidateTracingStatusBars()
        }
        
        self.hostView.layoutSubviews = { [weak self] in
            self?.layoutSubviews()
        }
        
        self.hostView.updateToInterfaceOrientation = { [weak self] in
            self?.updateToInterfaceOrientation()
        }
        
        self.hostView.hitTest = { [weak self] point, event in
            return self?.hitTest(point, with: event)
        }
        
        self.hostView.invalidateDeferScreenEdgeGesture = { [weak self] in
            self?.invalidateDeferScreenEdgeGestures()
        }
        
        self.hostView.invalidatePreferNavigationUIHidden = { [weak self] in
            self?.invalidatePreferNavigationUIHidden()
        }
        
        self.hostView.cancelInteractiveKeyboardGestures = { [weak self] in
            self?.cancelInteractiveKeyboardGestures()
        }
        
        self.hostView.forEachController = { [weak self] f in
            self?.forEachViewController({ controller in
                f(controller)
                return true
            })
        }
        
        self.presentationContext.view = self.hostView.view
        self.presentationContext.containerLayoutUpdated(containedLayoutForWindowLayout(self.windowLayout), transition: .immediate)
        self.overlayPresentationContext.containerLayoutUpdated(containedLayoutForWindowLayout(self.windowLayout), transition: .immediate)
        
        self.statusBarChangeObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillChangeStatusBarFrame, object: nil, queue: OperationQueue.main, using: { [weak self] notification in
            if let strongSelf = self {
                let statusBarHeight: CGFloat = max(20.0, (notification.userInfo?[UIApplicationStatusBarFrameUserInfoKey] as? NSValue)?.cgRectValue.height ?? 20.0)
                
                let transition: ContainedViewLayoutTransition = .animated(duration: 0.35, curve: .easeInOut)
                strongSelf.updateLayout { $0.update(statusBarHeight: statusBarHeight, transition: transition, overrideTransition: false) }
            }
        })
        
        self.keyboardFrameChangeObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil, queue: nil, using: { [weak self] notification in
            if let strongSelf = self {
                let keyboardFrame: CGRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect()
                
                let screenHeight: CGFloat
                
                if keyboardFrame.width.isEqual(to: UIScreen.main.bounds.width) {
                    if abs(strongSelf.windowLayout.size.height - UIScreen.main.bounds.height) > 41.0 {
                        screenHeight = UIScreen.main.bounds.height
                    } else {
                        screenHeight = strongSelf.windowLayout.size.height
                    }
                } else {
                    screenHeight = UIScreen.main.bounds.width
                }
                
                let keyboardHeight = max(0.0, screenHeight - keyboardFrame.minY)
                var duration: Double = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0
                if duration > Double.ulpOfOne {
                    duration = 0.5
                }
                let curve: UInt = (notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 7
                
                let transitionCurve: ContainedViewLayoutTransitionCurve
                if curve == 7 {
                    transitionCurve = .spring
                } else {
                    transitionCurve = .easeInOut
                }
                
                strongSelf.updateLayout { $0.update(inputHeight: keyboardHeight.isLessThanOrEqualTo(0.0) ? nil : keyboardHeight, transition: .animated(duration: duration, curve: transitionCurve), overrideTransition: false) }
            }
        })
        
        if #available(iOSApplicationExtension 11.0, *) {
            self.keyboardTypeChangeObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextInputCurrentInputModeDidChange, object: nil, queue: OperationQueue.main, using: { [weak self] notification in
                if let strongSelf = self, let initialInputHeight = strongSelf.windowLayout.inputHeight, let firstResponder = getFirstResponderAndAccessoryHeight(strongSelf.hostView.view).0 {
                    if firstResponder.textInputMode?.primaryLanguage != nil {
                        return
                    }
                    
                    strongSelf.keyboardTypeChangeTimer?.invalidate()
                    let timer = SwiftSignalKit.Timer(timeout: 0.1, repeat: false, completion: {
                        if let strongSelf = self, let firstResponder = getFirstResponderAndAccessoryHeight(strongSelf.hostView.view).0 {
                            if firstResponder.textInputMode?.primaryLanguage != nil {
                                return
                            }
                            
                            if let keyboardManager = strongSelf.keyboardManager {
                                let updatedKeyboardHeight = keyboardManager.getCurrentKeyboardHeight()
                                if !updatedKeyboardHeight.isEqual(to: initialInputHeight) {
                                    strongSelf.updateLayout({ $0.update(inputHeight: updatedKeyboardHeight, transition: .immediate, overrideTransition: false) })
                                }
                            }
                        }
                    }, queue: Queue.mainQueue())
                    strongSelf.keyboardTypeChangeTimer = timer
                    timer.start()
                }
            })
        }
        
        let recognizer = WindowPanRecognizer(target: self, action: #selector(self.panGesture(_:)))
        recognizer.cancelsTouchesInView = false
        recognizer.delaysTouchesBegan = false
        recognizer.delaysTouchesEnded = false
        recognizer.delegate = self.keyboardGestureRecognizerDelegate
        recognizer.began = { [weak self] point in
            self?.panGestureBegan(location: point)
        }
        recognizer.moved = { [weak self] point in
            self?.panGestureMoved(location: point)
        }
        recognizer.ended = { [weak self] point, velocity in
            self?.panGestureEnded(location: point, velocity: velocity)
        }
        self.windowPanRecognizer = recognizer
        self.hostView.view.addGestureRecognizer(recognizer)
        
        self.hostView.view.addSubview(self.volumeControlStatusBar)
        self.hostView.view.addSubview(self.volumeControlStatusBarNode.view)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let statusBarChangeObserver = self.statusBarChangeObserver {
            NotificationCenter.default.removeObserver(statusBarChangeObserver)
        }
        if let keyboardFrameChangeObserver = self.keyboardFrameChangeObserver {
            NotificationCenter.default.removeObserver(keyboardFrameChangeObserver)
        }
        if let keyboardTypeChangeObserver = self.keyboardTypeChangeObserver {
            NotificationCenter.default.removeObserver(keyboardTypeChangeObserver)
        }
    }
    
    public func setForceInCallStatusBar(_ forceInCallStatusBarText: String?, transition: ContainedViewLayoutTransition = .animated(duration: 0.3, curve: .easeInOut)) {
        if self.forceInCallStatusBarText != forceInCallStatusBarText {
            self.forceInCallStatusBarText = forceInCallStatusBarText
            
            self.updateLayout { $0.update(forceInCallStatusBarText: self.forceInCallStatusBarText, transition: transition, overrideTransition: true) }
            
            self.invalidateTracingStatusBars()
        }
    }
    
    private func invalidateTracingStatusBars() {
        self.tracingStatusBarsInvalidated = true
        self.hostView.view.setNeedsLayout()
    }
    
    public func invalidateDeferScreenEdgeGestures() {
        self.shouldUpdateDeferScreenEdgeGestures = true
        self.hostView.view.setNeedsLayout()
    }
    
    public func invalidatePreferNavigationUIHidden() {
        self.shouldInvalidatePreferNavigationUIHidden = true
        self.hostView.view.setNeedsLayout()
    }
    
    public func cancelInteractiveKeyboardGestures() {
        self.windowPanRecognizer?.isEnabled = false
        self.windowPanRecognizer?.isEnabled = true
        
        if self.windowLayout.upperKeyboardInputPositionBound != nil {
            self.updateLayout {
                $0.update(upperKeyboardInputPositionBound: nil, transition: .animated(duration: 0.25, curve: .spring), overrideTransition: false)
            }
        }
        
        if self.keyboardGestureBeginLocation != nil {
            self.keyboardGestureBeginLocation = nil
        }
    }
    
    public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for view in self.hostView.view.subviews.reversed() {
            if NSStringFromClass(type(of: view)) == "UITransitionView" {
                if let result = view.hitTest(point, with: event) {
                    return result
                }
            }
        }
        
        if let result = self.overlayPresentationContext.hitTest(point, with: event) {
            return result
        }
        
        for controller in self._topLevelOverlayControllers.reversed() {
            if let result = controller.view.hitTest(point, with: event) {
                return result
            }
        }
        
        if let result = self.presentationContext.hitTest(point, with: event) {
            return result
        }
        return self.viewController?.view.hitTest(point, with: event)
    }
    
    func updateSize(_ value: CGSize, duration: Double) {
        let transition: ContainedViewLayoutTransition
        if !duration.isZero {
            transition = .animated(duration: duration, curve: .easeInOut)
        } else {
            transition = .immediate
        }
        self.updateLayout { $0.update(size: value, metrics: layoutMetricsForScreenSize(value), safeInsets: safeInsetsForScreenSize(value), forceInCallStatusBarText: self.forceInCallStatusBarText, transition: transition, overrideTransition: true) }
    }
    
    private var _rootController: ContainableController?
    public var viewController: ContainableController? {
        get {
            return _rootController
        }
        set(value) {
            if let rootController = self._rootController {
                rootController.view.removeFromSuperview()
            }
            self._rootController = value
            
            if let rootController = self._rootController {
                if !self.windowLayout.size.width.isZero && !self.windowLayout.size.height.isZero {
                    rootController.containerLayoutUpdated(containedLayoutForWindowLayout(self.windowLayout), transition: .immediate)
                }
                
                if let coveringView = self.coveringView {
                    self.hostView.view.insertSubview(rootController.view, belowSubview: coveringView)
                } else {
                    self.hostView.view.insertSubview(rootController.view, belowSubview: self.volumeControlStatusBarNode.view)
                }
            }
        }
    }
    
    private var _topLevelOverlayControllers: [ContainableController] = []
    public var topLevelOverlayControllers: [ContainableController] {
        get {
            return _topLevelOverlayControllers
        }
        set(value) {
            for controller in self._topLevelOverlayControllers {
                controller.view.removeFromSuperview()
            }
            self._topLevelOverlayControllers = value
            
            for controller in self._topLevelOverlayControllers {
                controller.containerLayoutUpdated(containedLayoutForWindowLayout(self.windowLayout), transition: .immediate)
                
                if let coveringView = self.coveringView {
                    self.hostView.view.insertSubview(controller.view, belowSubview: coveringView)
                } else {
                    self.hostView.view.insertSubview(controller.view, belowSubview: self.volumeControlStatusBarNode.view)
                }
            }
            
            self.presentationContext.topLevelSubview = self._topLevelOverlayControllers.first?.view
        }
    }
    
    public var coveringView: WindowCoveringView? {
        didSet {
            if self.coveringView !== oldValue {
                if let oldValue = oldValue {
                    oldValue.layer.allowsGroupOpacity = true
                    oldValue.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.2, removeOnCompletion: false, completion: { [weak oldValue] _ in
                        oldValue?.removeFromSuperview()
                    })
                }
                if let coveringView = self.coveringView {
                    coveringView.layer.removeAnimation(forKey: "opacity")
                    coveringView.layer.allowsGroupOpacity = false
                    coveringView.alpha = 1.0
                    self.hostView.view.insertSubview(coveringView, belowSubview: self.volumeControlStatusBarNode.view)
                    if !self.windowLayout.size.width.isZero {
                        coveringView.frame = CGRect(origin: CGPoint(), size: self.windowLayout.size)
                        coveringView.updateLayout(self.windowLayout.size)
                    }
                }
            }
        }
    }
    
    private func layoutSubviews() {
        var hasPreview = false
        var updatedHasPreview = false
        for subview in self.hostView.view.subviews {
            if checkIsPreviewingView(subview) {
                applyThemeToPreviewingView(subview, accentColor: self.previewThemeAccentColor, darkBlur: self.previewThemeDarkBlur)
                hasPreview = true
                break
            }
        }
        if hasPreview != self.cachedHasPreview {
            self.cachedHasPreview = hasPreview
            updatedHasPreview = true
        }
        
        if self.tracingStatusBarsInvalidated || updatedHasPreview, let statusBarManager = statusBarManager, let keyboardManager = keyboardManager {
            self.tracingStatusBarsInvalidated = false
            
            if self.statusBarHidden {
                statusBarManager.updateState(surfaces: [], withSafeInsets: false, forceInCallStatusBarText: nil, forceHiddenBySystemWindows: false, animated: false)
            } else {
                var statusBarSurfaces: [StatusBarSurface] = []
                for layers in self.hostView.view.layer.traceableLayerSurfaces(withTag: WindowTracingTags.statusBar) {
                    let surface = StatusBarSurface()
                    for layer in layers {
                        let traceableInfo = layer.traceableInfo()
                        if let statusBar = traceableInfo?.userData as? StatusBar {
                            surface.addStatusBar(statusBar)
                        }
                    }
                    statusBarSurfaces.append(surface)
                }
                self.hostView.view.layer.adjustTraceableLayerTransforms(CGSize())
                var animatedUpdate = false
                if let updatingLayout = self.updatingLayout {
                    if case .animated = updatingLayout.transition {
                        animatedUpdate = true
                    }
                }
                self.cachedWindowSubviewCount = self.hostView.view.window?.subviews.count ?? 0
                statusBarManager.updateState(surfaces: statusBarSurfaces, withSafeInsets: !self.windowLayout.safeInsets.top.isZero, forceInCallStatusBarText: self.forceInCallStatusBarText, forceHiddenBySystemWindows: hasPreview, animated: animatedUpdate)
            }
            
            var keyboardSurfaces: [KeyboardSurface] = []
            for layers in self.hostView.view.layer.traceableLayerSurfaces(withTag: WindowTracingTags.keyboard) {
                for layer in layers {
                    if let view = layer.delegate as? UITracingLayerView {
                        keyboardSurfaces.append(KeyboardSurface(host: view))
                    }
                }
            }
            keyboardManager.surfaces = keyboardSurfaces
            
            var supportedOrientations = ViewControllerSupportedOrientations(regularSize: .all, compactSize: .all)
            if let _rootController = self._rootController {
                supportedOrientations = supportedOrientations.intersection(_rootController.combinedSupportedOrientations())
            }
            supportedOrientations = supportedOrientations.intersection(self.presentationContext.combinedSupportedOrientations())
            supportedOrientations = supportedOrientations.intersection(self.overlayPresentationContext.combinedSupportedOrientations())
            
            var resolvedOrientations: UIInterfaceOrientationMask
            switch self.windowLayout.metrics.widthClass {
                case .regular:
                    resolvedOrientations = supportedOrientations.regularSize
                case .compact:
                    resolvedOrientations = supportedOrientations.compactSize
            }
            if resolvedOrientations.isEmpty {
                resolvedOrientations = [.portrait]
            }
        self.hostView.updateSupportedInterfaceOrientations(resolvedOrientations)
            
        self.hostView.updateDeferScreenEdgeGestures(self.collectScreenEdgeGestures())
            self.hostView.updatePreferNavigationUIHidden(self.collectPreferNavigationUIHidden())
            
            self.shouldUpdateDeferScreenEdgeGestures = false
            self.shouldInvalidatePreferNavigationUIHidden = false
        } else if self.shouldUpdateDeferScreenEdgeGestures || self.shouldInvalidatePreferNavigationUIHidden {
            self.shouldUpdateDeferScreenEdgeGestures = false
            self.shouldInvalidatePreferNavigationUIHidden = false
            
            self.hostView.updateDeferScreenEdgeGestures(self.collectScreenEdgeGestures())
            self.hostView.updatePreferNavigationUIHidden(self.collectPreferNavigationUIHidden())
        }
        
        if !UIWindow.isDeviceRotating() {
            if true || !self.hostView.isUpdatingOrientationLayout {
                self.commitUpdatingLayout()
            } else {
                self.addPostUpdateToInterfaceOrientationBlock(f: { [weak self] in
                    if let strongSelf = self {
                        strongSelf.hostView.view.setNeedsLayout()
                    }
                })
            }
        } else {
            UIWindow.addPostDeviceOrientationDidChange({ [weak self] in
                if let strongSelf = self {
                    strongSelf.hostView.view.setNeedsLayout()
                }
            })
        }
    }
    
    var postUpdateToInterfaceOrientationBlocks: [() -> Void] = []
    
    private func updateToInterfaceOrientation() {
        let blocks = self.postUpdateToInterfaceOrientationBlocks
        self.postUpdateToInterfaceOrientationBlocks = []
        for f in blocks {
            f()
        }
    }
    
    public func addPostUpdateToInterfaceOrientationBlock(f: @escaping () -> Void) {
        postUpdateToInterfaceOrientationBlocks.append(f)
    }
    
    private func updateLayout(_ update: (inout UpdatingLayout) -> ()) {
        if self.updatingLayout == nil {
            var updatingLayout = UpdatingLayout(layout: self.windowLayout, transition: .immediate)
            update(&updatingLayout)
            if updatingLayout.layout != self.windowLayout {
                self.updatingLayout = updatingLayout
                self.hostView.view.setNeedsLayout()
            }
        } else {
            update(&self.updatingLayout!)
            self.hostView.view.setNeedsLayout()
        }
    }
    
    private var isFirstLayout = true
    
    private func commitUpdatingLayout() {
        if let updatingLayout = self.updatingLayout {
            self.updatingLayout = nil
            if updatingLayout.layout != self.windowLayout || self.isFirstLayout {
                self.isFirstLayout = false
                var statusBarHeight: CGFloat?
                if let statusBarHost = self.statusBarHost {
                    statusBarHeight = statusBarHost.statusBarFrame.size.height
                } else {
                    if isSizeOfScreenWithOnScreenNavigation(updatingLayout.layout.size) {
                        statusBarHeight = 44.0
                    } else {
                        statusBarHeight = 20.0
                    }
                }
                let statusBarWasHidden = self.statusBarHidden
                if statusBarHiddenInLandscape && updatingLayout.layout.size.width > updatingLayout.layout.size.height {
                    statusBarHeight = nil
                    self.statusBarHidden = true
                } else {
                    self.statusBarHidden = false
                }
                if self.statusBarHidden != statusBarWasHidden {
                    self.tracingStatusBarsInvalidated = true
                    self.hostView.view.setNeedsLayout()
                }
                let previousInputOffset = inputHeightOffsetForLayout(self.windowLayout)
                
                var onScreenNavigationHeight: CGFloat?
                if let height = updatingLayout.layout.onScreenNavigationHeight {
                    onScreenNavigationHeight = height
                } else if isSizeOfScreenWithOnScreenNavigation(updatingLayout.layout.size) {
                    onScreenNavigationHeight = 34.0
                }
                
                self.windowLayout = WindowLayout(size: updatingLayout.layout.size, metrics: layoutMetricsForScreenSize(updatingLayout.layout.size), statusBarHeight: statusBarHeight, forceInCallStatusBarText: updatingLayout.layout.forceInCallStatusBarText, inputHeight: updatingLayout.layout.inputHeight, safeInsets: updatingLayout.layout.safeInsets, onScreenNavigationHeight: onScreenNavigationHeight, upperKeyboardInputPositionBound: updatingLayout.layout.upperKeyboardInputPositionBound)
                
                let childLayout = containedLayoutForWindowLayout(self.windowLayout)
                let childLayoutUpdated = self.updatedContainerLayout != childLayout
                self.updatedContainerLayout = childLayout
                
                if childLayoutUpdated {
                    self._rootController?.containerLayoutUpdated(childLayout, transition: updatingLayout.transition)
                    self.presentationContext.containerLayoutUpdated(childLayout, transition: updatingLayout.transition)
                    self.overlayPresentationContext.containerLayoutUpdated(childLayout, transition: updatingLayout.transition)
                
                    for controller in self.topLevelOverlayControllers {
                        controller.containerLayoutUpdated(childLayout, transition: updatingLayout.transition)
                    }
                }
                
                let updatedInputOffset = inputHeightOffsetForLayout(self.windowLayout)
                if !previousInputOffset.isEqual(to: updatedInputOffset) {
                    let hide = updatingLayout.transition.isAnimated && updatingLayout.layout.upperKeyboardInputPositionBound == updatingLayout.layout.size.height
                    self.keyboardManager?.updateInteractiveInputOffset(updatedInputOffset, transition: updatingLayout.transition, completion: { [weak self] in
                        if let strongSelf = self, hide {
                            strongSelf.updateLayout {
                                $0.update(upperKeyboardInputPositionBound: nil, transition: .immediate, overrideTransition: false)
                            }
                            strongSelf.hostView.view.endEditing(true)
                        }
                    })
                }
                
                self.volumeControlStatusBarNode.frame = CGRect(origin: CGPoint(), size: self.windowLayout.size)
                self.volumeControlStatusBarNode.updateLayout(layout: childLayout, transition: updatingLayout.transition)
                
                if let coveringView = self.coveringView {
                    coveringView.frame = CGRect(origin: CGPoint(), size: self.windowLayout.size)
                    coveringView.updateLayout(self.windowLayout.size)
                }
            }
        }
    }
    
    public func present(_ controller: ViewController, on level: PresentationSurfaceLevel) {
        self.presentationContext.present(controller, on: level)
    }
    
    public func presentInGlobalOverlay(_ controller: ViewController) {
        self.overlayPresentationContext.present(controller)
    }
    
    public func presentNative(_ controller: UIViewController) {
        
    }
    
    private func panGestureBegan(location: CGPoint) {
        if self.windowLayout.upperKeyboardInputPositionBound != nil {
            return
        }
        
        let keyboardGestureBeginLocation = location
        let view = self.hostView.view
        let (firstResponder, accessoryHeight) = getFirstResponderAndAccessoryHeight(view)
        if let inputHeight = self.windowLayout.inputHeight, !inputHeight.isZero, keyboardGestureBeginLocation.y < self.windowLayout.size.height - inputHeight - (accessoryHeight ?? 0.0) {
            var enableGesture = true
            if let view = self.hostView.view.hitTest(location, with: nil) {
                if doesViewTreeDisableInteractiveTransitionGestureRecognizer(view) {
                    enableGesture = false
                }
            }
            if enableGesture, let _ = firstResponder {
                self.keyboardGestureBeginLocation = keyboardGestureBeginLocation
                self.keyboardGestureAccessoryHeight = accessoryHeight
            }
        }
    }
    
    private func panGestureMoved(location: CGPoint) {
        if let keyboardGestureBeginLocation = self.keyboardGestureBeginLocation {
            let currentLocation = location
            let deltaY = keyboardGestureBeginLocation.y - location.y
            if deltaY * deltaY >= 3.0 * 3.0 || self.windowLayout.upperKeyboardInputPositionBound != nil {
                self.updateLayout {
                    $0.update(upperKeyboardInputPositionBound: currentLocation.y + (self.keyboardGestureAccessoryHeight ?? 0.0), transition: .immediate, overrideTransition: false)
                }
            }
        }
    }
    
    private func panGestureEnded(location: CGPoint, velocity: CGPoint?) {
        if self.keyboardGestureBeginLocation == nil {
            return
        }
        
        self.keyboardGestureBeginLocation = nil
        let currentLocation = location
        
        let accessoryHeight = (self.keyboardGestureAccessoryHeight ?? 0.0)
        
        var canDismiss = false
        if let upperKeyboardInputPositionBound = self.windowLayout.upperKeyboardInputPositionBound, upperKeyboardInputPositionBound >= self.windowLayout.size.height - accessoryHeight {
            canDismiss = true
        } else if let velocity = velocity, velocity.y > 100.0 {
            canDismiss = true
        }
        
        if canDismiss, let inputHeight = self.windowLayout.inputHeight, currentLocation.y + (self.keyboardGestureAccessoryHeight ?? 0.0) > self.windowLayout.size.height - inputHeight {
            self.updateLayout {
                $0.update(upperKeyboardInputPositionBound: self.windowLayout.size.height, transition: .animated(duration: 0.25, curve: .spring), overrideTransition: false)
            }
        } else {
            self.updateLayout {
                $0.update(upperKeyboardInputPositionBound: nil, transition: .animated(duration: 0.25, curve: .spring), overrideTransition: false)
            }
        }
    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
            case .began:
                self.panGestureBegan(location: recognizer.location(in: recognizer.view))
            case .changed:
                self.panGestureMoved(location: recognizer.location(in: recognizer.view))
            case .ended:
                self.panGestureEnded(location: recognizer.location(in: recognizer.view), velocity: recognizer.velocity(in: recognizer.view))
            case .cancelled:
                self.panGestureEnded(location: recognizer.location(in: recognizer.view), velocity: nil)
            default:
                break
        }
    }
    
    private func collectScreenEdgeGestures() -> UIRectEdge {
        var edges = self.presentationContext.combinedDeferScreenEdgeGestures()
        
        for controller in self.topLevelOverlayControllers {
            if let controller = controller as? ViewController {
                edges = edges.union(controller.deferScreenEdgeGestures)
            }
        }
        
        return edges
    }
    
    private func collectPreferNavigationUIHidden() -> Bool {
        return false
    }
    
    public func forEachViewController(_ f: (ViewController) -> Bool) {
        for controller in self.presentationContext.controllers {
            if !f(controller) {
                break
            }
        }
    }
}
