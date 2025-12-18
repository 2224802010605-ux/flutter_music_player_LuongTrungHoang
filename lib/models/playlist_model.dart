class PlaylistModel {
 final String id;
 final String name;
 final List<String> songIds;
 final DateTime createdAt;
 final DateTime updatedAt;
 final String? coverImage;

 PlaylistModel({
 required this.id,
 required this.name,
 required this.songIds,
 required this.createdAt,
 required this.updatedAt,
 this.coverImage,
 });

 factory PlaylistModel.fromJson(Map<String, dynamic> json) {
 return PlaylistModel(
 id: json['id'],
 name: json['name'],
 songIds: List<String>.from(json['songIds']),
 createdAt: DateTime.parse(json['createdAt']),
 updatedAt: DateTime.parse(json['updatedAt']),
 coverImage: json['coverImage'],
 );
 }

 Map<String, dynamic> toJson() {
 return {
 'id': id,
 'name': name,
 'songIds': songIds,
 'createdAt': createdAt.toIso8601String(),
 'updatedAt': updatedAt.toIso8601String(),
 'coverImage': coverImage,
 };
 }

 PlaylistModel copyWith({
 String? name,
 List<String>? songIds,
 DateTime? updatedAt,
 String? coverImage,
 }) {
 return PlaylistModel(
 id: this.id,
 name: name ?? this.name,
 songIds: songIds ?? this.songIds,
 createdAt: this.createdAt,
 updatedAt: updatedAt ?? DateTime.now(),
 coverImage: coverImage ?? this.coverImage,
 );
 }
}
