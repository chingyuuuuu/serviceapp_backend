import 'package:flutter/material.dart';
import 'dining.dart';


class Choose extends StatelessWidget {
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
          SizedBox(height:40.0),
          ElevatedButton(
            onPressed: (){
              Navigator.push(
                 context,
                MaterialPageRoute(builder: (context)=>dining()),
              );
            },
             child: Text('餐飲業',
                         style:TextStyle(
                           fontSize:30,
                         ),
              ),
             style: ElevatedButton.styleFrom(
               backgroundColor: Color(0xFF36FDE6),
               foregroundColor: Colors.white,
               minimumSize: Size(250,80),
               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
             ),
          ),
          SizedBox(height: 32.0),
          ElevatedButton(
              onPressed: (){},
              child: Text('客服',
                          style:TextStyle(
                          fontSize: 30,

                  ),
               ),
              style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF36FDE6),
              foregroundColor: Colors.white,
              minimumSize: Size(250, 80),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
           ),
          ),
        ],
      ),
    );
  }
}
