import Defaults
import Foundation
import JellyfinAPI
import SwiftUI

final class ApiClient {
    private(set) var services: ApiServices = .preview

    init() {
        Defaults[.previewMode] ? usePreviewMode() : useDefaultMode()
    }

    init(previewEnabled: Bool = true) {
        previewEnabled ? usePreviewMode() : useDefaultMode()
    }

    /// Use preview mode of the client with mocked data. Does not persist any changes.
    public func usePreviewMode() {
        services = .preview
    }

    public func useDefaultMode() {
        var connectUrl = URL(string: "http://localhost:8096")!
        if let validServerUrl = URL(string: Defaults[.serverUrl]) {
            connectUrl = validServerUrl
        }

        let jellyfinClient = JellyfinClient(configuration: .init(
            url: connectUrl,
            client: "JellyMusic",
            deviceName: UIDevice.current.model,
            deviceID: UIDevice.current.identifierForVendor?.uuidString ?? "missing_id",
            version: "0.0"
        ))

        services = ApiServices(
            albumService: DefaultAlbumService(client: jellyfinClient),
            songService: DefaultSongService(client: jellyfinClient),
            imageService: DefaultImageService(client: jellyfinClient),
            systemService: DefaultSystemService(client: jellyfinClient)
        )
    }

    public func performAuth() throws {
        Task(priority: .background) {
            try await services.systemService.logIn(username: Defaults[.username], password: "aaa")
        }
    }
}

struct ApiServices {
    let albumService: any AlbumService
    let songService: any SongService
    let imageService: any ImageService
    let systemService: any SystemService
}

private struct APIEnvironmentKey: EnvironmentKey {
    static let defaultValue: ApiClient = .init()
}

extension ApiServices {
    static var preview: ApiServices {
        ApiServices(
            albumService: DummyAlbumService(
                albums: [
                    Album(
                        uuid: "1",
                        name: "Nice album name",
                        artistName: "Album artist",
                        isFavorite: true
                    ),
                    Album(
                        uuid: "2",
                        name: "Album with very long name that one gets tired reading it",
                        artistName: "Unamusing artist",
                        isDownloaded: true
                    ),
                    Album(
                        uuid: "3",
                        name: "Very long album name that can't possibly fit on one line on phone screen either in vertical or horizontal orientation",
                        artistName: "Very long artist name that can't possibly fit on one line on phone screen either in vertical or horizontal orientation",
                        isFavorite: true
                    )
                ]
            ),
            songService: DummySongService(
                songs: [
                    // Songs for album 1
                    Song(
                        uuid: "1",
                        index: 1,
                        name: "Song name 1",
                        parentId: "1",
                        isDownloaded: true
                    ),
                    Song(
                        uuid: "2",
                        index: 2,
                        name: "Song name 2 but this one has very long name",
                        parentId: "1",
                        isDownloaded: true
                    ),
                    // Songs for album 2
                    Song(
                        uuid: "3",
                        index: 1,
                        name: "Song name 3",
                        parentId: "2",
                        isDownloaded: true
                    ),
                    Song(
                        uuid: "4",
                        index: 2,
                        name: "Song name 4 but this one has very long name",
                        parentId: "2",
                        isDownloaded: true
                    ),
                    Song(
                        uuid: "5",
                        index: 1,
                        name: "Very long song name that can't possibly fit on one line on phone screen either in vertical or horizontal orientation",
                        parentId: "3"
                    )
                ]
            ),
            imageService: DummyImageService(),
            systemService: MockSystemService()
        )
    }
}

extension EnvironmentValues {
    var api: ApiClient {
        get { self[APIEnvironmentKey.self] }
        set { self[APIEnvironmentKey.self] = newValue }
    }
}