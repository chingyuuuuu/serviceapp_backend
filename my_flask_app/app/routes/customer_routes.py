from flask import Blueprint, request, jsonify,send_from_directory
import os


customer_routes=Blueprint('customer_routes',__name__)

@customer_routes.route('/savedata',methods=['POST'])
def save_data():
     from ..models import QA
     from ..import db

     # 獲得當前文件的目錄
     current_dir = os.path.dirname(os.path.abspath(__file__))
     #絕對路徑
     uploads_folder = os.path.join(current_dir,'..', 'uploads')

     if not os.path.exists(uploads_folder):
         os.makedirs(uploads_folder)

     image_url=None
     if 'image' in request.files:
         image_file = request.files['image']
         # 圖片儲存在絕對路徑，但是資料庫儲存的是相對路徑
         image_path = os.path.join("uploads", image_file.filename)
         absolute_image_path = os.path.join(uploads_folder, image_file.filename)
         image_file.save(absolute_image_path)  # 保存文件到指定路径
         image_url = f"http://127.0.0.1:5000/{image_path.replace(os.sep, '/')}"

     data = request.form
     question = data.get('question')
     answer = data.get('answer')
     userId = data.get('user_id')
     type=data.get('type',None)
     print(image_url)

     if not question or not answer:
              return jsonify({"error":"question and answer are required"}),400

     try:
             #創建QA
             new_qa=QA(
                  type=type,
                  question=question,
                  answer=answer,
                  image=image_url ,
                  quser_id=userId
             )
             db.session.add(new_qa)
             db.session.commit()

             return jsonify({"message":"Data saved successfully"}),200
     except Exception as e:
              print(f"Error occured:{e}")
              return jsonify({"error":"An error occurred while saving"}),500

@customer_routes.route('/getqa',methods=['GET'])#用userid去查找已經創建的qa
def getqa():
    from ..models import QA
    try:
        user_id=request.args.get('user_id')
        if not user_id:
            return jsonify({"error":"user_id is not found"}),400

        qa_list=QA.query.filter_by(quser_id=user_id).all()
        if not qa_list:
            return jsonify([]),200
        result=[]
        for qa in qa_list:
            result.append({
                  'qaId':qa.QA_id,
                  'question':qa.question,
                  'answer':qa.answer
            })
            return jsonify(result),200
    except Exception as e:
         print(f"Error occurred:{e}")
         return jsonify({"error": "An error occurred while fetching QA data"}), 500


@customer_routes.route('/getqabyqaid/<int:qaId>', methods=['GET'])
def getqabyqaid(qaId):
    from ..models import QA
    try:

        qa = QA.query.filter_by(QA_id=qaId).first()

        if not qa:
            return jsonify([]), 200

        if qa.image:
            image_url = f"http://127.0.0.1:5000/{qa.image}" if '/uploads/' not in qa.image else qa.image
        else:
            image_url = None

        result = [{
            'qaId': qa.QA_id,
            'question': qa.question,
            'answer': qa.answer,
            'type': qa.type if qa.type else None,
            'image': image_url
        }]

        return jsonify(result), 200

    except Exception as e:
        print(f"Error occurred: {e}")
        return jsonify({"error": "An error occurred while fetching QA data"}), 500

@customer_routes.route('/updatedata/<int:qaId>',methods=['POST'])
def update(qaId):
    from ..models import QA
    from ..import db
    try:
        data=request.get_json()#獲取前端提交的數據
        qa=QA.query.filter_by(QA_id=qaId).first()
        if not qa:
            return jsonify({"error":"QA not found"}),404
        #更新資料
        qa.question=data.get('question',qa.question)
        qa.answer=data.get('answer',qa.answer)
        qa.type=data.get('type',qa.type)
        qa.image=data.get('image',qa.image)
        db.session.commit()
        return jsonify({"message":"QA updated successfully"}),200
    except Exception as e:
        print(f"Error occured:{e}")
        return jsonify({"error":"An error occurred while updating QA"}),500


@customer_routes.route('/deletedata/<int:qaId>', methods=['DELETE'])
def delete_data(qaId):
    from ..models import QA
    from .. import db
    try:
        qa = QA.query.get(qaId)

        if qa:
            db.session.delete(qa)
            db.session.commit()
            return jsonify({"message": "Data deleted successfully"}), 200
        else:
            return jsonify({"error": "Data not found"}), 404

    except Exception as e:
        print(f"Error occurred: {e}")
        return jsonify({"error": "An error occurred while deleting"}), 500


@customer_routes.route('/uploads/<filename>',methods=['GET'])
def uploaded_file(filename):
    uploads_folder = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'uploads')
    return send_from_directory(uploads_folder, filename)


