// for http connection
import 'package:http/http.dart' as http;
// for stdin
import 'dart:io';
// for json decode
import 'dart:convert';

Future<void> main() async {
  print("===== Login =====");
  stdout.write("Username: ");
  String? username = stdin.readLineSync()?.trim();
  stdout.write("Password: ");
  String? password = stdin.readLineSync()?.trim();

  if (username == null || password == null) {
    print("Incomplete input");
    return;
  }

  final loginUrl = Uri.parse('http://localhost:3000/login');
  final response = await http.post(
    loginUrl,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"username": username, "password": password}),
  );

  if (response.statusCode != 200) {
    print("Login failed: ${response.body}");
    return;
  }

  // final loginData = jsonDecode(response.body);
  // int userId = loginData['user_id'];
  // print("Welcome $username");

  // loop menu
  while (true) {
    print("\n======== Expense Tracking App =========");
    final loginData = jsonDecode(response.body);
    int userId = loginData['user_id'];
    print("Welcome $username");
    print("1. All expenses");
    print("2. Today's expense");
    print("3. Search expense");
    print("4. Add new expense");
    print("5. Delete an expense");
    print("6. Exit");
    stdout.write("Choose... ");
    String? choice = stdin.readLineSync();

    if (choice == "1") {
      await showExpenses(userId, all: true);
    } else if (choice == "2") {
      await showExpenses(userId, all: false);
    } else if (choice == "3") {
      // feature search




    } else if (choice == "4") {
      // feature add
      print("===== Add new item =====");
      stdout.write("Item : ");
      String? itemName = stdin.readLineSync()?.trim();
      stdout.write("Paid : ");
      String? paidPrice = stdin.readLineSync()?.trim();
      if (itemName == null || paidPrice == null) {
        print("Incomplete input");
        continue;
      }

      final addUrl = Uri.parse('http://localhost:3000/expenses');
      final response = await http.post(
        addUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_id": userId,
          "item": itemName,
          "paid": int.tryParse(paidPrice) ?? 0,
          "date": DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Inserted!");
      } else {
        print("Failed to insert. Status: ${response.statusCode}");
      }    
      

    } else if (choice == "5") {
      // feature delete




    } else if (choice == "6") {
      print("------- Bye -------");
      break;
    } else {
      print("Invalid choice!");
    }
  }
}

Future<void> showExpenses(int userId, {required bool all}) async {
  final url = Uri.parse('http://localhost:3000/expenses?user_id=$userId');
  final response = await http.get(url);

  if (response.statusCode != 200) {
    print("Error fetching expenses");
    return;
  }

  final expenses = jsonDecode(response.body) as List;
  int total = 0;

  print(all ? "------------- All expenses ------------" 
             : "---------- Today's expenses -----------");

  for (var exp in expenses) {
    final dt = DateTime.parse(exp['date']).toLocal();
    if (!all) {
      // filter only today's
      final now = DateTime.now();
      if (dt.year != now.year || dt.month != now.month || dt.day != now.day) {
        continue;
      }
    }

    print("${exp['id']}. ${exp['item']} : ${exp['paid']}฿ : $dt");
    total += exp['paid'] as int;
  }
  print("Total expenses = ${total}฿");
}
