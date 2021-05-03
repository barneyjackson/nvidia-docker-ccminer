FROM nvidia/cuda:11.3.0-devel-ubuntu20.04

# We will need Git to pull the repo
RUN yum -y -q install git

# The packages mentioned in the INSTALL phase, except:
# make - Added it because Centos doesn't have it even after getting autoconf/automake
RUN yum -y -q install gcc gcc-c++ make wget autoconf automake install openssl-devel libcurl-devel zlib-devel jansson

# Create a user to do the build
ENV BUILD_FOLDER=/minerbuild
ENV APP_FOLDER=/app
ENV APP_USER=minerbuilder
ENV CCMINER_VERSION=2.3.1-tpruvot

RUN adduser $APP_USER && \
    mkdir $BUILD_FOLDER && \
    chown $APP_USER.users $BUILD_FOLDER

# Now switch to the builder and check out the git repo
USER $APP_USER

# Clone from the git repo
RUN cd $BUILD_FOLDER && \
    git clone https://github.com/tpruvot/ccminer.git --branch $CCMINER_VERSION --single-branch

ENV CCMINER_FOLDER=$BUILD_FOLDER/ccminer

# Copy Makefile with correct CUDA config
COPY /src/Makefile.am $CCMINER_FOLDER/Makefile.am

# Run the build
RUN cd $CCMINER_FOLDER && ./build.sh

# Copy the ccminer binary to a /app folder
USER root

RUN mkdir $APP_FOLDER && \
    chown $APP_USER.users $APP_FOLDER && \
    cp $CCMINER_FOLDER/ccminer $APP_FOLDER

# Switch to a multistage build with the runtime image
FROM nvidia/cuda:11.3.0-runtime-ubuntu20.04

# Redefine the app user and folder - note app folder must be the same as the first stage
ENV APP_FOLDER=/app
ENV APP_USER=miner

# Copy the stuff that we built
COPY --from=0 $APP_FOLDER $APP_FOLDER
COPY --from=0 /usr/local/lib /usr/local/lib

# Get the non-devel versions of the libraries that we need
RUN yum -y -q install openssl libcurl zlib libgomp &&  \
    yum clean all && \
    rm -rf /var/cache/yum

# Load the Jansson library that's now built
RUN echo /usr/local/lib > /etc/ld.so.conf.d/userlocal.conf && \
    ldconfig

# Symlink the app to /usr/local/bin
RUN ln -s $APP_FOLDER/ccminer /usr/local/bin/ccminer && \
    chown -R root.root $APP_FOLDER

# Symlink the missing Cuda lib?
RUN cp /usr/local/cuda-10.1/compat/* /usr/lib64/

# Recreate and switch to the app user for this build
RUN adduser $APP_USER
USER $APP_USER

CMD [ ccminer ]
# ccminer -a scrypt -o stratum+tcp://prohashing.com:3333 -u bjmjackson -p "a=scrypt,n=trial1,o=cloud"
# ccminer -a scrypt -o stratum+tcp://ltc.pool.minergate.com:3336 -u virtualcoin.videos@gmail.com -p x
# ccminer -a lyra2v2 -o stratum+tcp://imaginedpool.doesnotexist.net:1234 -u myuser.w1 -p x

# AWS ECS-optimised LINUX GPU London AMI: ami-08d7e834ed45b7859 (from: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html)
