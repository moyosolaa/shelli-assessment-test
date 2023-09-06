import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Employee {
  final String name;
  final int age;
  final int networth;
  Employee(this.name, this.age, this.networth);
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      json['employee_name'],
      json['employee_age'],
      json['employee_salary'],
    );
  }
}

Future<List<Employee>> fetchEmployees() async {
  final response = await http.get(Uri.parse('https://dummy.restapiexample.com/api/v1/employees'));
  if (response.statusCode == 200) {
    Map<String, dynamic> res = json.decode(response.body);
    List<dynamic> data = res['data'];
    return data.map((json) => Employee.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load employees');
  }
}

class YourHomePage extends StatefulWidget {
  const YourHomePage({super.key});

  @override
  _YourHomePageState createState() => _YourHomePageState();
}

class _YourHomePageState extends State<YourHomePage> {
  late Future<List<Employee>> futureEmployees;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    futureEmployees = fetchEmployees();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee List'),
        actions: [
          Switch(
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Employee>>(
          future: futureEmployees,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: 20, //snapshot.data!.length,
                itemBuilder: (context, index) {
                  final employee = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      title: Text('Name: ${employee.name}'),
                      trailing: Text('Age: ${employee.age}'),
                      subtitle: Text('Networth: ${employee.networth.toStringAsFixed(2)}'),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

final ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.light,
  inputDecorationTheme: const InputDecorationTheme(
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue),
    ),
  ),
);

// Dark theme data
final ThemeData darkTheme = ThemeData(
  primarySwatch: Colors.grey,
  brightness: Brightness.dark,
  inputDecorationTheme: const InputDecorationTheme(
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
  ),
);

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            theme: themeProvider.isDarkMode ? darkTheme : lightTheme,
            home: const YourHomePage(),
          );
        },
      ),
    ),
  );
}
