<h1 align="center">
  Javinizer (JAV Organizer)
  <br>
</h1>

<h4 align="center"><strong>A commandline and GUI based PowerShell module used to scrape metadata and sort your local Japanese Adult Video (JAV) files into a media library compatible format.</strong></h4>

<br>

<p align="center">
  <a href="https://github.com/jvlflame/Javinizer/releases">
    <img src="https://img.shields.io/github/v/release/jvlflame/Javinizer?include_prereleases&style=plastic&label=release"
         alt="GitHub">
  </a>
  <a href="https://www.powershellgallery.com/packages/Javinizer/"><img src="https://img.shields.io/powershellgallery/dt/javinizer?color=red&label=psgallery&style=plastic"
  alt="PSGallery">
  </a>
  <a href="https://hub.docker.com/r/jvlflame/javinizer">
      <img src="https://img.shields.io/docker/pulls/jvlflame/javinizer?style=plastic&color=red&label=docker"
      alt="Docker">
  </a>
  <a href="https://discord.gg/Pds7xCpzpc">
    <img src="https://img.shields.io/discord/608449512352120834?color=brightgreen&style=plastic&label=discord"
    alt="Discord">
  </a>
    <a href="https://github.com/jvlflame/Javinizer/compare/dev">
    <img src="https://img.shields.io/github/commits-since/jvlflame/javinizer/latest/dev?style=plastic"
    alt="Commits">
  </a>
</p>

<p align="center">
  <a href="#features"><strong>Features</strong></a> •
  <a href="#getting-started"><strong>Getting Started</strong></a> •
  <a href="#example-output"><strong>Examples</strong></a> •
  <a href="https://docs.jvlflame.net/" target="_blank"><strong>Documentation</strong></a>

</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/jvlflame/Javinizer/master/media/demo.gif" width="1280">
  <img src="https://raw.githubusercontent.com/jvlflame/Javinizer/master/media/demo-gui.jpg" width="1280">
</p>

<p align="center">
  <a href="https://gfycat.com/spiriteddefenselessgrouper">View GUI demo video (NSFW)</a>
</p>

## Features

-   **Highly customizable**. An assortment of scrapers are available for you to mix-and-match metadata with. Scrapers sources include sites such as Javlibrary, R18, Dmm (Fanza), JavBus, Jav321, AVEntertainment, MGStage, and DLGetchu. Various _.csv_ settings files are also provided to customize your metadata even further.

-   **Flexible file detection**. Multiple methods are provided to detect your local JAV files such as the built-in file matcher as well as a customizable regex string.

-   **Multi-language support**. Scraper sources provide English, Japanese, and occasionally Chinese language support. Machine translation modules are also available to translate individual metadata fields of your choice.

-   **You own the data**. Metadata _.nfo_ files are created for each JAV file to be read by a media library application. Contrary to a media library metadata plugin, if an online scraper suddenly disappears, you still keep your metadata.

## Getting Started

