# Setting owned movies on Javlibrary

{% hint style="info" %}
The recommended workflow for setting owned movies is to run it on files directly after sorting them. This is due to JAVLibrary's owned movie list only aggregating the first 5,000 owned movies which causes Javinizer to not recognize already-owned movies if you surpass that count.
{% endhint %}

If you are a JAVLibrary user, chances are you would like to track movies that you are sorting as an "Owned" movie. Javinizer has the capability to scan your JAV directories and set the status of that movie to "Owned".

To use this functionality, perform the following steps:

### Login to JAVLibrary

Click the "Sign In" button on the upper-right of the JAVLibrary homepage and enter your credentials.

![](../../.gitbook/assets/javlibrary\_login.png)

### View site cookies

After logging in to JAVLibrary, view the site cookies. You will need to enter these into your settings file.

| Setting                   | Value                               |
| ------------------------- | ----------------------------------- |
| javlibrary.cookie.session | Cookie content value from `session` |
| javlibrary.cookie.userid  | Cookie content value from `userid`  |

![](../../.gitbook/assets/javlibrary\_cookie.png)

### Run the Javinizer -SetOwned command

You will need to define the `-Path` to your sorted files as well as the switch `-SetOwned`. This command will check your existing owned movies on JAVLibrary and compare it to files found. If the file is correctly matched to a movie on JAVLibrary, it will perform a POST request to set the movie as owned.

```
Javinizer -Path "C:\JAV\Sorted" -Recurse -SetOwned
```
