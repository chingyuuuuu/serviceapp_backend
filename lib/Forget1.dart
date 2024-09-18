import 'package:flutter/material.dart';
import 'Forget2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; //用於解析json數據
import 'package:shared_preferences/shared_preferences.dart';


class Forget1 extends StatefulWidget {
  @override
  _Forget1State createState() => _Forget1State();
}

class _Forget1State extends State<Forget1> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSending = false;
  String _message = '';

  Future<void> _storeEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  Future<void> _sendResetCode() async {
    final email = _emailController.text;

    if (email.isEmpty) {
      setState(() {
        _message = 'Email is required';
      });
      return;
    }

    setState(() {
      _isSending = true;
      _message = '';
    });

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/forget_password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    setState(() {
      _isSending = false;
    });

    if (response.statusCode == 200) {
      setState(() {
        _message = 'Reset code sent successfully!';
      });
      await _storeEmail(email); // Store email

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Forget2(), // Navigate to Forget2
        ),
      );
    } else {
      final responseData = jsonDecode(response.body);
      setState(() {
        _message = 'Failed to send reset code: ${responseData['message']}';
      });
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '驗證',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                  ),
                ),
                SizedBox(height: 10.0),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _sendResetCode,
                    child: _isSending ? CircularProgressIndicator() : Text('確認'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF36FDE6),
                      foregroundColor: Colors.white,
                      minimumSize: Size(80, 50),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                if (_message.isNotEmpty)
                  Center(
                    child: Text(
                      _message,
                      style: TextStyle(
                        color: _message.startsWith('Failed') ? Colors.red : Colors.green,
                      ),
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