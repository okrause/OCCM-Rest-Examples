#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Example how to do API calls to Netapp OnCommand Cloud Manager (OCCM)
# OCCM API documentation (Swagger) at http://<occm-ip>/occm/api-doc

import json
import requests
from time import sleep

server = '<<http://your_occm_ip>>'

# How ot login to OCCM
credentials = json.load(open("credentials.json"))
r = requests.post(server + "/auth/login", json = credentials)

# Example for return code checking
if (r.status_code == 204):
    cookie = r.cookies
else:
    print('Cannot login to ' + server + ". Skipping ...")

# POST requests
## create OTC working environment
otc = json.load(open("otc.json"))

r = requests.post(server + "/vsa/working-environments", json=otc, cookies=cookie)
otcid = r.json()["publicId"]

r = requests.get(server + "/vsa/working-environments", cookies=cookie)
#if (r.status_code == 200):

# How to do GET requests
## show working environments
r = requests.get(server + "/vsa/working-environments", cookies=cookie)
for x in r.json():
    print(x['publicId'])

## check if environment is ready
# status = (ON|OFF|DELETING|INITIALIZING)
while True:
    sleep(15)
    r = requests.get(server + "/vsa/working-environments/" + otcid + "?fields=status,svmName", cookies=cookie)
    status = r.json()['status']['status']
    print(status)
    if status == 'ON':
        break

print("Cluster: {}, SVM: {} is up and running.".format(r.json()['name'], r.json()['svmName']))

# How to do DELETE request
## delete OTC instance
r = requests.delete(server + "/vsa/working-environments/" + otcid, cookies=cookie)
