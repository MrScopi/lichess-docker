ARG JAVA_VER=17.0.5
ARG JAVA_EDITION=8
ARG SBT_VER=1.8.2
ARG SCALA_VER=2.13.10
ARG JAVA_DIST=eclipse-temurin

FROM sbtscala/scala-sbt:${JAVA_DIST}-${JAVA_VER}_${JAVA_EDITION}_${SBT_VER}_${SCALA_VER}

SHELL ["/bin/bash", "-c"]

ENV TZ=Etc/GMT
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN useradd -ms /bin/bash lichess \
    && apt-get update \
    && apt update \
    && apt-get install -y sudo gnupg ca-certificates\
    # Disable sudo login for the new lichess user.
    && echo "lichess ALL = NOPASSWD : ALL" >> /etc/sudoers

RUN curl -fsSL https://deb.nodesource.com/setup_19.x | bash -
RUN apt-get install nodejs && \
  npm install -g pnpm

# mongodb
RUN wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add - \
  && echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org.list

RUN sudo apt-get update && sudo apt update \
  && sudo apt-get install -y \
  unzip \
  zip \
  curl \
#  libssl3 \
#  mongodb-org \
#  parallel \ 
#  && sudo apt install -y \ 
#  redis-server \
#  git-all \
#  vim
  nano
#  mongodb-org

# Silence the parallel citation warning.
#RUN sudo mkdir -p ~/.parallel && sudo touch ~/.parallel/will-cite

# Git cloning instructions from
# https://github.com/lichess-org/lila/wiki/Lichess-Development-Onboarding [Accessed 2023-01-07]

WORKDIR /home/lichess
# Checkpoint at 2023-01-08
ENV LILA_CHECKPOINT=0435ab85fad6679bbf49de2056279eb3fc2cc72d
# Clone main lila repo
RUN git clone --recursive https://github.com/lichess-org/lila.git
RUN cd lila && git reset --hard $LILA_CHECKPOINT

# Clone lila-ws repo
WORKDIR /home/lichess
# Checkpoint at 2023-01-08
ENV LILA_WS_CHECKPOINT=3632342ac9f88bbe4bc7b91ee8a83e8b6a8ccbe9
RUN git clone https://github.com/lichess-org/lila-ws.git
RUN cd lila-ws && git reset --hard $LILA_WS_CHECKPOINT
# Do some building
WORKDIR /home/lichess/lila
RUN ./ui/build
RUN ./lila compile

#  mongosh lichess < bin/mongodb/indexes.js && \
  # Previous step seeds the database with indices -- otherwise it won't do anything

# Make directories for mongodb
# RUN sudo mkdir -p /data/db && sudo chmod 666 /data/db

# Cleanup
#RUN sudo apt-get autoremove -y \
#  && sudo apt-get clean \
#  && sudo rm -rf /home/lichess/build \
#  && rm -R /home/lichess/.sdkman \
#  && rm -R /home/lichess/.nvm

ADD run.sh /home/lichess/run.sh

#RUN mkdir /home/lichess

#COPY --from=build /home/lichess /home/lichess

# Use UTF-8 encoding.
ENV LANG "en_US.UTF-8"
ENV LC_CTYPE "en_US.UTF-8"

WORKDIR /home/lichess

ENTRYPOINT ./run.sh
