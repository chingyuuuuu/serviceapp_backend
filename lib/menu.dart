import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String password = '123456'; // 預設密碼
  TextEditingController passwordController = TextEditingController();

  // 初始化不同食物種類和價格
  List<Map<String, dynamic>> foodItems = [
    {'name': '飯1', 'price': 120},
    {'name': '飯2', 'price': 150},
    {'name': '飯3', 'price': 100},
    {'name': '飯4', 'price': 130}
  ];

  String selectedCategory = '飯';

  // 購物車內容
  List<Map<String, dynamic>> cartItems = []; // 購物車內的商品列表
  int totalAmount = 0; // 總金額

  // 當按下不同的按鈕時，更新顯示的食物列表
  void updateFoodItems(String category) {
    setState(() {
      selectedCategory = category;
      if (category == '飯') {
        foodItems = [
          {'name': '飯1', 'price': 120},
          {'name': '飯2', 'price': 150},
          {'name': '飯3', 'price': 100},
          {'name': '飯4', 'price': 130}
        ];
      } else if (category == '麵') {
        foodItems = [
          {'name': '麵1', 'price': 110},
          {'name': '麵2', 'price': 140},
          {'name': '麵3', 'price': 130},
          {'name': '麵4', 'price': 90}
        ];
      } else if (category == '飲料') {
        foodItems = [
          {'name': '飲料1', 'price': 50},
          {'name': '飲料2', 'price': 60},
          {'name': '飲料3', 'price': 45},
          {'name': '飲料4', 'price': 55}
        ];
      }
    });
  }

  // 添加商品至購物車
  void addToCart(String item, int price) {
    setState(() {
      cartItems.add({'item': item, 'price': price});
      totalAmount += price;  // 確保這裡的 totalAmount 是 int
    });
  }

  // 從購物車中移除商品
  void removeFromCart(int index) {
    setState(() {
      totalAmount -= cartItems[index]['price'] as int; // 使用 as 將值強制轉換為 int
      cartItems.removeAt(index); // 移除該商品
    });
  }

  // 顯示密碼對話框
  void _showPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '輸入後台密碼',
            style: TextStyle(color: Colors.red),
          ),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'password',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 關閉對話框
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                // 檢查密碼是否正確
                if (passwordController.text == password) {
                  Navigator.of(context).pop(); // 關閉對話框
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('密碼正確，進入後台設定')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('密碼錯誤')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              child: const Text('輸入'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // 打開 Drawer
              },
            );
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                updateFoodItems('飯');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                selectedCategory == '飯' ? Colors.yellow : Colors.grey,
                minimumSize: const Size(100, 50),
              ),
              child: const Text('飯'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                updateFoodItems('麵');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                selectedCategory == '麵' ? Colors.yellow : Colors.grey,
                minimumSize: const Size(100, 50),
              ),
              child: const Text('麵'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                updateFoodItems('飲料');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                selectedCategory == '飲料' ? Colors.yellow : Colors.grey,
                minimumSize: const Size(100, 50),
              ),
              child: const Text('飲料'),
            ),
          ],
        ),
        actions: const [SizedBox(width: 48)], // 用來確保標題在中間
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              child: Center(
                child: Text('選單', style: TextStyle(fontSize: 24)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('購物車'),
              onTap: () {
                // 點擊後跳轉到購物車
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setModalState) {
                        return Column(
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                              '購物車內容',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: cartItems.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(cartItems[index]['item']),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('NT\$ ${cartItems[index]['price']}'),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              removeFromCart(index);  // 在主畫面狀態中更新購物車內容
                                            });
                                            setModalState(() {});  // 在底部彈出框中立即更新畫面
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              color: Colors.blueAccent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('總共 NT\$', style: TextStyle(color: Colors.white)),
                                  Text(totalAmount.toString(), style: const TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('通知'),
              onTap: () {
                // 可以添加通知的動作
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('設定'),
              onTap: () {
                // 點擊 "設定" 時彈出密碼對話框
                _showPasswordDialog(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: foodItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 兩列
                childAspectRatio: 1.0, // 格子寬高比
              ),
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(foodItems[index]['name']),
                      const SizedBox(height: 8),
                      Text('NT\$ ${foodItems[index]['price']}'),
                      ElevatedButton(
                        onPressed: () {
                          addToCart(foodItems[index]['name'], foodItems[index]['price']);
                        },
                        child: const Text('訂購'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(150, 50)),
                  child: const Text('桌號'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(150, 50)),
                  child: const Text('訂購'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
