import requests
url = "https://gradationproject.runasp.net/auths/register"

data = {
    "firstname":"ms235s",
    "lastname":"d2352354Sw",
    "email":"m235sh@gmail.com",
    "username":"aj235sf2242",
    "password":"Wiie2134@",
    "gender":"Male",
    "bio":"me",
    "country":"Egypt",
    "city":"Cairo",
    "dateofbirth":"2003-03-01T01:01:01Z"
}
resp = requests.post(url=url,data=data)
print(resp)
print(resp.content)