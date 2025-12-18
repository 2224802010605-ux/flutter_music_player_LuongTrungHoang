import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Playback', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _VolumeTile(),
            const SizedBox(height: 24),
            const Text('Appearance', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Consumer<ThemeProvider>(
              builder: (context, theme, child) {
                return SwitchListTile(
                  value: theme.dynamicTheme,
                  onChanged: (v) => theme.setDynamicTheme(v),
                  activeColor: AppColors.primary,
                  title: const Text('Dynamic theme from album art', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Bonus feature (optional)', style: TextStyle(color: Colors.grey)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _VolumeTile extends StatefulWidget {
  @override
  State<_VolumeTile> createState() => _VolumeTileState();
}

class _VolumeTileState extends State<_VolumeTile> {
  double _volume = 1.0;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    // no direct getter; start at 1.0 as per storage default
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Volume', style: TextStyle(color: Colors.white)),
        Slider(
          value: _volume,
          min: 0.0,
          max: 1.0,
          activeColor: AppColors.primary,
          onChanged: (v) async {
            setState(() => _volume = v);
            await context.read<AudioProvider>().setVolume(v);
          },
        ),
      ],
    );
  }
}
