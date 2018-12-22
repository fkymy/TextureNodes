//
//  BackgroundProperty.swift
//  TextureNodes
//
//  Created by Yuske Fukuyama on 2018/12/22.
//  Copyright © 2018 Yuske Fukuyama. All rights reserved.
//

import UIKit
import AsyncDisplayKit

final class BackgroundPropertyViewController: ASViewController<ASDisplayNode>, ASCollectionDelegate, ASCollectionDataSource {
  
  var collectionNode: ASCollectionNode {
    return node as! ASCollectionNode
  }
  
  let itemCount = 1000
  let itemSize: CGSize
  let padding: CGFloat
  
  init() {
    let layout = UICollectionViewFlowLayout()
    (padding, itemSize) = BackgroundPropertyViewController.computeLayoutSizesForMainScreen()
    layout.minimumInteritemSpacing = padding
    layout.minimumLineSpacing = padding
    let collectionNode = ASCollectionNode(collectionViewLayout: layout)
    super.init(node: collectionNode)
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Color", style: .plain, target: self, action: #selector(didTapColorsButton))
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Layout", style: .plain, target: self, action: #selector(didTapLayoutButton))
    collectionNode.delegate = self
    collectionNode.dataSource = self
    title = "Backgorund Updating"
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return itemCount
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    return {
      let node = DemoCellNode()
      node.backgroundColor = UIColor.random()
      node.childA.backgroundColor = UIColor.random()
      node.childB.backgroundColor = UIColor.random()
      return node
    }
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRangeMake(itemSize)
  }
  
  @objc func didTapColorsButton() {
    let currentlyVisibleNodes = collectionNode.visibleNodes
    DispatchQueue.main.async {
      for case let node as DemoCellNode in currentlyVisibleNodes {
        node.backgroundColor = UIColor.random()
      }
    }
  }
  
  @objc func didTapLayoutButton() {
    let currentlyVisibleNodes = collectionNode.visibleNodes
    DispatchQueue.main.async {
      for case let node as DemoCellNode in currentlyVisibleNodes {
        node.state.advance()
        node.transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
      }
    }
  }
  
  static func computeLayoutSizesForMainScreen() -> (padding: CGFloat, itemSize: CGSize) {
    let numberOfColumns: Int = 4
    let screen: UIScreen = UIScreen.main
    let scale: CGFloat = screen.scale
    let screenWidth: Int = Int(screen.bounds.width * scale)
    let itemWidthPx: Int = (screenWidth - (numberOfColumns - 1)) / numberOfColumns
    let leftover: Int = screenWidth - itemWidthPx * numberOfColumns
    let paddingPx: Int = leftover / (numberOfColumns - 1)
    let itemDimension: CGFloat = CGFloat(itemWidthPx) / scale
    let padding: CGFloat = CGFloat(paddingPx) / scale
//    let numberOfColumns: Int = 4
//    let padding: CGFloat = 10
//    let widthForSection = UIScreen.main.bounds.width - (padding * 2)
//    let columnWidth = (widthForSection - (CGFloat(numberOfColumns - 1) * padding)) / CGFloat(numberOfColumns)
    return (padding: padding, itemSize: CGSize(width: itemDimension, height: itemDimension))
  }
}

extension UIColor {
  static func random() -> UIColor {
    return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
  }
}

final class DemoCellNode: ASCellNode {
  
  let childA: ASDisplayNode = ASDisplayNode()
  let childB: ASDisplayNode = ASDisplayNode()
  var state: State = .right
  
  override init() {
    super.init()
    automaticallyManagesSubnodes = true
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let specA: ASRatioLayoutSpec = ASRatioLayoutSpec(ratio: 1.0, child: childA)
    specA.style.flexBasis = ASDimensionMake(1)
    specA.style.flexGrow = 1.0
    
    let specB: ASRatioLayoutSpec = ASRatioLayoutSpec(ratio: 1.0, child: childB)
    specB.style.flexBasis = ASDimensionMake(1)
    specB.style.flexGrow = 1.0
    let children: [ASRatioLayoutSpec] = state.isReverse ? [ specB, specA ] : [ specA, specB ]
    let direction: ASStackLayoutDirection = state.isVertical ? .vertical : .horizontal
    
    return ASStackLayoutSpec(
      direction: direction,
      spacing: 20,
      justifyContent: .spaceAround,
      alignItems: .center,
      children: children
    )
  }
  
  override func animateLayoutTransition(_ context: ASContextTransitioning) {
    childA.frame = context.initialFrame(for: childA)
    childB.frame = context.initialFrame(for: childB)
    let tinyDelay = drand48() / 10
    UIView.animate(
      withDuration: 0.5,
      delay: tinyDelay,
      usingSpringWithDamping: 0.9,
      initialSpringVelocity: 1.5,
      options: .beginFromCurrentState,
      animations: {
        self.childA.frame = context.finalFrame(for: self.childA)
        self.childB.frame = context.finalFrame(for: self.childB)
    }) { (success) in
      context.completeTransition(success)
    }
  }
  
  enum State {
    case right
    case up
    case left
    case down
    
    var isVertical: Bool {
      switch self {
      case .up, .down:
        return true
      case .left, .right:
        return false
      }
    }
    
    var isReverse: Bool {
      switch self {
      case .left, .up:
        return true
      case .right, .down:
        return false
      }
    }
    
    mutating func advance() {
      switch self {
      case .right:
        self = .up
      case .up:
        self = .left
      case .left:
        self = .down
      case .down:
        self = .right
      }
    }
  }
}
