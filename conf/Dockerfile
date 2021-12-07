FROM alpine

# Copy entrypoint scripts to the container and 
COPY image/entrypoint /opt/entrypoint
RUN chmod 755 -R /opt/entrypoint/*

# Container entrypoint
ENTRYPOINT [ "/opt/entrypoint/entrypoint.sh" ]
