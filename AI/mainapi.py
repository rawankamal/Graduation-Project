import fastapi as fap
import fastapi.responses as resps
from fastapi import status as stts
from fastapi.middleware.cors import CORSMiddleware
from supabaseprojdb import db
from projbot import bot
import json
from pydantic import BaseModel, Field
from typing import List, Optional, Literal, Final
from basemodels import *

# To run ->   uvicorn mainapi:app --reload

app = fap.FastAPI(docs_url=None, redoc_url=None, openapi_url=None)
# app = fap.FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins = ["*"],
    allow_credentials = True,
    allow_methods = ["*"],
    allow_headers = ["*"]
)

print("API Initiated")


@app.post("/auth/user/register")
async def register_user(user: user_base):
    if user.username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"User username missed"}
    )
    if user.email == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"User email missed"}
    )
    if user.password == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"User password missed"}
    )

    db_resp = db.add_user(user.username,user.email,user.password,user.fname,user.lname,user.dateofbirth,user.gender,user.bio,user.profilepic,user.country,user.city)
    return resps.JSONResponse(
        status_code = stts.HTTP_201_CREATED if db_resp == 'User added' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.post("/auth/admin/register")
async def register_admin(admin: admin_base):
    if admin.username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin username missed"}
    )
    if admin.email == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin email missed"}
    )
    if admin.password == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin password missed"}
    )
    db_resp = db.add_admin(admin.username,admin.email,admin.password,admin.fname,admin.lname,admin.dateofbirth,admin.gender,admin.country,admin.city)
    
    return resps.JSONResponse(
        status_code = stts.HTTP_201_CREATED if db_resp == 'Admin added' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.post("/auth/supervisor/register")
async def register_supervisor(user: user_base):
    if user.username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor username missed"}
    )
    if user.email == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor email missed"}
    )
    if user.password == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor password missed"}
    )

    db_resp = db.add_supervisor(user.username,user.email,user.password,user.fname,user.lname,user.dateofbirth,user.gender,user.bio,user.profilepic,user.country,user.city)
    
    return resps.JSONResponse(
        status_code = stts.HTTP_201_CREATED if db_resp == 'Supervisor added' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.post("/auth/user/login")
async def login_user(user: login_base):
    if user.username == '' and user.email == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"User username or email missed"}
    )
    if user.password == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"User password missed"}
    )
    
    user.username = db.get_user_username(user.email) if user.username == '' else user.username
    user_data = db.get_user(user.username)
    if user_data != "User not exist" and user_data[2] == user.password:
        user_session_id = db.gen_session_id()
        db.ini_user_session(user.username, user_session_id)
        return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"msg": "User login success","session_id": user_session_id}
    )
    else:
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "User login failed"}
    )
    
@app.post("/auth/admin/login")
async def login_admin(admin: login_base):
    if admin.username == '' and admin.email == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Admin username or email missed"}
    )
    if admin.password == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Admin password missed"}
    )
    admin.username = db.get_admin_username(admin.email) if admin.username == '' else admin.username
    admin_data = db.get_admin(admin.username)
    if admin_data != "Admin not exist" and admin_data[2] == admin.password:
        admin_session_id = db.gen_session_id()
        db.ini_admin_session(admin.username, admin_session_id)
        return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"msg": "Admin login success","session_id": admin_session_id}
    )
    else:
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Admin login failed"}
    )
    
@app.post("/auth/supervisor/login")
async def login_supervisor(supervisor: login_base):
    if supervisor.username == '' and supervisor.email == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Supervisor username or email missed"}
    )
    if supervisor.password == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Supervisor password missed"}
    )
    
    supervisor.username = db.get_supervisor_username(supervisor.email) if supervisor.username == '' else supervisor.username
    supervisor_data = db.get_supervisor(supervisor.username)
    if supervisor_data != "Supervisor not exist" and supervisor_data[2] == supervisor.password:
        supervisor_session_id = db.gen_session_id()
        db.ini_supervisor_session(supervisor.username, supervisor_session_id)
        return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"msg": "Supervisor login success","session_id": supervisor_session_id}
    )
    else:
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Supervisor login failed"}
    )
    
