import SFSafeSymbols
import SwiftUI

/// Now playing component, somewhat similar what can be seen in Apple Music app.
///
/// Base implementation taken from: https://itnext.io/add-a-now-playing-bar-with-swiftui-to-your-app-d515b03f05e3
struct NowPlayingComponent<Content: View>: View {
    @Binding
    var isPresented: Bool

    var content: Content

    var body: some View {
        VStack(spacing: 0) {
            content

            if isPresented {
                NowPlayingBar()
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .identity
                    ))
            }
        }
    }
}

#if DEBUG
struct NowPlayingComponent_Previews: PreviewProvider {
    @State
    static var isPresented = true

    static var player = {
        var mp = MusicPlayer(preview: true)
        mp.currentSong = PreviewData.songs.first!
        return mp
    }

    static var previews: some View {
        NowPlayingComponent(isPresented: $isPresented, content: LibraryScreen())
            .previewDisplayName("BG + buttons")

        NowPlayingBar(player: player())
            .previewDisplayName("Content")
    }
}
#endif

private struct NowPlayingBar: View {
    @ObservedObject
    private var player: MusicPlayer

    @State
    var isOpen: Bool = false

    init(player: MusicPlayer = .shared) {
        _player = ObservedObject(wrappedValue: player)
    }

    var body: some View {
        HStack(spacing: 0) {
            Button {
                isOpen = true
            } label: {
                SongInfo(song: $player.currentSong)
                    .frame(height: 60)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            PlayPauseButton(player: player)
                .frame(width: 60, height: 60)
                .font(.title2)
                .buttonStyle(.plain)
                .contentShape(Rectangle())

            PlayNextButton(player: player)
                .font(.title2)
                .frame(width: 60, height: 60)
                .buttonStyle(.plain)
                .contentShape(Rectangle())
        }
        .padding(.trailing, 10)
        .frame(width: UIScreen.main.bounds.size.width, height: 65)
        .background(Blur())
        .sheet(isPresented: $isOpen) {
            MusicPlayerScreen()
        }
    }
}

private struct SongInfo: View {
    @Binding
    var song: Song?

    var body: some View {
        HStack {
            ArtworkComponent(itemId: song?.uuid ?? "")
                .frame(width: 50, height: 50)
                .shadow(radius: 6, x: 0, y: 3)
                .padding(.leading)

            Text(song?.name ?? "")
                .font(.title3)
                .padding(.leading, 10)

            Spacer()
        }
    }
}

/// Blur effect.
///
/// From: https://itnext.io/add-a-now-playing-bar-with-swiftui-to-your-app-d515b03f05e3
struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemChromeMaterial

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
