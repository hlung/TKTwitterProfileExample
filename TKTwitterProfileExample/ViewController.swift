//
//  ViewController.swift
//  TKTwitterProfileExample
//
//  Created by Kolyutsakul, Thongchai on 6/6/18.
//

import UIKit

class ViewController: UIViewController {

  var containerInitialTopSpacing: CGFloat = 200
  var containerTotalAdjustment: CGFloat = 0

  lazy var containerTopConstraint: NSLayoutConstraint = {
    return self.tableView.topAnchor.constraint(equalTo: self.touchProxyView.topAnchor, constant: tableViewInitialTopSpacing)
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .lightGray
    view.addSubview(segmentedTableViewContainerView)

    let views: [String: UIView] = [
      "segmentedTableViewContainerView": segmentedTableViewContainerView,
      ]
    NSLayoutConstraint.activate(
      NSLayoutConstraint.constraints(withVisualFormat: "H:|-[segmentedTableViewContainerView]-|", options: [], metrics: nil, views: views)
      )
    NSLayoutConstraint.activate(
      NSLayoutConstraint.constraints(withVisualFormat: "V:|-200-[segmentedTableViewContainerView]-|", options: [], metrics: nil, views: views)
      )

    containerTopConstraint.isActive = true

    tableView1.addObserver(self, forKeyPath: "contentOffset", options: [.old, .new], context: nil)
    tableView2.addObserver(self, forKeyPath: "contentOffset", options: [.old, .new], context: nil)
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
    guard keyPath == "contentOffset", let scrollView = object as? UIScrollView else { return }

    // exits if not manually scrolling
    guard scrollView.isDragging || scrollView.isDecelerating else { return }

    guard let oldContentOffsetY = (change?[NSKeyValueChangeKey.oldKey] as? NSValue)?.cgPointValue.y,
      let newContentOffsetY = (change?[NSKeyValueChangeKey.newKey] as? NSValue)?.cgPointValue.y else { return }

    let adjustment = newContentOffsetY - oldContentOffsetY
    let isScrollingUp = adjustment > 0 && newContentOffsetY > 0
    let isScrollingDown = adjustment < 0 && newContentOffsetY < 0
    guard isScrollingUp || isScrollingDown else { return }

    // cap the adjustment to a certain range
    containerTotalAdjustment += adjustment
    containerTotalAdjustment = min(120, max(0, containerTotalAdjustment))
    print("adjustment:", adjustment)
    print("total:", containerTotalAdjustment)

    // apply
    containerTopConstraint.constant = containerInitialTopSpacing - containerTotalAdjustment
  }

  lazy var segmentedTableViewContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .gray

    var scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.backgroundColor = UIColor.lightGray
    scrollView.alwaysBounceHorizontal = true
    scrollView.isPagingEnabled = true
    view.addSubview(scrollView)

    let contentView = UIView()
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.backgroundColor = .gray

    contentView.addSubview(tableView1)
    contentView.addSubview(tableView2)

    NSLayoutConstraint.activate([
      tableView1.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
      tableView2.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
      tableView1.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1),
      tableView2.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1),
      ])

    //    NSLayoutConstraint.activate(
    //      visualFormats: [
    //        "H:|-[container]",
    //        "V:|-[container]",
    //        ],
    //      views: [
    //        "container": container,
    //        ])

//    NSLayoutConstraint.activate(
//      visualFormats: [
//        "H:|-[button]-[label]",
//        "V:|-[button]",
//        "V:|-[label]",
//        ],
//      views: [
//        "button": button,
//        "label": label,
//        ])

    return view
  }()

  lazy var tableView1: UITableView = {
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


