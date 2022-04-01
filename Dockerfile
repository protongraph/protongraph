FROM ubuntu:20.04

# Alter sources list so that we can find gcc-4.9
RUN cd /etc/apt && echo 'deb http://dk.archive.ubuntu.com/ubuntu/ xenial main\n' >> sources.list && echo 'deb http://dk.archive.ubuntu.com/ubuntu/ xenial universe\n' >> sources.list && cd -

# Make sure that we have add-apt-repository available
RUN apt-get -y -o Acquire::ForceIPv4=true update
RUN apt-get install software-properties-common -y

# Tooling to support running the programme
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y
RUN apt-get -y -o Acquire::ForceIPv4=true update && apt-get install -y gcc-4.9 && apt-get upgrade -y libstdc++6
RUN apt-get dist-upgrade -y

# Packages for runtime execution
RUN apt-get -y -o Acquire::ForceIPv4=true update && apt -y -o Acquire::ForceIPv4=true install xvfb libxcursor-dev libxinerama1 libxrandr2 libxi6 libasound2 libpulse0 libgl1-mesa-glx
# ELF utils
RUN apt-get -y install binutils elfutils patchelf
# Additional utils for runtime execution
RUN apt-get -y install curl
# Copy the headless binary + pck
COPY builds/server /usr/protongraph
# Copy the native resources (basically just compiled Kafka library for now)
COPY native/thirdparty/librdkafka/librdkafka.gdns /usr/protongraph/native/thirdparty/librdkafka/librdkafka.gdns
COPY native/thirdparty/librdkafka/librdkafka.tres /usr/protongraph/native/thirdparty/librdkafka/librdkafka.tres
COPY native/thirdparty/librdkafka/bin/x11/librdkafka.so /usr/protongraph/native/thirdparty/librdkafka/bin/x11/librdkafka.so
COPY native/thirdparty/librdkafka/bin/x11/librdkafka.so.1 /usr/protongraph/native/thirdparty/librdkafka/bin/x11/librdkafka.so.1

# Copy the hyper-important config files across; without these we can't connect to Kafka
COPY config /usr/protongraph/config
WORKDIR /usr/protongraph

# Hack sourced from here to work around X11 requirement: https://github.com/godotengine/godot/issues/18171#issuecomment-383058814
CMD xvfb-run -a -n 55 -s "-screen 0 1400x900x24 -ac +extension GLX +render -noreset" ./headless --audio-driver Dummy --display-driver headless
EXPOSE 4347
