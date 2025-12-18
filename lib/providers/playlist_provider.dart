import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../services/storage_service.dart';

class PlaylistProvider extends ChangeNotifier {
  final StorageService _storage;
  List<PlaylistModel> _playlists = [];
  bool _loading = true;

  PlaylistProvider(this._storage) {
    _init();
  }

  bool get isLoading => _loading;
  List<PlaylistModel> get playlists => List.unmodifiable(_playlists);

  Future<void> _init() async {
    _playlists = await _storage.getPlaylists();
    _loading = false;
    notifyListeners();
  }

  Future<void> reload() async {
    _loading = true;
    notifyListeners();
    _playlists = await _storage.getPlaylists();
    _loading = false;
    notifyListeners();
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> createPlaylist(String name) async {
    final now = DateTime.now();
    final p = PlaylistModel(
      id: _newId(),
      name: name.trim(),
      songIds: const [],
      createdAt: now,
      updatedAt: now,
      coverImage: null,
    );
    _playlists = [..._playlists, p];
    await _storage.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> deletePlaylist(String id) async {
    _playlists = _playlists.where((p) => p.id != id).toList();
    await _storage.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> renamePlaylist(String id, String newName) async {
    _playlists = _playlists.map((p) {
      if (p.id != id) return p;
      return p.copyWith(name: newName.trim(), updatedAt: DateTime.now());
    }).toList();
    await _storage.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> addSong(String playlistId, String songId) async {
    _playlists = _playlists.map((p) {
      if (p.id != playlistId) return p;
      if (p.songIds.contains(songId)) return p;
      return p.copyWith(
        songIds: [...p.songIds, songId],
        updatedAt: DateTime.now(),
      );
    }).toList();
    await _storage.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> removeSong(String playlistId, String songId) async {
    _playlists = _playlists.map((p) {
      if (p.id != playlistId) return p;
      return p.copyWith(
        songIds: p.songIds.where((x) => x != songId).toList(),
        updatedAt: DateTime.now(),
      );
    }).toList();
    await _storage.savePlaylists(_playlists);
    notifyListeners();
  }

  PlaylistModel? byId(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
