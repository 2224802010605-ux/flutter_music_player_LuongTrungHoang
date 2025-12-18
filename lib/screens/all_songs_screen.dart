import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../services/playlist_service.dart';
import '../services/playlist_service.dart' show SongSortMode, SongFilterMode;
import '../utils/constants.dart';
import '../widgets/song_tile.dart';
import '../widgets/mini_player.dart';

class AllSongsScreen extends StatefulWidget {
  @override
  State<AllSongsScreen> createState() => _AllSongsScreenState();
}

class _AllSongsScreenState extends State<AllSongsScreen> {
  final PlaylistService _service = PlaylistService();

  List<SongModel> _songs = [];
  bool _loading = true;

  // SORT + FILTER state
  SongSortMode _sort = SongSortMode.title;
  bool _ascending = true;
  SongFilterMode _filterMode = SongFilterMode.none;
  String? _filterValue;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _songs = await _service.getAllSongs(
        sort: _sort,
        ascending: _ascending,
        filterMode: _filterMode,
        filterValue: _filterValue,
      );
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  // Lấy danh sách artist/album để filter
  List<String> get _allArtists {
    final set = <String>{};
    for (final s in _songs) {
      final v = s.artist.trim();
      if (v.isNotEmpty) set.add(v);
    }
    final list = set.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  List<String> get _allAlbums {
    final set = <String>{};
    for (final s in _songs) {
      final v = (s.album ?? '').trim();
      if (v.isNotEmpty) set.add(v);
    }
    final list = set.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  String _sortLabel(SongSortMode m) {
    switch (m) {
      case SongSortMode.title:
        return 'Title';
      case SongSortMode.artist:
        return 'Artist';
      case SongSortMode.album:
        return 'Album';
      case SongSortMode.dateAdded:
        return 'Date added';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('All Songs'),
        actions: [
          // SORT menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (v) async {
              if (v == 'asc') {
                setState(() => _ascending = true);
                await _load();
                return;
              }
              if (v == 'desc') {
                setState(() => _ascending = false);
                await _load();
                return;
              }
              setState(() {
                _sort = switch (v) {
                  'title' => SongSortMode.title,
                  'artist' => SongSortMode.artist,
                  'album' => SongSortMode.album,
                  'date' => SongSortMode.dateAdded,
                  _ => SongSortMode.title,
                };
              });
              await _load();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'title', child: Text('Sort by Title')),
              const PopupMenuItem(value: 'artist', child: Text('Sort by Artist')),
              const PopupMenuItem(value: 'album', child: Text('Sort by Album')),
              const PopupMenuItem(value: 'date', child: Text('Sort by Date added')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'asc', child: Text('Ascending')),
              const PopupMenuItem(value: 'desc', child: Text('Descending')),
            ],
          ),

          // FILTER button
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _openFilterSheet(),
          ),
        ],
      ),
      body: Column(
        children: [
          // nhỏ gọn: hiển thị trạng thái sort/filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                _chip('Sort: ${_sortLabel(_sort)} ${_ascending ? "↑" : "↓"}'),
                const SizedBox(width: 8),
                _chip(
                  _filterMode == SongFilterMode.none
                      ? 'Filter: None'
                      : 'Filter: ${_filterMode == SongFilterMode.artist ? "Artist" : "Album"}',
                ),
                if (_filterMode != SongFilterMode.none && (_filterValue?.isNotEmpty ?? false)) ...[
                  const SizedBox(width: 8),
                  Expanded(child: _chip('= $_filterValue')),
                ],
              ],
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _songs.length,
              itemBuilder: (_, i) {
                final song = _songs[i];
                return SongTile(
                  song: song,
                  onTap: () => context.read<AudioProvider>().setPlaylist(_songs, i),
                );
              },
            ),
          ),
          Consumer<AudioProvider>(
            builder: (context, provider, child) {
              if (provider.currentSong == null) return const SizedBox.shrink();
              return const MiniPlayer();
            },
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }

  Future<void> _openFilterSheet() async {
    final selected = await showModalBottomSheet<_FilterResult>(
      context: context,
      backgroundColor: AppColors.card,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Filter', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                ListTile(
                  leading: const Icon(Icons.clear, color: Colors.white),
                  title: const Text('None', style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context, _FilterResult(SongFilterMode.none, null)),
                ),

                ListTile(
                  leading: const Icon(Icons.person, color: Colors.white),
                  title: const Text('By Artist', style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    final v = await _pickFromList('Choose artist', _allArtists);
                    if (!mounted) return;
                    Navigator.pop(context, _FilterResult(SongFilterMode.artist, v));
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.album, color: Colors.white),
                  title: const Text('By Album', style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    final v = await _pickFromList('Choose album', _allAlbums);
                    if (!mounted) return;
                    Navigator.pop(context, _FilterResult(SongFilterMode.album, v));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null) return;

    setState(() {
      _filterMode = selected.mode;
      _filterValue = selected.value;
    });
    await _load();
  }

  Future<String?> _pickFromList(String title, List<String> items) async {
    if (items.isEmpty) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to filter')),
      );
      return null;
    }

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.card,
      builder: (_) {
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    return ListTile(
                      title: Text(items[i], style: const TextStyle(color: Colors.white)),
                      onTap: () => Navigator.pop(context, items[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterResult {
  final SongFilterMode mode;
  final String? value;
  _FilterResult(this.mode, this.value);
}
