import Foundation
import AVFoundation

protocol PlayerInfoDelegate {
    func nextFrame()
    func songFinished(_ player: AVAudioPlayer, successfully flag: Bool)
}
//custom class to automatic update currentTime in the AVAudioPlayer and when a song ended
class PlayerInfoHandler: NSObject, AVAudioPlayerDelegate {
    var delegate: PlayerInfoDelegate!
    
    private var _enabled = false
    var link: CADisplayLink!
    
    override init() {
        super.init()
        link = CADisplayLink(target: self, selector: #selector(update))
    }
    
    var fps: Int {
        get { link.preferredFramesPerSecond }
        set { link.preferredFramesPerSecond = newValue }
    }
    
    var enabled: Bool {
        get {
            return _enabled
        }
        set {
            if newValue {
                link.add(to: .current, forMode: .common)
            } else {
                link.remove(from: .current, forMode: .common)
            }
            _enabled = newValue
        }
    }
    
    @objc func update(displaylink: CADisplayLink) {
        guard let delegate = delegate else {return}
        delegate.nextFrame()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard let delegate = delegate else {return}
        delegate.songFinished(player, successfully: flag)
    }
}


class AudioPlayerExample {
    
    private let playerinfo_handler: PlayerInfoHandler!
    
    private var _audioplayer: AVAudioPlayer!
    private var nextSong: AVAudioPlayer!
    private let session = AVAudioSession.sharedInstance()
    private var py: AudioPlayerExamplePyCallback!
    
    private var current_playlist: [URL] = []
    private var song_count = 0
    private var playlist_size = 0
    
    private var playlist_running = false
    
    /* assign a new track with this property, it will automatic set the
     AVAudioPlayerDelegate delegate for the PlayerInfo_Handler class
    */
    var current_track: AVAudioPlayer! {
        get { _audioplayer }
        set {
            _audioplayer = newValue
            newValue.delegate = playerinfo_handler
        }
    }
    
    init() {
        playerinfo_handler = PlayerInfoHandler()
        playerinfo_handler.delegate = self
        //set playerinfo refresh rate (fps)
        playerinfo_handler.fps = 2
        
        InitAudioPlayerExample_Delegate(delegate: self)
    }
    
    var isPlaying: Bool {
        guard let player = current_track else { return false }
        return player.isPlaying
    }
    
    func startPlaylist() {
        guard let first_song = current_playlist.first else { return }
        let player = try! AVAudioPlayer(contentsOf: first_song)
        current_track = player
        //guard let player = audioplayer else { return } //returns if player not set
        player.prepareToPlay()
        player.play()
        py.playing_status(state: 1)
        playerinfo_handler.enabled = true
        playlist_running = true
        song_count = 0
        if playlist_size > 0 {
            prepareNextSong(index: 1)
        }
        
    }
    
    func resume() {
        guard let track = current_track else { return } //returns if player not set
        track.play()
        py.playing_status(state: 1)
        playerinfo_handler.enabled = true
        
    }
    
    func pause() {
        guard let track = current_track else { return } //returns if player not set
        track.pause()
        playerinfo_handler.enabled = false
        py.playing_status(state: 0)
    }
    
    
    func prepareNextSong(index: Int) {
        let nextURL = current_playlist[index]
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            
            let next = try! AVAudioPlayer(contentsOf: nextURL)
            next.prepareToPlay()
            self.nextSong = next
        }
    }
    
    func playNextSong() {
        current_track = nextSong
        resume()
    }
    
    func jump2Track(index: Int) {
        let next = current_playlist[index]
        let player = try! AVAudioPlayer.init(contentsOf: next)
        player.prepareToPlay()
        song_count = index
        current_track = player
        player.play()
        if index < playlist_size {
            prepareNextSong(index: index + 1)
        }
        
    }
}

//PlayerInfo Callback extension
extension AudioPlayerExample: PlayerInfoDelegate {
 
    func nextFrame() {
        guard let track = current_track else { return }
        let time = track.currentTime
        let dur = track.duration
        let progress = time / dur
        let _time = Int(time)
        let mins = _time / 60
        let secs = _time % 60
        let _dur = Int(dur)
        let p_text = String(format: "%02d:%02d/%02d:%02d", mins, secs, _dur / 60, _dur % 60)
        
        py.player_info(mins: mins, secs: secs, progress_text: p_text, progress: progress)
    }
    
    func songFinished(_ player: AVAudioPlayer, successfully flag: Bool) {
        if song_count < playlist_size {
            playNextSong()
            prepareNextSong(index: song_count)
            song_count += 1
            return
        }
        py.playing_status(state: -1)
        playerinfo_handler.enabled = false
        playlist_running = false
        song_count = 0
    }
    
}

//Python Extension
extension AudioPlayerExample: AudioPlayerExample_Delegate {
    func set_AudioPlayerExample_Callback(callback: AudioPlayerExamplePyCallback) {
        py = callback
    }
    
    
    func play_pause() {
        if isPlaying {
            pause()
        } else {
            if playlist_running {
                resume()
            } else {
                startPlaylist()
            }
        }
    }
    
    func next() {
        let count = song_count + 1
        if count <= playlist_size {
            jump2Track(index: count)
        }
        
    }
    
    func prev() {
        let count = song_count - 1
        if count >= 0 {
            jump2Track(index: count)
        }
    }
    
    func jump_to_track(index: Int) {
        if index <= song_count {
            jump2Track(index: index)
        }
    }
    
    func stop() {
        guard let track = current_track else { return } //returns if player not set
        track.stop()
        playerinfo_handler.enabled = false
    }
    
    func rate_adjustment(adjuster: Float) {
        guard let track = current_track else { return }
        track.rate += adjuster
        print("changing rate \(track.rate)")
    }
    
    func rate_reset() {
        guard let track = current_track else { return }
        track.rate = 1.0
    }
    
    
    
    
    
    func new_song_url(filePath: String) {
        do {
            current_track = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
        }
        
        catch {
            print(error.localizedDescription)
        }
        
    }
    
    func new_song_bytes(data: Data) {
        do {
            current_track = try AVAudioPlayer(data: data)
            current_track.enableRate = true
            py.set_duration(duration: current_track.duration)
        }
        
        catch {
            print(error.localizedDescription)
        }
    }
    
    
    func new_playlist(files: [String]) {
        current_playlist = files.map{ f in URL(fileURLWithPath: f) }
        playlist_size = files.count - 1
        print(current_playlist)
        startPlaylist()
    }
    
    func add2playlist(filePath: String) {
        current_playlist.append( URL(fileURLWithPath: filePath) )
        playlist_size += 1
    }
    
}
