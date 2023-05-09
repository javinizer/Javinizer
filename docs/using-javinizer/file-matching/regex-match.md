# Regex Match

Javinizer supports using regex match instead of the default file matcher.

| Setting             | Description                                                                                            | Value         |
| ------------------- | ------------------------------------------------------------------------------------------------------ | ------------- |
| match.regex         | Specifies that Javinizer will perform the directory search using regex rather than the default matcher | true or false |
| match.regex.string  | Specifies the regex string that Javinizer will use to perform the directory search.                    | Regex string  |
| match.regex.idmatch | Specifies the regex match of the movie's ID of the regex string.                                       | Any number    |
| match.regex.ptmatch | Specifies the regex match of the movie's part number of the regex string.                              | Any number    |

To use, you will need to set `match.regex` to true. The regex string used is defined in setting `match.regex.string`. To include support for multi-part videos, you can optionally add the regex to grab the part number of the video you are sorting. This is more strict than the default file matcher, and requires that the part number be defined as an integer (1, 2, 3, etc.) rather than a letter or anything else.

## Example

Let's take the default regex settings as an example. As we are defining this as a JSON string, you will need to escape your backslashes with an additional backslash character.&#x20;

`\` => `\\`

In this regex string, we are trying to match the default DVD ID format of output files from Javinizer.&#x20;

```
"match.regex": true,
"match.regex.string": "([a-zA-Z|tT28]+-\\d+[zZ]?[eE]?)(?:-pt)?(\\d{1,2})?",
"match.regex.idmatch": 1,
"match.regex.ptmatch": 2,
```

I tend to look at [regex101](https://regex101.com/r/ze1Sya/1) to create my regex strings. We can see here with the default regex, we are matching the ID `ABP-420` as group 1, and the part numbers as group 2. These are the values we need to define in the `match.regex.idmatch` and `match.regex.ptmatch` settings.

![](../../.gitbook/assets/regex\_match.png)

To test your regex settings with Javinizer, view the instructions to [display the file matcher output](./).
