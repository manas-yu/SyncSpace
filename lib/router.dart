import 'package:dodoc/screens/home_screen.dart';
import 'package:dodoc/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoutes = RouteMap(
  routes: {
    '/': (route) {
      return const MaterialPage(child: LoginScreen());
    },
  },
);
final loggedInRoutes = RouteMap(
  routes: {
    '/': (route) {
      return const MaterialPage(child: HomeScreen());
    },
  },
);