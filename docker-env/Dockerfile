FROM debian:8
ADD . /dpmd_build
RUN /dpmd_build/install.sh
ENTRYPOINT ["/sbin/inithostmount"]
