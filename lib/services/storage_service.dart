import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist_model.dart';

class StorageService {
 static const String _playlistsKey = 'playlists';
 static const String _lastPlayedKey = 'last_played';
 static const String _shuffleKey = 'shuffle_enabled';
 static const String _repeatKey = 'repeat_mode';
 static const String _volumeKey = 'volume';
 static const String _dynamicThemeKey = 'dynamic_theme';

 // Save playlists
 Future<void> savePlaylists(List<PlaylistModel> playlists) async {
 final prefs = await SharedPreferences.getInstance();
 final playlistsJson = playlists.map((p) => p.toJson()).toList();
 await prefs.setString(_playlistsKey, json.encode(playlistsJson));
 }

 // Get playlists
 Future<List<PlaylistModel>> getPlaylists() async {
 final prefs = await SharedPreferences.getInstance();
 final playlistsString = prefs.getString(_playlistsKey);

 if (playlistsString != null) {
 final List<dynamic> playlistsJson = json.decode(playlistsString);
 return playlistsJson.map((json) => PlaylistModel.fromJson(json)).toList();
 }
 return [];
 }

 // Save last played song
 Future<void> saveLastPlayed(String songId) async {
 final prefs = await SharedPreferences.getInstance();
 await prefs.setString(_lastPlayedKey, songId);
 }

 // Get last played song
 Future<String?> getLastPlayed() async {
 final prefs = await SharedPreferences.getInstance();
 return prefs.getString(_lastPlayedKey);
 }

 // Save shuffle state
 Future<void> saveShuffleState(bool enabled) async {
 final prefs = await SharedPreferences.getInstance();
 await prefs.setBool(_shuffleKey, enabled);
 }

 // Get shuffle state
 Future<bool> getShuffleState() async {
 final prefs = await SharedPreferences.getInstance();
 return prefs.getBool(_shuffleKey) ?? false;
 }

 // Save repeat mode (0: off, 1: all, 2: one)
 Future<void> saveRepeatMode(int mode) async {
 final prefs = await SharedPreferences.getInstance();
 await prefs.setInt(_repeatKey, mode);
 }

 // Get repeat mode
 Future<int> getRepeatMode() async {
 final prefs = await SharedPreferences.getInstance();
 return prefs.getInt(_repeatKey) ?? 0;
 }

 // Save volume
 Future<void> saveVolume(double volume) async {
 final prefs = await SharedPreferences.getInstance();
 await prefs.setDouble(_volumeKey, volume);
 }

 // Get volume
 Future<double> getVolume() async {
 final prefs = await SharedPreferences.getInstance();
 return prefs.getDouble(_volumeKey) ?? 1.0;
 }

 Future<void> saveDynamicTheme(bool enabled) async {
   final prefs = await SharedPreferences.getInstance();
   await prefs.setBool(_dynamicThemeKey, enabled);
 }

 Future<bool> getDynamicTheme() async {
   final prefs = await SharedPreferences.getInstance();
   return prefs.getBool(_dynamicThemeKey) ?? false;
 }
}
