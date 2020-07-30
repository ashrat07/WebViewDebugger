//
//  FileHandler.swift
//  HackProj
//
//  Created by Ashish on 27/07/20.
//  Copyright © 2020 Ashish. All rights reserved.
//

import UIKit

class FileHandler: NSObject {
    
    private let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    private var tempFileURLs = Set<URL>()
    
    func createTempFile(with fileName: String) -> URL {
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        tempFileURLs.insert(fileURL)
        return fileURL
    }
    
    func write(jsonObject: Any, to fileName: String) -> URL? {
        guard let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else { return nil }
        return write(data: data, to: fileName)
    }
    
    func write(text: String, to fileName: String) -> URL? {
        guard let data = text.data(using: .utf8) else { return nil }
        return write(data: data, to: fileName)
    }
    
    func write(data: Data, to fileName: String) -> URL {
        let fileURL = createTempFile(with: fileName)
        write(data: data, to: fileURL)
        return fileURL
    }
    
    func write(data: Data, to fileURL: URL) {
        try? data.write(to: fileURL, options: .atomic)
    }
    
    func append(text: String, to fileURL: URL) {
        guard let data = text.data(using: .utf8) else { return }
        append(data: data, to: fileURL)
    }
    
    func append(data: Data, to fileURL: URL) {
        let fileHandle = try? FileHandle(forWritingTo: fileURL)
        let _ = try? fileHandle?.seekToEnd()
        fileHandle?.write(data)
    }
    
    func remove(at fileURL: URL) {
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    deinit {
        for fileURL in tempFileURLs {
            remove(at: fileURL)
        }
    }
    
}
