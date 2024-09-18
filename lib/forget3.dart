import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class Forget3 extends StatefulWidget {
  @override
  _Forget3State createState() => _Forget3State();
}

class _Forget3State extends State<Forget3> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _message = '';
  String? email; //讀取存取的email

  @override
  void initState() {
    super.initState();//確保flutter內的初始邏輯
    _loadEmail();//初始化以儲存的email
  }

  Future<void> _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();//用來access本地儲存的資料
    setState(() {
      email = prefs.getString('user_email');
    });
  }

  Future<void> _updatePassword() async {
    final new_password = _newPasswordController.text;
    final confirm_password = _confirmPasswordController.text;
    if ( new_password.isEmpty || confirm_password.isEmpty) {
      setState(() {
        _message = 'Both fields are required';
      });
      return;
    }
    if (new_password != confirm_password) {
      setState(() {
        _message = 'Passwords do not match';
      });
      return;
    }
    if (email == null) {
      setState(() {
        _message = 'Email is not available';
      });
      return;
    }

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/update_password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'new_password': new_password,
        'confirm_password':confirm_password,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _message = 'Password updated successfully!';
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } else {
      final responseData = jsonDecode(response.body);
      setState(() {
        _message = 'Failed to update password: ${responseData['message']}';
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
            Navigator.pop(context); // 返回到上頁
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
              crossAxisAlignment: CrossAxisAlignment.start, // 设置为 CrossAxisAlignment.start
              children: <Widget>[
                Text(
                  '請更改你的新密碼',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                  ),
                ),
                SizedBox(height: 10.0),
                TextField(
                  controller:_newPasswordController,
                  decoration: InputDecoration(
                    labelText: '請輸入你的新密碼',
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10.0),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: '請再次輸入新密碼',
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0), // 在按钮上方添加间距
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _updatePassword();
                    },
                    child: Text('確認'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF36FDE6), // 按钮背景颜色
                      foregroundColor: Colors.white, // 按钮文本颜色
                      minimumSize: Size(80, 50), // 按钮大小
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // 按钮内边距
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
