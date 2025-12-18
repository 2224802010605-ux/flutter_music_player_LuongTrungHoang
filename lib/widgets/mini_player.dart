import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../screens/now_playing_screen.dart';
import '../utils/constants.dart';
import '../widgets/album_art.dart';
import '../models/playback_state_model.dart';

class MiniPlayer extends StatelessWidget {
 const MiniPlayer({super.key});

 @override
 Widget build(BuildContext context) {
 return GestureDetector(
 onTap: () {
 Navigator.push(
 context,
 MaterialPageRoute(builder: (_) => NowPlayingScreen()),
 );
 },
 child: Container(
 height: AppDimens.miniPlayerHeight,
 decoration: BoxDecoration(
 color: AppColors.card,
 boxShadow: [
 BoxShadow(
 color: Colors.black.withOpacity(0.3),
 blurRadius: 10,
 offset: const Offset(0, -5),
 ),
 ],
 ),
 child: Consumer<AudioProvider>(
 builder: (context, provider, child) {
 final song = provider.currentSong;
 if (song == null) return const SizedBox.shrink();
 return Column(
 children: [
 // Progress indicator
 StreamBuilder<PlaybackStateModel>(
 stream: provider.playbackStateStream,
 builder: (context, snapshot) {
 final progress = snapshot.data?.progress ?? 0.0;
 return LinearProgressIndicator(
 value: progress,
 backgroundColor: Colors.grey[800],
 valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
 minHeight: 2,
 );
 },
 ),
 // Player content
 Expanded(
 child: Padding(
 padding: const EdgeInsets.symmetric(horizontal: 16),
 child: Row(
 children: [
 AlbumArt(albumArtPath: song.albumArt, size: 50, radius: 4),
 const SizedBox(width: 12),
 Expanded(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 song.title,
 style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
 maxLines: 1,
 overflow: TextOverflow.ellipsis,
 ),
 Text(
 song.artist,
 style: const TextStyle(color: Colors.grey, fontSize: 12),
 maxLines: 1,
 overflow: TextOverflow.ellipsis,
 ),
 ],
 ),
 ),
 StreamBuilder<bool>(
 stream: provider.playingStream,
 builder: (context, snapshot) {
 final isPlaying = snapshot.data ?? false;
 return IconButton(
 icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 32),
 onPressed: () => provider.playPause(),
 );
 },
 ),
 IconButton(
 icon: const Icon(Icons.skip_next, color: Colors.white),
 onPressed: () => provider.next(),
 ),
 ],
 ),
 ),
 ),
 ],
 );
 },
 ),
 ),
 );
 }
}
