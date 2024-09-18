import os

class Config:
    # 数据库配置
    SQLALCHEMY_DATABASE_URI = 'mysql+mysqlconnector://root:ki20030108@localhost/JKM'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SECRET_KEY = 'kikiki'
    # 其他配置项
    DEBUG = True
    TESTING = False
    MAIL_SERVER = 'smtp.gmail.com'
    MAIL_PORT = 587
    MAIL_USERNAME = 'plankcanon78@gmail.com'
    MAIL_PASSWORD = 'hhma ibgb khll ahbm'
    MAIL_USE_TLS = True
    MAIL_USE_SSL = False