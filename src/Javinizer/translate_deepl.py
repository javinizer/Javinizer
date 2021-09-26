import sys
import requests
import tempfile
import os
import json

#Select Url based on key provided (free keys always end in :fx)
baseurl = "https://api-free.deepl.com/v2/translate" if sys.argv[3].endswith(":fx") else "https://api.deepl.com/v2/translate"

url = "{}?auth_key={}&text={}&target_lang={}".format(baseurl, sys.argv[3], sys.argv[1], sys.argv[2])
r = requests.get(url)
j = json.loads(r.text)
n = j['translations'][0]['text']

text = n.encode('utf8')

# Write the translated text to a temporary file to bypass encoding issues when redirecting the text to PowerShell
new_file, filename = tempfile.mkstemp()
os.write(new_file, text)
os.close(new_file)

# Return the path to the temporary file to read it from PowerShell
print(filename)
