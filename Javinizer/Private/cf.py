import sys
import cfscrape

tokens = cfscrape.get_tokens(sys.argv[1])
print(tokens)
