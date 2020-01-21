FROM emmanuelkiegaing/nvidia-mcr2018b:latest
LABEL maintainer="Emmanuel Kiegaing Kouokam kiegaingemmanuel@gmail.com"

COPY ./ /

#COPY ./jm_16.1_xmltrace_v1.5  /jm_16.1_xmltrace_v1.5
#COPY ./ldecod /ldecod

WORKDIR /

#EXPOSE 5555
run apt-get install ffmpeg -y

ENTRYPOINT ["/bin/sh"]
