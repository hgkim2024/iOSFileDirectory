//
//  FileService.swift
//  FileDirectory
//
//  Created by 김현구 on 4/2/24.
//

import Foundation

class FileService {
    
    static let shared = FileService()
    
    let fileManager: FileManager
    private var parentDirectoryPath: URL
    private var directoryPath: URL?
    private var filePath: URL?
    
    private init() {
        fileManager = FileManager.default
        parentDirectoryPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // TODO: - 다른 디렉토리에 저장하면 어떻게 되는지 체크 - ex) .documentDirectory 이외의 디렉토리
    func setParentDirectory(url: URL) {
        parentDirectoryPath = url
    }
    
    func createDirectory(_ directoryName: String) {
        directoryPath = parentDirectoryPath.appendingPathComponent(directoryName)
        guard let directoryPath = directoryPath else {
            Log.tag(.STORAGE).d("Directory Path is null")
            return
        }
        
        do {
            if !fileManager.fileExists(atPath: directoryPath.path) {
                try fileManager.createDirectory(at: directoryPath, withIntermediateDirectories: false, attributes: nil)
            }
        } catch let e {
            print(e.localizedDescription)
        }
    }
    
    func setFile(_ fileName: String) {
        guard let directoryPath = directoryPath else {
            Log.tag(.STORAGE).d("Directory Path is null")
            return
        }
        
        filePath = directoryPath.appendingPathComponent(fileName)
    }
    
    // : Overwrite file data
    func write(data: Data?) {
        guard let data = data else {
            Log.tag(.STORAGE).d("data is null")
            return
        }
        
        guard directoryPath != nil else {
            Log.tag(.STORAGE).d("Directory Path is null")
            return
        }
        
        guard let filePath = filePath else {
            Log.tag(.STORAGE).d("File Path is null")
            return
        }
        
        do {
            try data.write(to: filePath)
        } catch let e {
            Log.tag(.STORAGE).e(e.localizedDescription)
        }
    }
    
    // : Append fild data
    func append(data: Data?) {
        guard let data = data else {
            Log.tag(.STORAGE).d("data is null")
            return
        }
        
        guard directoryPath != nil else {
            Log.tag(.STORAGE).d("Directory Path is null")
            return
        }
        
        guard let filePath = filePath else {
            Log.tag(.STORAGE).d("File Path is null")
            return
        }
        
        if fileManager.fileExists(atPath: filePath.path) {
            if let fileHandle = FileHandle(forWritingAtPath: filePath.path) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            write(data: data)
        }
    
    }
    
    func stringToData(_ str: String) -> Data? {
        return str.data(using: String.Encoding.utf8) ?? nil
    }
    
    func read(_ fileName: String? = nil) -> Data? {
        if let fileName = fileName {
            setFile(fileName)
        }
        
        guard directoryPath != nil else {
            Log.tag(.STORAGE).d("Directory Path is null")
            return nil
        }
        
        guard let filePath = filePath else {
            Log.tag(.STORAGE).d("File Path is null")
            return nil
        }
        
        do {
            let dataFromPath: Data = try Data(contentsOf: filePath)
            return dataFromPath
        } catch let e {
            Log.tag(.STORAGE).e(e.localizedDescription)
            return nil
        }
    }
    
    func remove() {
        guard directoryPath != nil else {
            Log.tag(.STORAGE).d("Directory Path is null")
            return
        }
        
        guard let filePath = filePath else {
            Log.tag(.STORAGE).d("File Path is null")
            return
        }
        
        do {
            try fileManager.removeItem(at: filePath)
        } catch let e {
            Log.tag(.STORAGE).e(e.localizedDescription)
        }
    }
    
    
}
