FROM naspeh/base
MAINTAINER Grisha Kostyuk "naspeh@gmail.com"

ENV PACMAN pacman --noconfirm --noprogressbar

RUN $PACMAN -Sy \
    sudo zsh git openssh supervisor \
    python python2 python-virtualenv python-requests

ADD pkgs /pkgs
RUN $PACMAN -U /pkgs/vim*

RUN rm -rf /pkgs /var/cache/pacman/pkg/*

RUN cd /home/ && git clone https://github.com/naspeh/dotfiles.git
RUN sudo /home/dotfiles/manage.py init --boot zsh bin vim dev

RUN chsh -s /bin/zsh

RUN ssh-keygen -A
RUN sed -i \
    -e 's/^#*\(PermitRootLogin\) .*/\1 yes/' \
    -e 's/^#*\(PasswordAuthentication\) .*/\1 yes/' \
    -e 's/^#*\(PermitEmptyPasswords\) .*/\1 yes/' \
    -e 's/^#*\(UsePAM\) .*/\1 no/' \
    /etc/ssh/sshd_config

ADD supervisord.conf /etc/supervisord.conf

EXPOSE 22
VOLUME /var/log/supervisor
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
