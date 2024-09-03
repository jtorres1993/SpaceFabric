
import SpriteKit

/**The various states a JKButtonNode object can be.*/
public enum JKButtonState {
    
    /**The normal, or default state of a button—that is, enabled but not highlighted.*/
    case normal
    
    /**Highlighted state of a button. A button becomes highlighted when a touch event
     enters the button's bounds, and it loses that highlight when there is a touch-up
     event or when the touch event exits the button's bounds.*/
    case highlighted
    
    /**Disabled state of a button. User interactions with disabled button have no effect
     and the control draws itself with a specific background noting it's disabled.*/
    case disabled
    
   
}

enum JKButtonSelectedState {
    
    case selected
    
    case unselected
}

/**A JKButtonNode is used to display a button in SpriteKit that is composed of an SKSpriteNode and an SKLabelNode.*/
class JKButtonNode: SKSpriteNode {
    
    var selected = JKButtonSelectedState.unselected
    
    
    var shouldDisableChangeStateAfterPress = false
    
    var enableSelectionState = false
    
    //--------------------
    //-----Properties-----
    //--------------------
    /**Whether to allow the button to be pressed. Setting it to false will also assign the correct background image
     and the button's state to disabled.*/
    var enabled = true //{
    //didSet {
    //   enabled ? set(state: .normal) : (canChangeState ? set(state: .disabled): set(state: .normal))
    // }
    //  }
    
    /**Prevents the button from calling its action property when pressed. A custom action can be done
     by calling containsPoint on the button itself inside the touch functions and passing the user's touch.
     This type of custom action will activate as soon as the user touches the button.*/
    var useCustomAction = false {
        didSet {
            useCustomAction ? (isUserInteractionEnabled = false) : (isUserInteractionEnabled = true)
        }
    }
    
    //Whether the button can make sounds.
    var canPlaySounds = true
    
    /**Whether the button can change states when pressed or disabled.
     This will not change the current background of the button.*/
    var canChangeState = true
    
    //BUG: Having empty strings will play any random sound file even when checking
    //if the strings are empty.
    /**The sound that is played when the user releases the button.*/
    var releasedSounds = ""
    var pressedSound = ""
    
    /**The sound that is played when the user attempts to touch a disabled button.*/
    var disabledSound = ""
    
    /**The function to call after the button has been pressed successfully.*/
    var action:((_ sender: JKButtonNode) -> Void)?
    var menuCallback:((_ sender: JKButtonNode) -> Void)?
    
    
    var startAction:(()->Void)?
    var endAction:(()->Void)?
    
    //The state of the button only accessed by the class.
    var state: JKButtonState = .normal
    
    /**The string that the button displays.*/
    var title: SKLabelNode!
    
    var toggleState = false 
    /**The default background of the button when there is no interaction.
     All other button states will be assigned this image unless otherwise specified.*/
    var normalBG = SKTexture(imageNamed: "")
    
    var normalBKG : SKSpriteNode? = nil
    
    /**The background of the button when it has been pressed.*/
    var highlightedBG : SKTexture? = nil
    
    /**The background of the button when the button is not allowed to be pressed.*/
    var disabledBG = SKTexture(imageNamed: "")
    
    /**Bounce of button when pressed**/
    
    var buttonPressedAnimation : SKAction? = nil
    
    var reversedButtonAnimation : SKAction? = nil
    
    var managedProperty = "" 
    
    //----------------------
    //-----Initializers-----
    //----------------------
    /**Initializes a new button with just a background and no title.
     You can declare the button's action later if you choose not to at initialization.*/
    init(backgroundNamed name: String, action: ((_ button: JKButtonNode) -> Void)? = nil) {
        self.title = SKLabelNode(text: "")
        self.action = action
        super.init(texture: SKTexture(imageNamed: name), color: UIColor.clear, size: SKTexture(imageNamed: name).size())
        finalizeInit(state: .normal, background: SKTexture(imageNamed: name))
    }
    
    /**Initializes a new button with a specific background for the specified state.
     You can declare the button's action later if you choose not to at initialization.*/
    init(backgroundNamed name: String, state: JKButtonState, action: ((_ button: JKButtonNode) -> Void)? = nil) {
        self.title = SKLabelNode(text: "")
        self.action = action
        self.state = state
        super.init(texture: SKTexture(imageNamed: name), color: UIColor.clear, size: SKTexture(imageNamed: name).size())
        finalizeInit(state: state, background: SKTexture(imageNamed: name))
    }
    
