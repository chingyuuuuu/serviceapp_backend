import 'package:flutter/material.dart';
import 'package:jkmapp/forget3.dart';
import 'First.dart'; // 导入你的页面文件
import 'Login.dart';
import 'Forget1.dart';
import 'Choose.dart';
import 'Register.dart';
import 'Forget2.dart';
import 'api_service.dart';
import 'forget3.dart';
import 'dining.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/first', // 设置初始路由为 first 页面
      routes: {
        '/first': (context) => First(),
        '/login': (context) => Login(),
        '/forget1':(context)=> Forget1(),
        '/choose':(context)=> Choose(),
        '/register':(context)=>Register(),
        '/forget2':(context)=>Forget2(),
        '/forget3':(cnotext)=>Forget3(),
        '/dining':(context)=>dining(),
      },
    );
  }
}

class DataWidget extends StatefulWidget {
  @override
  _DataWidgetState createState() => _DataWidgetState();
}

class _DataWidgetState extends State<DataWidget> {
  Future<Map<String, dynamic>>? _data;

  @override
  void initState() {
    super.initState();
    _data = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(//用於存取從flask 獲取的數據
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Text('Message: ${snapshot.data!['message']}');
        }
      },
    );
  }
}