@app.post("/model/admin/add")
async def admin_add_model(username: str, session_id: str, model: model_base):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin session_id missed"}
    )
    if model.model_name == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin model_name missed"}
    )
    
    db_check_session = db.check_admin_session(username,session_id)
    if db_check_session == "Admin Session not exist" or db_check_session == "Admin Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    
    db_resp = db.admin_add_model(username, model.model_name, model.model_context, model.model_bio)
    return resps.JSONResponse(
        status_code = stts.HTTP_201_CREATED if db_resp == 'Admin Model added' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.post("/model/supervisor/add")
async def supervisor_add_model(username: str, session_id: str, model: model_base):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor session_id missed"}
    )
    if model.model_name == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor model_name missed"}
    )
    
    db_check_session = db.check_supervisor_session(username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    
    db_resp = db.supervisor_add_model(username, model.model_name, model.model_context, model.model_bio)
    return resps.JSONResponse(
        status_code = stts.HTTP_201_CREATED if db_resp == 'Supervisor Model added' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.post("/auth/supervisor/user/add")
async def supervisor_add_user(username: str, session_id: str, user: user_base):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor session_id missed"}
    )
    if user.username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Supervisor User username missed"}
    )
    if user.email == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Supervisor User email missed"}
    )
    if user.password == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Supervisor User password missed"}
    )
    
    db_check_session = db.check_supervisor_session(username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )

    db_resp = db.supervisor_add_user(username,user.username,user.email,user.password,user.fname,user.lname,user.dateofbirth,user.gender,user.bio,user.profilepic,user.country,user.city)
    return resps.JSONResponse(
        status_code = stts.HTTP_201_CREATED if db_resp == 'Supervisor User added' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.post("/assign/supervisor/add")
async def supervisor_assign_model(supervisor_username: str, user_username: str, model_name: str, session_id: str):
    if supervisor_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Assign supervisor username missed"}
    )
    if user_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Assign user username missed"}
    )
    if model_name == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Assign model name missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Assign session id missed"}
    )

    db_check_session = db.check_supervisor_session(supervisor_username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    db_resp = db.supervisor_assign_model(supervisor_username,user_username,model_name)
    return resps.JSONResponse(
        status_code = stts.HTTP_201_CREATED if db_resp == 'Supervisor User Model added' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.post("/thread/supervisor/member/add")
async def supervisor_add_thread_member(supervisor_username: str, user_username: str, member_username: str, session_id: str):
    if supervisor_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Add Memeber supervisor username missed"}
    )
    if user_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Add Member user username missed"}
    )
    if member_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Add Member member username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Add Member session id missed"}
    )
    
    db_check_session = db.check_supervisor_session(supervisor_username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    db_resp = db.supervisor_add_thread_member(supervisor_username,user_username,member_username)
    return resps.JSONResponse(
        status_code = stts.HTTP_201_CREATED if db_resp == 'Supervisor User Member added' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.post("/thread/supervisor/chat/send")
async def supervisor_send_thread_chat(supervisor_username: str, user_username: str, member_username: str, msg_text: str, session_id: str):
    if supervisor_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Send supervisor username missed"}
    )
    if user_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Send user username missed"}
    )
    if member_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Send member username missed"}
    )
    if msg_text == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Send msg text missed"}
    )
        return 
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Send session id missed"}
    )
    
    db_check_session = db.check_supervisor_session(member_username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    db_resp = db.supervisor_send_thread_chat(supervisor_username,user_username,member_username,msg_text)
    return resps.JSONResponse(
        status_code = stts.HTTP_201_CREATED if db_resp == 'Supervisor User Member chat sent' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.post("/model/chat/user/send")
async def user_send_chat(username: str, model_name: str, msg_text: str, session_id: str):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Send Chat username missed"}
    )
    if model_name == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Send Chat model name missed"}
    )
    if msg_text == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Send Chat model msg text missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Send Chat session_id missed"}
    )
    
    db_check_session = db.check_user_session(username, session_id)
    if db_check_session == "User Session not exist" or db_check_session == "User Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg":db_check_session}
    )
    model_resp = bot.send_msg(username,model_name,msg_text)
    if model_resp == "Model not exist" or model_resp == "User Model Chat not exist" or model_resp == "User not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":model_resp}
    )
    return resps.JSONResponse(
        status_code = stts.HTTP_201_CREATED,
        content = {"model_msg":model_resp}
    )

@app.post("/supervisor/chat/send")
async def supervisor_send_chat(supervisor1_username: str, supervisor2_username: str, msg_text: str, session_id: str):
    if supervisor1_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Send Chat supervisor1 username missed"}
    )
    if supervisor2_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Send Chat supervisor2 username missed"}
    )
    if msg_text == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Send Chat msg text missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Send Chat session id missed"}
    )
    
    db_check_session = db.check_supervisor_session(supervisor1_username, session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    db_resp = db.supervisor_send_chat(supervisor1_username,supervisor2_username,supervisor1_username,msg_text)
    return resps.JSONResponse(
        status_code = stts.HTTP_201_CREATED if db_resp == 'Supervisor Chat send' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.get("/auth/user/get")
async def get_user(username: str):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "User username missed"}
    )    
    user_data = db.get_user(username)
    if user_data == "User not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": user_data}
    )

    user_data_base = {
        "username":user_data[0],
        "email":user_data[1],
        "fname":user_data[3],
        "lname":user_data[4],
        "dateofbirth":user_data[5],
        "gender":user_data[6],
        "bio":user_data[7],
        "profilepic":user_data[8],
        "country":user_data[9],
        "city":user_data[10]
    }
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = user_data_base
    )

@app.get("/auth/admin/get")
async def get_admin(username: str):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Admin username missed"}
    )

    admin_data = db.get_admin(username)
    if admin_data == "Admin not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": admin_data}
    )

    admin_data_base = {
        "username":admin_data[0],
        "email":admin_data[1],
        "fname":admin_data[3],
        "lname":admin_data[4],
        "dateofbirth":admin_data[5],
        "gender":admin_data[6],
        "country":admin_data[7],
        "city":admin_data[8]
    }
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = admin_data_base
    )

@app.get("/auth/supervisor/get")
async def get_supervisor(username: str):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Supervisor username missed"}
    )

    user_data = db.get_supervisor(username)
    if user_data == "Supervisor not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": user_data}
    )

    user_data_base = {
        "username":user_data[0],
        "email":user_data[1],
        "fname":user_data[3],
        "lname":user_data[4],
        "dateofbirth":user_data[5],
        "gender":user_data[6],
        "bio":user_data[7],
        "profilepic":user_data[8],
        "country":user_data[9],
        "city":user_data[10]
    }
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = user_data_base
    )

