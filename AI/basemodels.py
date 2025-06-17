import json
from pydantic import BaseModel, Field
from typing import List, Optional, Literal, Final

class user_base(BaseModel):
    username: str = Field(default='',description='User username')
    email: str = Field(default='',description='User email')
    password: str = Field(default='',description='User password')
    fname: str = Field(default='',description='User first name')
    lname: str = Field(default='',description='User last name')
    dateofbirth: str = Field(default='',description='User date of birth')
    gender: str = Field(default='',description='User gender')
    bio: str = Field(default='',description='User bio')
    profilepic: str = Field(default='',description='User profilepic')
    country: str = Field(default='',description='User country')
    city: str = Field(default='',description='User city')

class admin_base(BaseModel):
    username: str = Field(default='',description='Admin username')
    email: str = Field(default='',description='Admin email')
    password: str = Field(default='',description='Admin password')
    fname: str = Field(default='',description='Admin first name')
    lname: str = Field(default='',description='Admin last name')
    dateofbirth: str = Field(default='',description='Admin date of birth')
    gender: str = Field(default='',description='Admin gender')
    country: str = Field(default='',description='Admin country')
    city: str = Field(default='',description='Admin city')

class model_base(BaseModel):
    model_name: str = Field(default='',description='Model name')
    model_context: str = Field(default='',description='Model context')
    model_bio: str = Field(default='',description='Model bio')

class login_base(BaseModel):
    username: str = Field(default='',description='User username')
    email: str = Field(default='',description='User email')
    password: str = Field(default='',description='User password')

class volunteering_experience_base(BaseModel):
    organization: str = Field(default='',description='Volunteering organization name')
    role: str = Field(default='',description='Volunteering role')
    years_active: str = Field(default='',description='Volunteering years active')
    activities: List[str] = Field(default=[],description='Volunteering activities')

class pet_base(BaseModel):
    type: str = Field(default='',description='Pet type')
    name: str = Field(default='',description='Pet name')
    gender: Literal['male','female'] = Field(default='',description='Pet gender')
    age: str = Field(default='',description='Pet age')
    breed: str = Field(default='',description='Pet breed')
    special_cares: List[str] = Field(default=[],description='Pet special cares')

class parent_base(BaseModel):
    father: str = Field(default='',description='Father name')
    mother: str = Field(default='',description='Mother name')

class sibling_base(BaseModel):
    name: str = Field(default='',description='Sibling name')
    gender: Literal['male','female','man','woman','boy','girl'] = Field(default='',description='Sibling gender')
    age: str = Field(default='',description='Sibling age')
    relationship: str = Field(default='',description='Sibling relationship')
    occupation: str = Field(default='',description='Sibling occupation')
    
class children_base(BaseModel):
    name: str = Field(default='',description='Children name')
    gender: Literal['male','female','man','woman','boy','girl'] = Field(default='',description='Children gender')
    age: str = Field(default='',description='Children age')
    occupation: str = Field(default='',description='Children occupation')
    
class family_base(BaseModel):
    parents: List[parent_base] = Field(default=[],description='Family parents')
    siblings: List[sibling_base] = Field(default=[],description='Family siblings')
    children: List[children_base] = Field(default=[],description='Family children')

class certification_base(BaseModel):
    certification: str = Field(default='',description='Certification title')
    issued_by: str = Field(default='',description='Certification issued by')
    issued_date: str = Field(default='',description='Certification issued date')

class daliy_routine_base(BaseModel):
    morning: str = Field(default='',description='Daliy routine morning')
    afternoon: str = Field(default='',description='Daliy routine afternoon')
    evening: str = Field(default='',description='Daliy routine evening')
    weekend: str = Field(default='',description='Daliy routine weekend')

class personal_style_base(BaseModel):
    fashion_preferences: List[str] = Field(default=[],description='Personal style fashion preferences')
    favorite_brands: List[str] = Field(default=[],description='Personal style favorite brands')
    shopping_habits: List[str] = Field(default=[],description='Personal style shopping habits')

class friend_base(BaseModel):
    name: str = Field(default='',description='Friend name')
    gender: Literal['male','female','man','woman','boy','girl'] = Field(default='',description='Friend gender')
    age: str = Field(default='',description='Friend age')
    occupation: str = Field(default='',description='Friend occupation')
    known_years: str = Field(default='',description='Friend known years')

