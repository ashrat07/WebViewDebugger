//
//  SimpleTableViewController.swift
//  HackProj
//
//  Created by Ashish on 29/07/20.
//  Copyright © 2020 Ashish. All rights reserved.
//

import UIKit

class SimpleTableViewController: UIViewController {
    
    var result: [Any]?
    private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

}

extension SimpleTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = result else {
            return 0
        }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = result,
            section < sections.count,
            let rows = sections[section] as? [Any] else {
            return 0
        }
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sections = result,
            indexPath.section < sections.count,
            let rows = sections[indexPath.section] as? [Any],
            indexPath.row < rows.count,
            let row = rows[indexPath.row] as? String else {
                preconditionFailure("This should never happen")
        }
        
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "defaultTableViewCell")
        cell.textLabel?.text = row
        cell.backgroundColor = indexPath.row % 2 == 0 ? .white : .lightGray
        return cell
    }
}

extension SimpleTableViewController: UITableViewDelegate {
    
    
}
