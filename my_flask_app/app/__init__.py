from flask import Flask
from flask_cors import CORS
from .extensions import db
from .routes import main_routes
from .config import Config
from flask_mail import Mail

mail = Mail()

def create_app():    #配置flask
    app = Flask(__name__)   #創建flask實例
    app.config.from_object('app.config.Config')
    CORS(app)
    db.init_app(app)
    mail.init_app(app)
    app.register_blueprint(main_routes)

    return app
