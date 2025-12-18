import 'package:flutter/material.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';

class PlayerControls extends StatelessWidget {
 final AudioProvider provider;

 const PlayerControls({super.key, required this.provider});

 @override
 Widget build(BuildContext context) {
  return Column(
   children: [
    // Secondary controls (shuffle, repeat)
    Row(
     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
     children: [
      Column(
       children: [
        IconButton(
         icon: Icon(
          Icons.shuffle,
          color: provider.isShuffleEnabled ? AppColors.primary : Colors.grey,
         ),
         onPressed: provider.toggleShuffle,
        ),
        const SizedBox(height: 2),
        const Text('Shuffle', style: TextStyle(color: Colors.grey, fontSize: 12)),
       ],
      ),
      const SizedBox(width: 20),
      Column(
       children: [
        _buildRepeatButton(),
        const SizedBox(height: 2),
        Text(
         _repeatLabel(),
         style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
       ],
      ),
     ],
    ),

    const SizedBox(height: 20),

    // Main controls
    Row(
     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
     children: [
      IconButton(
       icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
       onPressed: provider.previous,
      ),

      StreamBuilder<bool>(
       stream: provider.playingStream,
       builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;
        return Container(
         width: 70,
         height: 70,
         decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
         ),
         child: IconButton(
          icon: Icon(
           isPlaying ? Icons.pause : Icons.play_arrow,
           color: Colors.white,
           size: 40,
          ),
          onPressed: provider.playPause,
         ),
        );
       },
      ),

      IconButton(
       icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
       onPressed: provider.next,
      ),
     ],
    ),
   ],
  );
 }

 String _repeatLabel() {
  // provider.loopMode thường là LoopMode (just_audio), nhưng UI không import just_audio.
  // Dùng toString() để không phụ thuộc type.
  final v = provider.loopMode.toString();
  if (v.contains('one')) return 'Repeat 1';
  if (v.contains('all')) return 'Repeat all';
  return 'Repeat off';
 }

 Widget _buildRepeatButton() {
  final v = provider.loopMode.toString();

  IconData icon;
  Color color;

  if (v.contains('one')) {
   icon = Icons.repeat_one;
   color = AppColors.primary;
  } else if (v.contains('all')) {
   icon = Icons.repeat;
   color = AppColors.primary;
  } else {
   icon = Icons.repeat;
   color = Colors.grey;
  }

  return IconButton(
   icon: Icon(icon, color: color),
   onPressed: provider.toggleRepeat,
  );
 }
}
