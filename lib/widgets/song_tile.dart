import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../widgets/album_art.dart';

class SongTile extends StatelessWidget {
 final SongModel song;
 final VoidCallback onTap;
 final VoidCallback? onMore;

 const SongTile({
  super.key,
  required this.song,
  required this.onTap,
  this.onMore,
 });

 @override
 Widget build(BuildContext context) {
  return ListTile(
   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
   leading: AlbumArt(
    albumId: song.albumId,
    albumArtPath: song.albumArt, // giữ lại cho tương thích
    size: 50,
    radius: 4,
   ),
   title: Text(
    song.title,
    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
   ),
   subtitle: Text(
    song.artist,
    style: const TextStyle(color: Colors.grey),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
   ),
   trailing: IconButton(
    icon: const Icon(Icons.more_vert, color: Colors.grey),
    onPressed: onMore,
   ),
   onTap: onTap,
  );
 }
}
