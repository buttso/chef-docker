#
# Dockerfile for Chef Environment
# 

FROM ubuntu

MAINTAINER Steve Button <steve.button@oracle.com>

ENV	DEBIAN_FRONTEND noninteractive

RUN	apt-get update
RUN	apt-get install -yq wget
RUN	apt-get install -yq curl
RUN apt-get install -yq git

RUN wget https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_0.3.5-1_amd64.deb
RUN	dpkg -i chefdk*.deb
#RUN chef verify	
RUN echo 'eval "$(chef shell-init bash)"' >> ~/.bash_profile
RUN echo 'eval "$(chef shell-init bash)"' >> ~/.bashrc

RUN mkdir /u01
RUN chmod a+x /u01
RUN chmod a+r /u01

RUN useradd -b /u01 -m -s /bin/bash oracle
RUN echo oracle:welcome1 | chpasswd
RUN chown oracle:oracle -R /u01

RUN usermod -a -G sudo oracle

WORKDIR /u01/oracle
USER oracle
#RUN echo 'eval "$(chef shell-init bash)"' >> ~/.bash_profile
RUN echo 'eval "$(chef shell-init bash)"' >> ~/.bashrc

RUN cd /u01/oracle
RUN git clone git://github.com/opscode/chef-repo.git
RUN mkdir -p ~/chef-repo/.chef
RUN echo '.chef' >> ~/chef-repo/.gitignore
#RUN echo 'export PATH="/opt/chefdk/embedded/bin:$PATH"' >> ~/.bash_profile
RUN echo 'export PATH="/opt/chefdk/embedded/bin:$PATH"' >> ~/.bashrc
RUN . ~/.bashrc
RUN knife cookbook site download java
RUN knife cookbook site download weblogic
RUN chef generate template wls-steve index.html

RUN tar xvf weblogic-0.1.6.tar.gz -C /u01/oracle/chef-repo/cookbooks
RUN tar xvf java-*.tar.gz -C /u01/oracle/chef-repo/cookbooks

CMD	["/bin/bash"]