    /**Initializes a new button with a title and specified state.
     You can set the state backgrounds by calling setStateBackgrounds on the button.*/
    init(title: String, state: JKButtonState, action: ((_ button: JKButtonNode) -> Void)? = nil) {
        self.title = SKLabelNode(text: title)
        self.action = action
        self.state = state
        super.init(texture: normalBG, color: UIColor.clear, size: normalBG.size())
        finalizeInit(state: state, background: nil)
    }
    
    /**Initializes a new button with a title and background.*/
    init(title: String, backgroundNamed name: String, action: ((_ button: JKButtonNode) -> Void)? = nil) {
        self.title = SKLabelNode(text: title)
        self.action = action
        super.init(texture: SKTexture(imageNamed: name), color: UIColor.clear, size: SKTexture(imageNamed: name).size())
        finalizeInit(state: .normal, background: SKTexture(imageNamed: name))
    }
    
    /**Initializes a new button with specific properties.*/
    init(title: String, backgroundNamed name: String, state: JKButtonState, action: ((_ button: JKButtonNode) -> Void)? = nil) {
        self.title = SKLabelNode(text: title)
        self.action = action
        self.state = state
        super.init(texture: SKTexture(imageNamed: name), color: UIColor.clear, size: SKTexture(imageNamed: name).size())
        finalizeInit(state: state, background: SKTexture(imageNamed: name))
    }
    
    /**Initializes a new button with specific properties using an SKTexture instead.*/
    init(title: String, background: SKTexture, state: JKButtonState, action: ((_ button: JKButtonNode) -> Void)? = nil) {
        self.title = SKLabelNode(text: title)
        self.action = action
        self.state = state
        super.init(texture: background, color: UIColor.clear, size: background.size())
        finalizeInit(state: state, background: background)
    }
    
