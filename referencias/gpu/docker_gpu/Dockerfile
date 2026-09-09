FROM nvidia/cuda:11.0-base-ubuntu20.04

ENV DEBIAN_FRONTEND noninteractive

#set up environment
RUN apt-get update && apt-get install --no-install-recommends --no-install-suggests -y curl apt-utils
RUN apt-get install unzip
RUN apt-get -y install python3
RUN apt-get -y install python3-pip

RUN pip3 install numpy 
RUN pip3 install numba

# copy the content of the local src directory to the working directory
COPY src/ /src/

WORKDIR /src

CMD ["python3", "test.py"]