@app.get("/model/admin/get")
async def admin_get_model(username: str, session_id: str, model_name: str):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin session_id missed"}
    )
    if model_name == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin model_name missed"}
    )
    
    db_check_session = db.check_admin_session(username,session_id)
    if db_check_session == "Admin Session not exist" or db_check_session == "Admin Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    
    model_data = db.admin_get_model(username,model_name)
    if model_data == "Model not exist" or model_data == "Admin Model not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":model_data}
    )

    model_data_base = model_base()
    model_data_base.model_name = model_data[0]
    model_data_base.model_context = model_data[1]
    model_data_base.model_bio = model_data[2]
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = model_data_base.model_dump()
    )

@app.get("/model/admin/gets")
async def admin_get_models(username: str, session_id: str):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin session_id missed"}
    )
    
    db_check_session = db.check_admin_session(username,session_id)
    if db_check_session == "Admin Session not exist" or db_check_session == "Admin Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    
    models_data = db.admin_get_models(username)
    models_data_bases = []
    for model in models_data:
        model_data_base = model_base()
        model_data = db.admin_get_model(username, model[1])
        model_data_base.model_name = model_data[0]
        model_data_base.model_context = model_data[1]
        model_data_base.model_bio = model_data[2]
        models_data_bases.append(model_data_base)

    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"models":models_data_bases.model_dump()}
    )

@app.get("/model/supervisor/get")
async def supervisor_get_model(username: str, session_id: str, model_name: str):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor session_id missed"}
    )
    if model_name == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor model_name missed"}
    )
    
    db_check_session = db.check_supervisor_session(username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    
    model_data = db.supervisor_get_model(username,model_name)
    if model_data == "Model not exist" or model_data == "Supervisor Model not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": model_data}
    )

    model_data_base = model_base()
    model_data_base.model_name = model_data[0]
    model_data_base.model_context = model_data[1]
    model_data_base.model_bio = model_data[2]
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = model_data_base.model_dump()
    )

@app.get("/model/supervisor/gets")
async def supervisor_get_models(username: str, session_id: str):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor session_id missed"}
    )
    
    db_check_session = db.check_supervisor_session(username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    
    models_data = db.supervisor_get_models(username)
    models_data_bases = []
    for model in models_data:
        model_data_base = model_base()
        model_data = db.supervisor_get_model(username, model[1])
        model_data_base.model_name = model_data[0]
        model_data_base.model_context = model_data[1]
        model_data_base.model_bio = model_data[2]
        models_data_bases.append(model_data_base.model_dump())
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"models":models_data_bases}
    )

@app.get("/auth/supervisor/user/get")
async def supervisor_get_user(username: str, session_id: str, user_username: str):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor session_id missed"}
    )
    if user_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Supervisor User username missed"}
    )
    
    db_check_session = db.check_supervisor_session(username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )

    user_data = db.supervisor_get_user(username,user_username)
    if user_data == "User not exist" or user_data == "Supervisor User not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": user_data}
    )
    
    user_data_base = {
        "username":user_data[0],
        "email":user_data[1],
        "fname":user_data[3],
        "lname":user_data[4],
        "dateofbirth":user_data[5],
        "gender":user_data[6],
        "bio":user_data[7],
        "profilepic":user_data[8],
        "country":user_data[9],
        "city":user_data[10]
    }

    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = user_data_base
    )

@app.get("/auth/supervisor/user/gets")
async def supervisor_get_users(username: str, session_id: str):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor session_id missed"}
    )
    
    db_check_session = db.check_supervisor_session(username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    
    users_data = db.supervisor_get_users(username)
    users_data_bases = []
    for user in users_data:
        user_data = db.supervisor_get_user(username, user[1])
        if user_data != "Supervisor User not exist" and user_data != "User not exist":
            user_data_base = {
                "username":user_data[0],
                "email":user_data[1],
                "fname":user_data[3],
                "lname":user_data[4],
                "dateofbirth":user_data[5],
                "gender":user_data[6],
                "bio":user_data[7],
                "profilepic":user_data[8],
                "country":user_data[9],
                "city":user_data[10],
            }
            users_data_bases.append(user_data_base)

    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"users":users_data_bases}
    )

@app.get("/thread/supervisor/member/gets")
async def supervisor_get_thread_members(supervisor_username: str, user_username: str, session_id: str):
    if supervisor_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Get Members supervisor username missed"}
    )
    if user_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Get Members user username missed"}
    )
    
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Get Members session id missed"}
    )
    
    db_check_session = db.check_supervisor_session(supervisor_username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    db_resp = db.supervisor_get_thread_members(supervisor_username,user_username)
    if db_resp == "Supervisor User Member not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )
    
    thread_members = []
    for member in db_resp:
        thread_members.append({
            "member_username":member[0],
            "member_fname":member[3],
            "member_lname":member[4]
        })

    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"thread_members":thread_members}
    )

@app.get("/supervisor/gets")
async def get_supervisors():
    db_resp = db.admin_get_supervisors()
    
    supervisors = []
    for member in db_resp:
        supervisors.append({
            "supervisor_username":member[0],
            "supervisor_email":member[1],
            "supervisor_fname":member[2],
            "supervisor_lname":member[3]
        })

    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"supervisors":supervisors}
    )

@app.get("/thread/supervisor/chat/get")
async def supervisor_get_thread_chat(supervisor_username: str, user_username: str, member_username: str, session_id: str):
    if supervisor_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Get Chat supervisor username missed"}
    )
    if user_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Get Chat user username missed"}
    )
    if member_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Get Chat member username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Get Chat session id missed"}
    )
    
    db_check_session = db.check_supervisor_session(member_username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    db_resp = db.supervisor_get_thread_chat(supervisor_username,user_username,member_username)
    if db_resp == "Supervisor User Member not exist" or db_resp == "Thread Chat Member not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )
    thread_chat = []
    for msg in db_resp:
        msg_base = {
            "member_username":msg[2],
            "msg_text":msg[3],
            "datetime":msg[4]
        }
        thread_chat.append(msg_base)

    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"thread_chat":thread_chat}
    )

