import string ,random
from flask import Blueprint, request, jsonify,send_from_directory
from sqlalchemy.exc import SQLAlchemyError, OperationalError
from .models import User
from sqlalchemy.sql import text
from flask_mail import Message
from werkzeug.security import generate_password_hash

main_routes = Blueprint('main_routes', __name__)


@main_routes.route('/api/data')
def get_data():
    return jsonify({'message': 'Hello from Flask!'})

@main_routes.route('/')
def home():
    return 'Welcome to the home page!'


@main_routes.route('/login', methods=['POST'])
def login():
    from .models import User  # 延遲導入
    from werkzeug.security import check_password_hash

    data = request.get_json() #客戶端發送數據，用來解析json格式的數據
    account = data.get('account')
    password = data.get('password')


    if not account or not password:
        return jsonify({"message": "Account and password are required"}), 400

    try:#在database當中查找account and password
        user = User.query.filter_by(account=account).first()
        if not user:
            return jsonify({"message":"Invalid username or password"})
        if check_password_hash(user.password,password):
            # 從後端傳送user_id到前端
            return jsonify({"message":"Login successful","user_id":str(user.user_id)})
        else:
            return jsonify({"message":"Invalid username or password"})

    except SQLAlchemyError as e:
        return jsonify({"message": "An error occurred", "error": str(e)}), 500





@main_routes.route('/register', methods=['POST'])
def register():
    from . import db
    data = request.get_json()
    if not data:
        return jsonify({"message": "No data provided"}), 400

    account = data.get('account')
    password = data.get('password')

    if not account or not password:
        return jsonify({"message": "Account and password are required"}), 400

    try:
        existing_user = User.query.filter_by(account=account).first()  #獲取第一條訊息
        if existing_user:
            return jsonify({"message": "account already exists"}), 409

        # 創建新用戶
        hashed_password = generate_password_hash(password)
        new_user = User(account=account, password= hashed_password)
        db.session.add(new_user)#加入database
        db.session.commit()#儲存到database

        return jsonify({"message": "User registered successfully", "user_id": new_user.user_id}),200

    except SQLAlchemyError as e:#用於捕獲數據庫異常
        db.session.rollback()  # 撤销所有更改
        return jsonify({"message": "An error occurred", "error": str(e)}), 500

@main_routes.route('/forget_password',methods=['POST'])
def forget_password():
    from . import mail
    from . import db
    data = request.get_json()
    if not data or 'email' not in data:
        return jsonify({"message":"Email is required"}),400

    email = data.get('email')#從客戶端的數據中，取得email對應值
    if not email:
        return jsonify({"message": "Email is required"}), 400
    user = User.query.filter_by(account=email).first()#找到account
    if not user:
        return jsonify({"message":"User not found"}),404


    #生成驗證碼
    token = ''.join(random.choices(string.ascii_letters + string.digits,k=6))#join元素串接
    user.reset_token = token #更新用戶的token
    db.session.commit()

    #發送郵件
    #Message-是flask-mail提供的一個類，用於創建email消息對象
    try:
        msg = Message('Password Reset Code', sender='plankcanon78@gmail.com', recipients=[email])
        msg.body = f'Your password reset code is: {token}'
        mail.send(msg)
        return jsonify({"message": "Reset code sent"}), 200
    except Exception as e:
        print(f"Error sending email: {e}")
        return jsonify({"message": "Failed to send email"}), 500

@main_routes.route('/verify',methods=['POST'])
def verify():
    from .import db
    try:
            data = request.get_json()
            #檢查是否提供驗證碼
            if  'code' not in data:
                return jsonify({'message':'缺少驗證碼'}),400

            email = data['email']
            code = data['code']
            user=User.query.filter_by(account=email).first()
            if not user:
                return jsonify({'message': '該用戶不存在'}), 404

            #驗證碼是否匹配
            if user.reset_token == code:
                #驗證通過
               user.reset_token= None #清除token
               db.session.commit()
               return jsonify({'message':'驗證成功!'}),200
            else:
                return jsonify({'message':'驗證碼錯誤'}),400

    except Exception as e:
        return jsonify({'message': '服務器錯誤', 'error': str(e)}), 500

@main_routes.route('/update_password', methods=['POST'])
def update_password():
    from .import db
    from werkzeug.security import generate_password_hash

    try:
        data = request.get_json()

        # 检查是否提供了所有必需的字段
        if not all(key in data for key in ('email', 'new_password', 'confirm_password')):
            return jsonify({'message': 'Missing required fields'}), 400

        email = data.get('email')
        new_password = data.get('new_password')
        confirm_password = data.get('confirm_password')


        if new_password != confirm_password:
            return jsonify({'message': 'Passwords do not match'}), 400

        # 找到用户
        user = User.query.filter_by(account=email).first()
        if not user:
            return jsonify({'message': 'User not found'}), 404

        #檢查密碼長度
        if len(new_password) < 8:
            return jsonify({'message': 'New password must be at least 8 characters'}), 400

        # 更新用戶密碼
        user.password = generate_password_hash(new_password)
        db.session.commit()

        return jsonify({'message': 'Password updated successfully!'}), 200

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Server error', 'error': str(e)}), 500

