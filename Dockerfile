FROM ubuntu:latest
ARG TERRAFORM_VERSION=1.3.7
ARG ARCHITECTURE=linux_amd64

# Prepare required packages. Self-bootstrap cron (including new cron directory which later get's overwritten by a mount)
RUN apt update && apt install -y --no-install-recommends \
    ca-certificates \
    cron \
    curl \
    unzip \
  && curl -sLo /terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${ARCHITECTURE}.zip \
  && unzip /terraform.zip \
  && rm /terraform.zip \
  && apt remove -y \
    curl \
    p7zip-full \
  && rm -rf /var/lib/apt/lists/* \
  && echo '* * * * * crontab /etc/cron.d/dyndns' >> /etc/cron.d/dyndns \
  && crontab /etc/cron.d/dyndns

# Run cron in foreground
CMD ["cron", "-f"]
