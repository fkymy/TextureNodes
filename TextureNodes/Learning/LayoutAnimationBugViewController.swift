import UIKit
import AsyncDisplayKit

let shouldShowBug = false

class Cell: ASCellNode {
  let text: ASTextNode
  let textTruncated: ASTextNode
  let lineNode: ASImageNode
  let button1: ASButtonNode
  let button2: ASButtonNode
  
  fileprivate var expanded = false {
    didSet {
      transitionLayout(withAnimation: true, shouldMeasureAsync: false, measurementCompletion: nil)
    }
  }
  
  override init() {
    text = ASTextNode()
    text.maximumNumberOfLines = 0
    
    textTruncated = ASTextNode()
    textTruncated.maximumNumberOfLines = 1
    
    lineNode = ASImageNode()
    lineNode.image = UIImage.as_resizableRoundedImage(withCornerRadius: 5.0,
                                                      cornerColor: .black,
                                                      fill: .black,
                                                      borderColor: .black,
                                                      borderWidth: 0.0)
    lineNode.isLayerBacked = shouldShowBug
    lineNode.style.flexGrow = 1.0
    
    button1 = ASButtonNode()
    button1.setTitle("Button 1", with: nil, with: .black, for: [])
    
    button2 = ASButtonNode()
    button2.setTitle("Button 2", with: nil, with: .black, for: [])
    
    [button1, button2].forEach { $0.style.alignSelf = .center }
    [text, textTruncated].forEach {
      $0.attributedText = NSAttributedString(string: "This is not a very long text but it might still be truncated on smaller devices. This is not a very long text but it might still be truncated on smaller devices.")
      $0.isLayerBacked = shouldShowBug
    }
    
    super.init()
    
    selectionStyle = .none
    automaticallyManagesSubnodes = true
    // defaultLayoutTransitionDuration = 1.0
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let verticalSpec = ASStackLayoutSpec.vertical()
    verticalSpec.spacing = 12.0
    verticalSpec.children = (expanded ? [text] : [textTruncated]) + [lineNode, button1, button2]
    
    return verticalSpec
  }
  
  override func animateLayoutTransition(_ context: ASContextTransitioning) {
    
    let fromNode = context.removedSubnodes()[0]
    let toNode = context.insertedSubnodes()[0]
    
    let heightDifference = abs(context.finalFrame(for: toNode).size.height - context.finalFrame(for: fromNode).size.height)
    let duration = defaultLayoutTransitionDuration
    
    guard heightDifference >= 0.0 else { return }
    
    let nodesBelowText = [lineNode,
                          button1,
                          button2]
    
    toNode.alpha = 0.0 // start hidden
    
    UIView.animate(withDuration: duration, animations: { [weak self] in
      guard let `self` = self else { return }
      
      // self size
      if
        let fromSize = context.layout(forKey: ASTransitionContextFromLayoutKey)?.size,
        let toSize = context.layout(forKey: ASTransitionContextToLayoutKey)?.size,
        fromSize != toSize {
        self.frame = CGRect(x: self.frame.origin.x,
                            y: self.frame.origin.y,
                            width: toSize.width, height: toSize.height)
      }
      
      nodesBelowText.forEach({
        print(context.finalFrame(for: $0))
        $0.frame = context.finalFrame(for: $0)
      })
      
      }, completion: { finished in
        context.completeTransition(finished)
    })
    
    UIView.animate(withDuration: 0.5*duration,
                   delay: expanded ? 0.5*duration : 0.0,
                   animations: {
                    fromNode.alpha = 0.0
                    toNode.alpha = 1.0
    }, completion: { finished in
      context.completeTransition(finished)
    })
  }
}

final class LayoutAnimationBugViewController: ASViewController<ASTableNode>, ASTableDelegate, ASTableDataSource {
  
  init() {
    let tableNode = ASTableNode()
    
    super.init(node: tableNode)
    
    tableNode.delegate = self
    tableNode.dataSource = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("You don't wanna go there again...")
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    return {
      return Cell()
    }
  }
  
  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    tableNode.deselectRow(at: indexPath, animated: false)
    
    if let cell = tableNode.nodeForRow(at: indexPath) as? Cell {
      cell.expanded = !cell.expanded
    }
  }
  
  func numberOfSections(in tableNode: ASTableNode) -> Int {
    return 1
  }
  
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return 5
  }
}

