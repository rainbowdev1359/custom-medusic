import Foundation

@MainActor
final class AlbumDetailController: ObservableObject {
    @Published
    var album: Album?

    @Published
    var songs: [Song]?

    @Published
    var isDownloaded: Bool = false

    @Published
    var isFavorite: Bool = false

    let albumId: String
    var albumRepo: AlbumRepository
    var songRepo: SongRepository

    init(
        albumId: String,
        albumRepo: AlbumRepository = AlbumRepository.shared,
        songRepo: SongRepository = SongRepository.shared
    ) {
        self.albumId = albumId
        self.albumRepo = albumRepo
        self.songRepo = songRepo
    }

    func onAppear() {
        Task {
            await setAlbum()
            await setSongs()
        }
    }

    private func setAlbum() async {
        album = await albumRepo.getAlbum(by: albumId)
    }

    private func setSongs() async {
        songs = await songRepo.getSongs(ofAlbum: albumId)
    }

    func refresh() async {
        do {
            try await songRepo.refresh(for: albumId)
            await setSongs()
        } catch {
            print("Failed to refresh the songs", error)
        }
    }
}
