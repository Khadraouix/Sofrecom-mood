import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sofrecommood/login_screen/login_screen.dart';

class TableItem {
  String matricule;
  String nom;
  String prenom;
  String humeur;
  String description;
  DateTime date;

  TableItem({
    required this.matricule,
    required this.nom,
    required this.prenom,
    required this.humeur,
    required this.description,
    required this.date,
  });
}

class HomeManagerPage extends StatelessWidget {
  const HomeManagerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Container(
          width: 70,
          height: 40,
          child: Image.asset('assets/images/sofrecom.png'),
        ),
        backgroundColor: Color(0xFF234E70),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        LoginScreen()), // Replace with your actual LoginScreen class
              );
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      backgroundColor: Color(0xFF234E70),
      body: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, String> moodEmojis = {
    "happy": "😄",
    "sad": "😢",
    "neutral": "😐",
    "angry": "😠",
  };

  final List<TableItem> tableData = [
    TableItem(
        matricule: "",
        nom: "",
        prenom: "",
        humeur: "",
        description: "",
        date: DateTime.now())

    // Add more items...
  ];

  List<TableItem> filteredData = [];
  TableItem? selectedPerson;
  final TextEditingController matriculeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  void performSearch() {
    String matricule = matriculeController.text.toLowerCase();
    String date = dateController.text.toLowerCase();

    // Filter the data based on search criteria
    filteredData = tableData.where((item) {
      bool matchMatricule = item.matricule.toLowerCase().contains(matricule);
      //bool matchDate = item.date.toLowerCase().contains(date);
      bool matchDate =
          item.date.toString().toLowerCase().contains(date.toLowerCase());

      return matchMatricule && matchDate;
    }).toList();
  }

  List<dynamic> users = [];
  List<dynamic> Moods = [];

  @override
  void initState() {
    super.initState();
    filteredData = List.from(
        tableData); // Initialize filteredData with all tableData items

    ApiService.fetchUsers().then((value) {
      List<TableItem> items = value.map((user) {
        return TableItem(
          matricule: user.user.matricule,
          nom: user.user.nom,
          prenom: user.user.prenom,
          humeur: user.humeur.libHumeur,
          description: user.description,
          date: user.dateHumeur,
        );
      }).toList();

      filteredData = items;
      return items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: matriculeController,
                    style: TextStyle(
                        color:
                            Color(0xFFFBF8BE)), // Set text color to Pale Yellow
                    decoration: InputDecoration(
                      labelText: "Search by matricule",
                      labelStyle: TextStyle(
                          color: Color(
                              0xFFFBF8BE)), // Set label color to Pale Yellow
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(
                                0xFFFBF8BE)), // Set underline color to Pale Yellow
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(
                                0xFFFBF8BE)), // Set focused underline color to Pale Yellow
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: dateController,
                    style: TextStyle(
                        color:
                            Color(0xFFFBF8BE)), // Set text color to Pale Yellow
                    decoration: InputDecoration(
                      labelText: "Search by date",
                      labelStyle: TextStyle(
                          color: Color(
                              0xFFFBF8BE)), // Set label color to Pale Yellow
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(
                                0xFFFBF8BE)), // Set underline color to Pale Yellow
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(
                                0xFFFBF8BE)), // Set focused underline color to Pale Yellow
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  performSearch();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFFBF8BE), // Set button color to Pale Yellow
                ),
                child: Text(
                  "Search",
                  style: TextStyle(
                      color: Color(0xFF234E70)), // Set text color to Royal Blue
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final item = filteredData[index];
                final isSelected = item == selectedPerson;

                return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedPerson = null;
                        } else {
                          selectedPerson = item;
                        }
                      });
                    },
                    child: Card(
                      color: Color(
                          0xFF234E70), // Set card background color to Royal Blue
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "${moodEmojis[item.humeur]}",
                                  style: TextStyle(fontSize: 20),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text("${item.nom} ${item.prenom}",
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Color(0xFFFBF8BE))),
                                  // Set text color to Pale Yellow
                                ),
                                if (isSelected)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Matricule: ${item.matricule}',
                                          style: TextStyle(
                                              color: Color(0xFFFBF8BE))),

                                      Text('Description: ${item.description}',
                                          style: TextStyle(
                                              color: Color(
                                                  0xFFFBF8BE))), // Set text color to Pale Yellow
                                      Text('Date: ${item.date}',
                                          style: TextStyle(
                                              color: Color(
                                                  0xFFFBF8BE))), // Set text color to Pale Yellow
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ApiService {
  static const String baseUrl =
      'http://10.0.2.2:8081/Humeur_salarie/api/allmoods';
  static Future<List<MoodData>> fetchUsers() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<MoodData> moodDataList = [];
      print(data);
      for (var item in data) {
        var userJson = item['user'];
        var departementJson = userJson['departement'];
        var humeurJson = item['humeur'];

        var user = User(
          id: userJson['id'],
          matricule: userJson['matricule'],
          nom: userJson['nom'],
          prenom: userJson['prenom'],
          mdp: userJson['mdp'],
          role: userJson['role'],
          departement: Departement(
            idDep: departementJson['id_dep'],
            libDep: departementJson['lib_dep'],
          ),
        );

        var humeur = Humeur(
          id: humeurJson['id'],
          libHumeur: humeurJson['lib_humeur'],
        );

        var moodData = MoodData(
          id: item['id'],
          user: user,
          humeur: humeur,
          description: item['description'],
          dateHumeur: DateTime.parse(item['date_humeur']),
        );

        moodDataList.add(moodData);
      }
      return moodDataList;
    } else {
      throw Exception('Failed to fetch data');
    }
  }
}

class User {
  final int id;
  final String matricule;
  final String nom;
  final String prenom;
  final String mdp;
  final String role;
  final Departement departement;

  User({
    required this.id,
    required this.matricule,
    required this.nom,
    required this.prenom,
    required this.mdp,
    required this.role,
    required this.departement,
  });
}

class Departement {
  final int idDep;
  final String libDep;

  Departement({
    required this.idDep,
    required this.libDep,
  });
}

class Humeur {
  final int id;
  final String libHumeur;

  Humeur({
    required this.id,
    required this.libHumeur,
  });
}

class MoodData {
  final int id;
  final User user;
  final Humeur humeur;
  final String description;
  final DateTime dateHumeur;

  MoodData({
    required this.id,
    required this.user,
    required this.humeur,
    required this.description,
    required this.dateHumeur,
  });
}
