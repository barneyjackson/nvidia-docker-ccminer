FROM nvidia/cuda:11.3.0-devel-ubuntu20.04 AS builder

ENV BUILD_DIR=/build
ENV CCMINER_DIR=$BUILD_DIR/ccminer
ENV CCMINER_VERSION=2.3.1-tpruvot

RUN apt-get update && \
    apt-get install -y \
        git make gcc g++ make autoconf automake libssl-dev libjansson-dev \
        libcurl4-openssl-dev autotools-dev build-essential

RUN mkdir $BUILD_DIR && \
    cd $BUILD_DIR && \
    git clone https://github.com/tpruvot/ccminer.git --branch $CCMINER_VERSION --single-branch

COPY /src/Makefile.am $CCMINER_DIR/Makefile.am

RUN cd $CCMINER_DIR && ./build.sh

FROM nvidia/cuda:11.3.0-runtime-ubuntu20.04 AS runner

ENV BUILD_DIR=/build/ccminer
ENV CCMINER_DEST=/ccminer

RUN mkdir $CCMINER_DEST

COPY --from=builder $BUILD_DIR $CCMINER_DEST
COPY --from=builder /usr/local/lib /usr/local/lib

# Symlink the missing Cuda lib?
RUN cp /usr/local/cuda-11.3/compat/* /usr/local/cuda/lib64/

RUN ln -s $CCMINER_DEST/ccminer /usr/local/bin/ccminer && \
    chown -R root.root $CCMINER_DEST

RUN apt-get update && \
    apt-get install -y libcurl4 libjansson4 libgomp1 && \
    apt-get clean

CMD [ ccminer ]
