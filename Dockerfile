FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y \
    openssh-server \
    rsync \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Setup SSH
# https://docs.docker.com/engine/examples/running_ssh_service/
EXPOSE 22
RUN mkdir /var/run/sshd
RUN sed -i 's/.*PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Setup rsync
EXPOSE 873

CMD ["rsync_server"]
ENTRYPOINT ["/entrypoint.sh"]
COPY entrypoint.sh /entrypoint.sh
COPY pipework /usr/bin/pipework
RUN chmod 744 /entrypoint.sh

#docker build -t land007/rsync-server:latest .
#> docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t land007/rsync-server:latest --push .
#docker run -it --name rsync-server -p 10873:873 -p 10822:22 -e USERNAME=land007 -e PASSWORD=1234567 -v ~/.ssh/authorized_keys:/root/.ssh/authorized_keys land007/rsync-server:latest

#docker rm -f rsync-server ; docker run -it --name rsync-server --restart=always -p 10873:873 -p 10822:22 -e USERNAME=land007 -e PASSWORD=419718 -v ~/.ssh/authorized_keys:/root/.ssh/authorized_keys -v /mnt/ecd1eda9-a0c3-48ce-84f6-d8b2b0b48918/docker/rsync-server/data:/data land007/rsync-server:latest
