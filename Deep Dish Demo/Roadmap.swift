//
//  Roadmap.swift
//  MacWhisper
//
//  Created by Jordi Bruin on 18/02/2023.
//

import SwiftUI
import Roadmap


struct Roadmap: View {
    
    let configuration: RoadmapConfiguration

    @Environment(\.dismiss) var dismiss

    init() {

        

        configuration = RoadmapConfiguration(
            roadmapJSONURL: Bundle.main.url(forResource: "roadmap", withExtension: "json")!,
    //        namespace: "roadmaptest",
            voter: FeatureVoterTallyAPI(),
            style: RoadmapStyle(upvoteIcon: Image(systemName: "arrowtriangle.up.fill"), unvoteIcon: Image(systemName: "arrowtriangle.down.fill"),
                            titleFont: Font.headline,
                            numberFont: Font.body.monospacedDigit(),
                            statusFont: Font.caption.bold(),
                            statusTintColor: { status in
                                switch status.lowercased() {
                                case "planned":
                                    return Color.blue
                                case "researching":
                                    return Color.orange
                                case "in progress":
                                    return Color.purple
                                case "finished":
                                    return Color.green
                                default:
                                    return Color.primary
                                }
                            },
                            cornerRadius: 10),
        
            shuffledOrder: true,
            allowVotes: true
        )
    }

    var body: some View {
        
        NavigationStack {
            RoadmapView(configuration: configuration) {
                GroupBox {
                    HStack {
                        Text("This is a list of planned features that I'm trying to add to MacWhisper. If you have a MacWhisper Pro license you can vote on the features you want to see me add first. If you purchased Pro and have a feature suggestion, let me know through the button in the bottom left.")
                            .padding(10)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }.padding(.vertical, 4)
            } footer: {
                HStack {
                    Spacer()
                    Text("Feature Voting with [Roadmap](https://github.com/AvdLee/Roadmap)")
                    Spacer()
                }.padding(.vertical, 10)
            }
            //                .navigationTitle("Roadmap")
            //                    .toolbar {
            //                        ToolbarItem {
            //                            Spacer()
            //                        }
            //                }
            // .searchable(text: .constant(""))
            
        }
        .frame(width: 600, height: 600)
    }
    
}

//
//struct RoadmapList: View {
//    @Environment(\.openURL) var openURL
//    @ObservedObject var theme = ThemeManager.shared
//
//    private let configuration = RoadmapConfiguration(
//        roadmapJSONURL: URL(string: "https://nowplaying-content.vercel.app/GolaRoadmap.json")!,
//        voter: FeatureVoterTallyAPI(),
//        style: roadmapStyle,
//        shuffledOrder: true
//    )
//
//    var body: some View {
//
//        RoadmapView(configuration: configuration)
//            .background(theme.colors.background)
//            .toolbarBackground(theme.colors.background.opacity(0.7), for: .navigationBar)
//            .navigationTitle("Roadmap")
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    Text("Roadmap")
//                        .font(.HgoalTitle)
//                        .foregroundColor(.Htext)
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    NavigationBarButton(placement: .trailing, tint: theme.colors.tint, title: "Request Feature") {
//                        openURL(URL(string: "https://forms.gle/TsMoT63XuxNURfTq5")!)
//                    }
//                }
//            }
//    }
//
//}



struct RoadmapFeatureVotingCount: Codable {
    let value: Int?
}

enum JSONDataFetcher {
    enum Error: Swift.Error {
        case invalidURL
    }
    
    private static var urlSession: URLSession = .init(configuration: .ephemeral)
    
    static func loadJSON<T: Decodable>(url: URL) async throws -> T {
        let data = try await urlSession.data(from: url).0
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    static func loadJSON<T: Decodable>(fromURLString urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw Error.invalidURL
        }
        return try await loadJSON(url: url)
    }
}

public struct FeatureVoterTallyAPI: FeatureVoter {
    let namespace = Bundle.main.bundleIdentifier ?? "NoBundleIdentifier"
    
    /// Fetches the current count for the given feature.
    /// - Returns: The current `count`, else `0` if unsuccessful.
    public func fetch(for feature: RoadmapFeature) async -> Int {
        do {
            let urlString = "https://tally.fly.dev/get/\(namespace)/feature\(feature.id)"
            let count: RoadmapFeatureVotingCount = try await JSONDataFetcher.loadJSON(fromURLString: urlString)
            return count.value ?? 0
        } catch {
            return 0
        }
    }
    
    /// Votes for the given feature.
    /// - Returns: The new `count` if successful.
    public func vote(for feature: RoadmapFeature) async -> Int? {
        return await delta(for: feature, delta: 1)
    }
    
    /// Removes a vote for the given feature.
    /// - Returns: The new `count` if successful.
    public func unvote(for feature: RoadmapFeature) async -> Int? {
        return await delta(for: feature, delta: -1)
    }
    
    internal func delta(for feature: RoadmapFeature, delta: Int) async -> Int? {
        do {
            let urlString = "https://tally.fly.dev/add/\(namespace)/feature\(feature.id)?delta=\(delta)"
            let count: RoadmapFeatureVotingCount = try await JSONDataFetcher.loadJSON(fromURLString: urlString)
            return count.value
        } catch {
            return nil
        }
    }
}
