
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
RUN ls /home/Universal
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

# Download dashboard files
RUN mkdir /pages
RUN curl https://gist.githubusercontent.com/jvlflame/ab6a598445c36f50f45b604c30f9b34b/raw/4b6e373a66f5a22c2c73384da27d42793edc5627/main -o javinizer.ps1
WORKDIR /home/pages
RUN curl https://gist.githubusercontent.com/jvlflame/97e2c544a492738726d87c32fd77e75a/raw/2c185df411ada7c4298671a845f8a0b17b280b74/page -o page.ps1

EXPOSE 5000
ENTRYPOINT ["/home/Universal/Universal.Server"]
