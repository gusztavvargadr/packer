FROM library/consul:1.8.0

ADD ./consul.agent.hcl /consul/config/agent.hcl

ENV CONSUL_DISABLE_PERM_MGMT=

CMD [ "agent" ]
