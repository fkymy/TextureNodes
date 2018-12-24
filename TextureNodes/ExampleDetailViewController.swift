import AsyncDisplayKit

final class ExampleDetailViewController: ASViewController<ASDisplayNode> {
  
  let exampleNode: ExampleNode
  
  init(exampleType: ExampleNode.Type) {
    exampleNode = exampleType.init()
    
    super.init(node: ASDisplayNode())
    
    self.title = exampleType.title
    self.node.addSubnode(exampleNode)
    
    self.node.backgroundColor = exampleType.needsOnlyYCentering ? .lightGray : .white
    
    self.node.layoutSpecBlock = { [weak self] (node, constrainedSize) in
      guard let exampleNode = self?.exampleNode else { return ASLayoutSpec() }
      return ASCenterLayoutSpec(
        centeringOptions: exampleType.needsOnlyYCentering ? .Y : .XY,
        sizingOptions: .minimumXY,
        child: exampleNode
      )
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
