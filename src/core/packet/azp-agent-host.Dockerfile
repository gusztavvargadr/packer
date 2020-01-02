ARG AZP_AGENT_HOST_OS

FROM docker.pkg.github.com/gusztavvargadr/packet/sample-device-${AZP_AGENT_HOST_OS}:latest

ADD ./azp-agent-host.entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
