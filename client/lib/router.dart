import 'package:dodoc/screens/document_screen.dart';
import 'package:dodoc/screens/files_screen.dart';
import 'package:dodoc/screens/home_screen.dart';
import 'package:dodoc/screens/login_screen.dart';
import 'package:dodoc/screens/video_screen.dart';
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
    '/document/:id': (route) {
      final id = route.pathParameters['id'] ?? ' ';
      return MaterialPage(child: DocumentScreen(id: id));
    },
    '/document/:id/files': (route) {
      final roomId = route.pathParameters['id'] ?? ' ';
      return MaterialPage(child: FileScreen(roomId: roomId));
    },
    '/document/:id/video-screen': (route) {
      final roomId = route.pathParameters['id'] ?? ' ';
      return MaterialPage(child: VideoScreen(roomId: roomId));
    },
  },
);
