import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LottieCache {
  // Singleton instance
  static final LottieCache _instance = LottieCache._internal();
  factory LottieCache() => _instance;
  LottieCache._internal();

  // Cache to store downloaded JSON data
  final Map<String, String> _cache = {};
  bool _isPreloaded = false;
  
  // URLs of animations used in the app
  static const String transitUpdatesUrl = 'https://lottie.host/c3840e87-654a-46c8-95dc-495ca29192d8/8ExnBLLBxR.json';
  static const String greenPointsUrl = 'https://lottie.host/fd392de6-f482-4da0-bae9-ee7dfe804ed1/EBwuP8nh8a.json';
  static const String nfcScanUrl = 'https://lottie.host/d129a21f-30b5-4d9a-a46b-89273b31a04f/UnSsoKtWuw.json';
  static const String emptyFavoritesUrl = 'https://lottie.host/afd0bcc2-4c2e-4907-b4bf-58f09a54a3ae/y3k9UjOHCQ.json';
  static const String noSearchResultsUrl = 'https://lottie.host/4b2ea990-4d76-4439-824f-d0a7ad476586/ZZL3OHDool.json';

  bool get isPreloaded => _isPreloaded;

  // Preload all animations used in the app
  Future<void> preloadAll() async {
    if (_isPreloaded) return;
    
    await Future.wait([
      _downloadAndCache(transitUpdatesUrl),
      _downloadAndCache(greenPointsUrl),
      _downloadAndCache(nfcScanUrl),
      _downloadAndCache(emptyFavoritesUrl),
      _downloadAndCache(noSearchResultsUrl),
    ]);
    
    _isPreloaded = true;
  }

  // Download and cache a single animation
  Future<void> _downloadAndCache(String url) async {
    if (_cache.containsKey(url)) return;
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        // Store the raw JSON string
        _cache[url] = utf8.decode(response.bodyBytes);
      }
    } catch (e) {
      debugPrint('Failed to download Lottie animation: $e');
    }
  }

  // Get a widget that displays a cached animation or loads it from network
  Widget getLottieWidget({
    required String url,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    bool repeat = true,
    bool animate = true,
  }) {
    if (_cache.containsKey(url)) {
      // Use cached animation from memory
      return Lottie.memory(
        utf8.encode(_cache[url]!),
        width: width,
        height: height,
        fit: fit,
        repeat: repeat,
        animate: animate,
      );
    }
    
    // Fallback to loading from network
    return Lottie.network(
      url,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
      animate: animate,
    );
  }
} 