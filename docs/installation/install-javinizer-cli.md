# Install Javinizer (CLI)

## Installation Types

There are currently two ways to install the CLI:

* [Local machine (Windows/MacOS/Linux)](install-javinizer-cli.md#local-machine)
  * This method requires that you install all dependencies by yourself
* [Docker](install-javinizer-cli.md#docker)

## Local Machine

{% hint style="info" %}
Download the versions appropriate for the operating system you are installing on
{% endhint %}

### PowerShell Core (Required)

PowerShell Core (Version 6+) is required for use of the Javinizer module. I recommend using the latest stable release of PowerShell 7.

[You can find the download/installation binaries for PowerShell 7 here.](https://github.com/PowerShell/PowerShell/releases/latest)

### Python 3 (Required)

Python 3 is required for the use of some features of the Javinizer module:

* Image cropping (Poster Image)
* Text translation
* CloudFlare scraping (deprecated)

#### Windows

[You can find the download/installation binaries for Python 3.9.16 here.](https://www.python.org/downloads/release/python-3916/)

Python needs to be added to your system PATH. Select the "Add Python 3.9 to PATH" checkbox during installation. After installing Python, you will need to install three Python modules via pip.

* [Pillow](https://pypi.org/project/Pillow/)
* [googletrans](https://pypi.org/project/googletrans/4.0.0rc1/)
* [google\_trans\_new](https://pypi.org/project/google-trans-new/)

Open an administrator PowerShell or CMD console and run the following command.

```powershell
pip install pillow
pip install googletrans==4.0.0rc1
pip install google_trans_new
```

#### Linux/MacOS

Follow install instructions for your specific Linux distribution. Javinizer calls all Python commands on Linux using `python3` and modules will need to be installed using `pip3`.

```sh
pip3 install pillow
pip3 install googletrans==4.0.0rc1
pip3 install google_trans_new
```

### MediaInfo (Optional)

MediaInfo (CLI) is required for the use of some features of the Javinizer module:

* Parse media file metadata (resolution, etc.)

#### Windows/Linux

[You can find the download/installation binaries for MediaInfo here.](https://mediaarea.net/en/MediaInfo/Download)

* The MediaInfo executable will need to be added to your system PATH. Generic instructions [here](https://stackoverflow.com/a/41895179).

### Installing Javinizer

There are two ways to install Javinizer:

* [PSGallery (recommended)](install-javinizer-cli.md#install-via-psgallery)
* [Manual Import](install-javinizer-cli.md#manually-import-to-your-shell)

The recommended method to use Javinizer is installing the module via PSGallery. For power users, downloading releases manually or importing the module may be your choice instead.

{% hint style="danger" %}
Please choose either one method as they are mutually exclusive. If you are not sure, please install with PSGallery only.
{% endhint %}

#### Install via PSGallery

Run PowerShell 7 as administrator.

Install the module via the `Install-Module` command and then restart your shell.

```
Install-Module Javinizer
```

#### Manually Import to your Shell

[Download the latest release](https://github.com/javinizer/Javinizer/releases) or clone the repository and extract the files to a directory of your choice.

Run PowerShell 7 and run the following command:

```
Import-Module .\Javinizer\Javinizer.psm1
```

### Installation Check

You can check if Javinizer has successfully installed from PowerShell 7 and run the following command:

```
Javinizer -v
```

## Docker

Note that the CLI docker build versions are meant to give you a Powershell interpreter with Javinizer pre-installed. You would then need to refer the [CLI usage guide](../using-javinizer/using-the-cli/) to execute the appropriate commands. Also note that you will now need to refer to mount points inside the container. For example, if you mounted `-v /path/to/media:/mnt` then you will need to refer `/mnt` and not `/path/to/media`.\
\
If you want to run it on the NAS without using the CLI, it's recommended to use the [Web GUI ](install-javinizer-web-gui.md)version instead.

You can run the latest cli docker build (CLI tags are labeled as `[version]-cli`).

```
docker run --name javinizer -it javinizer/javinizer:latest-cli
```

### Persisting Data

You will most likely want to persist settings data when running Javinizer within Docker.

{% hint style="warning" %}
**Your sort input and output paths should be using the same bind mount, otherwise moving files between them will take an extended amount of time.**
{% endhint %}

### Docker Run Example

The following command will provide you with a Powershell interpreter which you can then use to execute Javinizer's CLI commands with your media mapped to `/mnt` while keeping the persistency of your `jvSettings.json`.

```
docker run --name javinizer -v path/to/media:/mnt -v path/to/jvSettings.json:/home/jvSettings.json -it javinizer/javinizer:latest-cli
```

To persist your settings file, create a copy of the [settings file](../../src/Javinizer/jvSettings.json) and bind mount the file:

* `/home/jvSettings.json`

To persist other settings files, set paths in your location settings:

* "location.thumbcsv": ""
* "location.genrecsv": ""
* "location.uncensorcsv": ""
* "location.historycsv": ""
* "location.tagcsv": ""
* "location.log": "",
