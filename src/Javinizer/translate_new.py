from google_trans_new import google_translator
import sys
import tempfile
import os

google_translator = google_translator()
translation = google_translator.translate(sys.argv[1], lang_tgt=sys.argv[2])

text = translation.encode('utf8')

# Write the translated text to a temporary file to bypass encoding issues when redirecting the text to PowerShell
new_file, filename = tempfile.mkstemp()
os.write(new_file, text)
os.close(new_file)

# Return the path to the temporary file to read it from PowerShell
print(filename)
