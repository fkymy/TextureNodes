import AsyncDisplayKit

struct Story {
  let name: String
  let image: String
}

final class Stories: ExampleNode, ASCollectionDelegate, ASCollectionDataSource {
  
  var stories: [Story] = []
  let kNumberOfStories: UInt = 12
  private let collectionNode: ASCollectionNode
  // private let layoutInspector = StoriesLayoutInspector()
  
  override class var title: String {
    return "Stories"
  }
  
  override class var description: String {
    return "A common stories layout"
  }
  
  override class var needsOnlyYCentering: Bool {
    return true
  }
  
  required init() {
    collectionNode = ASCollectionNode(collectionViewLayout: StoriesLayout())
    
    super.init()
    
    for idx in 0..<kNumberOfStories {
      stories.append(Story(name: String(format: "Person %d", idx), image: String(format: "image_%d.jpg", idx)))
    }
    
    setupNodes()
  }
  
  private func setupNodes() {
    setupCollectionNode()
  }
  
  private func setupCollectionNode() {
    collectionNode.delegate = self
    collectionNode.dataSource = self
    collectionNode.backgroundColor = .white
    collectionNode.style.height = ASDimensionMake(224)
    // collectionNode.layoutInspector = layoutInspector
    collectionNode.registerSupplementaryNode(ofKind: UICollectionView.elementKindSectionHeader)
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
    let story = stories[indexPath.item]
    return StoryCellNode(story: story)
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNode {
    return HeaderCellNode()
  }
  
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return 1
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return stories.count
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASWrapperLayoutSpec(layoutElement: collectionNode)
  }
  
}

final class HeaderCellNode: ASCellNode {
  
  let title: ASTextNode
  let more: ASTextNode
  
  override init() {
    title = ASTextNode()
    more = ASTextNode()
    
    super.init()
    
    backgroundColor = .blue
    
    let attributes: [NSAttributedString.Key: Any] = [
      NSAttributedString.Key.foregroundColor: UIColor.gray,
      NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
    ]
    
    title.attributedText = NSAttributedString(string: "ストーリー", attributes: attributes)
    more.attributedText = NSAttributedString(string: "アーカイブを見る>", attributes: attributes)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let spacer = ASLayoutSpec()
    spacer.style.flexGrow = 1
    
    let stackSpec = ASStackLayoutSpec(
      direction: .horizontal,
      spacing: 2.0,
      justifyContent: .start,
      alignItems: .center,
      children: [title, spacer, more]
    )
    
    return ASInsetLayoutSpec(
      insets: UIEdgeInsets(top: 11.0, left: 4.0, bottom: 11.0, right: 4.0),
      child: stackSpec
    )
  }
  
}

final class StoryCellNode: ASCellNode {
  
  private let containerNode: ContainerNode
  
  init(story: Story) {
    self.containerNode = ContainerNode(story: story)
    super.init()
    self.selectionStyle = .none
    addSubnode(containerNode)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASInsetLayoutSpec(
      insets: UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0),
      child: containerNode
    )
  }
  
}

final class ContainerNode: ASControlNode {
  
  private let story: Story
  
  private let imageNode = ASImageNode()
  private let nameNode = ASTextNode()
  private let avatarNode = ASImageNode()
  
  init(story: Story) {
    self.story = story
    
    super.init()
    
    addTarget(self, action: #selector(didTouchDown), forControlEvents: .touchDown)
    addTarget(self, action: #selector(didTouchUpOutside), forControlEvents: .touchUpOutside)
    addTarget(self, action: #selector(didTouchUpInside), forControlEvents: .touchUpInside)
    
    avatarNode.image = UIImage.as_resizableRoundedImage(
      withCornerRadius: 22.0,
      cornerColor: .clear,
      fill: .gray,
      borderColor: .white,
      borderWidth: 2.0
    )
    
    avatarNode.style.preferredSize = CGSize(width: 44.0, height: 44.0)
    
    imageNode.image = UIImage(named: story.image)
    
    nameNode.attributedText = NSAttributedString(
      string: story.name,
      attributes: [
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)
      ]
    )
    
    addSubnode(imageNode)
    addSubnode(nameNode)
    addSubnode(avatarNode)
  }
  
  override func didLoad() {
    super.didLoad()
    layer.cornerRadius = 5.0
    clipsToBounds = true
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let spacer = ASLayoutSpec()
    spacer.style.flexGrow = 1
    
    let stack = ASStackLayoutSpec(
      direction: .vertical,
      spacing: 2.0,
      justifyContent: .start,
      alignItems: .start,
      children: [avatarNode, spacer, nameNode]
    )
    
    let stackInset = ASInsetLayoutSpec(
      insets: UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0),
      child: stack
    )
    
    let overlay = ASOverlayLayoutSpec(
      child: imageNode,
      overlay: stackInset
    )
    
    return overlay
  }
  
  @objc private func didTouchDown() {
    // send message to delegate or
    print("didTouchDown")
  }
  
  @objc private func didTouchUpInside() {
    // send message to delegate or
    print("didTouchUpInside")
  }
  
  @objc private func didTouchUpOutside() {
    // send message to delegate or
    print("didTouchUpOutside")
  }
}
