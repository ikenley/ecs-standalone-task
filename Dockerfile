FROM amazonlinux:2022

WORKDIR /src

COPY ./src .

ENTRYPOINT ["bash", "/src/main.sh"]