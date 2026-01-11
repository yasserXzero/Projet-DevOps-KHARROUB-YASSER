FROM jenkins/jenkins:lts-jdk17

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    docker.io \
    docker-compose \
    curl \
  && rm -rf /var/lib/apt/lists/*

# Allow jenkins user to use docker socket (works when /var/run/docker.sock is mounted)
RUN groupadd -f docker && usermod -aG docker jenkins

USER jenkins
