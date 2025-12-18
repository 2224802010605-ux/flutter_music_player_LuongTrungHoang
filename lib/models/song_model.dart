class SongModel {
 final String id;
 final String title;
 final String artist;
 final String? album;
 final String filePath;
 final Duration duration;

 // Dùng cho QueryArtworkWidget
 final int? albumId;

 // Dùng cho sort DATE_ADDED
 final int? dateAdded;

 // Giữ lại để không vỡ code cũ (bạn đang dùng song.albumArt)
 // Nhưng về sau không cần nữa vì ta dùng albumId để lấy artwork.
 final String? albumArt;

 SongModel({
  required this.id,
  required this.title,
  required this.artist,
  required this.album,
  required this.filePath,
  required this.duration,
  this.albumId,
  this.dateAdded,
  this.albumArt,
 });

 factory SongModel.fromAudioQuery(dynamic audio) {
  return SongModel(
   id: (audio.id ?? '').toString(),
   title: (audio.title ?? 'Unknown'),
   artist: (audio.artist ?? 'Unknown'),
   album: audio.album,
   filePath: audio.data ?? '',
   duration: Duration(milliseconds: audio.duration ?? 0),
   albumId: audio.albumId,
   dateAdded: audio.dateAdded,
   albumArt: null, // không dùng path nữa
  );
 }
}