View the full Javinizer installation and usage documentation on [GitBook](https://docs.jvlflame.net/).

### Prerequisites

To run Javinizer, you will need to install following:

**NOTE**: You will need to add Python and MediaInfo to your system PATH. Windows calls `python`, while Unix/MacOS calls `python3`.

-   [PowerShell 7](https://github.com/PowerShell/PowerShell)
-   [Python 3](https://www.python.org/downloads/)
    -   [Pillow](https://pypi.org/project/Pillow/)
    -   [googletrans >= 4.0.0rc1](https://pypi.org/project/googletrans/) or [google_trans_new](https://pypi.org/project/google-trans-new/)
-   [MediaInfo](https://mediaarea.net/en/MediaInfo/Download) (Optional)

```python
# Install the python modules using pip. If running Unix/MacOS, use pip3/python3
> pip install pillow
> pip install googletrans==4.0.0rc1
> pip install google_trans_new
```

### Installation

After installing the required prerequisites, run the following command in an administrator PowerShell 7 (pwsh.exe) console to install the Javinizer module. If this is your first time using PowerShell, you may run into some prompts about security policies. Follow the instructions given in the prompts to unrestrict the code.

```powershell
# Install the module from PowerShell gallery
> Install-Module Javinizer

# Check that the module has been installed; if error, restart your console
> Javinizer -v
```

### Quick start (CLI)

Here are some common commands that you can run with Javinizer:

```powershell
# Run a command to sort your JAV files using default settings
> Javinizer -Path "C:\JAV\Unsorted" -DestinationPath "C:\JAV\Sorted"

# Run a command to sort your JAV files while searching folders recursively (within the folders)
> Javinizer -Path "C:\JAV\Unsorted" -DestinationPath "C:\JAV\Sorted" -Recurse

# Run a command to sort a JAV file using direct URLs
> Javinizer -Path "C:\JAV\Unsorted\IPX-535.mp4" -Url 'https://www.javlibrary.com/en/?v=javmeza7s4', 'https://www.r18.com/videos/vod/movies/detail/-/id=ipx00535/'

# Run a command to find metadata
> Javinizer -Find "ABP-420" -Javlibrary

# Run a command to find metadata and aggregate it according to your settings file
> Javinizer -Find "ABP-420" -Javlibrary -R18 -DmmJa -Aggregated

# Run a command to find metadata, aggregate it according to your settings file, and output the nfo
> Javinizer -Find "ABP-420" -Javlibrary -R18 -DmmJa -Aggregated -Nfo

# Open the Javinizer settings configuration
> Javinizer -OpenSettings

# Update your Javinizer module
> Javinizer -UpdateModule

# View the Javinizer commandline help (may not be up to date)
> Javinizer -Help
```

### Quick start (GUI)

#### Windows

```powershell
# Install PowerShell Universal to Javinizer module folder (Run as administrator)
> Javinizer -InstallGUI

# Runs the PowerShell Universal application and opens the Javinizer GUI dashboard page
# Optionally specify a custom port using the -Port parameter
> Javinizer -OpenGUI
```

After running `Javinizer -OpenGUI`, the PowerShell Universal process should run in a separate window and open your browser to 'http://localhost:[PORT]/' which contains the Javinizer dashboard.

#### Docker

```
# To run GUI
docker run --name javinizer -p 8600:8600 -d jvlflame/javinizer:latest

# To run CLI
docker run --name javinizer -p 8600:8600 -d jvlflame/javinizer:latest-cli

# Optional
# You will need to copy the jvSettings.json configuration from [here](./src/Javinizer/jvSettings.json) and write it to your path/to/jvSettings.json location
-v path/to/jvSettings.json:/home/jvSettings.json
```

## Example Output

A few examples of Javinizer's sort output are listed below.

### Basic Folder Structures

```json
"sort.format.folder": "<ID> [<STUDIO>] - <TITLE> (<YEAR>)",
"sort.format.outputfolder": []
```

```
├─IDBD-979 [Idea Pocket] - Yume Nishinomiya Ultimate Blowjob... (2020)
│      fanart.jpg
│      folder.jpg
│      IDBD-979.mp4
│      IDBD-979.nfo
│
├─IPX-399 [Idea Pocket] - Shes Luring You To Temptation... (2019)
│      fanart.jpg
│      folder.jpg
│      IPX-399.mp4
│      IPX-399.nfo
│
├─IPX-485 [Idea Pocket] - A Big Tits Wife Who Got Fucked... (2020)
│      fanart.jpg
│      folder.jpg
│      IPX-485.mp4
│      IPX-485.nfo
```

### Advanced Folder Structures

```json
"sort.format.folder": "<ID> [<STUDIO>] - <TITLE>",
"sort.format.outputfolder": ["<ACTORS>", "<YEAR>"]
```

```
├─Nishimiya Yume
│  └─2020
│      └─IDBD-979 [Idea Pocket] - Yume Nishinomiya Ultimate Blowjob...
│          │  fanart.jpg
│          │  folder.jpg
│          │  IDBD-979-trailer.mp4
│          │  IDBD-979.mp4
│          │  IDBD-979.nfo
│          │
│          ├─.actors
│          │      Nishimiya_Yume.jpg
│          │
│          └─extrafanart
│                  fanart1.jpg
│                  fanart2.jpg
│                  fanart3.jpg
│
└─Sakura Momo
    ├─2019
    │  └─IPX-399 [Idea Pocket] - Shes Luring You To Temptation...
    │      │  fanart.jpg
    │      │  folder.jpg
    │      │  IPX-399-trailer.mp4
    │      │  IPX-399.mp4
    │      │  IPX-399.nfo
    │      │
    │      ├─.actors
    │      │      Sakura_Momo.jpg
    │      │
    │      └─extrafanart
    │              fanart1.jpg
    │              fanart2.jpg
    │              fanart3.jpg
    │
    └─2020
        └─IPX-485 [Idea Pocket] - A Big Tits Wife Who Got Fucked...
            │  fanart.jpg
            │  folder.jpg
            │  IPX-485-trailer.mp4
            │  IPX-485.mp4
            │  IPX-485.nfo
            │
            ├─.actors
            │      Sakura_Momo.jpg
            │
            └─extrafanart
                    fanart1.jpg
                    fanart2.jpg
                    fanart3.jpg
```

### Metadata Output .nfo

A .nfo metadata file is created for each movie.

```
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<movie>
    <title>[IDBD-979] Yume Nishinomiya Ultimate Blowjoc Complete BEST - Lots of Cum, 40 Shots!</title>
    <originaltitle>西宮ゆめ 至高のフェラチオコンプリートBEST 大量射精40発！</originaltitle>
    <id>IDBD-979</id>
    <premiered>2020-09-12</premiered>
    <year>2020</year>
    <director></director>
    <studio>Idea Pocket</studio>
    <rating></rating>
    <votes></votes>
    <plot>デビュー4周年を迎えたアイポケの小悪魔美少女’’西宮ゆめ’’のフェラチオシーンのみを集めたベストが登場！</plot>
    <runtime>237</runtime>
    <trailer>https://awscc3001.r18.com/litevideo/freepv/i/idb/idbd00979/idbd00979_dmb_w.mp4</trailer>
    <mpaa>XXX</mpaa>
    <tagline></tagline>
    <set></set>
    <genre>Beautiful Girl</genre>
    <genre>Blowjob</genre>
    <genre>Facial</genre>
    <genre>Deep Throat</genre>
    <genre>Digital Mosaic</genre>
    <genre>Actress Best Compilation</genre>
    <actor>
        <name>Nishimiya Yume</name>
        <altname>西宮ゆめ</altname>
        <thumb>https://pics.r18.com/mono/actjpgs/nisimiya_yume.jpg</thumb>
        <role>Actress</role>
    </actor>
</movie>
```
