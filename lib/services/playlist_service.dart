import 'package:on_audio_query/on_audio_query.dart' as oq;
import '../models/song_model.dart';

enum SongSortMode { title, artist, album, dateAdded }
enum SongFilterMode { none, artist, album }

class PlaylistService {
  final oq.OnAudioQuery _audioQuery = oq.OnAudioQuery();

  Future<List<SongModel>> getAllSongs({
    SongSortMode sort = SongSortMode.title,
    bool ascending = true,
    SongFilterMode filterMode = SongFilterMode.none,
    String? filterValue,
  }) async {
    try {
      final sortType = switch (sort) {
        SongSortMode.title => oq.SongSortType.TITLE,
        SongSortMode.artist => oq.SongSortType.ARTIST,
        SongSortMode.album => oq.SongSortType.ALBUM,
        SongSortMode.dateAdded => oq.SongSortType.DATE_ADDED,
      };

      final orderType = ascending
          ? oq.OrderType.ASC_OR_SMALLER
          : oq.OrderType.DESC_OR_GREATER;

      final List<oq.SongModel> audioList = await _audioQuery.querySongs(
        sortType: sortType,
        orderType: orderType,
        uriType: oq.UriType.EXTERNAL,
        ignoreCase: true,
      );

      var songs =
      audioList.map((audio) => SongModel.fromAudioQuery(audio)).toList();

      // FILTER
      if (filterMode != SongFilterMode.none &&
          (filterValue?.trim().isNotEmpty ?? false)) {
        final fv = filterValue!.trim().toLowerCase();
        if (filterMode == SongFilterMode.artist) {
          songs = songs.where((s) => s.artist.toLowerCase() == fv).toList();
        } else if (filterMode == SongFilterMode.album) {
          songs = songs
              .where((s) => (s.album ?? '').trim().toLowerCase() == fv)
              .toList();
        }
      }

      return songs;
    } catch (e) {
      throw Exception('Error loading songs: $e');
    }
  }

  Future<SongModel?> getSongById(String id) async {
    final all = await getAllSongs();
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
