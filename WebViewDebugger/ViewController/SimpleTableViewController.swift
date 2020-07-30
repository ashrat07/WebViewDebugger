//
//  SimpleTableViewController.swift
//  WebViewDebugger
//
//  Created by Ashish on 29/07/20.
//  Copyright © 2020 Microsoft Corporation. All rights reserved.
//

import UIKit

class SimpleTableViewController: UIViewController {
    
    private enum JSON {
        case nameArray(value: [(String, Any)])
        case array(value: [Any])
        case dictionary(value: [String: Any])
        case text(value: String)
    }
    
    private var tableView: UITableView!
    
    private let value: Any!
    
    init(value: Any) {
        self.value = value
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.random
        
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
    
    private func getJSON(from value: Any?) -> JSON? {
        if let nameArray = value as? [(String, Any)] {
            return .nameArray(value: nameArray)
        }
        else if let array = value as? [Any] {
            return .array(value: array)
        }
        else if let dictionary = value as? [String: Any] {
            return .dictionary(value: dictionary)
        }
        else if let text = value as? String {
            return .text(value: text)
        }
        return nil
    }
    
    private func getText(from value: Any) -> String? {
        guard let json = getJSON(from: value) else {
            return nil
        }
        
        switch json {
        case let .nameArray(value: nameArray):
            return nameArray.map({ "\($0.0): \($0.1)" }).joined(separator: "\n")
        case let .array(value: array):
            return array.map({ "\($0)" }).joined(separator: "\n")
        case let .dictionary(value: dictionary):
            return dictionary.map({ "\($0.0): \($0.1)" }).joined(separator: "\n")
        case let .text(value: text):
            return text
        }
    }
    
}

extension SimpleTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let json = getJSON(from: value) else {
            return 0
        }
        
        switch json {
        case let .nameArray(value: nameArray):
            return nameArray.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let json = getJSON(from: value) else {
            return 0
        }
        
        switch json {
        case let .nameArray(value: nameArray):
            if section < nameArray.count,
                let json = getJSON(from: nameArray[section].1) {
                switch json {
                case let .nameArray(value: nameArray):
                    return nameArray.count
                case let .array(value: array):
                    return array.count
                default:
                    return 1
                }
            }
        case let .array(value: array):
            return array.count
        default:
            return 1
        }

        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "defaultTableViewCell")
        cell.textLabel?.font = UIFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = indexPath.row % 2 == 0 ? .white : .lightYellow
        
        guard let json = getJSON(from: value) else {
            assertionFailure()
            return cell
        }
        
        switch json {
        case let .nameArray(value: nameArray):
            if indexPath.section < nameArray.count,
                let json = getJSON(from: nameArray[indexPath.section].1) {
                switch json {
                case let .nameArray(value: nameArray):
                    if indexPath.section < nameArray.count {
                        cell.textLabel?.text = getText(from: nameArray[indexPath.row])
                    }
                case let .array(value: array):
                    if indexPath.section < array.count {
                        cell.textLabel?.text = getText(from: array[indexPath.row])
                    }
                case let .dictionary(value: dictionary):
                    cell.textLabel?.text = getText(from: dictionary)
                case let .text(value: text):
                    cell.textLabel?.text = text
                }
            }
        case let .array(value: array):
            if indexPath.section < array.count {
                cell.textLabel?.text = getText(from: array[indexPath.row])
            }
        case let .dictionary(value: dictionary):
            cell.textLabel?.text = getText(from: dictionary)
        case let .text(value: text):
            cell.textLabel?.text = text
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let json = getJSON(from: value) else {
            return nil
        }
        
        switch json {
        case let .nameArray(value: nameArray):
            if section < nameArray.count {
                return nameArray[section].0
            }
        default:
            return nil
        }

        return nil
    }
    
}

extension SimpleTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
