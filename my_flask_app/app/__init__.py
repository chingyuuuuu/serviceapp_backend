from flask import Flask
from flask_cors import CORS
from .extensions import db
from my_flask_app.app.routes.main_route import main_routes
from .config import Config
from flask_mail import Mail
from .routes import auth_routes, product_routes,order_routes,main_route

mail = Mail()

def create_app():    #配置flask
    app = Flask(__name__)   #創建flask實例
    app.config.from_object('app.config.Config')
    CORS(app)
    db.init_app(app)
    mail.init_app(app)
    app.register_blueprint(main_routes)
    app.register_blueprint(product_routes)
    app.register_blueprint(auth_routes)
    app.register_blueprint(order_routes)
    return app
