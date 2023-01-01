FROM amazonlinux:2022

# Install AWS CLI
RUN yum install -y unzip && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

WORKDIR /src

COPY ./src .

ARG IMAGE_TAG
ENV IMAGE_TAG=$IMAGE_TAG

ENTRYPOINT ["bash", "/src/main.sh"]