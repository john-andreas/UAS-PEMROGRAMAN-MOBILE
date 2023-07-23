import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class Station {
  final String code;
  final String name;
  final String city;
  final String cityName;

  Station({
    required this.code,
    required this.name,
    required this.city,
    required this.cityName,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stasiun Indonesia',
      theme: ThemeData(
        primaryColor: Colors.purple, // Change the primary color to purple
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple), // Set the color scheme
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Station>> _stationsFuture;
  late List<Station> _stations;

  @override
  void initState() {
    super.initState();
    _stationsFuture = fetchStations();
  }

  Future<List<Station>> fetchStations() async {
    final response =
        await http.get(Uri.parse('https://booking.kai.id/api/stations2'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      final List<Station> stations = [];

      for (var stationData in responseData) {
        Station station = Station(
          code: stationData['code'],
          name: stationData['name'],
          city: stationData['city'],
          cityName: stationData['cityname'],
        );
        stations.add(station);
      }

      return stations;
    } else {
      throw Exception('Failed to fetch stations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stasiun Indonesia'),
      ),
      body: FutureBuilder<List<Station>>(
        future: _stationsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _stations = snapshot.data!;

            return ListView.builder(
              itemCount: _stations.length,
              itemBuilder: (context, index) {
                Station station = _stations[index];
                return ListTile(
                  title: Text('${station.name} - ${station.cityName}'),
                  subtitle: Text(station.city),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
