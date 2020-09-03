from googletrans import Translator
import sys

translator = Translator()
translation = translator.translate(sys.argv[1], dest=sys.argv[2])

text = translation.text.encode('utf8')
sys.stdout.buffer.write(text)
