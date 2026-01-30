import 'package:first_flutter/data/models/sentence.dart';
import 'package:first_flutter/data/repositories/authentication_repository.dart';
import 'package:first_flutter/data/repositories/sentence_repository.dart';
import 'package:first_flutter/data/services/authentication_service.dart';
import 'package:first_flutter/data/services/sentence_service.dart';
import 'package:first_flutter/presentation/viewmodels/login_vm.dart';
import 'package:first_flutter/presentation/viewmodels/profile_vm.dart';
import 'package:first_flutter/presentation/viewmodels/sentence_creation_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/viewmodels/sentence_vm.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<ISentenceService>(
          create: (context) => SentenceService(), // ISentenceService instance
        ),
        Provider<IAuthenticationService>(
          create: (context) =>
              AuthenticationService(), // ILoginService instance
        ),
        Provider<ISentenceRepository>(
          create: (context) => SentenceRepository(
            sentenceService: context.read(),
          ), //ISentenceRepository instance
        ),
        ChangeNotifierProvider<IAuthenticationRepository>(
          create: (context) => AuthenticationRepository(
            authenticationService: context.read(),
          ), //ILoginRepository instance
        ),
        ChangeNotifierProvider<SentenceCreationVM>(
          create: (context) =>
              SentenceCreationVM(sentenceRepository: context.read()),
        ),
        ChangeNotifierProvider<LoginVM>(
          create: (context) =>
              LoginVM(authenticationRepository: context.read()),
        ),
        ChangeNotifierProvider<ProfileVM>(
          create: (context) =>
              ProfileVM(authenticationRepository: context.read()),
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
    return ChangeNotifierProvider(
      create: (context) => SentenceVM(sentenceRepository: context.read()),
      child: MaterialApp(
        title: 'Sentence App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; // ← Add this property.

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      case 2:
        page = CreationPage();
      case 3:
        page = LoginPage();
      case 4:
        page = ProfilePage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 450) {
          return Scaffold(
            body: Row(children: [MainArea(page: page)]),
            bottomNavigationBar: NavigationBar(
              destinations: [
                NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(
                  icon: Icon(Icons.favorite),
                  label: 'Favorites',
                ),
                NavigationDestination(
                  icon: Icon(Icons.create),
                  label: 'Creation',
                ),
                NavigationDestination(icon: Icon(Icons.login), label: 'Login'),
                NavigationDestination(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          );
        } else {
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 800, // ← Here.
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite),
                        label: Text('Favorites'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.create),
                        label: Text('Creation'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.login),
                        label: Text('Login'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person),
                        label: Text('Profile'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                MainArea(page: page),
              ],
            ),
          );
        }
      },
    );
  }
}

class MainArea extends StatelessWidget {
  const MainArea({super.key, required this.page});

  final Widget page;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: page,
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var vm = context.watch<SentenceVM>();

    if (vm.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    var sentence = vm.current;
    IconData icon;
    if (vm.isFavorite(sentence)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, //Main axis is vertical for Column
        children: [
          Expanded(
            child: ListView(
              children: [
                for (var word in vm.history)
                  ListTile(
                    leading: Icon(
                      vm.isFavorite(word)
                          ? Icons.favorite
                          : Icons.favorite_border,
                    ),
                    title: Text(word.text),
                  ),
              ],
            ),
          ),
          Text('A random AWESOME  idea:'),
          BigCard(pair: sentence),
          // ↓ Add this.
          SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min, // ← Add this.
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  vm.toggleCurrentFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 20), // ← Add some spacing between buttons.
              ElevatedButton(
                onPressed: () {
                  vm.next();
                },
                child: Text('Next'),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var vm = context.watch<SentenceVM>();

    if (vm.favorites.isEmpty) {
      return Center(child: Text('No favorites yet.'));
    }
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'You have '
            '${vm.favorites.length} favorites:',
          ),
        ),
        for (var word in vm.favorites)
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.favorite),
              color: Theme.of(context).colorScheme.primary,
              onPressed: () {
                vm.toggleFavorite(word);
              },
              tooltip: 'Remove from favorites',
            ),
            title: Text(word.text),
          ),
      ],
    );
  }
}

class CreationPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var vm = context.watch<SentenceCreationVM>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Enter Sentence'),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            vm.createSentence(_controller.text);
          },
          child: const Text('Create Sentence'),
        ),
        const SizedBox(height: 20),
        vm.isLoading
            ? const CircularProgressIndicator()
            : vm.createdSentence != null
            ? Text('Your created sentence: ${vm.createdSentence!.text}')
            : Text("Not created yet."),
        const SizedBox(height: 20),
      ],
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var vm = context.watch<LoginVM>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextField(
            controller: _userController,
            decoration: const InputDecoration(hintText: 'Enter Username'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextField(
            controller: _passwordController,
            decoration: const InputDecoration(hintText: 'Enter Password'),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            vm.validateLogin(_userController.text, _passwordController.text);
          },
          child: const Text('Login'),
        ),
        const SizedBox(height: 20),
        vm.isLoading
            ? const CircularProgressIndicator()
            : vm.error != null
            ? Text('Error: ${vm.error}')
            : vm.user != null
            ? Text('You are logged in as: ${vm.user!.username}')
            : Text("Not logged in yet."),
        const SizedBox(height: 20),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("Building ProfilePage...");
    var vm = context.watch<ProfileVM>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Add UI elements to display profile information only if profile is loaded
        vm.isLoading
            ? const CircularProgressIndicator()
            : vm.error != null
            ? Text('Error: ${vm.error}')
            : vm.profile != null
            ? Column(
                children: [
                  Text(
                    'Profile Username: ${vm.profile?.username}',
                  ),
                  Text('Profile Email: ${vm.profile?.email}'),
                  Text('First Name: ${vm.profile?.firstname}'),
                  Text('Last Name: ${vm.profile?.lastname}'),
                  Text('Birthdate: ${vm.profile?.birthdate}'),
                ],
              ): Text("Profile not loaded yet."),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.pair});

  final Sentence pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      shadows: [
        Shadow(color: theme.colorScheme.primaryContainer, blurRadius: 10),
      ],
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(pair.text, style: style),
      ),
    );
  }
}
