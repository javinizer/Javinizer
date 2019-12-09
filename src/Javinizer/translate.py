from googletrans import Translator
import sys

translator = Translator()
translation = translator.translate(sys.argv[1], dest='en')

print(translation.text)
