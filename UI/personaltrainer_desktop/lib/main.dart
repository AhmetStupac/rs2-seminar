import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:personaltrainer_desktop/providers/auth_provider.dart';
import 'package:personaltrainer_desktop/providers/base_provider.dart';
import 'package:personaltrainer_desktop/providers/blob_storage_provider.dart';
import 'package:personaltrainer_desktop/providers/equipment_provider.dart';
import 'package:personaltrainer_desktop/providers/exerciseProvider.dart';
import 'package:personaltrainer_desktop/providers/exercise_plan.dart';
import 'package:personaltrainer_desktop/providers/gym_provider.dart';
import 'package:personaltrainer_desktop/providers/muscle_group_provider.dart';
import 'package:personaltrainer_desktop/providers/training_plan_provider.dart';
import 'package:personaltrainer_desktop/providers/training_provider.dart';
import 'package:personaltrainer_desktop/providers/user_provider.dart';
import 'package:personaltrainer_desktop/providers/signalr_provider.dart';
import 'package:personaltrainer_desktop/providers/admin_provider.dart';
import 'package:personaltrainer_desktop/screens/banned_screen.dart';
import 'package:personaltrainer_desktop/screens/training_plan_screen.dart';
import 'package:personaltrainer_desktop/screens/register_screen.dart';
import 'package:personaltrainer_desktop/screens/change_password_screen.dart';
import 'package:provider/provider.dart';
import 'package:personaltrainer_desktop/providers/messages_provider.dart';
import 'package:personaltrainer_desktop/providers/dashboard_provider.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ExerciseProvider>(
          create: (_) => ExerciseProvider(),
        ),
        ChangeNotifierProvider<MuscleGroupProvider>(
          create: (_) => MuscleGroupProvider(),
        ),
        ChangeNotifierProvider<TrainingProvider>(
          create: (_) => TrainingProvider(),
        ),
        ChangeNotifierProvider<BlobStorageProvider>(
          create: (_) => BlobStorageProvider(),
        ),
        ChangeNotifierProvider<EquipmentProvider>(
          create: (_) => EquipmentProvider(),
        ),
        ChangeNotifierProvider<ExercisePlanProvider>(
          create: (_) => ExercisePlanProvider(),
        ),
        ChangeNotifierProvider<TrainingPlanProvider>(
          create: (_) => TrainingPlanProvider(),
        ),
        ChangeNotifierProvider<SignalRProvider>(
          create: (_) => SignalRProvider(),
        ),
        ChangeNotifierProvider<MessagesProvider>(
          create: (_) => MessagesProvider(),
        ),
        ChangeNotifierProvider<GymProvider>(create: (_) => GymProvider()),
        ChangeNotifierProvider<DashboardProvider>(
          create: (_) => DashboardProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Widget homeWidget;

    // Choose appropriate handler based on platform
    if (kIsWeb) {
      homeWidget = _WebUrlHandler();
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Desktop platforms - use simple handler since app_links may not work
      homeWidget = _DesktopHandler();
    } else {
      // Mobile platforms (Android/iOS) - use app_links
      homeWidget = _MobileDeepLinkHandler();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Trainer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: homeWidget,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/register':
            return MaterialPageRoute(builder: (context) => RegisterScreen());
          case '/training-plans':
            return MaterialPageRoute(
              builder: (context) => TrainingPlanScreen(),
            );
          case '/change-password':
            return MaterialPageRoute(
              builder: (context) => ChangePasswordScreen(),
            );
          default:
            return MaterialPageRoute(builder: (context) => LoginPage());
        }
      },
    );
  }
}

// Desktop handler - simple approach for Windows/Mac/Linux
class _DesktopHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LoginPage();
  }
}

// Mobile/Desktop deep link handler using app_links
class _MobileDeepLinkHandler extends StatefulWidget {
  @override
  State<_MobileDeepLinkHandler> createState() => _MobileDeepLinkHandlerState();
}

