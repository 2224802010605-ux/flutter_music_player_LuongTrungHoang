import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService _storage;
  bool _dynamicTheme = false;
  Color _accent = AppColors.primary;

  ThemeProvider(this._storage) {
    _init();
  }

  bool get dynamicTheme => _dynamicTheme;
  Color get accent => _accent;

  Future<void> _init() async {
    _dynamicTheme = await _storage.getDynamicTheme();
    notifyListeners();
  }

  Future<void> setDynamicTheme(bool enabled) async {
    _dynamicTheme = enabled;
    await _storage.saveDynamicTheme(enabled);
    notifyListeners();
  }

  void setAccent(Color color) {
    _accent = color;
    notifyListeners();
  }
}
