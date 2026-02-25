import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';
import 'package:personaltrainer_mobile/providers/blob_storage_provider.dart';
import 'package:personaltrainer_mobile/providers/equipment_provider.dart';
import 'package:personaltrainer_mobile/providers/exerciseProvider.dart';
import 'package:personaltrainer_mobile/providers/exercise_plan.dart';
import 'package:personaltrainer_mobile/providers/gym_provider.dart';
import 'package:personaltrainer_mobile/providers/muscle_group_provider.dart';
import 'package:personaltrainer_mobile/providers/training_plan_provider.dart';
import 'package:personaltrainer_mobile/providers/training_provider.dart';
import 'package:personaltrainer_mobile/providers/user_provider.dart';
import 'package:personaltrainer_mobile/providers/signalr_provider.dart';
import 'package:personaltrainer_mobile/screens/training_plan_screen.dart';
import 'package:personaltrainer_mobile/screens/register_screen.dart';
import 'package:personaltrainer_mobile/screens/change_password_screen.dart';
import 'package:provider/provider.dart';
import 'package:personaltrainer_mobile/providers/messages_provider.dart';

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
            return MaterialPageRoute(builder: (context) => TrainingPlanScreen());
          case '/change-password':
            return MaterialPageRoute(builder: (context) => ChangePasswordScreen());
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
      print('📱 Initial link: $uri');
      if (uri != null) {
        _handleDeepLink(uri);
      }
    } catch (e) {
      print('❌ Error getting initial link: $e');
    }

    // Listen for incoming links
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      print('📱 Incoming link: $uri');
      _handleDeepLink(uri);
    }, onError: (err) {
      print('❌ Error listening to links: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    print('📱 Handling deep link: $uri');
    print('📱 Scheme: ${uri.scheme}');
    print('📱 Host: ${uri.host}');
    print('📱 Path: ${uri.path}');
    print('📱 Query params: ${uri.queryParameters}');

    // Handle custom scheme: personaltrainerapp://reset-password?token=xxx
    if (uri.scheme == 'personaltrainerapp' && uri.host == 'reset-password') {
      final token = uri.queryParameters['token'];
      print('📱 Reset token: ${token?.substring(0, 30)}...');
      
      final email = uri.queryParameters['email'];
      print('📱 Email from deep link: $email');
      
      if (email != null && email.isNotEmpty && mounted) {
        print('✅ Navigating to password reset screen');
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
      print('📱 Email from HTTP: $email');
      
      if (email != null && email.isNotEmpty && mounted) {
        print('✅ Navigating to password reset screen');
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
    print('🌐 ========== WEB URL HANDLER ==========');
    print('🌐 Full URI: $uri');
    print('🌐 Fragment: "${uri.fragment}"');
    print('🌐 Fragment isEmpty: ${uri.fragment.isEmpty}');
    
    if (uri.fragment.isNotEmpty) {
      try {
        final fragmentPath = uri.fragment;
        print('🌐 Raw fragment: "$fragmentPath"');
        
        final parts = fragmentPath.split('?');
        final path = parts[0];
        
        print('🌐 Path from fragment: "$path"');
        print('🌐 Number of parts: ${parts.length}');
        
        if (path == '/reset-password') {
          print('🌐 ✓ Path matches /reset-password');
          
          if (parts.length > 1) {
            final queryString = parts[1];
            print('🌐 Query string: "${queryString.substring(0, queryString.length > 50 ? 50 : queryString.length)}..."');
            
            final queryParams = Uri.splitQueryString(queryString);
            print('🌐 Parsed query params keys: ${queryParams.keys.toList()}');
            
            final token = queryParams['token'];
            
            if (token != null) {
              print('🌐 Token found: ${token.substring(0, token.length > 30 ? 30 : token.length)}...');
              print('🌐 Token length: ${token.length}');
              
              if (token.isNotEmpty) {
                print('✅ All checks passed - Navigating to password reset screen');
                final email = uri.queryParameters['email'];
                
                Future.delayed(Duration(milliseconds: 100), () {
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen(email: email),
                      ),
                    );
                  }
                });
                return;
              } else {
                print('❌ Token is empty');
              }
            } else {
              print('❌ Token is null');
            }
          } else {
            print('❌ No query parameters found (parts.length = ${parts.length})');
          }
        } else {
          print('❌ Path "$path" does not match /reset-password');
        }
      } catch (e, stack) {
        print('❌ Error handling URL: $e');
        print('Stack trace: $stack');
      }
    } else {
      print('🌐 Fragment is empty - staying on login page');
    }
    
    print('🌐 ========== END URL HANDLER ==========');
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
                      print("Attempting login with: $username");
                      try {
                        // Call the proper login endpoint
                        var data = await userProvider.login(username, password);
                        print("✅ Login successful");
                        print("Login response: $data");

                        // JWT token is already stored by userProvider.login via AuthProvider.applyLoginResponse
                        print(
                          "📝 JWT token stored - User ID: ${AuthProvider.userId}",
                        );
                        print(
                          "📝 Token present: ${AuthProvider.token != null ? 'Yes' : 'No'}",
                        );

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
                        print("❌ Login failed: $e");
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Login Error"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Ok"),
                              ),
                            ],
                            content: Text("Invalid username or password. Please try again."),
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
    final TextEditingController tokenController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Reset Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Paste your reset link or token from the email:",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            TextField(
              controller: tokenController,
              decoration: InputDecoration(
                labelText: "Reset Link or Token",
                hintText: "personaltrainerapp://reset-password?token=...",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final input = tokenController.text.trim();
              if (input.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please paste a reset link or token")),
                );
                return;
              }
              
              String? token;
              String? email;
              
              // Try to extract token from URL
              if (input.contains('token=') || input.contains('email=')) {
                final parsedUri = Uri.tryParse(input);
                if (parsedUri != null) {
                  token = parsedUri.queryParameters['token'];
                  email = parsedUri.queryParameters['email'];
                } else {
                  // Try to extract from plain string
                  final tokenMatch = RegExp(r'token=([^&\s]+)').firstMatch(input);
                  if (tokenMatch != null) {
                    token = tokenMatch.group(1);
                  }
                  final emailMatch = RegExp(r'email=([^&\s]+)').firstMatch(input);
                  if (emailMatch != null) {
                    email = emailMatch.group(1);
                  }
                }
              } else {
                // Assume entire input is the token
                token = input;
              }
              
              if (token != null && token.isNotEmpty) {
                Navigator.pop(context); // Close dialog
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordScreen(email: email),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Could not extract token from input")),
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
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
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