class mental_health_base(BaseModel):
    stress_level: str = Field(default='',description='User mental health stress level')
    meditation_practice: str = Field(default='',description='User mental health meditation practice')

class health_data_base(BaseModel):
    weight: str = Field(default='',description='User weight')
    height: str = Field(default='',description='User height')
    blood_type: str = Field(default='',description='User blood type')
    sleeping_quality: str = Field(default='',description='User sleeping quality')
    sleeping_hours: str = Field(default='',description='User sleeping hours')
    mental_health: mental_health_base = Field(default=mental_health_base(),description='User mental health')
    health_conditions: List[str] = Field(default=[],description='User health conditions')
    allergies: List[str] = Field(default=[],description='User allergies')

class user_info_base(BaseModel):
    first_name: str = Field(default='',description='User first name')
    last_name: str = Field(default='',description='User last name')
    gender: Literal['male','female','man','woman','boy','girl'] = Field(default='',description='User gender')
    age: str = Field(default='',description='User age')
    birth_date: str = Field(default='',description='User birthdate')
    country: str = Field(default='',description='User country')
    city: str = Field(default='',description='User city')
    interests: List[str] = Field(default=[],description='User interests')
    favorite_genres: List[str] = Field(default=[],description='User favorite genres')
    liked_activities: List[str] = Field(default=[],description='User liked activities')
    not_liked_activities: List[str] = Field(default=[],description='User not liked activities')
    recent_activities: List[str] = Field(default=[],description='User recent activities')
    first_language: str = Field(default='',description='User frist langauge')
    second_languages: List[str] = Field(default=[],description='User second langauges')
    occupation: str = Field(default='',description='User occupation')
    industry: str = Field(default='',description='User industry')
    education_level: str = Field(default='',description='User education level')
    education_field: str = Field(default='',description='User education field')
    university: str = Field(default='',description='User university')
    school: str = Field(default='',description='User school')
    relationship_status: str = Field(default='',description='User relationship status')
    motivations: List[str] = Field(default=[],description='User motivations')
    health_status: str = Field(default='',description='User health status')
    fitness_level: str = Field(default='',description='User fitness level')
    diet: str = Field(default='',description='User diet')
    clubs: List[str] = Field(default=[],description='User clubs')
    teams: List[str] = Field(default=[],description='User teams')
    liked_foods: List[str] = Field(default=[],description='User liked foods')
    not_liked_foods: List[str] = Field(default=[],description='User not liked foods')
    travel_history: List[str] = Field(default=[],description='User travel history')
    future_travel_plans: List[str] = Field(default=[],description='User future travel plans')
    liked_hobbies: List[str] = Field(default=[],description='User liked hobbies')
    not_liked_hobbies: List[str] = Field(default=[],description='User not liked hobbies')
    volunteering_experiences: List[volunteering_experience_base] = Field(default=[],description='User volunterring experiences')
    pets: List[pet_base] = Field(default=[],description='User pets')
    family: List[family_base] = Field(default=[],description='User family')
    skills: List[str] = Field(default=[],decription='User skills')
    certifications: List[certification_base] = Field(default=[],description='User certifications')
    financial_goals: List[str] = Field(default=[],description='User financial goals')
    career_goals: List[str] = Field(default=[],description='User careet goals')
    personal_goals: List[str] = Field(default=[],description='User personal goals')
    daliy_routine: daliy_routine_base = Field(default=daliy_routine_base(),description='User daliy routine')
    productivity_methods: List[str] = Field(default=[],description='User productivity methods')
    personal_style: personal_style_base = Field(default=personal_style_base(),description='User personal style')
    friends: List[friend_base] = Field(default=[],description='User friends')
    typical_social_activities: List[str] = Field(default=[],description='User typical social activities')
    liked_drinks: List[str] = Field(default=[],description='User liked drinks')
    not_liked_drinks: List[str] = Field(default=[],description='User not liked drinks')
    health_data: health_data_base = Field(default=health_data_base(),description='User health data')

base_temp = user_info_base().model_dump_json()
base_schema = json.dumps(user_info_base.model_json_schema(), ensure_ascii=False)
