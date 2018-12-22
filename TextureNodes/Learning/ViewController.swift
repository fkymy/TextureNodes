import UIKit
import AsyncDisplayKit


final class ViewController: ASViewController<ASDisplayNode>, ASTableDelegate, ASTableDataSource {

  struct State {
    var itemCount: Int
    var fetchingMore: Bool
    static let empty: State = State(itemCount: 20, fetchingMore: false)
  }
  
  enum Action {
    case beginBatchFetch
    case endBatchFetch(resultCount: Int)
  }
  
  var tableNode: ASTableNode {
    return node as! ASTableNode
  }
  
  fileprivate(set) var state: State = .empty
  
  init() {
    super.init(node: ASTableNode())
    tableNode.delegate = self
    tableNode.dataSource = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
    let rowCount: Int = self.tableNode(tableNode, numberOfRowsInSection: indexPath.section)
    
    if state.fetchingMore && indexPath.row == rowCount - 1 {
      let node: TailLoadingCellNode = TailLoadingCellNode()
      node.style.height = ASDimensionMake(44.0)
      return node
    }
    
    let node: ASTextCellNode = ASTextCellNode()
    node.text = String(format: "[%1d.%1d] hello there", indexPath.section, indexPath.row)
    return node
  }
  
  func numberOfSections(in tableNode: ASTableNode) -> Int {
    return 1
  }
  
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    var count: Int = state.itemCount
    if state.fetchingMore {
      count += 1
    }
    return count
  }
  
  func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
    print("willBeginBatchFetchWith")
    
    DispatchQueue.main.async {
      let oldState = self.state
      self.state = ViewController.handleAction(.beginBatchFetch, fromState: oldState)
      self.renderDiff(oldState)
    }
    
    ViewController.fetchDataWithCompletion { resultCount in
      let action = Action.endBatchFetch(resultCount: resultCount)
      let oldState = self.state
      self.state = ViewController.handleAction(action, fromState: oldState)
      self.renderDiff(oldState)
      context.completeBatchFetching(true)
    }
  }
  
  private func renderDiff(_ oldState: State) {
    
    self.tableNode.performBatchUpdates({
      let rowCountChange = state.itemCount - oldState.itemCount
      if rowCountChange > 0 {
        let indexPaths = (oldState.itemCount..<state.itemCount).map { index in
          IndexPath(row: index, section: 0)
        }
        tableNode.insertRows(at: indexPaths, with: .none)
      } else if rowCountChange < 0 {
        assertionFailure("Deleting rows is not implemented. ")
      }
      
      if state.fetchingMore != oldState.fetchingMore {
        if state.fetchingMore {
          let spinnerIndexPath = IndexPath(row: state.itemCount, section: 0)
          tableNode.insertRows(at: [ spinnerIndexPath ], with: .none)
        } else {
          let spinnerIndexPath = IndexPath(row: oldState.itemCount, section: 0)
          tableNode.deleteRows(at: [ spinnerIndexPath ], with: .none)
        }
      }
    }, completion: nil)
  }
  
  private static func fetchDataWithCompletion(_ completion: @escaping (Int) -> Void) {
    let time = DispatchTime.now() + Double(Int64(TimeInterval(NSEC_PER_SEC) * 1.0)) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time) {
      let resultCount = Int(arc4random_uniform(20))
      completion(resultCount)
    }
  }
  
  private static func handleAction(_ action: Action, fromState state: State) -> State {
    var state = state
    switch action {
    case .beginBatchFetch:
      state.fetchingMore = true
    case let .endBatchFetch(resultCount):
      state.itemCount += resultCount
      state.fetchingMore = false
    }
    return state
  }
}

final class TailLoadingCellNode: ASCellNode {
  
  let spinner = SpinnerNode()
  let text = ASTextNode()
  
  override init() {
    super.init()
    
    addSubnode(text)
    text.attributedText = NSAttributedString(
      string: "Loading...",
      attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
        NSAttributedString.Key.foregroundColor: UIColor.lightGray,
        NSAttributedString.Key.kern: -0.3,
      ]
    )
    addSubnode(spinner)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    return ASStackLayoutSpec(
      direction: .horizontal,
      spacing: 16,
      justifyContent: .center,
      alignItems: .center,
      children: [ text, spinner ])
  }
}

final class SpinnerNode: ASDisplayNode {
  var activityIndicatorView: UIActivityIndicatorView {
    return view as! UIActivityIndicatorView
  }
  
  override init() {
    super.init()
    setViewBlock {
      UIActivityIndicatorView(style: .gray)
    }
    
    // Set spinner node to default size of the activity indicator view
    self.style.preferredSize = CGSize(width: 20.0, height: 20.0)
  }
  
  override func didLoad() {
    super.didLoad()
    
    activityIndicatorView.startAnimating()
  }
}