@app.get("/thread/supervisor/chat/gets")
async def supervisor_get_thread_chats(supervisor_username: str, session_id: str):
    if supervisor_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Get Chats supervisor username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Get Chats session id missed"}
    )
    db_check_session = db.check_supervisor_session(supervisor_username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    db_resp = db.supervisor_get_thread_chats(supervisor_username)
    thread_chats = []
    for msg in db_resp:
        tmp_resp = db.get_user(msg[1])
        msg_base = {
            "supervisor_username":msg[0],
            "user_username":msg[1],
            "member_username":msg[2],
            "title":tmp_resp[3] + " " + tmp_resp[4]
        }
        print(msg_base)
        thread_chats.append(msg_base)
    print(thread_chats)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"thread_chats":thread_chats}
    )

@app.get("/model/user/get")
async def user_get_model(username: str, model_name: str, session_id: str):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Get Model username missed"}
    )
    if model_name == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Get Model model name missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Get Model session_id missed"}
    )
    
    db_check_session = db.check_user_session(username, session_id)
    if db_check_session == "User Session not exist" or db_check_session == "User Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg":db_check_session}
    )
    
    model_data = db.user_get_model(username,model_name)
    if model_data == "User Not exist" or model_data == "Model not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":model_data}
    )

    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"model_name":model_data[0],"model_bio":model_data[2]}
    )

@app.get("/model/user/gets")
async def user_get_models(username: str, session_id: str):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Get Models username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Get Models session_id missed"}
    )
    
    db_check_session = db.check_user_session(username, session_id)
    if db_check_session == "User Session not exist" or db_check_session == "User Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg":db_check_session}
    )
    models_data = db.user_get_models(username)
    if models_data == "User Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":models_data}
    )
    models_data_bases = []
    for model in models_data:
        models_data_bases.append({"model_name":model[0],"model_bio":model[2]})

    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"models":models_data_bases}
    )

@app.get("/model/chat/user/get")
async def user_get_chat(username: str, model_name: str, session_id: str):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Get Chat username missed"}
    )
    if model_name == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Get Chat model name missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Get Chat session_id missed"}
    )
    
    db_check_session = db.check_user_session(username, session_id)
    if db_check_session == "User Session not exist" or db_check_session == "User Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg":db_check_session}
    )
    db_resp = db.user_get_chat(username,model_name)
    if db_resp == "Model not exist" or db_resp == "User Model Chat not exist" or db_resp == "User not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )
    
    user_chat = []
    for msg in db_resp:
        msg_base = {
            "role":msg[2],
            "msg_text":msg[3],
            "datetime":msg[4],
        }
        user_chat.append(msg_base)

    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"user_model_chat":user_chat}
    )

@app.get("/model/chat/user/gets")
async def user_get_chats(username: str, session_id: str):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Get Chats username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Get Chats session_id missed"}
    )
    
    db_check_session = db.check_user_session(username, session_id)
    if db_check_session == "User Session not exist" or db_check_session == "User Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg":db_check_session}
    )
    db_resp = db.user_get_chats(username)
    user_chats = []
    for msg in db_resp:
        
        msg_base = {
            "username":msg[0],
            "model_name":msg[1],
            "role":msg[2],
            "msg_text":msg[3],
            "datetime":msg[4]
        }
        user_chats.append(msg_base)

    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"user_model_chats":user_chats}
    )

@app.get("/supervisor/chat/get")
async def supervisor_get_chat(supervisor1_username: str, supervisor2_username: str, session_id: str):
    if supervisor1_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Get Chat supervisor1 username missed"}
    )
    if supervisor2_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Get Chat supervisor2 username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Get Chat session id missed"}
    )
    
    db_check_session = db.check_supervisor_session(supervisor1_username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    db_resp = db.supervisor_get_chat(supervisor1_username,supervisor2_username)
    if db_resp == "Supervisor Chat not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )
    chat = []
    for msg in db_resp:
        msg_base = {
            "member_username":msg[2],
            "msg_text":msg[3],
            "datetime":msg[4]
        }
        chat.append(msg_base)

    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"chat":chat}
    )

@app.get("/supervisor/chat/gets")
async def supervisor_get_chats(supervisor_username: str, session_id: str):
    if supervisor_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Get Chats supervisor username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Get Chats session id missed"}
    )
    
    db_check_session = db.check_supervisor_session(supervisor_username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    db_resp = db.supervisor_get_chats(supervisor_username)
    chats = []
    for msg in db_resp:
        msg_base = {
            "supervisor1_username":msg[0],
            "supervisor2_username":msg[1],
            "member_username":msg[2],
            "msg_text":msg[3],
            "datetime":msg[4]
        }
        chats.append(msg_base)

    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"chats":chats}
    )

@app.put("/auth/user/update")
async def update_user(username: str, session_id: str, password: str, user: user_base):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "User username missed"}
    )
    if password == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "User password missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "User session_id missed"}
    )
    
    user_data = db.get_user(username)
    if user_data == "User not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":user_data}
    )
    
    db_check_session = db.check_user_session(username,session_id)
    if db_check_session == "User Session not exist" or db_check_session == "User Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    
    if user_data[2] != password:
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "User data invalid"}
    )

    db_resp = db.update_user(username,user.username,user.email,user.password,user.fname,user.lname,user.dateofbirth,user.gender,user.bio,user.profilepic,user.country,user.city)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == 'User updated' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.put("/auth/admin/update")
