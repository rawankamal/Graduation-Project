import json
from pydantic import BaseModel, Field
from typing import List, Optional, Literal, Final
from supabase import create_client, Client
from basemodels import base_temp, base_schema
import random as rnd


class DB:
    def __init__(self):
        self.__con: Client = create_client("URL", "KEY")
        self.__session_id_chars = []
        for c in range(25):
            self.__session_id_chars.append(chr(ord('a')+c))
        for c in range(25):
            self.__session_id_chars.append(chr(ord('A')+c))
        for c in range(10):
            self.__session_id_chars.append(chr(ord('0')+c))
        
    def add_user(self, username: str, email: str, password: str, fname: str = None, lname: str = None, dateofbirth: str = None, gender: str = None, bio: str = None, profilepic: str = None, country: str = None, city: str = None):
        cur = self.__con
        resp = (cur.table("user").select("*").eq("username",username).execute()).data
        if len(resp) == 0:
            resp = (cur.table("user").select("*").eq("email",email).execute()).data
            if len(resp) == 0:
                (cur.table("user").insert({
                    "username":username,"email":email,"password":password,"fname":fname,"lname":lname,"dateofbirth":dateofbirth,"gender":gender,"bio":bio,"profilepic":profilepic,"country":country,"city":city
                    }).execute()
                )
                return "User added"
            else:
                return "User email exist"
        else:
            return "User username exist"

    def get_user(self, username: str):
        """ username, email, password, fname, lname, dateofbirth, gender, bio, profilepic, country, city """
        cur = self.__con
        resp = (cur.table("user").select("*").eq("username",username).execute()).data
        if len(resp) != 0:
            return tuple(resp[0].values())
        else:
            return "User not exist"

    def delete_user(self, username: str):
        cur = self.__con
        resp = (cur.table("user").select("*").eq("username",username).execute()).data
        if len(resp) != 0:
            (cur.table("user").delete().eq("username",username).execute())
            (cur.table("user_session").delete().eq("username",username).execute())
            (cur.table("user_model_chat").delete().eq("username",username).execute())
            (cur.table("user_info").delete().eq("username",username).execute())
            (cur.table("supervisor_user").delete().eq("user_username",username).execute())
            (cur.table("supervisor_user_model").delete().eq("user_username",username).execute())
            (cur.table("user_thread_member").delete().eq("user_username",username).execute())
            (cur.table("user_thread_chat").delete().eq("user_username",username).execute())

            return "User deleted"
        else:
            return "User not exist"
        
    def update_user(self, username: str, new_username: str = None, email: str = None, password: str = None, fname: str = None, lname: str = None, dateofbirth: str = None, gender: str = None, bio: str = None, profilepic: str = None, country: str = None, city: str = None):
        cur = self.__con
        user_data = (cur.table("user").select("*").eq("username",username).execute()).data
        if len(user_data) != 0:
            user_data = tuple(user_data[0].values())
            if new_username != '' and new_username != username:
                resp = (cur.table("user").select("*").eq("username",new_username).execute()).data
                if len(resp) != 0:
                    return "User username exist"
            else:
                new_username = username
            if email != '':
                resp = (cur.table("user").select("*").eq("email",email).execute()).data
                if len(resp) != 0:
                    return "User email exist"
            email = user_data[1] if email == '' else email
            password = user_data[2] if password == '' else password
            fname = user_data[3] if fname == '' else fname
            lname = user_data[4] if lname == '' else lname
            dateofbirth = user_data[5] if dateofbirth == '' else dateofbirth
            gender = user_data[6] if gender == '' else gender
            bio = user_data[7] if bio == '' else bio
            profilepic = user_data[8] if profilepic == '' else profilepic
            country = user_data[9] if country == '' else country
            city = user_data[10] if city == '' else city
            
            (cur.table("user").update({
                    "username":new_username,"email":email,"password":password,"fname":fname,"lname":lname,"dateofbirth":dateofbirth,"gender":gender,"bio":bio,"profilepic":profilepic,"country":country,"city":city
                    }).eq("username",username).execute())

            (cur.table("user_model_chat").update({"username":new_username}).eq("username",username).execute())
            (cur.table("user_info").update({"username":new_username}).eq("username",username).execute())

            (cur.table("supervisor_user").update({"user_username":new_username}).eq("user_username",username).execute())
            (cur.table("supervisor_user_model").update({"user_username":new_username}).eq("user_username",username).execute())
            
            (cur.table("user_thread_member").update({"user_username":new_username}).eq("user_username",username).execute())
            (cur.table("user_thread_chat").update({"user_username":new_username}).eq("user_username",username).execute())
            
            (cur.table("user_session").update({"username":new_username}).eq("username",username).execute())

            return "User updated"
        else:
            return "User not exist"
        
    def add_admin(self, username: str, email: str, password: str, fname: str = None, lname: str = None, dateofbirth: str = None, gender: str = None, country: str = None, city: str = None):
        cur = self.__con
        resp = (cur.table("admin").select("*").eq("username",username).execute()).data
        if len(resp) == 0:
            resp = (cur.table("admin").select("*").eq("email",email).execute()).data
            if len(resp) == 0:
                (cur.table("admin").insert({
                    "username":username,"email":email,"password":password,"fname":fname,"lname":lname,"dateofbirth":dateofbirth,"gender":gender,"country":country,"city":city
                }).execute())
                return "Admin added"
            else:
                return "Admin email exist"
        else:
            return "Admin username exist"

    def get_admin(self, username: str):
        """ username, email, password, fname, lname, dateofbirth, gender, country, city """
        cur = self.__con
        resp = (cur.table("admin").select("*").eq("username",username).execute()).data
        if len(resp) != 0:
            return tuple(resp[0].values())
        else:
            return "Admin not exist"

    def delete_admin(self, username: str):
        cur = self.__con
        resp = (cur.table("admin").select("*").eq("username",username).execute()).data
        if len(resp) != 0:
            admin_models = self.admin_get_models(username)
            for model in admin_models:
                self.delete_model(model[1])

            (cur.table("admin").delete().eq("username",username).execute())
            (cur.table("admin_session").delete().eq("username",username).execute())

            return "Admin deleted"
        else:
            return "Admin not exist"
        
    def update_admin(self, username: str, new_username: str = None, email: str = None, password: str = None, fname: str = None, lname: str = None, dateofbirth: str = None, gender: str = None, country: str = None, city: str = None):
        cur = self.__con
        user_data = (cur.table("admin").select("*").eq("username",username).execute()).data
        if len(user_data) != 0:
            user_data = tuple(user_data[0].values())
            if new_username != '' and new_username != username:
                resp = (cur.table("admin").select("*").eq("username",new_username).execute()).data
                if len(resp) != 0:
                    return "Admin username exist"
            else:
                new_username = username
            if email != '':
                resp = (cur.table("admin").select("*").eq("email",email).execute()).data
                if len(resp) != 0:
                    return "Admin email exist"
            email = user_data[1] if email == '' else email
            password = user_data[2] if password == '' else password
            fname = user_data[3] if fname == '' else fname
            lname = user_data[4] if lname == '' else lname
            dateofbirth = user_data[5] if dateofbirth == '' else dateofbirth
            gender = user_data[6] if gender == '' else gender
            country = user_data[7] if country == '' else country
            city = user_data[8] if city == '' else city

            (cur.table("admin").update({
                    "username":new_username,"email":email,"password":password,"fname":fname,"lname":lname,"dateofbirth":dateofbirth,"gender":gender,"country":country,"city":city
                }).eq("username",username).execute())

            (cur.table("admin_model").update({"admin_username":new_username}).eq("admin_username",username).execute())
            (cur.table("admin_session").update({"username":new_username}).eq("username",username).execute())
            
            return "Admin updated"
        else:
            return "Admin not exist"
        
    def admin_add_model(self, admin_username: str, model_name: str, model_context: str = None, model_bio: str = None):
        cur = self.__con
        resp = (cur.table("admin_model").select("*").eq("admin_username",admin_username).eq("model_name",model_name).execute()).data
        if len(resp) != 0:
            return "Admin Model exist"
        resp = self.add_model(model_name,model_context,model_bio)
        if resp == "Model added":
            (cur.table("admin_model").insert({"admin_username":admin_username,"model_name":model_name}).execute())
            return "Admin Model added"
        else:
            return resp
        
    def admin_update_model(self, admin_username: str, model_name: str, new_model_name: str = None, model_context: str = None, model_bio: str = None):    
        cur = self.__con
        resp = (cur.table("admin_model").select("*").eq("admin_username",admin_username).eq("model_name",model_name).execute()).data
        if len(resp) != 0:
            return self.update_model(model_name,new_model_name,model_context,model_bio)
        else:
            return "Admin Model not exist"
    
    def admin_delete_model(self, admin_username: str, model_name: str):    
        cur = self.__con
        resp = (cur.table("admin_model").select("*").eq("admin_username",admin_username).eq("model_name",model_name).execute()).data
        if len(resp) != 0:
            return self.delete_model(model_name)
        else:
            return "Admin Model not exist"
        
    def admin_get_model(self, admin_username: str, model_name: str):
        """ model_name, model_context, model_bio """     
        cur = self.__con
        resp = (cur.table("admin_model").select("*").eq("admin_username",admin_username).eq("model_name",model_name).execute()).data
        if len(resp) != 0:
            return self.get_model(model_name)
        else:
            return "Admin Model not exist"

    def admin_get_models(self, admin_username: str):
        """ [admin_username, model_name] """     
        cur = self.__con
        resp = (cur.table("admin_model").select("*").eq("admin_username",admin_username).execute()).data
        admin_models = []
        for model in resp:
            admin_models.append(tuple(model.values()))
        return admin_models
    
    def add_model(self, model_name: str, model_context: str = None, model_bio: str = None):
        cur = self.__con
        resp = (cur.table("model").select("*").eq("model_name",model_name).execute()).data
        if len(resp) == 0:
            (cur.table("model").insert({"model_name":model_name,"model_context":model_context,"model_bio":model_bio}).execute())
            return "Model added"
        else:
            return "Model exist"
    
    def get_model(self, model_name: str):
        """ model_name, model_context, model_bio """ 
        cur = self.__con
        model_data = (cur.table("model").select("*").eq("model_name",model_name).execute()).data
        if len(model_data) != 0:
            model_data[0].pop('id')
            return tuple(model_data[0].values())
        else:
            return "Model not exist"

    def delete_model(self, model_name: str):        
        cur = self.__con
        resp = (cur.table("model").select("*").eq("model_name",model_name).execute()).data
        if len(resp) != 0:
            (cur.table("model").delete().eq("model_name",model_name).execute())
            (cur.table("user_model_chat").delete().eq("model_name",model_name).execute())
            (cur.table("user_info").delete().eq("model_name",model_name).execute())

            (cur.table("supervisor_model").delete().eq("model_name",model_name).execute())
            (cur.table("supervisor_user_model").delete().eq("model_name",model_name).execute())
            (cur.table("admin_model").delete().eq("model_name",model_name).execute())
            return "Model deleted"
        else:
            return "Model not exist"

    def update_model(self, model_name: str, new_model_name: str = None, model_context: str = None, model_bio: str = None):
        cur = self.__con
        model_data = (cur.table("model").select("*").eq("model_name",model_name).execute()).data
        if len(model_data) != 0:
            model_data = tuple(model_data[0].values())
            if new_model_name != '' and new_model_name != model_name:
                resp = (cur.table("model").select("*").eq("model_name",new_model_name).execute()).data
                if len(resp) != 0:
                    return "Model name exist"
            else:
                new_model_name = model_name

            model_context = model_data['model_context'] if model_context == '' else model_context
            model_bio = model_data['model_bio'] if model_bio == '' else model_bio

            (cur.table("model").update({"model_name":new_model_name,"model_context":model_context,"model_bio":model_bio}).eq("model_name",model_name).execute())

            (cur.table("user_model_chat").update({"model_name":new_model_name}).eq("model_name",model_name).execute())
            (cur.table("user_info").update({"model_name":new_model_name}).eq("model_name",model_name).execute())

            (cur.table("supervisor_model").update({"model_name":new_model_name}).eq("model_name",model_name).execute())
            (cur.table("supervisor_user_model").update({"model_name":new_model_name}).eq("model_name",model_name).execute())
            (cur.table("admin_model").update({"model_name":new_model_name}).eq("model_name",model_name).execute())
            return "Model updated"
        else:
            return "Model not exist"

    def add_supervisor(self, username: str, email: str, password: str, fname: str = None, lname: str = None, dateofbirth: str = None, gender: str = None, bio: str = None, profilepic: str = None, country: str = None, city: str = None):
        cur = self.__con
        resp = (cur.table("supervisor").select("*").eq("username",username).execute()).data
        if len(resp) == 0:
            resp = (cur.table("supervisor").select("*").eq("email",email).execute()).data
            if len(resp) == 0:
                (cur.table("supervisor").insert({
                    "username":username,"email":email,"password":password,"fname":fname,"lname":lname,"dateofbirth":dateofbirth,"gender":gender,"bio":bio,"profilepic":profilepic,"country":country,"city":city
                    }).execute()
                )
                return "Supervisor added"
            else:
                return "Supervisor email exist"
        else:
            return "Supervisor username exist"

    def get_supervisor(self, username: str):
        """ username, email, password, fname, lname, dateofbirth, gender, bio, profilepic, country, city """
        cur = self.__con
        resp = (cur.table("supervisor").select("*").eq("username",username).execute()).data
        if len(resp) != 0:
            return tuple(resp[0].values())
        else:
            return "Supervisor not exist"

    def delete_supervisor(self, username: str):
        cur = self.__con
        resp = (cur.table("supervisor").select("*").eq("username",username).execute()).data
        if len(resp) != 0:
            supervisor_users = self.supervisor_get_users(username)
            supervisor_models = self.supervisor_get_models(username)

            (cur.table("supervisor").delete().eq("username",username).execute())
            
            (cur.table("supervisor_user").delete().eq("supervisor_username",username).execute())
            (cur.table("supervisor_model").delete().eq("supervisor_username",username).execute())
            (cur.table("supervisor_user_model").delete().eq("supervisor_username",username).execute())


            (cur.table("user_thread_member").delete().eq("supervisor_username",username).execute())
            (cur.table("user_thread_member").delete().eq("member_username",username).execute())
            (cur.table("user_thread_chat").delete().eq("supervisor_username",username).execute())
            (cur.table("user_thread_chat").delete().eq("member_username",username).execute())
                    
            (cur.table("supervisor_session").delete().eq("username",username).execute())

            (cur.table("supervisor_supervisor").delete().eq("supervisor1_username",username).execute())
            (cur.table("supervisor_supervisor").delete().eq("supervisor2_username",username).execute())
            (cur.table("supervisor_supervisor_chat").delete().eq("supervisor1_username",username).execute())
            (cur.table("supervisor_supervisor_chat").delete().eq("supervisor2_username",username).execute())
            (cur.table("supervisor_supervisor_chat").delete().eq("member_username",username).execute())

            for user in supervisor_users:
                self.delete_user(user[1])
            for model in supervisor_models:
                self.delete_model(model[1])

            return "Supervisor deleted"
        else:
            return "Supervisor not exist"
    
    def update_supervisor(self, username: str, new_username: str = None, email: str = None, password: str = None, fname: str = None, lname: str = None, dateofbirth: str = None, gender: str = None, bio: str = None, profilepic: str = None, country: str = None, city: str = None):
        cur = self.__con
        user_data = (cur.table("supervisor").select("*").eq("username",username).execute()).data
        if len(user_data) != 0:
            user_data = tuple(user_data[0].values())
            if new_username != '' and new_username != username:
                resp = (cur.table("supervisor").select("*").eq("username",new_username).execute()).data
                if len(resp) != 0:
                    return "Supervisor username exist"
            else:
                new_username = username
            if email != '':
                resp = (cur.table("supervisor").select("*").eq("email",email).execute()).data
                if len(resp) != 0:
                    return "Supervisor email exist"
            email = user_data[1] if email == '' else email
            password = user_data[2] if password == '' else password
            fname = user_data[3] if fname == '' else fname
            lname = user_data[4] if lname == '' else lname
            dateofbirth = user_data[5] if dateofbirth == '' else dateofbirth
            gender = user_data[6] if gender == '' else gender
            bio = user_data[7] if bio == '' else bio
            profilepic = user_data[8] if profilepic == '' else profilepic
            country = user_data[9] if country == '' else country
            city = user_data[10] if city == '' else city

            (cur.table("supervisor").update({
                    "username":new_username,"email":email,"password":password,"fname":fname,"lname":lname,"dateofbirth":dateofbirth,"gender":gender,"bio":bio,"profilepic":profilepic,"country":country,"city":city
                    }).eq("username",username).execute())

            (cur.table("supervisor_user").update({"supervisor_username":new_username}).eq("supervisor_username",username).execute())
            (cur.table("supervisor_model").update({"supervisor_username":new_username}).eq("supervisor_username",username).execute())
            (cur.table("supervisor_user_model").update({"supervisor_username":new_username}).eq("supervisor_username",username).execute())
            (cur.table("user_thread_member").update({"supervisor_username":new_username}).eq("supervisor_username",username).execute())
            (cur.table("user_thread_member").update({"member_username":new_username}).eq("member_username",username).execute())
            (cur.table("user_thread_chat").update({"supervisor_username":new_username}).eq("supervisor_username",username).execute())
            (cur.table("user_thread_chat").update({"member_username":new_username}).eq("member_username",username).execute())
            (cur.table("supervisor_session").update({"username":new_username}).eq("username",username).execute())

            (cur.table("supervisor_supervisor").update({"supervisor1_username":new_username}).eq("supervisor1_username",username).execute())
            (cur.table("supervisor_supervisor").update({"supervisor2_username":new_username}).eq("supervisor2_username",username).execute())
            (cur.table("supervisor_supervisor_chat").update({"supervisor1_username":new_username}).eq("supervisor1_username",username).execute())
            (cur.table("supervisor_supervisor_chat").update({"supervisor2_username":new_username}).eq("supervisor2_username",username).execute())
            (cur.table("supervisor_supervisor_chat").update({"member_username":new_username}).eq("member_username",username).execute())
            
            return "Supervisor updated"
        else:
            return "Supervisor not exist"
    
    def supervisor_add_user(self, supervisor_username: str, user_username: str, email: str, password: str, fname: str = None, lname: str = None, dateofbirth: str = None, gender: str = None, bio: str = None, profilepic: str = None, country: str = None, city: str = None):      
        cur = self.__con
        resp = (cur.table("supervisor_user").select("*").eq("supervisor_username",supervisor_username).eq("user_username",user_username).execute()).data
        if len(resp) != 0:
            return "Supervisor User exist"
        resp = self.add_user(user_username,email,password,fname,lname,dateofbirth,gender,bio,profilepic,country,city)
        if resp == "User added":
            (cur.table("supervisor_user").insert({"supervisor_username":supervisor_username,"user_username":user_username}).execute())
            (cur.table("user_thread_member").insert({"supervisor_username":supervisor_username,"user_username":user_username,"member_username":supervisor_username}).execute())
            return "Supervisor User added"
        else:
            return resp

    def supervisor_delete_user(self, supervisor_username: str, user_username:str):
        cur = self.__con
        resp = (cur.table("supervisor_user").select("*").eq("supervisor_username",supervisor_username).eq("user_username",user_username).execute()).data
        if len(resp) != 0:
            self.delete_user(user_username)
            return "Supervisor User deleted"
        else:
            return "Supervisor User not exist"

    def supervisor_get_user(self, supervisor_username: str, user_username: str):
        """ username, email, password, fname, lname, dateofbirth, gender, bio, profilepic, country, city """
        cur = self.__con
        resp = (cur.table("supervisor_user").select("*").eq("supervisor_username",supervisor_username).eq("user_username",user_username).execute()).data
        if len(resp) != 0:
            return self.get_user(user_username)
        else:
            return "Supervisor User not exist"

    def supervisor_get_users(self, supervisor_username: str):
        """ [supervisor_username, user_username] """
        cur = self.__con
        resp = (cur.table("supervisor_user").select("*").eq("supervisor_username",supervisor_username).execute()).data
        supervisor_users = []
        for user in resp:
            supervisor_users.append(tuple(user.values()))
        return supervisor_users

    def supervisor_add_model(self, supervisor_username: str, model_name: str, model_context: str = None, model_bio: str = None):
        cur = self.__con
        resp = (cur.table("supervisor_model").select("*").eq("supervisor_username",supervisor_username).eq("model_name",model_name).execute()).data
        if len(resp) != 0:
            return "Supervisor Model exist"
        resp = self.add_model(model_name,model_context,model_bio)
        if resp == "Model added":
            (cur.table("supervisor_model").insert({"supervisor_username":supervisor_username,"model_name":model_name}).execute())
            return "Supervisor Model added"
        else:
            return resp
        
    def supervisor_update_model(self, supervisor_username: str, model_name: str, new_model_name: str = None, model_context: str = None, model_bio: str = None):
        cur = self.__con
        resp = (cur.table("supervisor_model").select("*").eq("supervisor_username",supervisor_username).eq("model_name",model_name).execute()).data
        if len(resp) != 0:
            return self.update_model(model_name,new_model_name,model_context,model_bio)
        else:
            return "Supervisor Model not exist"
        
    def supervisor_delete_model(self, supervisor_username: str, model_name: str):
        cur = self.__con
        resp = (cur.table("supervisor_model").select("*").eq("supervisor_username",supervisor_username).eq("model_name",model_name).execute()).data
        if len(resp) != 0:
            return self.delete_model(model_name)
        else:
            return "Supervisor Model not exist"
    
    def supervisor_get_model(self, supervisor_username: str, model_name: str):
        """ model_name, model_context, model_bio """
        cur = self.__con
        resp = (cur.table("supervisor_model").select("*").eq("supervisor_username",supervisor_username).eq("model_name",model_name).execute()).data
        if len(resp) != 0:
            return self.get_model(model_name)
        else:
            return "Supervisor Model not exist"

    def supervisor_get_models(self, supervisor_username: str):
        """ [supervisor_username, model_name] """
        cur = self.__con
        resp = (cur.table("supervisor_model").select("*").eq("supervisor_username",supervisor_username).execute()).data
        supervisor_models = []
        for model in resp:
            supervisor_models.append(tuple(model.values()))
        return supervisor_models
    
    def supervisor_assign_model(self, supervisor_username: str, user_username: str, model_name: str):
        cur = self.__con
        resp = (cur.table("supervisor_user").select("*").eq("supervisor_username",supervisor_username).eq("user_username",user_username).execute()).data
        if len(resp) != 0:
            resp = (cur.table("supervisor_model").select("*").eq("supervisor_username",supervisor_username).eq("model_name",model_name).execute()).data
            if len(resp) != 0:
                resp = (cur.table("supervisor_user_model").select("*").eq("supervisor_username",supervisor_username).eq("user_username",user_username).eq("model_name",model_name).execute()).data
                if len(resp) == 0:
                    (cur.table("supervisor_user_model").insert({"supervisor_username":supervisor_username,"user_username":user_username,"model_name":model_name}).execute())
                    return "Supervisor User Model added"
                else:
                    return "Supervisor User Model exist"
            else:
                return "Supervisor Model not exist"
        else:
            return "Supervisor User not exist"
        
    def supervisor_delete_assign(self, supervisor_username: str, user_username: str, model_name: str):
        cur = self.__con
        resp = (cur.table("supervisor_user").select("*").eq("supervisor_username",supervisor_username).eq("user_username",user_username).execute()).data
        if len(resp) != 0:
            resp = (cur.table("supervisor_model").select("*").eq("supervisor_username",supervisor_username).eq("model_name",model_name).execute()).data
            if len(resp) != 0:
                resp = (cur.table("supervisor_user_model").select("*").eq("supervisor_username",supervisor_username).eq("user_username",user_username).eq("model_name",model_name).execute()).data
                if len(resp) != 0:
                    (cur.table("supervisor_user_model").delete().eq("supervisor_username",supervisor_username).eq("user_username",user_username).eq("model_name",model_name).execute())
                    (cur.table("user_model_chat").delete().eq("username",user_username).eq("model_name",model_name).execute())
                    (cur.table("user_info").delete().eq("username",user_username).eq("model_name",model_name).execute())
                    return "Supervisor User Model deleted"
                else:
                    return "Supervisor User Model not exist"
            else:
                return "Supervisor Model not exist"
        else:
            return "Supervisor User not exist"
        
    def supervisor_add_thread_member(self, supervisor_username: str, user_username: str, member_username: str):
        cur = self.__con
        resp = (cur.table("user_thread_member").select("*").eq("supervisor_username",supervisor_username).eq("user_username",user_username).eq("member_username",member_username).execute()).data
        if len(resp) == 0:
            resp = (cur.table("supervisor").select("*").eq("username",supervisor_username).execute()).data
            if len(resp) != 0:
                resp = (cur.table("user").select("*").eq("username",user_username).execute()).data
                if len(resp) != 0:
                    resp = (cur.table("supervisor_user").select("*").eq("supervisor_username",supervisor_username).eq("user_username",user_username).execute()).data
                    if len(resp) != 0:
                        resp = (cur.table("supervisor").select("*").eq("username",member_username).execute()).data
                        if len(resp) != 0:
                            (cur.table("user_thread_member").insert({"supervisor_username":supervisor_username,"user_username":user_username,"member_username":member_username}).execute())
                            return "Supervisor User Member added"
                        else:
                            return "Supervisor not exist"
                    else:
                        return "Supervisor User not exist"
                else:
                    return "User not exist"
            else:
                return "Supervisor not exist"
        else:
            return "Supervisor User Member exist"

    def supervisor_delete_thread_member(self, supervisor_username: str, user_username: str, member_username: str):
        cur = self.__con
        resp = (cur.table("user_thread_member").select("*").eq("supervisor_username",supervisor_username).eq("user_username",user_username).eq("member_username",member_username).execute()).data
        if len(resp) != 0:
            if supervisor_username == member_username:
                (cur.table("user_thread_member").delete().eq("supervisor_username",supervisor_username).eq("user_username",user_username).execute())
                (cur.table("user_thread_chat").delete().eq("supervisor_username",supervisor_username).eq("user_username",user_username).execute())
            else:
                (cur.table("user_thread_member").delete().eq("supervisor_username",supervisor_username).eq("user_username",user_username).eq("member_username",member_username).execute())
                (cur.table("user_thread_chat").delete().eq("supervisor_username",supervisor_username).eq("user_username",user_username).eq("member_username",member_username).execute())
            return "Supervisor User Member deleted"
        else:
            return "Supervisor User Member not exist"
        
    def supervisor_get_thread_members(self, supervisor_username: str, user_username: str):
        """ [ username, email, password, fname, lname, dateofbirth, gender, bio, profilepic, country, city ]"""
        cur = self.__con
        temp_thread_members = (cur.table("user_thread_member").select("*").eq("supervisor_username",supervisor_username).eq("user_username",user_username).execute()).data
        thread_members = []
        for member in temp_thread_members:
            thread_members.append(self.get_supervisor(tuple(member.values())[2]))
        return thread_members
        
    def supervisor_get_thread_chat(self, supervisor_username: str, user_username: str, member_username: str):
        """ [supervisor_username, user_username, member_username, msg_text, datetime] """
        cur = self.__con
        temp_thread_chat = (cur.table("user_thread_chat").select("*").eq("supervisor_username",supervisor_username).eq("user_username",user_username).order('datetime').execute()).data
        if len(temp_thread_chat) != 0:
            temp_thread_member_check = (cur.table("user_thread_member").select("*").eq("supervisor_username",supervisor_username).eq("user_username",user_username).eq("member_username",member_username).execute()).data
            if len(temp_thread_member_check) == 0:
                return "Thread Chat Member not exist"
            thread_chat = []
            for msg in temp_thread_chat:
                thread_chat.append(tuple(msg.values()))
            return thread_chat
        else:
            return "Supervisor User Member not exist"

    def supervisor_get_thread_chats(self, supervisor_username: str):
        cur = self.__con
        supervisor_chats = (cur.table("user_thread_member").select("*").eq("member_username",supervisor_username).execute()).data
        thread_chats = []
        for chat in supervisor_chats:
            thread_chats.append(tuple([chat['supervisor_username'],chat['user_username'],supervisor_username]))
        return thread_chats
    
    def supervisor_send_thread_chat(self, supervisor_username: str, user_username: str, member_username: str, msg_text: str):
        cur = self.__con
        resp = (cur.table("user_thread_member").select("*").eq("supervisor_username",supervisor_username).eq("user_username",user_username).eq("member_username",member_username).execute()).data
        if len(resp) != 0:
            (cur.table("user_thread_chat").insert({"supervisor_username":supervisor_username,"user_username":user_username,"member_username":member_username,"msg_text":msg_text}).execute())
            return "Supervisor User Member chat sent"
        else:
            return "Supervisor User Member not exist"
    
    def user_get_model(self, username: str, model_name: str):
        """ model_name, model_bio """
        cur = self.__con
        resp = (cur.table("user").select("*").eq("username",username).execute()).data
        if len(resp) == 0:
            return "User Not exist"
        return self.get_model(model_name)

    def user_get_models(self, username: str):
        """ [model_name, model_context, model_bio] """
        cur = self.__con
        resp = (cur.table("user").select("*").eq("username",username).execute()).data
        if len(resp) == 0:
            return "User Not exist"
        temp_admin_models = (cur.table("admin_model").select("model_name").execute()).data
        temp_supervisor_models = (cur.table("supervisor_user_model").select("model_name").eq("user_username",username).execute()).data
        user_models = []
        for model in temp_admin_models:
            user_models.append(self.get_model(model["model_name"]))
        for model in temp_supervisor_models:
            user_models.append(self.get_model(model["model_name"]))
        return user_models

    def user_get_chat(self, username: str, model_name: str):
        """ [username, model_name, msg_role, msg_text, datetime] """
        cur = self.__con
        resp = (cur.table("user").select("*").eq("username",username).execute()).data
        if len(resp) != 0:
            resp = (cur.table("model").select("*").eq("model_name",model_name).execute()).data
            if len(resp) != 0:
                temp_user_chat = (cur.table("user_model_chat").select("*").eq("username",username).eq("model_name",model_name).order('datetime').execute()).data
                if len(temp_user_chat) != 0:
                    user_chat = []
                    for msg in temp_user_chat:
                        msg.pop('id')
                        user_chat.append(tuple(msg.values()))
                    if len(user_chat) != 0:
                        user_chat.sort(key=lambda a: a[4])
                    return user_chat
                else:
                    return "User Model Chat not exist"
            else:
                return "Model not exist"
        else:
            return "User not exist"

    def user_get_chats(self, username: str):
        """ [[username, model_name, msg_role, msg_text, datetime]] """
        user_models = self.user_get_models(username)
        user_chats = []
        for model in user_models:
            user_model_chat = self.user_get_chat(username,model[0])
            if len(user_model_chat) != 0 and user_model_chat != "User Model Chat not exist" and  user_model_chat != "Model not exist" and user_model_chat != "User not exist":
                user_chats.append(user_model_chat[-1])
            if len(user_chats) != 0:
                user_chats.sort(key=lambda a: a[4])
        return user_chats

    def ini_user_model_chat(self, username: str, model_name: str):
        cur = self.__con
        resp = (cur.table("user").select("*").eq("username",username).execute()).data
        if len(resp) != 0:
            resp = (cur.table("model").select("*").eq("model_name",model_name).execute()).data
            if len(resp) != 0:
                resp = (cur.table("user_info").select("*").eq("username",username).eq("model_name",model_name).execute()).data
                if len(resp) == 0:
                    (cur.table("user_info").insert({"username":username,"model_name":model_name,"user_info":base_temp}).execute())
                    user_info = self.get_user_info(username, model_name)
                    user_reg_info = self.get_user(username)
                    user_info['first_name'] = user_reg_info[3]
                    user_info['last_name'] = user_reg_info[4]
                    user_info['gender'] = user_reg_info[6]
                    self.update_user_info(username,model_name,json.dumps(user_info, ensure_ascii=False))
                    return "User Model chat initiated"
                else:
                    user_info = self.get_user_info(username, model_name)
                    user_reg_info = self.get_user(username)
                    user_info['first_name'] = user_reg_info[3]
                    user_info['last_name'] = user_reg_info[4]
                    user_info['gender'] = user_reg_info[6]
                    self.update_user_info(username,model_name,json.dumps(user_info, ensure_ascii=False))
                    return "User Model chat exist"
            else:
                return "Model not exist"
        else:
            return "User not exist"

    def user_send_chat(self, username: str, model_name: str, msg_text: str):
        cur = self.__con
        resp = (cur.table("user").select("*").eq("username",username).execute()).data
        if len(resp) != 0:
            resp = (cur.table("model").select("*").eq("model_name",model_name).execute()).data
            if len(resp) != 0:
                (cur.table("user_model_chat").insert({"username":username,"model_name":model_name,"msg_role":"user","msg_text":msg_text}).execute())
                return "User Model Chat sent"
            else:
                return "Model not exist"
        else:
            return "User not exist"
        
    def model_send_chat(self, username: str, model_name: str, msg_text: str):
        cur = self.__con
        resp = (cur.table("user").select("*").eq("username",username).execute()).data
        if len(resp) != 0:
            resp = (cur.table("model").select("*").eq("model_name",model_name).execute()).data
            if len(resp) != 0:
                (cur.table("user_model_chat").insert({"username":username,"model_name":model_name,"msg_role":"model","msg_text":msg_text}).execute())
                return "User Model Chat sent"
            else:
                return "Model not exist"
        else:
            return "User not exist"

    def user_delete_chat(self, username: str, model_name: str):
        cur = self.__con
        resp = (cur.table("user").select("*").eq("username",username).execute()).data
        if len(resp) != 0:
            resp = (cur.table("model").select("*").eq("model_name",model_name).execute()).data
            if len(resp) != 0:
                resp = (cur.table("user_info").select("*").eq("username",username).eq("model_name",model_name).execute()).data
                if len(resp) != 0:
                    (cur.table("user_model_chat").delete().eq("username",username).eq("model_name",model_name).execute())
                    (cur.table("user_info").delete().eq("username",username).eq("model_name",model_name).execute())
                    return "User Model Chat deleted"
                else:
                    return "User Model Chat not exist"
            else:
                return "Model not exist"
        else:
            return "User not exist"

    def get_user_info(self, username: str, model_name: str):
        """ user_info as json """
        cur = self.__con
        resp = (cur.table("user").select("*").eq("username",username).execute()).data
        if len(resp) != 0:
            resp = (cur.table("model").select("*").eq("model_name",model_name).execute()).data
            if len(resp) != 0:
                resp = (cur.table("user_info").select("*").eq("username",username).eq("model_name",model_name).execute()).data
                if len(resp) == 0:
                    return "User Model Chat not exist"
                else:
                    return json.loads(tuple(resp[0].values())[2])
            else:
                return "Model not exist"
        else:
            return "User not exist"
        
    def update_user_info(self, username: str, model_name: str, user_info: str):
        cur = self.__con
        resp = (cur.table("user").select("*").eq("username",username).execute()).data
        if len(resp) != 0:
            resp = (cur.table("model").select("*").eq("model_name",model_name).execute()).data
            if len(resp) != 0:
                resp = (cur.table("user_info").select("*").eq("username",username).eq("model_name",model_name).execute()).data
                if len(resp) == 0:
                    return "User Model Chat not exist"
                else:
                    (cur.table("user_info").update({"user_info":user_info}).eq("username",username).eq("model_name",model_name).execute())
                    return "User Model UserInfo updated"
            else:
                return "Model not exist"
        else:
            return "User not exist"
        
    def get_chat_history(self, username: str, model_name: str):
        cur = self.__con
        resp = (cur.table("user").select("*").eq("username",username).execute()).data
        if len(resp) != 0:
            resp = (cur.table("model").select("*").eq("model_name",model_name).execute()).data
            if len(resp) != 0:
                resp = (cur.table("user_info").select("*").eq("username",username).eq("model_name",model_name).execute()).data
                if len(resp) == 0:
                    return "User Model Chat not exist"
                else:
                    temp_chat_history = (cur.table("user_model_chat").select("msg_role","msg_text").eq("username",username).eq("model_name",model_name).order('datetime').execute()).data
                    chat_history = []
                    for msg in temp_chat_history:
                        msg = tuple(msg.values())
                        chat_history.append({'role': msg[0], 'parts': [msg[1]]})
                    return chat_history
            else:
                return "Model not exist"
        else:
            return "User not exist"
        
    def get_user_username(self, email: str):
        """ email """
        cur = self.__con
        resp = (cur.table("user").select("*").eq("email",email).execute()).data
        if len(resp) == 0:
            return "User Not exist"
        return (cur.table("user").select("username").eq("email",email).execute()).data[0]["username"]

    def get_admin_username(self, email: str):
        """ email """
        cur = self.__con
        resp = (cur.table("admin").select("*").eq("email",email).execute()).data
        if len(resp) == 0:
            return "Admin Not exist"
        return (cur.table("admin").select("username").eq("email",email).execute()).data[0]["username"]
    
    def get_supervisor_username(self, email: str):
        """ email """
        cur = self.__con
        resp = (cur.table("supervisor").select("*").eq("email",email).execute()).data
        if len(resp) == 0:
            return "Supervisor Not exist"
        return (cur.table("supervisor").select("username").eq("email",email).execute()).data[0]["username"]
    
    def ini_user_session(self, username: str, session_id: str):
        cur = self.__con
        resp = (cur.table("user").select("*").eq("username",username).execute()).data
        if len(resp) == 0:
            return "User Not exist"
        (cur.table("user_session").insert({"username":username,"session_id":session_id}).execute())
        return "User session success"
    
    def ini_admin_session(self, username: str, session_id: str):
        cur = self.__con
        resp = (cur.table("admin").select("*").eq("username",username).execute()).data
        if len(resp) == 0:
            return "Admin Not exist"
        (cur.table("admin_session").insert({"username":username,"session_id":session_id}).execute())
        return "Admin session success"
    
    def ini_supervisor_session(self, username: str, session_id: str):
        cur = self.__con
        resp = (cur.table("supervisor").select("*").eq("username",username).execute()).data
        if len(resp) == 0:
            return "Supervisor Not exist"
        (cur.table("supervisor_session").insert({"username":username,"session_id":session_id}).execute())
        return "Supervisor session success"
    
    def gen_session_id(self):
        session_id = []
        for i in range(0,128):
            session_id.append(self.__session_id_chars[rnd.randint(0,len(self.__session_id_chars)-1)])
        return "".join(session_id)

    def check_user_session(self, username: str, session_id: str):
        cur = self.__con
        resp = (cur.table("user").select("*").eq("username",username).execute()).data
        if len(resp) == 0:
            return "User Not exist"
        resp = (cur.table("user_session").select("*").eq("username",username).eq("session_id",session_id).execute()).data
        if len(resp) != 0:
            return "User Session exist"
        else:
            return "User Session not exist"
        
    def check_admin_session(self, username: str, session_id: str):
        cur = self.__con
        resp = (cur.table("admin").select("*").eq("username",username).execute()).data
        if len(resp) == 0:
            return "Admin Not exist"
        resp = (cur.table("admin_session").select("*").eq("username",username).eq("session_id",session_id).execute()).data
        if len(resp) != 0:
            return "Admin Session exist"
        else:
            return "Admin Session not exist"
        
    def check_supervisor_session(self, username: str, session_id: str):
        cur = self.__con
        resp = (cur.table("supervisor").select("*").eq("username",username).execute()).data
        if len(resp) == 0:
            return "Supervisor Not exist"
        resp = (cur.table("supervisor_session").select("*").eq("username",username).eq("session_id",session_id).execute()).data
        if len(resp) != 0:
            return "Supervisor Session exist"
        else:
            return "Supervisor Session not exist"
        
    def user_change_password(self, username: str, password: str):
        cur = self.__con
        resp = (cur.table("user").select("*").eq("username",username).execute()).data
        if len(resp) != 0:
            (cur.table("user").update({"password":password}).eq("username",username).execute())
            return "User password reset success"
        else:
            return "User not exist"

    def admin_change_password(self, username: str, password: str):
        cur = self.__con
        resp = (cur.table("admin").select("*").eq("username",username).execute()).data
        if len(resp) != 0:
            (cur.table("admin").update({"password":password}).eq("username",username).execute())
            return "Admin password reset success"
        else:
            return "Admin not exist"
        
    def supervisor_change_password(self, username: str, password: str):
        cur = self.__con
        resp = (cur.table("supervisor").select("*").eq("username",username).execute()).data
        if len(resp) != 0:
            (cur.table("supervisor").update({"password":password}).eq("username",username).execute())
            return "Supervisor password reset success"
        else:
            return "Supervisor not exist"

    def user_logout(self, username: str, session_id: str):
        cur = self.__con
        resp = (cur.table("user").select("*").eq("username",username).execute()).data
        if len(resp) == 0:
            return "User Not exist"
        resp = (cur.table("user_session").select("*").eq("username",username).eq("session_id",session_id).execute()).data
        if len(resp) == 0 :
            return "User Session not exist"
        (cur.table("user_session").delete().eq("username",username).eq("session_id",session_id).execute())
        return "User Session logout"
    
    def admin_logout(self, username: str, session_id: str):
        cur = self.__con
        resp = (cur.table("admin").select("*").eq("username",username).execute()).data
        if len(resp) == 0:
            return "Admin Not exist"
        resp = (cur.table("admin_session").select("*").eq("username",username).eq("session_id",session_id).execute()).data
        if len(resp) == 0 :
            return "Admin Session not exist"
        (cur.table("admin_session").delete().eq("username",username).eq("session_id",session_id).execute())
        return "Admin Session logout"
    
    def supervisor_logout(self, username: str, session_id: str):
        cur = self.__con
        resp = (cur.table("supervisor").select("*").eq("username",username).execute()).data
        if len(resp) == 0:
            return "Supervisor Not exist"
        resp = (cur.table("supervisor_session").select("*").eq("username",username).eq("session_id",session_id).execute()).data
        if len(resp) == 0 :
            return "Supervisor Session not exist"
        (cur.table("supervisor_session").delete().eq("username",username).eq("session_id",session_id).execute())
        return "Supervisor Session logout"
    
    def ini_chat_supervisors(self, supervisor1_username: str, supervisor2_username: str):
        cur = self.__con
        resp = (cur.table("supervisor").select("*").eq("username",supervisor1_username).execute()).data
        if len(resp) != 0:
            resp = (cur.table("supervisor").select("*").eq("username",supervisor2_username).execute()).data
            if len(resp) != 0:
                resp1 = (cur.table("supervisor_supervisor").select("*").eq("supervisor1_username",supervisor1_username).eq("supervisor2_username",supervisor2_username).execute()).data
                resp2 = (cur.table("supervisor_supervisor").select("*").eq("supervisor1_username",supervisor2_username).eq("supervisor2_username",supervisor1_username).execute()).data
                if len(resp1) == 0 and len(resp2) == 0:
                    (cur.table("supervisor_supervisor").insert({"supervisor1_username":supervisor1_username,"supervisor2_username":supervisor2_username}).execute())
                    return "Supervisor Chat initiated"
                else:
                    return "Supervisor Chat exist"
            else:
                return "Supervisor2 not exist"
        else:
            return "Supervisor1 not exist"

    def supervisor_send_chat(self, supervisor1_username: str, supervisor2_username: str, member_username: str, msg_text: str):
        cur = self.__con
        resp = self.ini_chat_supervisors(supervisor1_username,supervisor2_username)
        if resp == "Supervisor1 not exist" or resp == "Supervisor2 not exist":
            return resp
        (cur.table("supervisor_supervisor_chat").insert({"supervisor1_username":supervisor1_username,"supervisor2_username":supervisor2_username,"member_username":member_username,"msg_text":msg_text}).execute())
        return "Supervisor Chat send"

    def supervisor_get_chat(self, supervisor1_username: str, supervisor2_username):
        cur = self.__con
        resp1 = (cur.table("supervisor_supervisor").select("*").eq("supervisor1_username",supervisor1_username).eq("supervisor2_username",supervisor2_username).execute()).data
        resp2 = (cur.table("supervisor_supervisor").select("*").eq("supervisor1_username",supervisor2_username).eq("supervisor2_username",supervisor1_username).execute()).data
        if len(resp1) != 0 or len(resp2) != 0:
            resp1 = (cur.table("supervisor_supervisor_chat").select("*").eq("supervisor1_username",supervisor1_username).eq("supervisor2_username",supervisor2_username).order('datetime').execute()).data
            resp2 = (cur.table("supervisor_supervisor_chat").select("*").eq("supervisor1_username",supervisor2_username).eq("supervisor2_username",supervisor1_username).order('datetime').execute()).data
            chat = []
            for msg in resp1:
                msg.pop('id')
                chat.append(tuple(msg.values()))
            for msg in resp2:
                msg.pop('id')
                chat.append(tuple(msg.values()))
            if len(chat) != 0:
                chat.sort(key=lambda a: a[4])
            if len(chat) != 0:
                return chat
            else:
                return "Supervisor Chat not exist"
        else:
            return "Supervisor Chat not exist"

    def supervisor_get_chats(self, supervisor_username: str):
        cur = self.__con
        resp1 = (cur.table("supervisor_supervisor").select("*").eq("supervisor1_username",supervisor_username).execute()).data
        resp2 = (cur.table("supervisor_supervisor").select("*").eq("supervisor2_username",supervisor_username).execute()).data
        user_chats = []
        for chat in resp1:
            user_chat = self.supervisor_get_chat(chat["supervisor1_username"],chat["supervisor2_username"])
            if len(user_chat) != 0 and user_chat != "Supervisor Chat not exist":
                user_chats.append(user_chat[-1])
        for chat in resp2:
            user_chat = self.supervisor_get_chat(chat["supervisor1_username"],chat["supervisor2_username"])
            if len(user_chat) != 0 and user_chat != "Supervisor Chat not exist":
                user_chats.append(user_chat[-1])
        if len(user_chats) != 0:
            user_chats.sort(key=lambda a: a[4])
        return user_chats

    def supervisor_delete_chat(self, supervisor1_username: str, supervisor2_username):
        cur = self.__con
        resp1 = (cur.table("supervisor_supervisor").select("*").eq("supervisor1_username",supervisor1_username).eq("supervisor2_username",supervisor2_username).execute()).data
        resp2 = (cur.table("supervisor_supervisor").select("*").eq("supervisor1_username",supervisor2_username).eq("supervisor2_username",supervisor1_username).execute()).data
        if len(resp1) != 0 or len(resp2) != 0:
            (cur.table("supervisor_supervisor").delete().eq("supervisor1_username",supervisor1_username).eq("supervisor2_username",supervisor2_username).execute())
            (cur.table("supervisor_supervisor").delete().eq("supervisor1_username",supervisor2_username).eq("supervisor2_username",supervisor1_username).execute())
            (cur.table("supervisor_supervisor_chat").delete().eq("supervisor1_username",supervisor1_username).eq("supervisor2_username",supervisor2_username).execute())
            (cur.table("supervisor_supervisor_chat").delete().eq("supervisor1_username",supervisor2_username).eq("supervisor2_username",supervisor1_username).execute())
            return "Supervisor Chat deleted"
        else:
            return "Supervisor Chat not exist"

    # new
    def supervisor_get_near_user_activity(self, supervisor_username):
        cur = self.__con
        users_models = (cur.table('supervisor_user_model')
                      .select('user_username','model_name').eq('supervisor_username',supervisor_username)
                      .execute()).data
        
        ret_lst = []
        for user_model in users_models:
            user_model_tuple = tuple(user_model.values())
            last_msg = (cur.table('user_model_chat')
                        .select('username, model_name, datetime.max()')
                        .eq('username',user_model_tuple[0])
                        .eq('model_name',user_model_tuple[1])
                        .execute()).data
            if len(last_msg) != 0:
                ret_lst.append(tuple(last_msg[0].values()))
        if len(ret_lst) != 0:
            ret_lst.sort(key=lambda a: a[2], reverse = True)
        ret = []
        for i in range(0, min(5,len(ret_lst))):
            ret.append(ret_lst[i])
        return ret
    
    def supervisor_get_far_user_activity(self, supervisor_username):
        cur = self.__con
        users_models = (cur.table('supervisor_user_model')
                      .select('user_username','model_name').eq('supervisor_username',supervisor_username)
                      .execute()).data
        
        ret_lst = []
        for user_model in users_models:
            user_model_tuple = tuple(user_model.values())
            last_msg = (cur.table('user_model_chat')
                        .select('username, model_name, datetime.max()')
                        .eq('username',user_model_tuple[0])
                        .eq('model_name',user_model_tuple[1])
                        .execute()).data
            if len(last_msg) != 0:
                ret_lst.append(tuple(last_msg[0].values()))
        if len(ret_lst) != 0:
            ret_lst.sort(key=lambda a: a[2])
        ret = []
        for i in range(0, min(5,len(ret_lst))):
            ret.append(ret_lst[i])
        return ret
    
    def supervisor_get_most_model(self, supervisor_username):
        cur = self.__con
        models = (cur.table('supervisor_model')
                      .select('model_name').eq('supervisor_username',supervisor_username)
                      .execute()).data
        
        ret_lst = []
        for model in models:
            model_tuple = tuple(model.values())
            cnt = (cur.table('user_model_chat')
                    .select('model_name, msg_text.count()')
                    .eq('model_name',model_tuple[0])
                    .eq('msg_role','model')
                    .execute()).data
            if len(cnt) != 0:
                ret_lst.append(tuple(cnt[0].values()))
        if len(ret_lst) != 0:
            ret_lst.sort(key=lambda a: a[1], reverse = True)
        ret = []
        for i in range(0, min(5,len(ret_lst))):
            ret.append(ret_lst[i])
        return ret
    
    def supervisor_get_count_user(self, supervisor_username):
        return len(self.supervisor_get_users(supervisor_username))
    
    def supervisor_get_count_model(self, supervisor_username):
        return len(self.supervisor_get_models(supervisor_username))
    
    def admin_get_count_user(self):
        return len(self.admin_get_users())

    def admin_get_count_supervisor(self):
        return len(self.admin_get_supervisors())

    def admin_get_count_model(self, admin_username):
        return len(self.admin_get_models(admin_username))
    
    def admin_get_most_model(self, admin_username):
        cur = self.__con
        models = (cur.table('admin_model')
                      .select('model_name').eq('admin_username',admin_username)
                      .execute()).data
        
        ret_lst = []
        for model in models:
            model_tuple = tuple(model.values())
            cnt = (cur.table('user_model_chat')
                    .select('model_name, msg_text.count()')
                    .eq('model_name',model_tuple[0])
                    .eq('msg_role','model')
                    .execute()).data
            if len(cnt) != 0:
                ret_lst.append(tuple(cnt[0].values()))
        if len(ret_lst) != 0:
            ret_lst.sort(key=lambda a: a[1], reverse = True)
        ret = []
        for i in range(0, min(5,len(ret_lst))):
            ret.append(ret_lst[i])
        return ret

    def admin_get_users(self):
        cur = self.__con
        users = (cur.table('user')
                 .select('username','email','fname','lname','gender','bio','profilepic')
                 .execute()).data
        ret = []
        for user in users:
            ret.append(tuple(user.values()))
        return ret

    def admin_get_supervisors(self):
        cur = self.__con
        supervisors = (cur.table('supervisor')
                 .select('username','email','fname','lname','gender','bio','profilepic')
                 .execute()).data
        ret = []
        for supervisor in supervisors:
            ret.append(tuple(supervisor.values()))
        return ret
    
    def admin_delete_user(self, user_username):
        return self.delete_user(user_username)
    
    def admin_delete_supervisor(self, supervisor_username):
        return self.delete_supervisor(supervisor_username)
    
    def get_users(self):
        cur = self.__con
        users = (cur.table('user')
                 .select('username','email','password','fname','lname','gender','bio','profilepic','country','city')
                 .execute()).data
        supervisors = (cur.table('supervisor')
                 .select('username','email','password','fname','lname','gender','bio','profilepic','country','city')
                 .execute()).data
        admins = (cur.table('admin')
                 .select('username','email','password','fname','lname','gender','country','city')
                 .execute()).data
        return {
            'users':users,
            'supervisors':supervisors,
            'admins':admins
        }
    
    def get_user_id(self, email: str):
        cur = self.__con
        from_user = (cur.table('user').select('username').eq('email',email).execute()).data
        from_supervisor = (cur.table('supervisor').select('username').eq('email',email).execute()).data
        from_admin = (cur.table('admin').select('username').eq('email',email).execute()).data
        if len(from_user) != 0:
            return from_user[0]['username']
        elif len(from_supervisor) != 0:
            return from_supervisor[0]['username']
        elif len(from_admin) != 0:
            return from_admin[0]['username']
        else:
            return "Not Found"
        
    def get_user_role(self, email: str):
        cur = self.__con
        from_user = (cur.table('user').select('username').eq('email',email).execute()).data
        from_supervisor = (cur.table('supervisor').select('username').eq('email',email).execute()).data
        from_admin = (cur.table('admin').select('username').eq('email',email).execute()).data
        if len(from_user) != 0:
            return "User"
        elif len(from_supervisor) != 0:
            return "Supervisor"
        elif len(from_admin) != 0:
            return "Admin"
        else:
            return "Not Found"

db = DB()

print("Database Initiated")