
FROM ubuntu:18.04
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update -y && apt-get install -y curl unrar wget software-properties-common apt-transport-https
RUN add-apt-repository multiverse
RUN mkdir /home/Universal
WORKDIR /home/Universal
RUN wget https://ftp.jeff-server.com/Universal.linux-x64.1.4.4.rar \
    && unrar x Universal.linux-x64.1.4.4.rar \
    && rm Universal.linux-x64.1.4.4.rar
RUN chmod +x /home/Universal/Universal.Server

# Add custom UD components
RUN pwsh -Command "Find-Module -Name 'UniversalDashboard.Style' -Repository 'PSGallery' | Save-Module -Path /Universal/UniversalDashboard/Components"

RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb && dpkg -i packages-microsoft-prod.deb && apt-get update
RUN add-apt-repository universe
RUN apt-get install -y powershell
RUN apt-get install -y mediainfo
RUN add-apt-repository -y ppa:deadsnakes/ppa
RUN apt-get update -y
RUN apt-get install -y python3.8 python3-pip
RUN pip3 install pillow googletrans
RUN apt-get install -y git

# Clone dev Javinizer branch
WORKDIR /home
RUN git clone -b dev https://github.com/jvlflame/Javinizer.git

EXPOSE 5000
VOLUME ["/data"]
ENV Data__RepositoryPath ./data/Repository
ENV Data__ConnectionString ./data/database.db
ENV UniversalDashboard__AssetsFolder ./data/UniversalDashboard
ENV Logging__Path ./data/logs/log.txt
ENTRYPOINT ["/home/Universal/Universal.Server"]
