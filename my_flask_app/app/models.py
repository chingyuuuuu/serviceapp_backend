from sqlalchemy import Column, Integer, String,DateTime
from .extensions import db
from datetime import datetime, timedelta


class User(db.Model):
    __tablename__ = 'user'

    user_id = Column(Integer, primary_key=True)
    account = Column(String(80), unique=True, nullable=False)
    password = Column(String(120), nullable=False)
    reset_token = Column(String(80), nullable=True)
    reset_token_created_at = Column(DateTime, nullable=True)  # 添加生成时间字段

    def __init__(self, account, password, reset_token=None):
        self.account = account
        self.password = password
        self.reset_token = reset_token
        self.reset_token_created_at = None  # 默认情况下，生成时间为空

    def set_reset_token(self, token):
        self.reset_token = token
        self.reset_token_created_at = datetime.utcnow() #當前時間
        db.session.commit()

    def clear_reset_token(self):
        self.reset_token = None
        self.reset_token_created_at = None  # 清除生成时间
        db.session.commit()

    def is_reset_token_valid(self, token, expiration_seconds=3600):
        if self.reset_token != token:
            return False

        # 确保 reset_token_created_at 存在且不为 None
        if self.reset_token_created_at is None:
            return False

        elapsed_time = (datetime.utcnow() - self.reset_token_created_at).total_seconds()
        return elapsed_time < expiration_seconds