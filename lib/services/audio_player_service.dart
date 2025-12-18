import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../models/playback_state_model.dart';

class AudioPlayerService {
 final AudioPlayer _audioPlayer = AudioPlayer();

 // Streams
 Stream<Duration> get positionStream => _audioPlayer.positionStream;
 Stream<Duration?> get durationStream => _audioPlayer.durationStream;
 Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
 Stream<bool> get playingStream => _audioPlayer.playingStream;

 // Current state getters
 Duration get currentPosition => _audioPlayer.position;
 Duration? get currentDuration => _audioPlayer.duration;
 bool get isPlaying => _audioPlayer.playing;

 // Playback state stream combining position, duration, and playing state
 Stream<PlaybackStateModel> get playbackStateStream {
 return Rx.combineLatest3<Duration, Duration?, bool, PlaybackStateModel>(
 positionStream,
 durationStream,
 playingStream,
 (position, duration, isPlaying) => PlaybackStateModel(
 position: position,
 duration: duration ?? Duration.zero,
 isPlaying: isPlaying,
 ),
 );
 }

 // Load and play audio from file path
 Future<void> loadAudio(String filePath) async {
 try {
 await _audioPlayer.setFilePath(filePath);
 } catch (e) {
 throw Exception('Error loading audio: $e');
 }
 }

 // Play
 Future<void> play() async {
 await _audioPlayer.play();
 }

 // Pause
 Future<void> pause() async {
 await _audioPlayer.pause();
 }

 // Stop
 Future<void> stop() async {
 await _audioPlayer.stop();
 }

 // Seek to position
 Future<void> seek(Duration position) async {
 await _audioPlayer.seek(position);
 }

 // Set volume (0.0 to 1.0)
 Future<void> setVolume(double volume) async {
 await _audioPlayer.setVolume(volume);
 }

 // Set speed (0.5 to 2.0)
 Future<void> setSpeed(double speed) async {
 await _audioPlayer.setSpeed(speed);
 }

 // Set loop mode
 Future<void> setLoopMode(LoopMode loopMode) async {
 await _audioPlayer.setLoopMode(loopMode);
 }

 // Dispose
 void dispose() {
 _audioPlayer.dispose();
 }
}
