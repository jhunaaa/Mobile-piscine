import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();

  String place = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildTabContent(String tabName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          tabName,
          style: const TextStyle(fontSize: 20),
        ),
        Text(
          place,
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:
          Theme.of(context).colorScheme.inversePrimary,
          title: TextField(
            controller: _searchController,
            onSubmitted: (value) {
              setState(() {
                place = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search location',
              prefixIcon: const Icon(Icons.person_search),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: const Icon(Icons.location_on),
                onPressed: () {
                  setState(() {
                    place = "Geolocation";
                  });
                },
              ),
            ),
          ),
        ),

        body: TabBarView(
          children: [
            _buildTabContent("Currently"),
            _buildTabContent("Today"),
            _buildTabContent("Weekly"),
          ],
        ),

        bottomNavigationBar: BottomAppBar(
          child: TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: const [
              Tab(
                icon: Icon(Icons.wb_sunny),
                text: "Currently",
              ),
              Tab(
                icon: Icon(Icons.today),
                text: "Today",
              ),
              Tab(
                icon: Icon(Icons.calendar_view_week),
                text: "Weekly",
              ),
            ],
          ),
        ),
      ),
    );
  }
}