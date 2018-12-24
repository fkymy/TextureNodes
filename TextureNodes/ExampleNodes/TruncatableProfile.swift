import AsyncDisplayKit

final class TruncatableProfile: ExampleNode {
  
  private let avatarNode: ASImageNode
  private let displayNameNode: ASTextNode
  private let usernameNode: ASTextNode
  private let followNode: ASButtonNode
  private let truncatedIntroductionNode: ASTextNode
  private let introductionNode: ASTextNode
  private let separatorNode: ASImageNode
  private let someTextNode: ASTextNode
  
  override class var title: String {
    return "Truncatable Profile"
  }
  
  override class var description: String {
    return "A common user profile page"
  }
  
  override class var needsOnlyYCentering: Bool {
    return true
  }
  
  private var expanded = false {
    didSet {
      transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
    }
  }
  
  required init() {
    avatarNode = ASImageNode()
    displayNameNode = ASTextNode()
    usernameNode = ASTextNode()
    followNode = ASButtonNode()
    truncatedIntroductionNode = ASTextNode()
    introductionNode = ASTextNode()
    separatorNode = ASImageNode()
    someTextNode = ASTextNode()
    
    super.init()
    
    setupNodes()
    buildNodeHierarchy()
    defaultLayoutTransitionDuration = 0.1
  }
  
  private func setupNodes() {
    setupAvatarNode()
    setupDisplayNameNode()
    setupUsernameNode()
    setupFollowNode()
    setupTruncatedIntroductionNode()
    setupIntroductionNode()
    setupSeparatorNode()
    setupSomeTextNode()
  }
  
