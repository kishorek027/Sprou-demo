import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      home: const SignInPage(),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _loading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _loading = false);
        return; // User canceled
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? user = userCredential.user;

      if (!mounted) return;

      if (user != null) {
        final usersCollection = FirebaseFirestore.instance.collection('users');
        await usersCollection.doc(user.uid).set({
          'name': user.displayName,
          'email': user.email,
          'photoURL': user.photoURL,
          'uid': user.uid,
          'lastLogin': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(user: user)),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithFacebook() async {
    setState(() => _loading = true);

    try {
      print("Starting Facebook login...");
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile'],
      );
      print("Facebook login result: ${result.status}");

      if (result.status == LoginStatus.success) {
        print("Facebook login success, getting credential...");
        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.token,
        );

        print("Signing in to Firebase with Facebook credential...");
        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(credential);

        final User? user = userCredential.user;
        print("Firebase user: $user");

        if (!mounted) return;

        if (user != null) {
          print("User is not null, getting user data from Facebook...");
          final userData = await FacebookAuth.instance
              .getUserData(fields: "name")
              .timeout(const Duration(seconds: 10));
          print("User data from Facebook: $userData");

          print("Writing user data to Firestore...");
          final usersCollection = FirebaseFirestore.instance.collection(
            'users',
          );
          await usersCollection.doc(user.uid).set({
            'name': userData['name'] ?? user.displayName,
            'email': user.email,
            'photoURL': userData['picture']?['data']?['url'] ?? user.photoURL,
            'uid': user.uid,
            'lastLogin': FieldValue.serverTimestamp(),
            'provider': 'facebook',
          });

          if (!mounted) return;

          print("Navigating to HomePage...");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage(user: user)),
          );
        } else {
          print("Firebase user is null after Facebook sign-in.");
          setState(() => _loading = false);
          return;
        }
      } else if (result.status == LoginStatus.cancelled) {
        print("Facebook login cancelled by user.");
        setState(() => _loading = false);
        return;
      } else {
        print("Facebook login failed: ${result.status}");
        throw Exception('Facebook login failed: ${result.status}');
      }
    } catch (e) {
      print("Error getting user data from Facebook: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get Facebook user data: $e')),
        );
      }
      setState(() => _loading = false);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_person_rounded,
                      size: 80,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Welcome to Sprounest',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Sign in to continue'),
                    const SizedBox(height: 30),
                    // Google Sign In Button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.login, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _signInWithGoogle,
                      label: const Text(
                        'Sign in with Google',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Facebook Sign In Button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.facebook, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF1877F2,
                        ), // Facebook blue
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _signInWithFacebook,
                      label: const Text(
                        'Sign in with Facebook',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final User user;
  const HomePage({super.key, required this.user});

  Future<void> _signOut(BuildContext context) async {
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome"),
        actions: [
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundImage: NetworkImage(user.photoURL ?? ''),
            ),
            const SizedBox(height: 12),
            Text(user.displayName ?? '', style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(user.email ?? '', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
