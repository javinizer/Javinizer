from google_trans_new import google_translator
import sys

google_translator = google_translator()
translation = google_translator.translate(sys.argv[1], lang_tgt=sys.argv[2])

text = translation.encode('utf8')
sys.stdout.buffer.write(text)