  private func setupAvatarNode() {
    let size = CGSize(width: 64, height: 64)
    let image = UIImage.draw(size: size, fillColor: .lightGray) { () -> UIBezierPath in
      return UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: size))
    }
    avatarNode.image = image
  }
  
  private func setupDisplayNameNode() {
    displayNameNode.attributedText = NSAttributedString.attributedString(string: "Yuske Fukuyama", fontSize: 14, color: .primaryColor)
    displayNameNode.maximumNumberOfLines = 1
    displayNameNode.truncationMode = .byTruncatingTail
  }
  
  private func setupUsernameNode() {
    usernameNode.attributedText = NSAttributedString.attributedString(string: "@yuskefukuyama", fontSize: 12, color: .lightGray)
    usernameNode.maximumNumberOfLines = 1
    usernameNode.truncationMode = .byTruncatingTail
  }
  
  private func setupFollowNode() {
    followNode.setTitle("Follow", with: UIFont.systemFont(ofSize: 12), with: .white, for: .normal)
    followNode.backgroundColor = .primaryColor
    followNode.contentEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
  }
  
  private func setupTruncatedIntroductionNode() {
    truncatedIntroductionNode.truncationAttributedText = NSAttributedString(string: " ...")
    truncatedIntroductionNode.additionalTruncationMessage = NSAttributedString.attributedString(string: "もっと見る", fontSize: 10, color: .primaryColor)
    truncatedIntroductionNode.attributedText = introductionTextAttributes()
    truncatedIntroductionNode.maximumNumberOfLines = 3
    truncatedIntroductionNode.onDidLoad { (node) in
      // https://github.com/facebookarchive/AsyncDisplayKit/issues/3298
      // This has some performance overheads. Consider subclassing ASControlNode and using addTarget:, or override touchesBegin:withEvent on ASDisplayNode.
      let tap = UITapGestureRecognizer(target: self, action: #selector(self.toggleIntroduction))
      node.view.addGestureRecognizer(tap)
      node.view.isUserInteractionEnabled = true
    }
  }
  
  private func setupIntroductionNode() {
    introductionNode.attributedText = introductionTextAttributes()
    introductionNode.maximumNumberOfLines = 0
    introductionNode.onDidLoad { (node) in
      // https://github.com/facebookarchive/AsyncDisplayKit/issues/3298
      // This has some performance overheads. Consider subclassing ASControlNode and using addTarget:, or override touchesBegin:withEvent on ASDisplayNode.
      let tap = UITapGestureRecognizer(target: self, action: #selector(self.toggleIntroduction))
      node.view.addGestureRecognizer(tap)
      node.view.isUserInteractionEnabled = true
    }
  }
  
  private func introductionTextAttributes() -> NSAttributedString {
    return NSAttributedString.attributedString(
      string: "This is a long introduction of myself. I am currently learning texture as an alternative to auto layouts. \n This is a long introduction of myself. \n I am currently learning texture as an alternative to auto layouts. \n This is a long introduction of myself. I am currently learning texture as an alternative to auto layouts. \n This is a long introduction of myself. I am currently learning texture as an alternative to auto layouts.",
      fontSize: 12,
      color: .darkGray
    )!
  }
  
  private func setupSeparatorNode() {
    separatorNode.style.height = ASDimensionMakeWithPoints(1.0)
    separatorNode.image = UIImage.as_resizableRoundedImage(
      withCornerRadius: 0.5,
      cornerColor: .lightGray,
      fill: .lightGray
    )
  }
  
  private func setupSomeTextNode() {
    someTextNode.attributedText = NSAttributedString(string: "Some text")
  }
  
  private func buildNodeHierarchy() {
    // subnode hierarchy
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let spacer = ASLayoutSpec()
    spacer.style.flexGrow = 1
    
    let nameSpec = ASStackLayoutSpec(
      direction: .vertical,
      spacing: 2.0,
      justifyContent: .start,
      alignItems: .start,
      children: [displayNameNode, usernameNode]
    )
    nameSpec.style.flexShrink = 1
    
    let topContentSpec = ASStackLayoutSpec(
      direction: .horizontal,
      spacing: 2.0,
      justifyContent: .start,
      alignItems: .center,
      children: [nameSpec, spacer, followNode]
    )
    
    let topContentInsetSpec = ASInsetLayoutSpec(
      insets: UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0),
      child: topContentSpec
    )
    
    let introductionSpec = ASInsetLayoutSpec(
      insets: UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0),
      child: expanded ? introductionNode : truncatedIntroductionNode
    )
    
    let contentSpec = ASStackLayoutSpec.vertical()
    contentSpec.alignItems = .stretch
    contentSpec.style.flexShrink = 1
    contentSpec.children = [topContentInsetSpec, introductionSpec]
    
    let profileSpec = ASStackLayoutSpec.horizontal()
    profileSpec.alignItems = .start
    profileSpec.spacing = 10.0
    profileSpec.style.flexShrink = 1
    profileSpec.children = [avatarNode, contentSpec]
    
    let profileInsetSpec =  ASInsetLayoutSpec(
      insets: UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0),
      child: profileSpec
    )
    
    separatorNode.style.flexGrow = 1.0
    
    let pageSpec = ASStackLayoutSpec.vertical()
    pageSpec.spacing = 4.0
    pageSpec.justifyContent = .center
    pageSpec.children = [profileInsetSpec, separatorNode, someTextNode]
    
    return ASInsetLayoutSpec(
      insets: UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0),
      child: pageSpec)
  }
  
  override func animateLayoutTransition(_ context: ASContextTransitioning) {
    let fromNode = context.removedSubnodes()[0]
    let toNode = context.insertedSubnodes()[0]
    
    let heightDiff = abs(context.finalFrame(for: toNode).size.height - context.finalFrame(for: fromNode).size.width)
    
    guard heightDiff >= 0.0 else { return }
    
    let nodesBelowProfile = [separatorNode, someTextNode]
    toNode.alpha = 0.0
    
    UIView.animate(
      withDuration: defaultLayoutTransitionDuration,
      delay: defaultLayoutTransitionDelay,
      options: .curveEaseOut,
      animations: { [weak self] in
        guard let self = self else { return }
        
        if let fromSize = context.layout(forKey: ASTransitionContextFromLayoutKey)?.size,
          let toSize = context.layout(forKey: ASTransitionContextToLayoutKey)?.size,
          fromSize != toSize {
          self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: toSize.width, height: toSize.height))
        }
        
        nodesBelowProfile.forEach {
          print(context.finalFrame(for: $0))
          $0.frame = context.finalFrame(for: $0)
        }
        
        fromNode.alpha = 0.0
        toNode.alpha = 1.0
        
      }, completion: { finished in
        context.completeTransition(finished)
    })
  }
  
}

extension TruncatableProfile {
  
  @objc private func toggleIntroduction() {
    expanded = !expanded
  }
}
