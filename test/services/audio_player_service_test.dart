import 'package:flutter_test/flutter_test.dart';
import 'package:offline_music_player/services/audio_player_service.dart';

void main() {
 group('AudioPlayerService Tests', () {
 late AudioPlayerService service;

 setUp(() {
 service = AudioPlayerService();
 });

 test('Service instantiates', () async {
 expect(service, isNotNull);
 });

 tearDown(() {
 service.dispose();
 });
 });
}