async def update_admin(username: str, session_id: str, password: str, admin: admin_base):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Admin username missed"}
    )
    if password == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Admin password missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Admin session_id missed"}
    )
    
    user_data = db.get_admin(username)
    if user_data == "Admin not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":user_data}
    )
    
    db_check_session = db.check_admin_session(username,session_id)
    if db_check_session == "Admin Session not exist" or db_check_session == "Admin Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    
    if user_data[2] != password:
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Admin data invalid"}
    )

    db_resp = db.update_admin(username,admin.username,admin.email,admin.password,admin.fname,admin.lname,admin.dateofbirth,admin.gender,admin.country,admin.city)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == 'Admin updated' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.put("/auth/supervisor/update")
async def update_supervisor(username: str, session_id: str, password: str, user: user_base):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Supervisor username missed"}
    )
    if password == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Supervisor password missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Supervisor session_id missed"}
    )
    
    user_data = db.get_supervisor(username)
    if user_data == "Supervisor not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":user_data}
    )
    
    db_check_session = db.check_supervisor_session(username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    if user_data[2] != password:
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Supervisor data invalid"}
    )
    
    db_resp = db.update_supervisor(username,user.username,user.email,user.password,user.fname,user.lname,user.dateofbirth,user.gender,user.bio,user.profilepic,user.country,user.city)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == 'Supervisor updated' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )


@app.put("/auth/user/forgetpassword")
async def forget_password_user(user: login_base):
    if user.username == '' and user.email == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "User username or email missed"}
    )
    if user.password == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "User password missed"}
    )
    user.username = db.get_user_username(user.email) if user.username == '' else user.username
    
    db_resp = db.user_change_password(user.username,user.password)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == 'User password reset success' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.put("/auth/admin/forgetpassword")
async def forget_password_admin(user: login_base):
    if user.username == '' and user.email == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Admin username or email missed"}
    )
    if user.password == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Admin password missed"}
    )
    user.username = db.get_admin_username(user.email) if user.username == '' else user.username
    
    db_resp = db.admin_change_password(user.username,user.password)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == 'Admin password reset success' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.put("/auth/supervisor/forgetpassword")
async def forget_password_supervisor(user: login_base):
    if user.username == '' and user.email == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Supervisor username or email missed"}
    )
    if user.password == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Supervisor password missed"}
    )
    user.username = db.get_supervisor_username(user.email) if user.username == '' else user.username
    
    db_resp = db.supervisor_change_password(user.username,user.password)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == 'Supervisor password reset success' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.put("/model/admin/update")
async def admin_update_model(username: str, session_id: str, model_name: str, model: model_base):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin session_id missed"}
    )
    if model_name == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin model_name missed"}
    )
    
    db_check_session = db.check_admin_session(username,session_id)
    if db_check_session == "Admin Session not exist" or db_check_session == "Admin Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    
    db_resp = db.admin_update_model(username,model_name,model.model_name,model.model_context,model.model_bio)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == 'Model updated' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.put("/model/supervisor/update")
async def supervisor_update_model(username: str, session_id: str, model_name: str, model: model_base):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor session_id missed"}
    )
    if model_name == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor model_name missed"}
    )
    
    db_check_session = db.check_supervisor_session(username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    
    db_resp = db.supervisor_update_model(username,model_name,model.model_name,model.model_context,model.model_bio)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == 'Model updated' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.put("/auth/user/confirm")
async def user_confirm_email(username: str, email: str, password: str):
    user_data = db.get_user(username)
    if user_data == "User not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":user_data}
    )
    if user_data[1] != email:
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"User Email Invalid"}
    )
    if user_data[2] != password:
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"User Password Invalid"}
    )

    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"msg":"User Email Confirmed"}
    )

@app.put("/auth/admin/confirm")
async def admin_confirm_email(username: str, email: str, password: str):
    user_data = db.get_admin(username)
    if user_data == "Admin not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":user_data}
    )
    if user_data[1] != email:
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin Email Invalid"}
    )
    if user_data[2] != password:
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin Password Invalid"}
    )

    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"msg":"Admin Email Confirmed"}
    )

@app.put("/auth/supervisor/confirm")
async def supervisor_confirm_email(username: str, email: str, password: str):
    user_data = db.get_supervisor(username)
    if user_data == "Supervisor not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":user_data}
    )
    if user_data[1] != email:
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor Email Invalid"}
    )
    if user_data[2] != password:
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor Password Invalid"}
    )
    
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"msg":"Supervisor Email Confirmed"}
    )

@app.delete("/auth/user/delete")
async def delete_user(username: str, password: str, session_id: str):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "User username missed"}
    )
    if password == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "User password missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "User session_id missed"}
    )
    
    user_data = db.get_user(username)
    if user_data == "User not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":user_data}
    )
    
    db_check_session = db.check_user_session(username,session_id)
    if db_check_session == "User Session not exist" or db_check_session == "User Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    
    if user_data[2] != password:
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "User data invalid"}
    )

    db_resp = db.delete_user(username)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == 'User deleted' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.delete("/auth/admin/delete")
async def delete_admin(username: str, password: str, session_id: str):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Admin username missed"}
    )
    if password == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Admin password missed"}
    )
        return 
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Admin session_id missed"}
    )
    
    user_data = db.get_admin(username)
    if user_data == "Admin not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":user_data}
    )
    
    db_check_session = db.check_admin_session(username,session_id)
    if db_check_session == "Admin Session not exist" or db_check_session == "Admin Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    
    if user_data[2] != password:
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Admin data invalid"}
    )

    db_resp = db.delete_admin(username)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == 'Admin deleted' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.delete("/auth/supervisor/delete")
