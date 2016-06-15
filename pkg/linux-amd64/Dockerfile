FROM crystallang/crystal:0.18.0

RUN apt-get update && apt-get install -y build-essential

VOLUME /mnt
WORKDIR /mnt

ENTRYPOINT ["make"]
CMD ["dist"]
