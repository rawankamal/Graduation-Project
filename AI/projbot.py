from typing import Final
import sqlite3 as sq
import google.generativeai as genai
from supabaseprojdb import db
from basemodels import base_temp, base_schema
import json
import time

genai.configure(api_key="KEY")

class BOT:
    def __init__(self):
        self.__info_gather = genai.GenerativeModel(
            model_name="gemini-2.0-flash-exp",
            system_instruction='\n'.join([
                "You will be provided with Message and Info.",
                "Message: the message from the user.",
                "Info: some information about user who message you.",
                "You have to extract JSON details from text according the Pydantic details.",
                "Extract details as mentioned from text.",
                "Extracted details must be in english only however the message text language was.",
                "Do not generate any introduction or conclusion.",
                "You must never remove previous info or erase any part of it."
            ]),
            generation_config={"temperature": 0.2}
        )

    def __get_model(self, model_name: str):
        model_context = db.get_model(model_name)
        if model_context == "Model not exist":
            return model_context
        model_context = model_context[1]
        model = genai.GenerativeModel(
            model_name="gemini-2.0-flash-exp",
            system_instruction= '\n'.join([
                f"Your name is {model_name}",
                "You will be provided with Message and Info.",
                "Message: the message from the user.",
                "Info: some information about user who message you.",
                f"If user ask about some info or interests about you, answer from your context: {model_context}.",
                "You are a good friend for the user.",
                "You must answer the message based on info and message.",
                "You must act like natural person not bot.",
                "You must never talk about what in your mind to generate the message.",
                "Take care if user just send you first message you should be not know him.",
                "You must answer the user in same context and tone.",
                "You must never info provided to you, only answer based on it.",
                "Always talk to him as he may have a psychopathic diseases.",
                "You must respond in way gentally and friendly to user context.",
                "You must never send messages with a lot of questions.",
                "If user send letters not in english neither arabic, reply that you don't understand it.",
                "If user message not in english neither arabic (egyptian dialect), reply that you don't undersand it, otherwise reply regulary.",
                "You must answer only in english and arabic (egyptian dialect).",
                "If user message in english reply in english only.",
                "If user message in arabic (egyptian dialect) reply in arabic (egyptian dialect) only.",
                "You must never use emojis, only if user use in message.",
                "If user question about something need knowledge, reply you don;t know that, you answer only if it public defination.",
                "If user ask about (math - code - science - learn) promblems in specific field, reply you don't know that.",
                "If user ask about any boys or girls interests, you must reply about any related topic.",
                "If user ask about something you don't know, you must reply you don't know and how about discuss it.",
                "If user ask about some personal info about himself, you must reply you don't know it.",
                "You must answer in summary way not too long message.",
                "You must never mention any robotic tone or words same like unnatural."
            ]),
            generation_config={"temperature":0.2}
        )
        return model
    
    def send_msg(self, username: str, model_name: str, msg_text: str):
        resp = db.ini_user_model_chat(username,model_name)
        if resp == "Model not exist" or resp == "User not exist":
            return resp
        user_info = db.get_user_info(username, model_name)
        if user_info == "Model not exist" or user_info == "User Model Chat not exist" or user_info == "User not exist":
            return user_info
        model = self.__get_model(model_name)
        if model == "Model not exist":
            return model
        chat_history = db.get_chat_history(username,model_name)
        if chat_history == "Model not exist" or chat_history == "User Model Chat not exist" or chat_history == "User not exist":
            return chat_history
        model = model.start_chat(history=chat_history)
        model.send_message('\n'.join([
            "## Message:",
            msg_text,
            "## User Info:",
            json.dumps(user_info, ensure_ascii=False)
        ]))
        rsp_text = model.last.text

        info_model = self.__info_gather.start_chat()
        info_model.send_message('\n'.join([
            "## Message:",
            msg_text,
            "## User Info:",
            json.dumps(user_info, ensure_ascii=False),
            "## Pydantic Details:",
            base_schema,
            "## New User Info:",
            "```json"
        ]))

        user_info = json.loads(info_model.last.text.removeprefix('```json').removesuffix('```'))
        db.update_user_info(username,model_name,json.dumps(user_info, ensure_ascii=False))
        db.user_send_chat(username,model_name,msg_text)
        db.model_send_chat(username,model_name,rsp_text)
        return rsp_text
    
    def send_tmp_msg(self, username: str, model_name: str, msg_text: str):
        user_info = db.get_user_info(username, model_name)
        model = self.__get_model(model_name)
        chat_history = db.get_chat_history(username,model_name)
        model = model.start_chat(history=chat_history)
        model.send_message('\n'.join([
            "## Message:",
            msg_text,
            "## User Info:",
            json.dumps(user_info, ensure_ascii=False)
        ]))
        rsp_text = model.last.text

        info_model = self.__info_gather.start_chat()
        info_model.send_message('\n'.join([
            "## Message:",
            msg_text,
            "## User Info:",
            json.dumps(user_info, ensure_ascii=False),
            "## Pydantic Details:",
            base_schema,
            "## New User Info:",
            "```json"
        ]))

        user_info = json.loads(info_model.last.text.removeprefix('```json').removesuffix('```'))
        db.update_user_info(username,model_name,json.dumps(user_info, ensure_ascii=False))
        db.user_send_chat(username,model_name,msg_text)
        db.model_send_chat(username,model_name,rsp_text)
        return rsp_text

bot = BOT()

print("Model Initiated")