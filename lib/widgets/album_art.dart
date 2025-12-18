import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AlbumArt extends StatelessWidget {
  final int? albumId;
  final double size;
  final double radius;

  // Giữ lại param cũ để không vỡ code nơi khác (bạn đang truyền albumArtPath)
  final String? albumArtPath;

  const AlbumArt({
    super.key,
    this.albumId,
    required this.size,
    required this.radius,
    this.albumArtPath,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: QueryArtworkWidget(
        id: albumId ?? 0,
        type: ArtworkType.ALBUM,
        artworkFit: BoxFit.cover,
        size: 300,
        nullArtworkWidget: Container(
          width: size,
          height: size,
          color: Colors.white10,
          child: const Icon(Icons.music_note, color: Colors.grey),
        ),
      ),
    );
  }
}
