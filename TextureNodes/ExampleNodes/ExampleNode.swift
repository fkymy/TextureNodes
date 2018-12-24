import AsyncDisplayKit

class ExampleNode: ASCellNode {
  
  override required init() {
    super.init()
    automaticallyManagesSubnodes = true
    backgroundColor = .white
  }
  
  class var title: String {
    assertionFailure()
    return ""
  }
  
  class var description: String? {
    return nil
  }
  
  class var needsOnlyYCentering: Bool {
    return false
  }
}
