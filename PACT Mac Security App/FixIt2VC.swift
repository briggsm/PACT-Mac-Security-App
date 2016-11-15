//
//  FixIt2VC.swift
//  PACT Mac Security App
//
//  Created by Mark Briggs on 11/14/16.
//  Copyright © 2016 Mark Briggs. All rights reserved.
//

import Cocoa

class FixIt2VC: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.reloadData()
        
    }
}


extension FixIt2VC: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 3
    }
}

extension FixIt2VC: NSTableViewDelegate {
    //func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var image:NSImage?
        var text:String = ""
        var cellIdentifier: String = ""
        
        // 1
//        guard let item = directoryItems?[row] else {
//            return nil
//        }
        
        // 2
        if tableColumn == tableView.tableColumns[0] {
            image = NSImage(named: "redX")
            text = "test123"
            cellIdentifier = "StatusCellID"
        } else if tableColumn == tableView.tableColumns[1] {
            text = "button column test"
            cellIdentifier = "ButtonsCellID"
        }
        
        // 3
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            cell.imageView?.image = image ?? nil
            
            return cell
       }
        return nil
    }
}