@main_routes.route('/uploadproducts', methods=['POST'],endpoint='uploadproducts')
def save_product():
    from .models import Product
    from . import db
    import os

    uploads_folder = 'uploads'
    #儲存圖片的url
    if 'image' not in request.files:
        image_path = None
    else:
        image_file = request.files['image']
        if not os.path.exists(uploads_folder):
            os.makedirs(uploads_folder)
        image_path = os.path.join(uploads_folder, image_file.filename)
        image_file.save(image_path)
        #生成圖片url
        image_url = f"http://127.0.0.1:5000/{image_path.replace(os.sep, '/')}"
        print(f"File saved to: {image_path}")

    data = request.form  # 请求数据
    user_id = int(data.get('user_id'))

    new_product = Product(
        name=data['name'],
        type=data['type'],
        price=data['price'],
        cost=data['cost'],
        quantity=data['quantity'],
        user_id=user_id,
        image=image_url  # 如果没有image，image_path 是 None
    )

    try:
        db.session.add(new_product)
        db.session.commit()
        return jsonify({
            "message": "Product saved successfully!",
            "image_url": image_url,
        }), 200
    except Exception as e:
        db.session.rollback()  # 如果提交失败，回滚会话
        print(f"Error occurred: {e}")  # 打印具體的錯誤信息
        return jsonify({"message": "An error occurred", "error": str(e)}), 500


@main_routes.route('/getProducts',methods=['GET'])
def get_products():
    from .models import Product
    try:
            user_id =request.args.get('user_id')
            if not user_id:
                return jsonify({"message":"User ID missing"}),400


            #將查詢結果轉換為json
            products = Product.query.filter_by(user_id=user_id).all()
            products_list=[]
            #遍歷每個商品並加入倒product_list
            for product in products:
                image_url = f"http://127.0.0.1:5000/{product.image}" if '/uploads/' not in product.image else product.image
                products_list.append({
                                'product_id':product.product_id,
                                'name': product.name,
                                'type': product.type,
                                'price': product.price,
                                'cost': product.cost,
                                'quantity': product.quantity,
                                'image':  image_url,
                            })

            return jsonify(products_list), 200
    except Exception as e:
        print(f"Error occurred while fetching products: {e}")  # 打印具體的錯誤信息
        return jsonify({"message": "An error occurred", "error": str(e)}), 500


@main_routes.route('/getproducts/<int:productId>',methods=['GET'])
def get_one_product(productId):
    from .models import Product
    try:
        #根據productId去資料庫找商品
        product = Product.query.get(productId)
        if product is None:
            return jsonify({"message":"Product not found"}),
        return jsonify({
             'product_id': product.product_id,
              'name':product.name,
             'type': product.type,
              'price': product.price,
              'cost': product.cost,
              'quantity': product.quantity,
        }),200
    except SQLAlchemyError as e:
        return jsonify({"message": "An error occurred", "error": str(e)}), 500



@main_routes.route('/update_product/<int:productId>',methods=['PUT'])
def update_product(productId):#接收ProudctId
    from .models import Product
    from . import db
    data = request.get_json()#從前端獲取數據

    if not data:
        return jsonify({"message":"No data provided"}),400
    try:
        #用product_id查找產品
        product = Product.query.get(productId)
        if not product:
            #不存在,404
            return jsonify({"message":"Product not found"}),404

        #初始化變數-如果前端提供某個欄位的值就使用，如果沒有就用現有的資訊去初始化
        name = data.get('name') if 'name' in data else product.name
        type = data.get('type') if 'type' in data else product.type
        price = data.get('price') if 'price' in data else product.price
        cost = data.get('cost') if 'cost' in data else product.cost
        quantity = data.get('quantity') if 'quantity' in data else product.quantity

        is_modified =False

        # 確保只有在值發生變化時才會更新
        if name != product.name:
            product.name = name
            is_modified = True
        if type != product.type:
            product.type = type
            is_modified = True
        if price != product.price:
            product.price = price
            is_modified = True
        if cost != product.cost:
            product.cost = cost
            is_modified = True
        if quantity != product.quantity:
            product.quantity = quantity
            is_modified = True

        if not is_modified:
            return jsonify({"message": "No changes were made to the product."}), 200

        db.session.commit()

        return jsonify({
                "message": "Product updated successfully",
                'product_id': product.product_id,  # 返回产品ID
                'name': product.name,
                'type': product.type,
                'price': product.price,
                'cost': product.cost,
                'quantity': product.quantity
        }), 200

    except SQLAlchemyError as e:
        db.session.rollback()
        return jsonify({"message":"An error occurred","error":str(e)}),500

@main_routes.route('/delete_product/<int:productId>',methods=['DELETE'])
def delete_prodcut(productId):
    from .models import Product
    from .import db
    try:
        product =Product.query.get(productId)
        if not product:
            return jsonify({"message":"Product not found "}),404
        db.session.delete(product)
        db.session.commit()

        return jsonify({"message":"Product deleted successful!"}),200
    except SQLAlchemyError as e:
        db.session.rollback()
        return jsonify({"message":"An error occurred","error":str(e)}),500


@main_routes.route('/uploads/<filename>', methods=['GET'])
def uploaded_file(filename):
    return send_from_directory('uploads', filename)


@main_routes.route('/test_db', methods=['GET'])
def test_db():
    from . import db
    try:
        db.session.execute(text('SELECT 1'))
        return  'Database connection is successful!', 200
    except OperationalError:
        return 'Database connection failed!', 500


@main_routes.route('/send_email')
def send_email():
    from . import mail
    msg = Message('Hello', sender='your_email@gmail.com', recipients=['recipient@example.com'])
    msg.body = 'This is a test email.'
    try:
        mail.send(msg)
        return 'Email sent!'
    except Exception as e:
        return f'Failed to send email: {e}'