async def delete_supervisor(username: str, password: str, session_id: str):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Supervisor username missed"}
    )
    if password == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Supervisor password missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Supervisor session_id missed"}
    )
    
    user_data = db.get_supervisor(username)
    if user_data == "Supervisor not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":user_data}
    )
    
    db_check_session = db.check_supervisor_session(username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    
    if user_data[2] != password:
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Supervisor data invalid"}
    )
    
    db_resp = db.delete_supervisor(username)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == 'Supervisor deleted' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.delete("/model/admin/delete")
async def admin_delete_model(username: str, session_id: str, model_name: str):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin session_id missed"}
    )
    if model_name == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin model_name missed"}
    )
    
    db_check_session = db.check_admin_session(username,session_id)
    if db_check_session == "Admin Session not exist" or db_check_session == "Admin Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    
    db_resp = db.admin_delete_model(username,model_name)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == 'Model deleted' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )


@app.delete("/model/supervisor/delete")
async def supervisor_delete_model(username: str, session_id: str, model_name: str):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor session_id missed"}
    )
    if model_name == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor model_name missed"}
    )
    
    db_check_session = db.check_supervisor_session(username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    
    db_resp = db.supervisor_delete_model(username,model_name)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == 'Model deleted' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

    
@app.delete("/auth/supervisor/user/delete")
async def supervisor_delete_user(username: str, session_id: str, user_username):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor session_id missed"}
    )
    if user_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg": "Supervisor User username missed"}
    )
    
    db_check_session = db.check_supervisor_session(username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )

    db_resp = db.supervisor_delete_user(username,user_username)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == 'Supervisor User deleted' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.delete("/auth/user/logout")
async def user_logout(username: str, session_id: str):
    db_resp = db.user_logout(username,session_id)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == 'User Session logout' else stts.HTTP_401_UNAUTHORIZED,
        content = {"msg":db_resp}
    )

@app.delete("/auth/admin/logout")
async def admin_logout(username: str, session_id: str):
    db_resp = db.admin_logout(username,session_id)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == 'Admin Session logout' else stts.HTTP_401_UNAUTHORIZED,
        content = {"msg":db_resp}
    )

@app.delete("/auth/supervisor/logout")
async def supervisor_logout(username: str, session_id: str):
    db_resp = db.supervisor_logout(username,session_id)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == 'Supervisor Session logout' else stts.HTTP_401_UNAUTHORIZED,
        content = {"msg":db_resp}
    )

@app.delete("/assign/supervisor/delete")
async def supervisor_delete_assign(supervisor_username: str, user_username: str, model_name: str, session_id: str):
    if supervisor_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Delete Assign supervisor username missed"}
    )
    if user_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Delete Assign user username missed"}
    )
    if model_name == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Delete Assign model name missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Delete Assign session id missed"}
    )
    
    db_check_session = db.check_supervisor_session(supervisor_username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )

    db_resp = db.supervisor_delete_assign(supervisor_username,user_username,model_name)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == 'Supervisor User Model deleted' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.delete("/model/chat/user/delete")
async def user_delete_chat(username: str, model_name: str, session_id: str):
    if username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Delete Chat username missed"}
    )
    if model_name == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Delete Chat model name missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Delete Chat session_id missed"}
    )
    
    db_check_session = db.check_user_session(username, session_id)
    if db_check_session == "User Session not exist" or db_check_session == "User Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg":db_check_session}
    )

    db_resp = db.user_delete_chat(username,model_name)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == 'User Model Chat deleted' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.delete("/thread/supervisor/member/delete")
async def supervisor_delete_thread_member(supervisor_username: str, user_username: str, member_username: str, session_id: str):
    if supervisor_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Delete Member supervisor username missed"}
    )
    if user_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Delete Member user username missed"}
    )
    if member_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Delete Member model name missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Thread Delete Member session id missed"}
    )
    
    db_check_session = db.check_supervisor_session(supervisor_username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    
    db_resp = db.supervisor_delete_thread_member(supervisor_username,user_username,member_username)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == 'Supervisor User Member deleted' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.delete("/supervisor/chat/delete")
async def supervisor_delete_chat(supervisor1_username: str, supervisor2_username: str, session_id: str):
    if supervisor1_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Delete Chat supervisor1 username missed"}
    )
    if supervisor2_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Delete Chat supervisor2 username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Delete Get Chat session id missed"}
    )
    
    db_check_session = db.check_supervisor_session(supervisor1_username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    
    db_resp = db.supervisor_delete_chat(supervisor1_username,supervisor2_username)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == 'Supervisor Chat deleted' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

@app.get("/supervisor/get/dashboard")
async def supervisor_get_dashboard(supervisor_email: str):
    if supervisor_email == '':
        return resps.JSONResponse(
            status_code = stts.HTTP_400_BAD_REQUEST,
            content = {"msg":"Supervisor email missed"}
        )
    supervisor_username = db.get_supervisor_username(supervisor_email)
    if supervisor_username == "Supervisor Not exist":
        return resps.JSONResponse(
            status_code = stts.HTTP_400_BAD_REQUEST,
            content = {"msg":supervisor_username}
        )
    db_resp = db.supervisor_get_near_user_activity(supervisor_username)
    near_user_model = []
    for i in db_resp:
        user_name = db.get_user(i[0])
        near_user_model.append({
            "user_name": user_name[3] + " " + user_name[4],
            "model_name": i[1],
            "datetime": i[2]
        })
    db_resp = db.supervisor_get_far_user_activity(supervisor_username)
    far_user_model = []
    for i in db_resp:
        user_name = db.get_user(i[0])
        far_user_model.append({
            "user_name": user_name[3] + " " + user_name[4],
            "model_name": i[1],
            "datetime": i[2]
        })
    db_resp = db.supervisor_get_most_model(supervisor_username)
    most_model = []
    for i in db_resp:
        most_model.append({
            "model_name": i[0],
            "msg_count": i[1]
        })
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {
            "near_user_model": near_user_model,
            "far_user_model": far_user_model,
            "most_model": most_model,
            "count_user": db.supervisor_get_count_user(supervisor_username),
            "count_model": db.supervisor_get_count_model(supervisor_username)
            }
    )

