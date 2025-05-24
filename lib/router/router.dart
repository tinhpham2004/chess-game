import 'package:chess_game/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
late GoRouter router;

class BaseRouter {
  BaseRouter();

  static String get currentLocation {
    final lastMatch = router.routerDelegate.currentConfiguration.last;
    final matchList = lastMatch is ImperativeRouteMatch ? lastMatch.matches : router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  GoRouter get baseRouter {
    router = GoRouter(
      initialLocation: _getInitialLocation(),
      navigatorKey: rootNavigatorKey,
      routes: [...AppRouter.routes],
    );

    return router;
  }

  String? _getInitialLocation() => AppRouter.homeScreen;
}
