FROM hadoop:3

WORKDIR /etc
COPY ./config/run.sh .

WORKDIR /opt/hadoop/etc/hadoop/
COPY ./config/workers ./

WORKDIR /home/hadoop
RUN mkdir data

CMD service ssh start && sleep infinity