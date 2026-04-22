FROM alpine

# Startup environment and configuration
WORKDIR /opt/scripts
COPY --chmod=755 image/scripts ./
COPY --chmod=755 image/entrypoint.sh /

WORKDIR /opt

# Container entrypoint
ENTRYPOINT [ "/entrypoint.sh" ]
