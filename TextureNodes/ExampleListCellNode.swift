import AsyncDisplayKit

final class ExampleListCellNode: ASCellNode {
  
  let exampleType: ExampleNode.Type
  
  private let titleNode: ASTextNode = ASTextNode()
  private let descriptionNode: ASTextNode = ASTextNode()
  
  init(exampleType: ExampleNode.Type) {
    self.exampleType = exampleType
    
    super.init()
    self.automaticallyManagesSubnodes = true
    
    titleNode.attributedText = NSAttributedString.attributedString(string: exampleType.title, fontSize: 16, color: .black)
    descriptionNode.attributedText = NSAttributedString.attributedString(string: exampleType.description, fontSize: 12, color: .lightGray)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let verticalStackSpec: ASStackLayoutSpec = ASStackLayoutSpec.vertical()
    verticalStackSpec.alignItems = .start
    verticalStackSpec.spacing = 4.0
    verticalStackSpec.children = [titleNode, descriptionNode]
    
    return ASInsetLayoutSpec(
      insets: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 10),
      child: verticalStackSpec
    )
  }
  
}
