//
//  KMKeys.swift
//  KMKeys
//
//  Created by McGills on 4/17/17.
//  Copyright © 2017 McGill DevTech, LLC. All rights reserved.
//
import UIKit

open class KMKeys: UIView {
    
    open let textField:UITextField = UITextField()
    open let toolbar:UIToolbar = UIToolbar()
    open let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(KMKeys.done))
    open let cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(KMKeys.cancel))
    public let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    open override var frame: CGRect {
        didSet {
            textField.frame = CGRect.init(x: 0, y: 0, width: defaultFrame.size.width, height: textFieldHeight)
            toolbar.frame = CGRect.init(x: 0, y: textFieldHeight, width: defaultFrame.size.width, height: toolbarHeight)
        }
    }
    
    private var textFieldHeight:CGFloat = 30.0
    private var toolbarHeight:CGFloat  = 44.0
    private var completionHandler:(_ text:String?) -> Void = {_ in }
    
    private let ANIMATION_SPEED = 0.25

    private var appWindow:UIWindow {
        get {
            return UIApplication.shared.keyWindow!
        }
    }
    private var defaultFrame:CGRect {
        get {
            return CGRect(x: 0, y: appWindow.bounds.size.height, width: appWindow.bounds.size.width, height: textFieldHeight + toolbarHeight)
        }
    }

    
    convenience public init() {
        self.init(frame: CGRect.zero)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    
    private func setup() {
        
        setToolbarItems(items: [cancelBarButton, flexibleSpace, doneBarButton])
        
        self.frame = defaultFrame
        self.addSubview(textField)
        self.addSubview(toolbar)

        NotificationCenter.default.addObserver(self, selector: #selector(KMKeys.keyboardDidChangeFrame(notification:)), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KMKeys.keyBoardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    open func done() {
        toggle()
        completionHandler(textField.text)
    }
    
    open func cancel() {
        toggle()
    }
    
    public func show(completionHandler:@escaping (_ text:String?) -> Void) {
        self.completionHandler = completionHandler
        toggle()
    }
    
    public func toggle() {
        
        if textField.isFirstResponder {
            textField.resignFirstResponder()
            self.removeFromSuperview()
        } else {
            appWindow.addSubview(self)
            textField.becomeFirstResponder()
        }
    }
    
    public func setToolbarItems(items: [UIBarButtonItem]) {
        toolbar.items = items
    }
    
    private func moveViewWithKeyboard(height: CGFloat) {
        print("Size: \(defaultFrame)")

        UIView.animate(withDuration: ANIMATION_SPEED, animations: {
            self.frame = self.defaultFrame.offsetBy(dx: 0, dy: height - self.frame.height)
        })
    }
    
    @objc private func keyboardDidChangeFrame(notification: NSNotification) {
        print("keyboardDidChangeFrame")
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        moveViewWithKeyboard(height: -frame.height)
    }

    @objc private func keyBoardWillHide(notification: NSNotification) {
        print("keyBoardWillHide")
        moveViewWithKeyboard(height: 0)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
