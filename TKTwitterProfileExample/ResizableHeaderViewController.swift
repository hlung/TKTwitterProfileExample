//
//  ResizableHeaderViewController.swift
//  TKTwitterProfileExample
//
//  Created by Kolyutsakul, Thongchai on 6/6/18.
//

import UIKit

class ResizableHeaderViewController: UIViewController {

  @IBOutlet weak var tableView: ControlContainableTableView!
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .lightGray

    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.dataSource = self
    tableView.delegate = self
    tableView.delaysContentTouches = true
    tableView.canCancelContentTouches = true

    let gesture = tableView.panGestureRecognizer
    headerView.addGestureRecognizer(gesture)
    view.addGestureRecognizer(gesture) // make the whole view controller scrollable
  }

  @IBAction func didTapButton(_ sender: Any) {
    headerViewHeightConstraint.constant = CGFloat(40 + arc4random() % 200)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    var offset = tableView.contentOffset
    tableView.contentInset = UIEdgeInsets(top: headerView.frame.height, left: 0, bottom: 0, right: 0)
    offset.y = -headerView.frame.height
    tableView.contentOffset = offset
  }

}

extension ResizableHeaderViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    print("offset: \(scrollView.contentOffset) isScrolling: \(scrollView.isDragging)")

    if scrollView.isDragging || scrollView.isDecelerating {
      headerViewHeightConstraint.constant = max(50, min(500, -scrollView.contentOffset.y))
    }
  }
}

extension ResizableHeaderViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 5
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Section \(section)"
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = "Row \(indexPath.row)"
    return cell
  }
}

// This class enables scrolling to start from touching UIControl subviews (e.g. UIButton).
final class ControlContainableTableView: UITableView {
  override func touchesShouldCancel(in view: UIView) -> Bool {
    if view is UIControl
      && !(view is UITextInput)
      && !(view is UISlider)
      && !(view is UISwitch) {
      return true
    }
    return super.touchesShouldCancel(in: view)
  }
}
