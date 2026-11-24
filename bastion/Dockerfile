FROM alpine:3.20

RUN apk add --no-cache openssh-server openssh-client bash curl && \
    ssh-keygen -A && \
    adduser -D -s /bin/bash adminuser && \
    echo "adminuser:BastionPass123!" | chpasswd && \
    sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/' /etc/ssh/sshd_config

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D", "-e"]