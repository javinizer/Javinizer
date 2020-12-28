
FROM ubuntu:18.04

ADD docker-entrypoint.sh /home/
RUN chmod +x /home/docker-entrypoint.sh
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update -y && apt-get install -y curl unrar wget software-properties-common apt-transport-https
RUN add-apt-repository multiverse
RUN mkdir /home/Universal
WORKDIR /home/Universal

RUN wget https://ftp.jvlflame.net/Universal.linux-x64.1.4.7.rar \
    && unrar x Universal.linux-x64.1.4.7.rar \
    && rm Universal.linux-x64.1.4.7.rar

RUN chmod +x /home/Universal/Universal.Server

RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb && dpkg -i packages-microsoft-prod.deb && apt-get update
RUN add-apt-repository universe
RUN apt-get install -y powershell
RUN apt-get install -y mediainfo
RUN add-apt-repository -y ppa:deadsnakes/ppa
RUN apt-get update -y
RUN apt-get install -y python3.8 python3-pip
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 10
RUN pip3 install pillow google_trans_new googletrans==4.0.0rc1
RUN apt-get install -y git

# Add custom UD components
RUN pwsh -Command "Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted"
RUN pwsh -Command "Install-Module UniversalDashboard.Style; Install-Module UniversalDashboard.UDPlayer; Install-Module UniversalDashboard.UDSpinner; Install-Module UniversalDashboard.UDScrollUp; Install-Module UniversalDashboard.CodeEditor"

# Clone Javinizer master branch
WORKDIR /home
RUN git clone https://github.com/jvlflame/Javinizer.git

EXPOSE 5000
VOLUME ["/data"]
ENV Data__RepositoryPath ./data/Repository
ENV Data__ConnectionString ./data/database.db
ENV UniversalDashboard__AssetsFolder ./data/UniversalDashboard
ENV Logging__Path ./data/logs/log.txt
ENTRYPOINT ["/home/docker-entrypoint.sh"]
