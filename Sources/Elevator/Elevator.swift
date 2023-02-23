//
//  File.swift
//  
//
//  Created by Joshua Clark on 1/31/23.
//

import Gardener
import Foundation

public class Elevator {
    public static let circuitPyPath = "/Volumes/CIRCUITPY/lib"
    public init() {
        guard let (exitCode, _, _) = Homebrew.install("micropython") else
        {
            return
        }
        
        guard exitCode == 0 else
        {
            return
        }
        
        guard let (exitCode, _, _) = Command().run("which", "mpy-cross") else
        {
            return
        }
        
        guard exitCode == 0 else
        {
            return
        }
    }
    
    public func filePyToMpy(filePathWithName: URL, fileDestination: URL) throws{
        guard let (exitCode, _, _) = Command().run("mpy-cross", "-o", "\(fileDestination)/\(filePathWithName.deletingPathExtension().lastPathComponent).mpy", filePathWithName.path) else
        {
            throw ElevatorErrors.commandNotFound
        }
        
        guard exitCode == 0 else
        {
            throw ElevatorErrors.commandFailed
        }
    }
    
    public func directoryPyToMpy(directoryPath: URL, fileDestination: URL) throws {
        let files = File.findFiles(directoryPath, pattern: "*.py")
        for file in files {
            try filePyToMpy(filePathWithName: file, fileDestination: fileDestination)
        }
    }
    
    public func pyToMpyWithSubdirectories(directoryPath: URL) throws {
        let directories = try File.findDirectories(directoryPath)
        for subDirectory in directories {
            let start = subDirectory.path.index(subDirectory.path.startIndex, offsetBy: directoryPath.path.count)
            let trimmedDirectoryString = subDirectory.path[start..<subDirectory.path.endIndex]
            let mpyPathURL = URL(fileURLWithPath: Self.circuitPyPath)
            let customDirectory = mpyPathURL.appendingPathComponent(String(trimmedDirectoryString))
            guard File.makeDirectory(url: customDirectory) else {
                throw ElevatorErrors.cantCreateDirectory
            }
            
            try directoryPyToMpy(directoryPath: directoryPath, fileDestination: customDirectory)
        }
    }
}

public enum ElevatorErrors: Error {
    case cantCreateDirectory
    case commandNotFound
    case commandFailed
}
