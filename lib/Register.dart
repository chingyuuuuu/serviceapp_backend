import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Login.dart';

class Register extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _register(BuildContext context) async {
    final email = _emailController.text;
    final password = _passwordController.text;

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'account': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201 ||response.statusCode == 200) {
      // Registration successful
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('註冊成功'),
          content: Text('你已經成功註冊了!'),
          actions: <Widget>[
            TextButton(
              child: Text('確定'),
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
            ),
          ],
        ),
      );
    } else {
      final responseData = json.decode(response.body);
      // Show error message
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('註冊失敗'),
          content: Text(responseData['message']),
          actions: <Widget>[
            TextButton(
              child: Text('確定'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 返回到上一个页面
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.0),
            color: Colors.white,
            child: Center(
              child: Text(
                'Service',
                style: TextStyle(
                  fontSize: 120,
                  fontFamily: 'Kapakana',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF223888),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  '註冊',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: UnderlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => _register(context),
                  child: Text('註冊'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xD367FF7F),
                    foregroundColor: Colors.white,
                    minimumSize: Size(150, 50),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
