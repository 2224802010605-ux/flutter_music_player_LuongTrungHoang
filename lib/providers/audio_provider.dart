import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import '../models/playback_state_model.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';

class AudioProvider extends ChangeNotifier {
 final AudioPlayerService _audioService;
 final StorageService _storageService;

 List<SongModel> _playlist = [];
 int _currentIndex = 0;
 bool _isShuffleEnabled = false;
 LoopMode _loopMode = LoopMode.off;

 StreamSubscription<PlayerState>? _playerStateSub;

 // chống completed bắn nhiều lần
 bool _handlingCompletion = false;

 AudioProvider(this._audioService, this._storageService) {
  _init();
  _listenAutoNext();
 }

 // Getters
 List<SongModel> get playlist => _playlist;
 int get currentIndex => _currentIndex;
 SongModel? get currentSong => _playlist.isEmpty ? null : _playlist[_currentIndex];
 bool get isShuffleEnabled => _isShuffleEnabled;
 LoopMode get loopMode => _loopMode;

 Stream<bool> get playingStream => _audioService.playingStream;
 Stream<PlaybackStateModel> get playbackStateStream => _audioService.playbackStateStream;

 Future<void> _init() async {
  _isShuffleEnabled = await _storageService.getShuffleState();

  final repeatMode = await _storageService.getRepeatMode();
  _loopMode = LoopMode.values[repeatMode.clamp(0, LoopMode.values.length - 1)];
  await _audioService.setLoopMode(_loopMode);

  final volume = await _storageService.getVolume();
  await _audioService.setVolume(volume);

  notifyListeners();
 }

 void _listenAutoNext() {
  _playerStateSub?.cancel();
  _playerStateSub = _audioService.playerStateStream.listen((state) async {
   // rời completed -> mở khóa
   if (state.processingState != ProcessingState.completed) {
    _handlingCompletion = false;
    return;
   }

   if (_handlingCompletion) return;
   _handlingCompletion = true;

   if (_playlist.isEmpty) return;

   // Repeat ONE: phát lại bài hiện tại
   if (_loopMode == LoopMode.one) {
    await _audioService.seek(Duration.zero);
    await _audioService.play();
    return;
   }

   final lastIndex = _playlist.length - 1;

   // ✅ Repeat ALL: nếu đang ở bài cuối -> quay về bài 1 (index 0)
   // (bỏ qua shuffle để đúng kỳ vọng của bạn)
   if (_loopMode == LoopMode.all && _currentIndex >= lastIndex) {
    await _playSongAtIndex(0);
    return;
   }

   // còn lại: next bình thường
   await next(autoFromCompletion: true);
  });
 }

 // Set playlist
 Future<void> setPlaylist(List<SongModel> songs, int startIndex) async {
  _playlist = songs;
  if (_playlist.isEmpty) {
   _currentIndex = 0;
   notifyListeners();
   return;
  }

  _currentIndex = startIndex.clamp(0, _playlist.length - 1);
  await _playSongAtIndex(_currentIndex);
  notifyListeners();
 }

 // Play song at index
 Future<void> _playSongAtIndex(int index) async {
  if (_playlist.isEmpty) return;
  if (index < 0 || index >= _playlist.length) return;

  _currentIndex = index;
  final song = _playlist[index];

  await _audioService.loadAudio(song.filePath);

  // đảm bảo loop mode đúng sau mỗi lần setFilePath
  await _audioService.setLoopMode(_loopMode);

  await _audioService.play();
  await _storageService.saveLastPlayed(song.id);

  notifyListeners();
 }

 // Play/Pause
 Future<void> playPause() async {
  if (_audioService.isPlaying) {
   await _audioService.pause();
  } else {
   await _audioService.play();
  }
  notifyListeners();
 }

 // Next song
 Future<void> next({bool autoFromCompletion = false}) async {
  if (_playlist.isEmpty) return;

  final lastIndex = _playlist.length - 1;

  // Nếu đang ở bài cuối
  if (_currentIndex >= lastIndex) {
   if (_loopMode == LoopMode.all) {
    await _playSongAtIndex(0);
   } else {
    await _audioService.stop();
    await _audioService.seek(Duration.zero);
    notifyListeners();
   }
   return;
  }

  // Shuffle: random (chỉ áp dụng khi chưa tới cuối)
  if (_isShuffleEnabled) {
   final idx = _getRandomIndex(exclude: _currentIndex);
   await _playSongAtIndex(idx);
   return;
  }

  // Bình thường: sang bài kế tiếp
  await _playSongAtIndex(_currentIndex + 1);
 }

 // Previous song
 Future<void> previous() async {
  if (_playlist.isEmpty) return;

  if (_audioService.currentPosition.inSeconds > 3) {
   await _audioService.seek(Duration.zero);
   return;
  }

  if (_isShuffleEnabled) {
   final idx = _getRandomIndex(exclude: _currentIndex);
   await _playSongAtIndex(idx);
   return;
  }

  if (_currentIndex <= 0) {
   if (_loopMode == LoopMode.all) {
    await _playSongAtIndex(_playlist.length - 1);
   } else {
    await _audioService.seek(Duration.zero);
    notifyListeners();
   }
   return;
  }

  await _playSongAtIndex(_currentIndex - 1);
 }

 // Seek
 Future<void> seek(Duration position) async {
  await _audioService.seek(position);
 }

 // Toggle shuffle
 Future<void> toggleShuffle() async {
  _isShuffleEnabled = !_isShuffleEnabled;
  await _storageService.saveShuffleState(_isShuffleEnabled);
  notifyListeners();
 }

 // Toggle repeat (off -> all -> one -> off)
 Future<void> toggleRepeat() async {
  switch (_loopMode) {
   case LoopMode.off:
    _loopMode = LoopMode.all;
    break;
   case LoopMode.all:
    _loopMode = LoopMode.one;
    break;
   case LoopMode.one:
    _loopMode = LoopMode.off;
    break;
  }

  await _audioService.setLoopMode(_loopMode);
  await _storageService.saveRepeatMode(_loopMode.index);
  notifyListeners();
 }

 // Set volume
 Future<void> setVolume(double volume) async {
  await _audioService.setVolume(volume);
  await _storageService.saveVolume(volume);
  notifyListeners();
 }

 // Random index (không lặp bài hiện tại nếu có thể)
 int _getRandomIndex({int? exclude}) {
  if (_playlist.isEmpty) return 0;
  if (_playlist.length == 1) return 0;

  final seed = DateTime.now().microsecondsSinceEpoch;
  var idx = seed % _playlist.length;
  if (exclude != null && idx == exclude) {
   idx = (idx + 1) % _playlist.length;
  }
  return idx;
 }

 @override
 void dispose() {
  _playerStateSub?.cancel();
  _audioService.dispose();
  super.dispose();
 }
}
