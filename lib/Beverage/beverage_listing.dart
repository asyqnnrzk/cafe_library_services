import 'package:cafe_library_services/Beverage/beverage_details.dart';
import 'package:cafe_library_services/Welcome/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Controller/connection.dart';
import '../Model/beverage_model.dart';
import '../Welcome/select_library.dart';

void main() {
  runApp(BeverageListing());
}

class BeverageListing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FutureBuilder<String>(
        future: getLibraryIdFromSharedPreferences(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              // Handle error
              return Scaffold(
                body: Center(
                  child: Text('Error: ${snapshot.error}'),
                ),
              );
            } else {
              String cafeId = snapshot.data ?? '';
              return BeverageListScreen(cafeId: cafeId);
            }
          } else {
            // While waiting for the Future to complete, show a loading indicator
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}

class BeverageListScreen extends StatefulWidget {
  final String cafeId;
  final Map<String, String>? headers;

  const BeverageListScreen({Key? key, required this.cafeId, this.headers}) : super(key: key);

  @override
  _BeverageListScreenState createState() => _BeverageListScreenState();
}

class FetchBeverage {
  late List<BeverageModel> beverages;

  Future<List<BeverageModel>> getBeverageList({String? category}) async {
    try {
      final String cafeId = await getCafeIdFromSharedPreferences();
      final String? token = await getToken();
      beverages = [];

      var url = Uri.parse('${API.beverage}?cafe_id=$cafeId${category != null ? '&category=$category' : ''}');
      var header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${token}"
      };

      var response = await http.get(
        url,
        headers: header,
      );

      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> result = jsonDecode(response.body);

          // Check if 'aaData' is a List
          if (result['data']['aaData'] is List) {
            List<dynamic> aaDataList = result['data']['aaData'];
            List<BeverageModel> beverages = [];

            // Iterate through the 'aaData' list
            for (var aaData in aaDataList) {
              // Check if 'beverages' is a List
              if (aaData['beverage'] is List) {
                List<dynamic> beveragesList = aaData['beverage'];

                // Iterate through the 'beverages' list
                for (var beverageData in beveragesList) {
                  // Create a BeverageModel instance from each beverage data and add it to the list
                  beverages.add(BeverageModel.fromJson(beverageData));
                }
              }
            }

            return beverages;
          } else {
            print('Error: "aaData" is not a List');
            return [];
          }
        } catch (error) {
          print('Error decoding JSON: $error');
          return [];
        }
      }

      print('Request URL: $url');
      print('Request Headers: $header');
      print(response.statusCode);
      print(response.body);
      return [];
    } catch (error) {
      print('Error fetching beverages: $error');
      return [];
    }
  }

  Future<List<String>> getCategoryList({String? search}) async {
    try {
      final String cafeId = await getCafeIdFromSharedPreferences();
      final String? token = await getToken();

      // Include the search parameter only if it's provided
      var url = Uri.parse('${API.beverage}?cafe_id=$cafeId${search != null ? '&search=$search' : ''}');
      var header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      };

      var response = await http.get(
        url,
        headers: header,
      );

      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> result = jsonDecode(response.body);

          // Check if 'aaData' is a List
          if (result['data']['aaData'] is List) {
            List<dynamic> aaDataList = result['data']['aaData'];
            List<String> categories = [];

            // Iterate through the 'aaData' list
            for (var aaData in aaDataList) {
              // Check if 'category' is available
              if (aaData['category'] != null) {
                categories.add(aaData['category']);
              }
            }

            return categories;
          } else {
            print('Error: "aaData" is not a List');
            return [];
          }
        } catch (error) {
          print('Error decoding JSON: $error');
          return [];
        }
      }

      print('Request URL: $url');
      print('Request Headers: $header');
      print(response.statusCode);
      print(response.body);
      return [];
    } catch (error) {
      print('Error fetching categories: $error');
      return [];
    }
  }
}

class _BeverageListScreenState extends State<BeverageListScreen> {

  late Future<List<BeverageModel>> beverageList;
  late Future<List<String>> categoryList;

  @override
  void initState() {
    fetchData();
  }

  Future<void> fetchData() async {
    beverageList = FetchBeverage().getBeverageList();
    categoryList = FetchBeverage().getCategoryList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Beverage Listing'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(libraryId: ''),
                ),
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // showSearch(
                //   context: context,
                //   delegate: SearchBeverage(),
                // );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            FutureBuilder<List<String>>(
              future: categoryList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  List<String> categories = snapshot.data!;
                  return Row(
                    children: categories
                        .map(
                          (genre) => Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              print('Pressed $genre');
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => GenreSpecificBeverageListScreen(genre: genre),
                              //   ),
                              // );
                            },
                            child: Text(genre),
                          ),
                          SizedBox(width: 16.0),
                        ],
                      ),
                    )
                        .toList(),
                  );
                }
              },
            ),
            Expanded(
              child: FutureBuilder<List<BeverageModel>>(
                future: beverageList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    List<BeverageModel> results = snapshot.data!;
                    results.shuffle();
                    return ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        var beverage = results[index];
                        return Card(
                          child: SizedBox(
                            height: 100.0,
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BeverageDetailsScreen(name: results[index].name,
                                      category: results[index].category,
                                       price: results[index].price,
                                      picture: results[index].picture,),
                                  ),
                                );
                              },
                              title: Row(
                                children: [
                                  Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Image.network(
                                        '${beverage.picture}',
                                        width: double.infinity,
                                        height: 150.0,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          // Handle image loading error
                                          return const Icon(Icons.error);
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 32),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${beverage.name}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'RM${beverage.price}',
                                      ),
                                      Text(
                                        '${beverage.category}',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up resources, cancel timers, etc.
    super.dispose();
  }
}
