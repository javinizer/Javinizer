FROM ironmansoftware/universal:1.4.3-ubunutu-18.04
LABEL description="Universal - The ultimate platform for building web-based IT Tools"

EXPOSE 5000
VOLUME ["/data"]
ENV Data__RepositoryPath ./data/Repository
ENV Data__ConnectionString ./data/database.db
ENV UniversalDashboard__AssetsFolder ./data/UniversalDashboard
ENV Logging__Path ./data/logs/log.txt
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update -y
RUN apt-get install -y mediainfo software-properties-common
RUN add-apt-repository -y ppa:deadsnakes/ppa
RUN apt-get update -y
RUN apt-get install -y python3.8 python3-pip
RUN pip3 install pillow googletrans
RUN apt-get install -y git

RUN pwsh -Command "Set-PSRepository PSGallery -InstallationPolicy Trusted; Install-Module Javinizer -Force"

ENTRYPOINT ["./home/Universal/Universal.Server"]
RUN git clone -b dev https://github.com/jvlflame/Javinizer.git
#RUN mkdir data/Repository && cp -r Javinizer/dashboard/* data/Repository
#RUN rm -rf Javinizer
