#
# Dockerfile for Chef 4 WLS Environment 
# 

FROM ubuntu

MAINTAINER Steve Button <steve.button@oracle.com>

ENV	DEBIAN_FRONTEND noninteractive

# Install Utilities
RUN	apt-get update
RUN	apt-get install -yq wget
RUN	apt-get install -yq curl
RUN apt-get install -yq git

# Install Chef
RUN wget https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_0.3.5-1_amd64.deb
RUN	dpkg -i chefdk*.deb

# Verify and Setup Chef
RUN chef verify	
RUN echo 'eval "$(chef shell-init bash)"' >> ~/.bash_profile
RUN echo 'eval "$(chef shell-init bash)"' >> ~/.bashrc

# Create Directory Layout
RUN mkdir /u01
RUN chmod a+x /u01
RUN chmod a+r /u01

#Create User
RUN useradd -b /u01 -m -s /bin/bash oracle
RUN echo oracle:welcome1 | chpasswd
RUN chown oracle:oracle -R /u01

RUN usermod -a -G sudo oracle

# Setup Oracle User
WORKDIR /u01/oracle
USER oracle
RUN echo 'eval "$(chef shell-init bash)"' >> ~/.bash_profile
RUN echo 'eval "$(chef shell-init bash)"' >> ~/.bashrc
RUN . ~/.bashrc

# Setup Git Config
RUN git config --global user.email "me@you.com"
RUN git config --global user.name "Me Me"

# Setup Local Chef-Repo
RUN cd /u01/oracle
RUN git clone git://github.com/opscode/chef-repo.git
RUN mkdir -p ~/chef-repo/.chef
RUN echo 'export PATH="/opt/chefdk/embedded/bin:$PATH"' >> ~/.bashrc
RUN . ~/.bashrc

# Don't need 'java' as its included by 'weblogic'
#RUN knife cookbook site install java -o /u01/oracle/chef-repo/cookbooks
RUN knife cookbook site install weblogic  -o /u01/oracle/chef-repo/cookbooks

# Generate a cookcook for wls-dev and add my local recipes, attributes
#RUN cd /u01/oracle/chef-repo/cookbooks; chef generate cookbook wls-dev; cd ~
#ADD cookbooks/wls-dev/recipes/*.rb /u01/oracle/chef-repo/cookbooks/wls-dev/recipes
#ADD cookbooks/wls-dev/attributes/*.rb /u01/oracle/chef-repo/cookbooks/wls-dev/attributes
ADD cookbooks/wls-dev /u01/oracle/chef-repo/cookbooks/wls-dev

# The default command to run when the container starts
CMD	["/bin/bash"]






