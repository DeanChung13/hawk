import Cocoa

class FileSearchManager {
    
    // Singleton instance
    static let shared = FileSearchManager()
    
    private init() {}
    
    // Search for files with the given name in the specified directory
    func searchFiles(name: String, in directory: URL, options: SearchOptions = SearchOptions()) -> [URL] {
        guard !name.isEmpty else {
            print("Error: Search name is empty")
            return []
        }
        
        // Start accessing security-scoped resource
        let accessGranted = PreferencesManager.shared.startAccessingDirectory(directory)
        guard accessGranted else {
            print("Error: Could not access security-scoped directory")
            return []
        }

      guard validateDirectory(directory) else {
        print("Error: Directory is invalid or inaccessible")
        return []
      }

        defer {
            // Always stop accessing the resource when done
            PreferencesManager.shared.stopAccessingDirectory(directory)
        }
        
        // Use the find command to search for files
        return searchUsingFindCommand(name: name, in: directory, options: options)
    }
    
    // Search using the system's find command
    private func searchUsingFindCommand(name: String, in directory: URL, options: SearchOptions) -> [URL] {
        let process = Process()
        let pipe = Pipe()
        
        process.standardOutput = pipe
        process.standardError = pipe
        process.executableURL = URL(fileURLWithPath: "/usr/bin/find")
        
        // Build the search pattern based on options
        var searchPattern = name
        if !options.caseSensitive {
            searchPattern = searchPattern.lowercased()
        }
        
        // Create -name argument with wildcards for fuzzy matching
        let nameArg = options.fuzzyMatching ? "*\(searchPattern)*" : searchPattern
        let nameArgCase = options.caseSensitive ? "-name" : "-iname"
        
        // Set arguments for the find command
        process.arguments = [
            directory.path, // Starting directory
            nameArgCase,    // Case sensitivity
            nameArg         // Search pattern
        ]
        
        do {
            try process.run()
            process.waitUntilExit()
            
            // Read the output
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let output = String(data: data, encoding: .utf8) else {
                print("Error: Unable to read find command output")
                return []
            }
            
            // Parse output and convert to URLs
            let fileLines = output.components(separatedBy: .newlines)
                .filter { !$0.isEmpty }
            
            let results = fileLines.compactMap { URL(fileURLWithPath: $0) }
            return results
            
        } catch {
            print("Error executing find command: \(error.localizedDescription)")
            return []
        }
    }
    
    // Validate if the directory exists and is accessible
    private func validateDirectory(_ directory: URL) -> Bool {
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        
        if fileManager.fileExists(atPath: directory.path, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                // Check read permissions
                return fileManager.isReadableFile(atPath: directory.path)
            }
        }
        
        return false
    }
    
    // Open a file in Finder
    func openInFinder(_ fileURL: URL) {
        NSWorkspace.shared.selectFile(fileURL.path, inFileViewerRootedAtPath: "")
    }
} 
