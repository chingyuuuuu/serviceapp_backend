import 'package:flutter/material.dart';
import 'forget3.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; //用於解析json數據
import 'package:shared_preferences/shared_preferences.dart';


class Forget2 extends StatefulWidget {
  @override
  _Forget2State createState() => _Forget2State(); //負責管理和更新這個state
}

class _Forget2State extends State<Forget2> {
  final TextEditingController _verifyController = TextEditingController();
  bool isSubmitting = false;
  String _message = '';
  String? email; // 用于存储从 SharedPreferences 读取的 email

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('user_email');
    });
  }

  Future<void> _verifyCode() async {
    final String code = _verifyController.text;

    if (code.isEmpty || email == null) {
      setState(() {
        _message = '需要輸入驗證碼和有效的 email';
      });
      return;
    }

    setState(() {
      isSubmitting = true;
      _message = '';
    });

    // 发送请求到后端进行验证码验证
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}), // 使用从 SharedPreferences 读取的 email
    );

    setState(() {
      isSubmitting = false;
    });

    if (response.statusCode == 200) {
      setState(() {
        _message = '驗證成功!';
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Forget3()), // 确保 Forget3 已定义并正确引入
      );
    } else {
      final responseData = jsonDecode(response.body);
      setState(() {
        _message = '${responseData['message']}';
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
                  controller: _verifyController,
                  decoration: InputDecoration(
                    labelText: '驗證碼',
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                if (_message.isNotEmpty)
                  Text(
                    _message,
                    style: TextStyle(
                      color: _message.startsWith('驗證成功') ? Colors.green : Colors.red,
                    ),
                  ),
                SizedBox(height: 5.0),
                Text(
                  '已經傳送驗證碼',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 15.0,
                  ),
                ),
                SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _verifyCode,
                    child: isSubmitting ? CircularProgressIndicator() : Text('確認'),
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