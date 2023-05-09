# Frequently Asked Questions

If you have a feature request, find a bug, or have a question please [create a new issue](https://github.com/javinizer/Javinizer/issues/new) or join the [Discord server](https://discord.gg/Pds7xCpzpc).

## FAQ

### "Unable to reach Javlibrary, enter a websession/cookies to use the scraper"

This error message usually indicates that Cloudflare anti-bot protection is restricting you from accessing the site without entering a captcha. You will likely need to enter the captcha and then use cookies from the site to use the scraper. View [issue #169](https://github.com/javinizer/Javinizer/issues/169) for details.

### My poster image isn't being created when completing a movie sort

If your poster image isn't being created even with `sort.download.posterimg` being set as true, then you likely have an issue with your Python Pillow module being called in the module. Review the documentation on the [install page](../installation/install-javinizer-cli.md).&#x20;

### My movie isn't being matched even though I can find it on the website

The Javinizer file matcher is optimized to run against movies using a standard DVD ID (e.g. ABP-420), thus if your movie does not match that standard, it will likely fail. Javinizer will only match a file if the cleaned filename matches the exact movie ID from the scraper. View the documentation on [file matching](../using-javinizer/file-matching/) for more details.

### I'm receiving an error during the metadata translation

Make sure you have Python and the translation modules installed. If you are using the googletrans module, you will need version 4.0.0rc1 at minimum. Otherwise, the googletrans and google\_trans\_new modules have a temporary rate-limit that you may hit if you are sorting a lot of movies at once. Consider using a VPN or swapping between modules to bypass this limit.

### Running Javinizer GUI on Synology does not work

[View the full discussion on GitHub](https://github.com/javinizer/Javinizer/discussions/162). The tl;dr is that you will likely need to run the `docker run` command via SSH on your Synology rather than use the Docker GUI.
