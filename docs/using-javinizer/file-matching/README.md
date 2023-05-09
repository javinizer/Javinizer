# File Matching

Javinizer will by default attempt to clean the filenames of downloaded files and match them to their Movie ID which normally appears in the form of ID-###.&#x20;

To reduce the likelihood of false matches, Javinizer requires that the filename match is **exactly** the ID that appears on the scraper source.&#x20;

For example, `ABP-420.1080p.mp4` will be automatically cleaned to `ABP-420` when matching. This must exactly match the movie ID `ABP-420` that is displayed on your selected scrapers.

In some cases, the default filematcher will fail to match the file due to edge case filenames or the ID listed on the scraper source does not follow the standard ID format. In these cases, you will likely need to sort using the [`-Url`](../using-the-cli/sorting-files.md#using-direct-urls)  or `-Strict` parameters.

## Strict filematching

The `-Strict` parameter works by forcing the filematcher to ignore the default filename cleaning logic and use the exact filename. The default filematcher will swap to strict filematching if the cleaned filename doesn't match the regex `([a-zA-Z|tT28]+-\d+[zZ]?[eE]?)` to better automatically match files.

For example:

* `Javinizer -Path .\ABP-42.720p.mp4` will automatically clean the file ID to `ABP-42`
* `Javinizer -Path .\ABP-42.720p.mp4 -Strict` will use the filename as the ID as `ABP-42.720p`

One thing to keep in mind is that `-Strict` will not support [multi-part sorting](multi-part-match.md) due to the nature of how it matches the filename exactly.

## Display the filematcher output

In some cases, you may be wondering what the filenames are being matched to. To do this, you can use the built-in `-Preview` parameter to output the filematcher results.

```
Javinizer -Path C:\JAV\Unsorted -Preview
```

### Example Result

```
Javinizer -Path C:\Javinizer\Test2 -Preview | Format-Table
```

```
Id        ContentId  FileName      BaseName  Directory          FullName                         Extension Length PartNumber
--        ---------  --------      --------  ---------          --------                         --------- ------ ----------
STARS-266 STARS00266 STARS-266.mp4 STARS-266 C:\Javinizer\Test2 C:\Javinizer\Test2\STARS-266.mp4 .mp4           0
STARS-270 STARS00270 STARS-270.mp4 STARS-270 C:\Javinizer\Test2 C:\Javinizer\Test2\STARS-270.mp4 .mp4           0
STARS-281 STARS00281 STARS-281.mp4 STARS-281 C:\Javinizer\Test2 C:\Javinizer\Test2\STARS-281.mp4 .mp4           0
STARS-283 STARS00283 STARS-283.mp4 STARS-283 C:\Javinizer\Test2 C:\Javinizer\Test2\STARS-283.mp4 .mp4           0
STARS-284 STARS00284 STARS-284.mp4 STARS-284 C:\Javinizer\Test2 C:\Javinizer\Test2\STARS-284.mp4 .mp4           0
STARS-289 STARS00289 STARS-289.mp4 STARS-289 C:\Javinizer\Test2 C:\Javinizer\Test2\STARS-289.mp4 .mp4           0
SUJI-121  SUJI00121  SUJI-121.mp4  SUJI-121  C:\Javinizer\Test2 C:\Javinizer\Test2\SUJI-121.mp4  .mp4           0
SUJI-122  SUJI00122  SUJI-122.mp4  SUJI-122  C:\Javinizer\Test2 C:\Javinizer\Test2\SUJI-122.mp4  .mp4           0
SW-574    SW00574    SW-574.mp4    SW-574    C:\Javinizer\Test2 C:\Javinizer\Test2\SW-574.mp4    .mp4           0
T28-564   T2800564   T28-564.mp4   T28-564   C:\Javinizer\Test2 C:\Javinizer\Test2\T28-564.mp4   .mp4           0
VENU-961  VENU00961  VENU-961.mp4  VENU-961  C:\Javinizer\Test2 C:\Javinizer\Test2\VENU-961.mp4  .mp4           0
WANZ-940  WANZ00940  WANZ-940.mp4  WANZ-940  C:\Javinizer\Test2 C:\Javinizer\Test2\WANZ-940.mp4  .mp4           0
WANZ-959  WANZ00959  WANZ-959.mp4  WANZ-959  C:\Javinizer\Test2 C:\Javinizer\Test2\WANZ-959.mp4  .mp4           0
WANZ-974  WANZ00974  WANZ-974.mp4  WANZ-974  C:\Javinizer\Test2 C:\Javinizer\Test2\WANZ-974.mp4  .mp4           0
WANZ-982  WANZ00982  WANZ-982.mp4  WANZ-982  C:\Javinizer\Test2 C:\Javinizer\Test2\WANZ-982.mp4  .mp4           0
WANZ-984  WANZ00984  WANZ-984.mp4  WANZ-984  C:\Javinizer\Test2 C:\Javinizer\Test2\WANZ-984.mp4  .mp4           0
WANZ-991  WANZ00991  WANZ-991.mp4  WANZ-991  C:\Javinizer\Test2 C:\Javinizer\Test2\WANZ-991.mp4  .mp4           0
XDO-002   XDO00002   XDO-002.mp4   XDO-002   C:\Javinizer\Test2 C:\Javinizer\Test2\XDO-002.mp4   .mp4           0
XRW-922   XRW00922   XRW-922.mp4   XRW-922   C:\Javinizer\Test2 C:\Javinizer\Test2\XRW-922.mp4   .mp4           0
YMDD-207  YMDD00207  YMDD-207.mp4  YMDD-207  C:\Javinizer\Test2 C:\Javinizer\Test2\YMDD-207.mp4  .mp4           0
YSN-518   YSN00518   YSN-518.mp4   YSN-518   C:\Javinizer\Test2 C:\Javinizer\Test2\YSN-518.mp4   .mp4           0
ZEX-397   ZEX00397   ZEX-397.mp4   ZEX-397   C:\Javinizer\Test2 C:\Javinizer\Test2\ZEX-397.mp4   .mp4           0
ZMEN-060  ZMEN00060  ZMEN-060.mp4  ZMEN-060  C:\Javinizer\Test2 C:\Javinizer\Test2\ZMEN-060.mp4  .mp4           0
```

You can use all of the available sort parameters that you would normally be able to use when running a sort with Javinizer.

* \-Path
* \-Recurse
* \-Depth
* \-Strict

The filematcher will take in your defined settings such as:

* match.minimumfilesize
* match.includedfileextension
* match.excludedfilestring
* match.regex
* match.regex.string
* match.regex.idmatch
* match.regex.ptmatch
