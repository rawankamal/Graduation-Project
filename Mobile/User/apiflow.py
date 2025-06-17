import requests, json
reg_resp = requests.post('https://gradationproject.runasp.net/auths/register',
json={
    "firstName": "mhmd",
    "lastname": "bakr",
    "email": "mhmd12345@gmail.com",
    "username": "mhmd12345",
    "bio": "me",
    "ProfilePic": "pic",
    "Country": "egypt",
    "City": "cairo",
    "password": "Pass123@",
    "dateofbirth": "2001-01-01T01:01:01Z"
}, headers={'Content-Type': 'application/json'})
if reg_resp.status_code == 200:
    print("Account created")
    reg_resp = json.loads(reg_resp.content)
    conf_resp = requests.post('https://gradationproject.runasp.net/auths/confirm-email',
    json={
        "userId": reg_resp['userId'],
        "code": reg_resp['code']
    }, headers={'Content-Type': 'application/json'})
    if conf_resp.status_code == 200:
        print("Account confirmed")
        login_resp = requests.post('https://gradationproject.runasp.net/auths/login',
        json={
            "email": "mhmd1234@gmail.com",
            "password": "Pass123@"
        }, headers={'Content-Type': 'application/json'})
        if login_resp.status_code == 200:
            print("Login success")
        elif login_resp.status_code == 400:
            print("Missing field")
        elif login_resp.status_code == 401:
            print("Invalid user")
        else:
            print("Unknown error")
    elif conf_resp.status_code == 400:
        print("Missing field")
    elif conf_resp.status_code == 401:
        print("Invalid code")
    else:
        print("Unknown error")
elif reg_resp.status_code == 400:
    print("Missing field")
elif reg_resp.status_code == 409:
    print("Email or Username exist")
    reconf_resp = requests.post('https://gradationproject.runasp.net/auths/reconfirm-email',
    json={
        "email": "mhmd12345@gmail.com"
    }, headers={'Content-Type': 'application/json'})
    print(reconf_resp.content)
    if reconf_resp.status_code == 200:
        print("Account found")
        reconf_resp = json.loads(reconf_resp.content)
        conf_resp = requests.post('https://gradationproject.runasp.net/auths/confirm-email',
        json={
            "userId": reconf_resp['userId'],
            "code": reconf_resp['code']
        }, headers={'Content-Type': 'application/json'})
        if conf_resp.status_code == 200:
            print("Account confirmed")
            login_resp = requests.post('https://gradationproject.runasp.net/auths/login',
            json={
                "email": "mhmd12345@gmail.com",
                "password": "Pass123@"
            }, headers={'Content-Type': 'application/json'})
            if login_resp.status_code == 200:
                print("Login success")
            elif login_resp.status_code == 400:
                print("Missing field")
            elif login_resp.status_code == 401:
                print("Invalid user")
            else:
                print("Unknown error")
        elif conf_resp.status_code == 400:
            print("Missing field")
        elif conf_resp.status_code == 401:
            print("Invalid code")
        else:
            print("Unknown error")
    elif reconf_resp.status_code == 400:
        print("Invalid email")
    elif reconf_resp.status_code == 409:
        print("Email verified")
    else:
        print("Unknown error")
else:
    print("Unknown error")