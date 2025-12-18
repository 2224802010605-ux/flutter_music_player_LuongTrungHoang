import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../services/playlist_service.dart';
import '../utils/constants.dart';
import '../widgets/playlist_card.dart';
import '../widgets/song_tile.dart';
import '../widgets/mini_player.dart';

class PlaylistScreen extends StatelessWidget {
  final List<SongModel> allSongs;
  const PlaylistScreen({super.key, required this.allSongs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Playlists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createPlaylistDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<PlaylistProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.playlists.isEmpty) {
                  return const Center(
                    child: Text('No playlists yet', style: TextStyle(color: Colors.grey)),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.playlists.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final p = provider.playlists[i];
                    return PlaylistCard(
                      playlist: p,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlaylistDetailScreen(playlistId: p.id, allSongs: allSongs),
                          ),
                        );
                      },
                    );
                  },
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

  Future<void> _createPlaylistDialog(BuildContext context) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Create playlist', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Playlist name',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              await context.read<PlaylistProvider>().createPlaylist(name);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;
  final List<SongModel> allSongs;

  const PlaylistDetailScreen({super.key, required this.playlistId, required this.allSongs});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final PlaylistService _service = PlaylistService();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlaylistProvider>();
    final playlist = provider.byId(widget.playlistId);

    if (playlist == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background, title: const Text('Playlist')),
        body: const Center(child: Text('Playlist not found', style: TextStyle(color: Colors.grey))),
      );
    }

    final songsInPlaylist = widget.allSongs.where((s) => playlist.songIds.contains(s.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(playlist.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _renameDialog(context, playlist),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await provider.deletePlaylist(playlist.id);
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _addSongBottomSheet(context, playlist),
        child: const Icon(Icons.playlist_add, color: Colors.white),
      ),
      body: Column(
        children: [
          if (songsInPlaylist.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<AudioProvider>().setPlaylist(songsInPlaylist, 0);
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Play'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: songsInPlaylist.isEmpty
                ? const Center(child: Text('No songs in playlist', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: songsInPlaylist.length,
                    itemBuilder: (_, i) {
                      final song = songsInPlaylist[i];
                      return SongTile(
                        song: song,
                        onTap: () => context.read<AudioProvider>().setPlaylist(songsInPlaylist, i),
                        onMore: () {
                          provider.removeSong(playlist.id, song.id);
                        },
                      );
                    },
                  ),
          ),
          Consumer<AudioProvider>(
            builder: (context, a, child) {
              if (a.currentSong == null) return const SizedBox.shrink();
              return const MiniPlayer();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _renameDialog(BuildContext context, PlaylistModel playlist) async {
    final controller = TextEditingController(text: playlist.name);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Rename playlist', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              await context.read<PlaylistProvider>().renamePlaylist(playlist.id, name);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addSongBottomSheet(BuildContext context, PlaylistModel playlist) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      builder: (_) {
        final height = MediaQuery.of(context).size.height * 0.75;
        return SizedBox(
          height: height,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 48, height: 5, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(99))),
              const SizedBox(height: 12),
              const Text('Add songs', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.allSongs.length,
                  itemBuilder: (_, i) {
                    final song = widget.allSongs[i];
                    final added = playlist.songIds.contains(song.id);
                    return ListTile(
                      title: Text(song.title, style: const TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(song.artist, style: const TextStyle(color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Icon(added ? Icons.check_circle : Icons.add_circle_outline, color: added ? AppColors.primary : Colors.white),
                      onTap: () async {
                        if (added) return;
                        await context.read<PlaylistProvider>().addSong(playlist.id, song.id);
                        if (context.mounted) setState(() {});
                      },
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
