import 'package:flutter/foundation.dart';

// Shared state for the logged-in username across the app
ValueNotifier<String?> loggedInUsername = ValueNotifier<String?>(null);