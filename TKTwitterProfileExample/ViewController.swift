//
//  ViewController.swift
//  TKTwitterProfileExample
//
//  Created by Kolyutsakul, Thongchai on 6/6/18.
//

import UIKit

class ViewController: UIViewController {

  var containerTotalAdjustment: CGFloat = 0
  var containerInitialAdjustment: CGFloat = 0
  @IBOutlet weak var containerTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var scrollView: UIScrollView!

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .lightGray
    scrollView.addSubview(contentView)

    let views: [String: UIView] = [
      "scrollView": scrollView,
      "contentView": contentView,
      ]
    var constraints: [NSLayoutConstraint] = []
    constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: [], metrics: nil, views: views)
    constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[contentView]|", options: [], metrics: nil, views: views)
    constraints += [contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1, constant: 0)]
    constraints += [contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1, constant: 0)]
    NSLayoutConstraint.activate(constraints)

    containerInitialAdjustment = containerTopConstraint.constant

    // magic!
    view.addGestureRecognizer(tableView1.panGestureRecognizer)
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
    guard keyPath == "contentOffset", let scrollView = object as? UIScrollView else { return }

    // ignore non-manual scrolling
    guard scrollView.isDragging || scrollView.isDecelerating else { return }

    guard let oldContentOffsetY = (change?[NSKeyValueChangeKey.oldKey] as? NSValue)?.cgPointValue.y,
      let newContentOffsetY = (change?[NSKeyValueChangeKey.newKey] as? NSValue)?.cgPointValue.y else { return }

    let adjustment = newContentOffsetY - oldContentOffsetY
    let isScrollingUp = adjustment > 0 && newContentOffsetY > 0
    let isScrollingDown = adjustment < 0 && newContentOffsetY < 0
    guard isScrollingUp || isScrollingDown else { return }

    // cap the adjustment to a certain range
    containerTotalAdjustment += adjustment
    containerTotalAdjustment = min(200, max(0, containerTotalAdjustment))
    print("adjustment:", adjustment)
    print("total:", containerTotalAdjustment)

    // apply
    containerTopConstraint.constant = containerInitialAdjustment - containerTotalAdjustment
  }

  lazy var contentView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .blue

    view.addSubview(tableView1)
//    view.addSubview(tableView2)

    NSLayoutConstraint.activate([
//      tableView1.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1),
//      tableView2.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
//      tableView1.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1),
//      tableView2.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1),
      ])

    let views: [String: UIView] = [
      "tableView1": tableView1,
//      "tableView2": tableView2,
      ]
    var constraints: [NSLayoutConstraint] = []
    constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView1]|", options: [], metrics: nil, views: views)
//    constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView1][tableView2]|", options: [], metrics: nil, views: views)
    constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView1]|", options: [], metrics: nil, views: views)
//    constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView2]|", options: [], metrics: nil, views: views)
    NSLayoutConstraint.activate(constraints)

    tableView1.addObserver(self, forKeyPath: "contentOffset", options: [.old, .new], context: nil)
//    tableView2.addObserver(self, forKeyPath: "contentOffset", options: [.old, .new], context: nil)

    return view
  }()

  lazy var tableView1: ControlContainableTableView = {
    let tableView = ControlContainableTableView(frame: .zero, style: .plain)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.separatorStyle = .none
    tableView.backgroundColor = UIColor.clear
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.dataSource = self
    tableView.delegate = self
    tableView.delaysContentTouches = true
    tableView.canCancelContentTouches = true
    return tableView
  }()

  lazy var tableView2: UITableView = {
    let tableView = UITableView(frame: .zero, style: .plain)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.separatorStyle = .none
    tableView.backgroundColor = UIColor.clear
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.dataSource = self
    tableView.delegate = self
    tableView.delaysContentTouches = true
    tableView.canCancelContentTouches = true
    return tableView
  }()

//  lazy var label: UILabel = {
//    let label = UILabel()
//    label.translatesAutoresizingMaskIntoConstraints = false
//    label.text = "TouchProxyView"
//    return label
//  }()
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
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
