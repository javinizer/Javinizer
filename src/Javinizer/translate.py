from googletrans import Translator
import sys
import tempfile
import os

translator = Translator()
translation = translator.translate(sys.argv[1], dest=sys.argv[2])

text = translation.text.encode('utf8')

# Write the translated text to a temporary file to bypass encoding issues when redirecting the text to PowerShell
new_file, filename = tempfile.mkstemp()
os.write(new_file, text)
os.close(new_file)

# Return the path to the temporary file to read it from PowerShell
print(filename)
