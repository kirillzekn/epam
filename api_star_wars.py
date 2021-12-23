import requests
import json

from requests.models import Response

# people_API = requests.get('https://swapi.dev/api/people/')
# people_data = people_API.text
# parse_people_json = json.loads(people_data)

# for i in parse_people_json['results']:
#     print('person_name is',i.get('name'),';',
#     'person_gender is',i.get('gender'),';',
#     'person_homeworld is',(json.loads(requests.get(i.get('homeworld')).text)).get('name'),';',
#     )

starships_API = requests.get('https://swapi.dev/api/starships/')
starships_data = starships_API.text
parse_starships_json = json.loads(starships_data)


for i in parse_starships_json['results']:
    print(
    'starship_name is',i.get('name'),';/n',
    'starship_manufacturer is',i.get('manufacturer'),';/n',
    'starship_cargo_capacity is',i.get('cargo_capacity'),';/n',
    'starship_model is',i.get('model'),';/n',
    'starship_pilots are',i.get('pilots'),';/n',
    )
    # if len(i.get('pilots')) >0:
    #     for a in i.get('pilots'):
    #         print( 
    #             (
    #                 json.loads(
    #                     requests.get(a).text
    #                 )
    #             ).get('name')
    #         )