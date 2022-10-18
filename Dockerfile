FROM ubuntu:22.04

RUN apt-get update && apt-get install -y build-essential nasm dumb-init

COPY . /asm

WORKDIR /asm

RUN make

# ENTRYPOINT ["./entrypoint.sh"]
CMD ["dumb-init", "./server"]
