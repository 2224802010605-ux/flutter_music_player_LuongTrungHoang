import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../services/playlist_service.dart';
import '../services/permission_service.dart';
import '../utils/constants.dart';
import '../widgets/song_tile.dart';
import '../widgets/mini_player.dart';

import 'all_songs_screen.dart';
import 'playlist_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlaylistService _playlistService = PlaylistService();
  final PermissionService _permissionService = PermissionService();

  List<SongModel> _songs = [];
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    setState(() {
      _isLoading = true;
    });

    final granted = await _permissionService.requestMusicPermission();
    if (!mounted) return;

    if (!granted) {
      setState(() {
        _hasPermission = false;
        _isLoading = false;
        _songs = [];
      });
      return;
    }

    _hasPermission = true;
    await _loadSongs();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadSongs() async {
    try {
      final songs = await _playlistService.getAllSongs();
      if (!mounted) return;
      setState(() => _songs = songs);
    } catch (e) {
      if (!mounted) return;
      setState(() => _songs = []);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading songs: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !_hasPermission
                  ? _buildPermissionDenied()
                  : _songs.isEmpty
                  ? _buildNoSongs()
                  : _buildSongList(),
            ),
            Consumer<AudioProvider>(
              builder: (context, provider, _) {
                if (provider.currentSong == null) return const SizedBox.shrink();
                return const MiniPlayer();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'My Music',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.library_music, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AllSongsScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.queue_music, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaylistScreen(allSongs: _songs),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SettingsScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () async {
                  await showSearch(
                    context: context,
                    delegate: _SongSearchDelegate(_songs),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSongList() {
    return ListView.builder(
      itemCount: _songs.length,
      itemBuilder: (context, index) {
        final song = _songs[index];
        return SongTile(
          song: song,
          onTap: () {
            context.read<AudioProvider>().setPlaylist(_songs, index);
          },
          onMore: () => _showSongOptions(song),
        );
      },
    );
  }

  void _showSongOptions(SongModel song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.play_arrow, color: Colors.white),
                title: const Text('Play', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  final idx = _songs.indexWhere((s) => s.id == song.id);
                  if (idx >= 0) {
                    context.read<AudioProvider>().setPlaylist(_songs, idx);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.white),
                title: const Text('Song info', style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  song.filePath,
                  style: const TextStyle(color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_off, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Permission Required',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 10),
          const Text(
            'Please grant permission to access music',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: openAppSettings,
            child: const Text('Open Settings'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _initializeApp,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSongs() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'No Music Found',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          SizedBox(height: 10),
          Text(
            'Add some music files to your device',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _SongSearchDelegate extends SearchDelegate {
  final List<SongModel> songs;
  _SongSearchDelegate(this.songs);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final q = query.toLowerCase().trim();
    final results = songs.where((s) =>
    s.title.toLowerCase().contains(q) ||
        s.artist.toLowerCase().contains(q) ||
        (s.album?.toLowerCase().contains(q) ?? false)).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) {
        final song = results[i];
        return SongTile(
          song: song,
          onTap: () {
            close(context, null);
            final idx = songs.indexWhere((x) => x.id == song.id);
            if (idx >= 0) {
              context.read<AudioProvider>().setPlaylist(songs, idx);
            }
          },
        );
      },
    );
  }
}