@app.get("/admin/get/dashboard")
async def admin_get_dashboard(admin_email: str):
    if admin_email == '':
        return resps.JSONResponse(
            status_code = stts.HTTP_400_BAD_REQUEST,
            content = {"msg":"Admin email missed"}
        )
    admin_username = db.get_admin_username(admin_email)
    if admin_username == "Admin Not exist":
        return resps.JSONResponse(
            status_code = stts.HTTP_400_BAD_REQUEST,
            content = {"msg":admin_username}
        )
    db_resp = db.admin_get_most_model(admin_username)
    most_model = []
    for i in db_resp:
        most_model.append({
            "model_name": i[0],
            "msg_count": i[1]
        })
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {
            "most_model": most_model,
            "count_user": db.admin_get_count_user(),
            "count_model": db.admin_get_count_model(admin_username),
            "count_supervisor": db.admin_get_count_supervisor()
            }
    )

@app.get("/supervisor/get/near/user")
async def supervisor_get_near_user_activity(supervisor_username: str, session_id: str):
    if supervisor_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Session id missed"}
    )
    db_check_session = db.check_supervisor_session(supervisor_username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    db_resp = db.supervisor_get_near_user_activity(supervisor_username)
    user_model = []
    for i in db_resp:
        user_model.append({
            "user_username": i[0],
            "model_name": i[1],
            "datetime": i[2]
        })
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"user_model": user_model}
    )

@app.get("/supervisor/get/far/user")
async def supervisor_get_far_user_activity(supervisor_username: str, session_id: str):
    if supervisor_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Session id missed"}
    )
    db_check_session = db.check_supervisor_session(supervisor_username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    db_resp = db.supervisor_get_far_user_activity(supervisor_username)
    user_model = []
    for i in db_resp:
        user_model.append({
            "user_username": i[0],
            "model_name": i[1],
            "datetime": i[2]
        })
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"user_model": user_model}
    )

@app.get("/supervisor/get/most/model")
async def supervisor_get_most_model(supervisor_username: str, session_id: str):
    if supervisor_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Session id missed"}
    )
    db_check_session = db.check_supervisor_session(supervisor_username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    db_resp = db.supervisor_get_most_model(supervisor_username)
    most_model = []
    for i in db_resp:
        most_model.append({
            "model_name": i[0],
            "msg_count": i[1]
        })
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"most_model": most_model}
    )

@app.get("/supervisor/get/count/user")
async def supervisor_get_count_user(supervisor_username: str, session_id: str):
    if supervisor_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Session id missed"}
    )
    db_check_session = db.check_supervisor_session(supervisor_username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"count_user": db.supervisor_get_count_user(supervisor_username)}
    )

@app.get("/supervisor/get/count/model")
async def supervisor_get_count_model(supervisor_username: str, session_id: str):
    if supervisor_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Session id missed"}
    )
    db_check_session = db.check_supervisor_session(supervisor_username,session_id)
    if db_check_session == "Supervisor Session not exist" or db_check_session == "Supervisor Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"count_model": db.supervisor_get_count_model(supervisor_username)}
    )

@app.get("/admin/get/count/user")
async def admin_get_count_user(admin_username: str, session_id: str):
    if admin_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Session id missed"}
    )
    db_check_session = db.check_admin_session(admin_username,session_id)
    if db_check_session == "Admin Session not exist" or db_check_session == "Admin Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"count_user": db.admin_get_count_user()}
    )


@app.get("/admin/get/count/supervisor")
async def admin_get_count_supervisor(admin_username: str, session_id: str):
    if admin_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Session id missed"}
    )
    db_check_session = db.check_admin_session(admin_username,session_id)
    if db_check_session == "Admin Session not exist" or db_check_session == "Admin Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"count_supervisor": db.admin_get_count_supervisor()}
    )

@app.get("/admin/get/count/model")
async def admin_get_count_model(admin_username: str, session_id: str):
    if admin_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Session id missed"}
    )
    db_check_session = db.check_admin_session(admin_username,session_id)
    if db_check_session == "Admin Session not exist" or db_check_session == "Admin Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"count_model": db.admin_get_count_model(admin_username)}
    )

@app.get("/admin/get/most/model")
async def admin_get_most_model(admin_username: str, session_id: str):
    if admin_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Session id missed"}
    )
    db_check_session = db.check_admin_session(admin_username,session_id)
    if db_check_session == "Admin Session not exist" or db_check_session == "Admin Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    db_resp = db.admin_get_most_model(admin_username)
    most_model = []
    for i in db_resp:
        most_model.append({
            "model_name": i[0],
            "msg_count": i[1]
        })
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"most_model": most_model}
    )

@app.get("/admin/get/users")
async def admin_get_users(admin_username: str, session_id: str):
    if admin_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Session id missed"}
    )
    db_check_session = db.check_admin_session(admin_username,session_id)
    if db_check_session == "Admin Session not exist" or db_check_session == "Admin Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    # 'username','email','fname','lname','gender','bio','profilepic'
    db_resp = db.admin_get_users()
    users = []
    for i in db_resp:
        users.append({
            'username':i[0],
            'email':i[1],
            'fname':i[2],
            'lname':i[3],
            'gender':i[4],
            'bio':i[5],
            'profilepic':i[6]
        })
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"users": users}
    )

