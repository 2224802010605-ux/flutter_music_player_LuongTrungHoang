import 'package:flutter/material.dart';
import '../utils/duration_formatter.dart';
import '../utils/constants.dart';

class ProgressBar extends StatelessWidget {
 final Duration position;
 final Duration duration;
 final Function(Duration) onSeek;

 const ProgressBar({
 super.key,
 required this.position,
 required this.duration,
 required this.onSeek,
 });

 @override
 Widget build(BuildContext context) {
 return Column(
 children: [
 SliderTheme(
 data: SliderThemeData(
 trackHeight: 3,
 thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
 overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
 activeTrackColor: AppColors.primary,
 inactiveTrackColor: Colors.grey[800],
 thumbColor: Colors.white,
 overlayColor: AppColors.primary.withOpacity(0.3),
 ),
 child: Slider(
 value: position.inMilliseconds.toDouble().clamp(0.0, duration.inMilliseconds.toDouble().clamp(0.0, double.infinity)),
 min: 0.0,
 max: duration.inMilliseconds.toDouble().clamp(0.0, double.infinity),
 onChanged: (value) {
 onSeek(Duration(milliseconds: value.toInt()));
 },
 ),
 ),

 Padding(
 padding: const EdgeInsets.symmetric(horizontal: 24),
 child: Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text(
 DurationFormatter.mmss(position),
 style: const TextStyle(color: Colors.grey, fontSize: 12),
 ),
 Text(
 DurationFormatter.mmss(duration),
 style: const TextStyle(color: Colors.grey, fontSize: 12),
 ),
 ],
 ),
 ),
 ],
 );
 }
}
