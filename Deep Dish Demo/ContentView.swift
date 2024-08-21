import SwiftUI
import AppKit

struct ContentView: View {
    
    @State private var selectedFolderURL: URL?
    @State private var swiftFiles: [URL] = []
    @State private var selectedFiles: Set<URL> = Set()
    @State private var combinedText: String = ""
    
    @State var showRoadmap = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            Group {
                if swiftFiles.isEmpty {
                    Button("Select Folder") {
                        let openPanel = NSOpenPanel()
                        openPanel.canChooseFiles = false
                        openPanel.canChooseDirectories = true
                        openPanel.allowsMultipleSelection = false
                        openPanel.begin { response in
                            if response == .OK {
                                selectedFolderURL = openPanel.urls.first
                                if let folderURL = selectedFolderURL {
                                    swiftFiles = findSwiftFiles(in: folderURL)
                                }
                            }
                        }
                    }
                } else {
                    List(swiftFiles, id: \.self) { file in
                        HStack {
                            Toggle(isOn: Binding(
                                get: { selectedFiles.contains(file) },
                                set: { isOn in
                                    if isOn {
                                        selectedFiles.insert(file)
                                    } else {
                                        selectedFiles.remove(file)
                                    }
                                    updateCombinedText()
                                }
                            )) {
                                Text(file.lastPathComponent)
                            }
                        }
                    }
                }
            }
            .frame(width: 200)
            
            // Main content
            VStack {
                // Display concatenated string
                TextEditor(text: $combinedText)
                    .disabled(combinedText.isEmpty)
                    .overlay(
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("\(combinedText.count)")
                            }
                        }
                    )
                
                HStack {
                    // Button to copy concatenated string to clipboard
                    SmallButton(action: {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(combinedText, forType: .string)
                    }, title: "Copy to Clipboard", helpText: "Copy to the clipboard", tintColor: .blue)
                    .disabled(combinedText.isEmpty)
                    
                    
                    SmallButton(action: {
                        showRoadmap = true
                    }, title: "Roadmap", helpText: "Vote on what we should add", tintColor: .blue)
                    
                    SmallButton(action: {
                        animate()
                    }, title: "Animate", helpText: "Vote on what we should add", tintColor: .blue)
                }
                
            }
        }
        .sheet(isPresented: $showRoadmap, content: {
            Roadmap()
        })
    }
    
    func animate() {
        for i in 0...4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(Double(i) * 0.2))) {
                NSApplication.shared.dockTile.contentView = NSImageView(image: NSImage(named: "an\(i)")!)
                NSApplication.shared.dockTile.display()
            }
        }
    }
    
    private func updateCombinedText() {
        combinedText = selectedFiles.compactMap { try? String(contentsOf: $0) }.joined(separator: "\n\n")
    }
    
    func findSwiftFiles(in folderURL: URL) -> [URL] {
        var swiftFiles: [URL] = []
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(at: folderURL, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
            return []
        }
        
        for case let fileURL as URL in enumerator {
            if fileURL.pathExtension == "swift" {
                swiftFiles.append(fileURL)
            }
        }
        
        selectedFiles = Set(swiftFiles)
        updateCombinedText()
        return swiftFiles
    }
}
