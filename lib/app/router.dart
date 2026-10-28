import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globsi/features/flags_learn/flags_learn_screen.dart';
import 'package:globsi/features/globe/globe_screen.dart';
import 'package:globsi/features/home/home_screen.dart';
import 'package:globsi/features/practice/flag_practice_screen.dart';
import 'package:globsi/features/practice/map_practice_screen.dart';
import 'package:globsi/features/settings/settings_screen.dart';
import 'package:globsi/features/stats/stats_screen.dart';
import 'package:go_router/go_router.dart';

abstract final class Routes {
  static const home = '/';
  static const explore = '/explore';
  static const flagsLearn = '/flags';
  static const mapPractice = '/practice/map';
  static const flagPractice = '/practice/flags';
  static const settings = '/settings';
  static const stats = '/stats';

  /// Explore, focused on country [id].
  static String exploreCountry(String id) =>
      Uri(path: explore, queryParameters: {'focus': id}).toString();
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'explore',
            builder: (context, state) =>
                GlobeScreen(focusId: state.uri.queryParameters['focus']),
          ),
          GoRoute(
            path: 'flags',
            builder: (context, state) => const FlagsLearnScreen(),
          ),
          GoRoute(
            path: 'practice/map',
            builder: (context, state) => const MapPracticeScreen(),
          ),
          GoRoute(
            path: 'practice/flags',
            builder: (context, state) => const FlagPracticeScreen(),
          ),
          GoRoute(
            path: 'stats',
            builder: (context, state) => const StatsScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
