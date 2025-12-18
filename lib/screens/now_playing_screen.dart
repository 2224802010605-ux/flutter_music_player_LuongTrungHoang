import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../models/playback_state_model.dart';
import '../providers/audio_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/color_extractor.dart';
import '../utils/constants.dart';
import '../widgets/album_art.dart';
import '../widgets/progress_bar.dart';
import '../widgets/player_controls.dart';

class NowPlayingScreen extends StatelessWidget {
 @override
 Widget build(BuildContext context) {
  return Scaffold(
   backgroundColor: AppColors.background,
   body: Consumer<AudioProvider>(
    builder: (context, provider, child) {
     final song = provider.currentSong;

     if (song == null) {
      return const Center(child: Text('No song playing'));
     }

     // dynamic theme accent (optional)
     _maybeUpdateAccent(context, song);

     return SafeArea(
      child: Column(
       children: [
        _buildAppBar(context),
        Expanded(
         child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
            // Album Art (chuẩn theo albumId)
            Container(
             width: 300,
             height: 300,
             decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
               BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
               ),
              ],
             ),
             child: AlbumArt(
              albumId: song.albumId,
              albumArtPath: song.albumArt,
              size: 300,
              radius: 8,
             ),
            ),
            const SizedBox(height: 40),
            _buildSongInfo(song),
            const SizedBox(height: 40),
            StreamBuilder<PlaybackStateModel>(
             stream: provider.playbackStateStream,
             builder: (context, snapshot) {
              final state = snapshot.data;
              return ProgressBar(
               position: state?.position ?? Duration.zero,
               duration: state?.duration ?? Duration.zero,
               onSeek: (position) => provider.seek(position),
              );
             },
            ),
            const SizedBox(height: 20),
            PlayerControls(provider: provider),
           ],
          ),
         ),
        ),
       ],
      ),
     );
    },
   ),
  );
 }

 Future<void> _maybeUpdateAccent(BuildContext context, SongModel song) async {
  final theme = context.read<ThemeProvider>();
  if (!theme.dynamicTheme) return;

  // Bạn đang trích màu từ file path albumArt, nhưng giờ artwork lấy từ MediaStore.
  // Nếu muốn dynamic theme “đúng nghĩa”, cần trích màu từ artwork bytes.
  // Để không vỡ code, mình giữ nguyên: nếu không có path thì bỏ qua.
  if (song.albumArt == null) return;

  final color = await ColorExtractor.dominantColorFromFile(song.albumArt!);
  if (color != null) theme.setAccent(color);
 }

 Widget _buildAppBar(BuildContext context) {
  return Padding(
   padding: const EdgeInsets.all(16),
   child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
     IconButton(
      icon: const Icon(Icons.keyboard_arrow_down,
          color: Colors.white, size: 32),
      onPressed: () => Navigator.pop(context),
     ),
     const Text(
      'Now Playing',
      style: TextStyle(color: Colors.white, fontSize: 16),
     ),
     IconButton(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onPressed: () {},
     ),
    ],
   ),
  );
 }

 Widget _buildSongInfo(SongModel song) {
  return Column(
   children: [
    Text(
     song.title,
     style: const TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
     ),
     textAlign: TextAlign.center,
     maxLines: 2,
     overflow: TextOverflow.ellipsis,
    ),
    const SizedBox(height: 8),
    Text(
     song.artist,
     style: const TextStyle(color: Colors.grey, fontSize: 16),
     textAlign: TextAlign.center,
    ),
   ],
  );
 }
}
