#FROM docker.elastic.co/elasticsearch/elasticsearch:6.2.4
FROM openjdk:9-jdk

RUN curl -OL http://services.gradle.org/distributions/gradle-4.3-all.zip
RUN unzip -d /opt/gradle gradle-4.3-all.zip
ENV PATH="/opt/gradle/gradle-4.3/bin:${PATH}"
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN apt-get install apt-transport-https
RUN echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-6.x.list
RUN apt-get update && apt-get install elasticsearch=6.2.4
ADD ./elasticsearch-aknn /data
WORKDIR /data
RUN gradle clean build -x integTestRunner -x test 
#--stacktrace --debug
ENV ELASTIC_HOME=/usr/share/elasticsearch
ENV PATH="${ELASTIC_HOME}/bin:${PATH}"
ENV PLUGINPATH="file:build/distributions/elasticsearch-aknn-0.0.1-SNAPSHOT.zip"
RUN elasticsearch-plugin remove elasticsearch-aknn | true
RUN elasticsearch-plugin install -b $PLUGINPATH
#RUN sysctl -w vm.max_map_count=262144
ENV ES_HEAP_SIZE=12g 
RUN chown -R elasticsearch:elasticsearch $ELASTIC_HOME
RUN echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml
USER elasticsearch
ENTRYPOINT $ELASTIC_HOME/bin/elasticsearch