class _MobileDeepLinkHandlerState extends State<_MobileDeepLinkHandler> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // Check initial link
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _handleDeepLink(uri);
      }
    } catch (e) {}

    // Listen for incoming links
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {});
  }

  void _handleDeepLink(Uri uri) {
    // Handle custom scheme: personaltrainerapp://reset-password?token=xxx
    if (uri.scheme == 'personaltrainerapp' && uri.host == 'reset-password') {
      final token = uri.queryParameters['token'];

      final email = uri.queryParameters['email'];

      if (email != null && email.isNotEmpty && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ChangePasswordScreen(email: email),
          ),
        );
      }
    }
    // Handle HTTP/HTTPS: http://localhost:8080/reset-password?email=xxx
    else if ((uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.path.contains('reset-password')) {
      final email = uri.queryParameters['email'];

      if (email != null && email.isNotEmpty && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ChangePasswordScreen(email: email),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoginPage();
  }
}

// Web URL handler (for web platform)
class _WebUrlHandler extends StatefulWidget {
  @override
  State<_WebUrlHandler> createState() => _WebUrlHandlerState();
}

class _WebUrlHandlerState extends State<_WebUrlHandler> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleWebUrl();
    });
  }

  void _handleWebUrl() {
    final uri = Uri.base;

    if (uri.fragment.isNotEmpty) {
      try {
        final fragmentPath = uri.fragment;

        final parts = fragmentPath.split('?');
        final path = parts[0];

        if (path == '/reset-password') {
          if (parts.length > 1) {
            final queryString = parts[1];

            final queryParams = Uri.splitQueryString(queryString);

            final token = queryParams['token'];

            if (token != null) {
              if (token.isNotEmpty) {
                final email = uri.queryParameters['email'];

                Future.delayed(Duration(milliseconds: 100), () {
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            ChangePasswordScreen(email: email),
                      ),
                    );
                  }
                });
                return;
              } else {}
            } else {}
          } else {}
        } else {}
      } catch (e, stack) {}
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return LoginPage();
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("login")),
      body: Center(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxHeight: 400, maxWidth: 400),
            child: Card(
              child: Column(
                children: [
                  Image.network(
                    "https://thumbs.dreamstime.com/b/man-running-against--sun-flat-vector-illustration-form-logo-icon-man-running-against-421221837.jpg",
                    height: 100,
                    width: 100,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.password),
                    ),
                    obscureText: true,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      UserProvider userProvider = UserProvider();
                      var username = _usernameController.text;
                      var password = _passwordController.text;
                      try {
                        // Call the proper login endpoint
                        var data = await userProvider.login(username, password);

                        // JWT token is already stored by userProvider.login via AuthProvider.applyLoginResponse

                        // Check if user is banned before proceeding
                        final adminProvider = AdminProvider();
                        final isBanned = await adminProvider.checkMyBan();

                        if (!context.mounted) return;

                        if (isBanned) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const BannedScreen(
                                reason: 'Your account has been banned by an administrator.',
                              ),
                            ),
                          );
                          return;
                        }

                        // Connect to SignalR after login
                        final signalRProvider = Provider.of<SignalRProvider>(
                          context,
                          listen: false,
                        );
                        signalRProvider.connect();

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => TrainingPlanScreen(),
                          ),
                        );
                      } on Exception catch (e) {
                        final errMsg = e.toString().replaceFirst(
                          'Exception: ',
                          '',
                        );
                        final isBan = errMsg.startsWith('BANNED:');
                        final isDeleted = errMsg.startsWith('DELETED:');

                        if (isBan) {
                          final banMessage = errMsg
                              .replaceFirst('BANNED:', '')
                              .trim();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => BannedScreen(
                                reason: banMessage.isNotEmpty
                                    ? banMessage
                                    : 'Your account has been banned by an administrator.',
                              ),
                            ),
                          );
                          return;
                        }

                        final deletedMessage = isDeleted
                            ? errMsg.replaceFirst('DELETED:', '').trim()
                            : null;
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Row(
                              children: [
                                Icon(
                                  isDeleted
                                      ? Icons.person_off
                                      : Icons.error_outline,
                                  color: isDeleted
                                      ? Colors.red
                                      : Colors.orange,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  isDeleted
                                      ? "Account Deleted"
                                      : "Login Error",
                                ),
                              ],
                            ),
                            content: Text(
                              isDeleted
                                  ? deletedMessage!
                                  : "Invalid username or password. Please try again.",
                              style: TextStyle(
                                color: isDeleted ? Colors.red[800] : null,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Ok"),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Text("Login"),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    },
                    child: Text("Don't have an account? Register"),
                  ),
                  TextButton(
                    onPressed: () {
                      _showResetPasswordDialog(context);
                    },
                    child: Text("Forgot Password? Reset Here"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Reset Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter your account email to receive a verification code:",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "name@example.com",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text("Please enter your email")),
                );
                return;
              }

              if (!email.contains('@') || !email.contains('.')) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text("Please enter a valid email")),
                );
                return;
              }

              final userProvider = UserProvider();
              final success = await userProvider.forgotPassword(email);

              if (!dialogContext.mounted) {
                return;
              }

              if (success) {
                Navigator.pop(dialogContext);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "If the email exists, a verification code has been sent.",
                    ),
                  ),
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordScreen(email: email),
                  ),
                );
              } else {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text("Failed to send verification code")),
                );
              }
            },
            child: Text("Continue"),
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