@app.get("/admin/get/supervisors")
async def admin_get_supervisors(admin_username: str, session_id: str):
    if admin_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Session id missed"}
    )
    db_check_session = db.check_admin_session(admin_username,session_id)
    if db_check_session == "Admin Session not exist" or db_check_session == "Admin Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    # 'username','email','fname','lname','gender','bio','profilepic'
    db_resp = db.admin_get_supervisors()
    supervisors = []
    for i in db_resp:
        supervisors.append({
            'username':i[0],
            'email':i[1],
            'fname':i[2],
            'lname':i[3],
            'gender':i[4],
            'bio':i[5],
            'profilepic':i[6]
        })
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"supervisors": supervisors}
    )

@app.delete("/admin/delete/user")
async def admin_delete_user(admin_username: str, user_username, session_id: str):
    if admin_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin username missed"}
    )
    if user_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"User username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Session id missed"}
    )
    db_check_session = db.check_admin_session(admin_username,session_id)
    if db_check_session == "Admin Session not exist" or db_check_session == "Admin Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    db_resp = db.delete_user(user_username)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == "User deleted" else stts.HTTP_400_BAD_REQUEST,
        content = {"msg": db_resp}
    )

@app.delete("/admin/delete/supervisor")
async def admin_delete_supervisor(admin_username: str, supervisor_username, session_id: str):
    if admin_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin username missed"}
    )
    if supervisor_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Supervisor username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Session id missed"}
    )
    db_check_session = db.check_admin_session(admin_username,session_id)
    if db_check_session == "Admin Session not exist" or db_check_session == "Admin Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    db_resp = db.delete_supervisor(supervisor_username)
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK if db_resp == "Supervisor deleted" else stts.HTTP_400_BAD_REQUEST,
        content = {"msg": db_resp}
    )

@app.post("/admin/add/admin")
async def admin_add_admin(admin_username: str, admin: admin_base, session_id: str):
    if admin_username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin username missed"}
    )
    if session_id == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Session id missed"}
    )
    if admin.username == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin Admin username missed"}
    )
    if admin.email == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin Admin email missed"}
    )
    if admin.password == '':
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Admin Admin password missed"}
    )
    db_check_session = db.check_admin_session(admin_username,session_id)
    if db_check_session == "Admin Session not exist" or db_check_session == "Admin Not exist":
        return resps.JSONResponse(
        status_code = stts.HTTP_401_UNAUTHORIZED,
        content = {"msg": db_check_session}
    )
    db_resp = db.add_admin(admin.username,admin.email,admin.password,admin.fname,admin.lname,admin.dateofbirth,admin.gender,admin.country,admin.city)
    
    return resps.JSONResponse(
        status_code = stts.HTTP_201_CREATED if db_resp == 'Admin added' else stts.HTTP_400_BAD_REQUEST,
        content = {"msg":db_resp}
    )

# API for .NET
class user_model_send_base(BaseModel):
    username: str = Field(default='',description='User username'),
    user_fname: str = Field(default='',description='User first name'),
    user_lname: str = Field(default='',description='User last name'),
    model_name: str = Field(default='',description='Model name'),
    model_context: str = Field(default='',description='Model context'),
    msg_text: str = Field(default='',description='Message text'),

@app.post("/user/model/send")
async def user_send_model(msg: user_model_send_base):
    if '' in [msg.username, msg.user_fname, msg.user_lname, msg.model_name, msg.model_context, msg.msg_text]:
        return resps.JSONResponse(
        status_code = stts.HTTP_400_BAD_REQUEST,
        content = {"msg":"Some fields missed"}
    )
    db.add_user(msg.username, msg.username, msg.username, msg.user_fname, msg.user_lname)
    db.add_model(msg.model_name,msg.model_context)

    db.update_user(msg.username, '', '', msg.username, msg.user_fname, msg.user_lname)
    db.update_model(msg.model_name, '', msg.model_context)

    db.ini_user_model_chat(msg.username, msg.model_name)

    resp = bot.send_tmp_msg(msg.username, msg.model_name, msg.msg_text)
    return resps.JSONResponse(
        status_code=stts.HTTP_200_OK,
        content = {"msg":resp}
    )
                    
@app.get("/users")
async def get_users():
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = db.get_users()
    )

@app.get("/auth/user/id")
async def get_user_id(email: str):
    if email == '':
        return resps.JSONResponse(
            status_code = stts.HTTP_400_BAD_REQUEST,
            content = {"msg":"Email missed"}
        )
    user_id = db.get_user_id(email)
    if user_id == "Not Found":
        return resps.JSONResponse(
            status_code = stts.HTTP_400_BAD_REQUEST,
            content = {"msg":"Email user not found"}
        )
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"user_id":user_id}
    )

@app.get("/auth/user/role")
async def get_user_role(email: str):
    if email == '':
        return resps.JSONResponse(
            status_code = stts.HTTP_400_BAD_REQUEST,
            content = {"msg":"Email missed"}
        )
    user_role = db.get_user_role(email)
    if user_role == "Not Found":
        return resps.JSONResponse(
            status_code = stts.HTTP_400_BAD_REQUEST,
            content = {"msg":"Email user not found"}
        )
    return resps.JSONResponse(
        status_code = stts.HTTP_200_OK,
        content = {"user_role":user_role}
    )