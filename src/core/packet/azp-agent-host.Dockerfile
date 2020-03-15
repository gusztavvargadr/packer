ARG AZP_AGENT_HOST_OS
ARG AZP_AGENT_HOST_VERSION

FROM gusztavvargadr/packet-sample-device-${AZP_AGENT_HOST_OS}:${AZP_AGENT_HOST_VERSION}

ADD ./azp-agent-host.entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
