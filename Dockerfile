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
    && apt-get install -y \
    sudo gnupg ca-certificates\
    # Disable sudo login for the new lichess user.
    && echo "lichess ALL = NOPASSWD : ALL" >> /etc/sudoers

RUN curl -fsSL https://deb.nodesource.com/setup_19.x | bash -\
  apt-get install nodejs && \
  npm install -g pnpm

RUN sudo apt-get update && sudo apt update \
  && sudo apt-get install -y \
  unzip zip curl nano

# Git cloning instructions from
# https://github.com/lichess-org/lila/wiki/Lichess-Development-Onboarding [Accessed 2023-01-07]

WORKDIR /home/lichess
# Checkpoint at 2023-01-08
ENV LILA_CHECKPOINT=0435ab85fad6679bbf49de2056279eb3fc2cc72d
# Clone main lila repo
RUN git clone --recursive https://github.com/lichess-org/lila.git && \
  cd lila && \
  git reset --hard $LILA_CHECKPOINT

# Add in configurations to application.conf
ENV DOMAIN=chess.example.com
ENV SOCKET_DOMAIN=chess-ws.example.com
ENV SSL=https://
ENV MAILER_HOST=in-v3.mailjet.com
ENV MAILER_USER=username
ENV MAILER_PASS=password
ENV MAILER_SENDER=noreply@example.com
ENV CONF_FILE=/home/lichess/lila/conf/application.conf

RUN echo net.domain = \"$DOMAIN\" >> $CONF_FILE && \
  echo net.socket.domains = [ \"$SOCKET_DOMAIN\" ] >> $CONF_FILE && \
  echo net.asset.base_url = \"$SSL\"${net.asset.domain} >> $CONF_FILE && \
  echo net.base_url = \"$SSL\"${net.domain} >> $CONF_FILE && \
  echo mailer.primary.host = $MAILER_HOST >> $CONF_FILE && \
  echo mailer.primary.user = $MAILER_USER >> $CONF_FILE && \
  echo mailer.primary.password = $MAILER_PASS >> $CONF_FILE && \
  echo mailer.primary.sender = \"$MAILER_SENDER\" >> $CONF_FILE

# Clone lila-ws repo
WORKDIR /home/lichess
# Checkpoint at 2023-01-08
ENV LILA_WS_CHECKPOINT=3632342ac9f88bbe4bc7b91ee8a83e8b6a8ccbe9
RUN git clone https://github.com/lichess-org/lila-ws.git && \
  cd lila-ws && git reset --hard $LILA_WS_CHECKPOINT
# Do some building
WORKDIR /home/lichess/lila
RUN ./ui/build
RUN ./lila compile

ADD run.sh /home/lichess/run.sh

# Use UTF-8 encoding.
ENV LANG "en_US.UTF-8"
ENV LC_CTYPE "en_US.UTF-8"

WORKDIR /home/lichess

ENTRYPOINT ./run.sh