    /**Initializes a new button with specific properties using an SKTexture instead.*/
    init(title: String, background: SKTexture, action: ((_ button: JKButtonNode) -> Void)? = nil) {
        self.title = SKLabelNode(text: title)
        self.action = action
        super.init(texture: background, color: UIColor.clear, size: background.size())
        finalizeInit(state: .normal, background: background)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //-------------------------
    //-----Private Methods-----
    //-------------------------
    //Shared function to be used by initializers only
    fileprivate func finalizeInit(state: JKButtonState, background: SKTexture?) {
        set( state, andBackground: background! )
        
        
        
        guard let title = self.title else { return }
        setupAnimations()
        assignTitleProperties()
        title.zPosition = 10
        addChild(title)
        
        isUserInteractionEnabled = true
    }
    
    
    func setupBKG(texture: SKTexture){
        
        self.normalBKG = SKSpriteNode.init(texture: texture)
        normalBKG?.zPosition = 11
        self.addChild(normalBKG!)
        
    }
    
    fileprivate func setupAnimations(){
        
        
        
        let buttonPressedAction = SKAction.scale(to: 1.1, duration: 0.1)
        let buttonUnPressedAction = SKAction.sequence([SKAction.scale(to: 0.9, duration: 0.05), SKAction.scale(to: 1.1, duration: 0.05), SKAction.scale(to: 1.0, duration: 0.05)])
        
        
        
        self.buttonPressedAnimation = buttonPressedAction
        self.reversedButtonAnimation = buttonUnPressedAction
        
        
        
    }
    
    //Assigns default values for the title.
    fileprivate func assignTitleProperties(fontName name: String? = "Piksel", size: CGFloat = 25, color: UIColor = UIColor.black) {
        title.fontName = name
        title.fontColor = color
        title.fontSize = size
        
        //This equation is used to center the label vertically when the font size is changed
        title.position = centerTitlePosition()
    }
    
    
    //Set the current state of the button with the specified background.
    func set(_ state: JKButtonState, andBackground background: SKTexture?) {
        
        
        switch state {
        case .normal:
            normalBG = background!
            self.texture = normalBG
            
            
            if let action = self.reversedButtonAnimation {
                self.removeAction(forKey: "highAni")
                self.run(action)}
            
        case .highlighted:
            highlightedBG = background
            if background != nil { self.texture = highlightedBG }
            
            if let action = self.buttonPressedAnimation {
                self.run(action,withKey: "highAni")
                
                
            }
        case .disabled:
            
            self.texture = background!
            
            
            
            enabled = false
        }
        
        self.state = state
    }
    
    //Check to make sure that the sounds have been set before trying to play any.
    fileprivate func play(_ sound: String) {
        
        //Disabling Playsound for Now as print is useless
        
       // sound.isEmpty ? print("Failed to play button sound because it has not been set.")
         //   : run(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
    }
    
    
    
    //Centers the title to the button
    fileprivate func centerTitlePosition() -> CGPoint {
        return CGPoint(x: 0, y: 0 - (self.title.fontSize * 0.4))
    }
    
    
    //------------------------
    //-----Public Methods-----
    //------------------------
    /**A convenient way to set several values at once.*/
    func setProperties(enabled: Bool, canPlaySound canPlay: Bool, canChangeState canChange: Bool, withSounds sounds: (normal: String, disabled: String)) {
        self.enabled = enabled
        self.canPlaySounds = canPlay
        self.canChangeState = canChange
        self.releasedSounds = sounds.normal
        self.disabledSound = sounds.disabled
    }
    
    /**Set specific backgrounds for each of the button states.*/
    func setBackgroundsForState(normal: String, highlighted: String, disabled: String) {
        self.normalBG = SKTexture(imageNamed: normal)
        self.size = SKTexture(imageNamed: normal).size()
        self.highlightedBG = SKTexture(imageNamed: highlighted)
        self.disabledBG = SKTexture(imageNamed: disabled)
        set(state: self.state)
    }
    
    /**Set the sounds to play when button has been pressed or when it can't be pressed.*/
    func setSounds(normalButton: String, andDisabledButton disabledButton: String) {
        self.releasedSounds = normalButton
        self.disabledSound = disabledButton
    }
    
    /**Assign custom properties for the title.*/
    func setPropertiesForTitle(fontName font: String?, size: CGFloat, color: UIColor) {
        title.fontName = font
        title.fontColor = color
        title.fontSize = size
        
        //This equation is used to center the label vertically into the background when the font size is changed
        title.position = centerTitlePosition()
    }
    
    /**Set the current state of the button. This will also apply the appropriate background.*/
    func set(state: JKButtonState) {
        
        switch state {
        case .normal:
            set(.normal, andBackground: normalBG)
        case .highlighted:
            if(highlightedBG != nil) {self.texture = highlightedBG }
            set(.highlighted, andBackground: highlightedBG)
        case .disabled: self.texture = disabledBG
        }
    }
    
    
    //-------------------------
    //-----Touch Functions-----
    //-------------------------
    
    var triggered = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        if let menuCallback {
            menuCallback(self)
        }
        
        triggered = true
        
        if enabled {
            
          
            if canChangeState {
                
                
                if let startAction {
                    startAction()
                }
                
                set(state: .highlighted)
                guard isUserInteractionEnabled, let buttonAction = action else { return; }
               // buttonAction(self)
                
                if canPlaySounds {
                        play(pressedSound)
                    
                }
                
                if shouldDisableChangeStateAfterPress == true {
                    canChangeState = false
                }
                
            }
        } else if canPlaySounds {
            
            play(disabledSound)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !enabled else {
            guard let touch = touches.first else { return }
            let userTouch = touch.location(in: parent!)
            
            //Cancels the touch if the user moved their finger out of the button's frame
            guard !self.contains(userTouch) else { 
                
                print("inside touch")
                if (self.state != .highlighted && canChangeState && triggered)
                 { set(state: .highlighted) }
                return }
            
            print("outside touch")
            
            if(state != .normal){
                triggered = false
                if let endAction {
                    endAction()
                }
                set(state: .normal)
            }
            
            return
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !enabled else {
            if canChangeState { 
                
                if(state != .normal){
                    set(state: .normal)
                    
                    if let endAction {
                        endAction()
                    }
                }
            
            triggered = false
            //Allows the action to be complete only if they let go of the button
            guard isUserInteractionEnabled, let buttonAction = action, let touch = touches.first else { return }
            let userTouch = touch.location(in: parent!)
            
            guard self.contains(userTouch) else { return }
            if canPlaySounds { play(releasedSounds) }
            
           
            
            if (enableSelectionState) {
                if selected == .selected {
                    selected = .unselected
                    set(state: .normal)
                    
                    
                } else {
                    selected = .selected
                    set(state: .highlighted)
                }
            }
            
            buttonAction(self)
            } else if ( shouldDisableChangeStateAfterPress == true ) {
                triggered = false
                //Allows the action to be complete only if they let go of the button
                guard isUserInteractionEnabled, let buttonAction = action, let touch = touches.first else { return }
                let userTouch = touch.location(in: parent!)
                
                guard self.contains(userTouch) else { return }
                buttonAction(self)

            }
            return
            
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        guard enabled else { return }
        set(state: .normal)
    }
}
