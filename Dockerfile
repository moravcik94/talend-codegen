#################################################################
# Dockerfile to build image for running Talend Open Studio 7.1.1
#################################################################

FROM ubuntu:18.04
MAINTAINER AODN

# Install Java 8.
RUN \
  apt-get update && \
  apt-get install -y openjdk-8-jdk && \
  rm -rf /var/lib/apt/lists/*

# Install curl and unzip
RUN \
  apt-get update && \
  apt-get install -y curl && \
  apt-get install -y unzip && \
  rm -rf /var/lib/apt/lists/*

# Download and install Talend Open Studio in /opt
RUN mkdir -p /opt \
  && cd /tmp \
  && curl -SL https://s3-ap-southeast-2.amazonaws.com/imos-binary/static/talend/TOS_DI-20181026_1147-V7.1.1.zip -O \
  && unzip -d /opt /tmp/TOS_DI-20181026_1147-V7.1.1.zip \
  && rm /tmp/TOS_DI-20181026_1147-V7.1.1.zip

# Download and install TOS SDI
RUN cd /tmp \
  && curl -SL https://s3-ap-southeast-2.amazonaws.com/imos-binary/static/talend/TOS-Spatial-7.1.1-patch.zip -O \
  && unzip -d /tmp /tmp/TOS-Spatial-7.1.1-patch.zip \
  && cp -r /tmp/target/TOS-Spatial-7.1.1/plugins/* /opt/TOS_DI-20181026_1147-V7.1.1/plugins \
  && rm -rf /tmp/TOS-Spatial-7.1.1-patch.zip /tmp/target

# Download and install xulrunner in /opt
RUN cd /tmp \
  && curl -SL http://ftp.mozilla.org/pub/xulrunner/nightly/2012/03/2012-03-02-03-32-11-mozilla-1.9.2/xulrunner-1.9.2.28pre.en-US.linux-i686.tar.bz2 -O \
  && tar xj -C /opt -f /tmp/xulrunner-1.9.2.28pre.en-US.linux-i686.tar.bz2 \
  && rm /tmp/xulrunner-1.9.2.28pre.en-US.linux-i686.tar.bz2

# Download and install talend maven repo
RUN cd /tmp \
  && curl -SL  https://s3-ap-southeast-2.amazonaws.com/imos-binary/static/talend/talend-maven-repo.zip -O \
  && mkdir -p /opt/TOS_DI-20181026_1147-V7.1.1/configuration/.m2 \
  && unzip -d /opt/TOS_DI-20181026_1147-V7.1.1/configuration/.m2 /tmp/talend-maven-repo.zip \
  && rm /tmp/talend-maven-repo.zip

# Install libcanberra-gtk
RUN \
  apt-get update && \
  apt-get install -y libcanberra-gtk-module && \
  rm -rf /var/lib/apt/lists/*

# Install xulrunner
RUN cd /tmp \
  && curl -SL http://ftp.mozilla.org/pub/xulrunner/nightly/2012/03/2012-03-02-03-32-11-mozilla-1.9.2/xulrunner-1.9.2.28pre.en-US.linux-i686.tar.bz2 -O \
  && tar xj -C /opt -f /tmp/xulrunner-1.9.2.28pre.en-US.linux-i686.tar.bz2 \
  && rm /tmp/xulrunner-1.9.2.28pre.en-US.linux-i686.tar.bz2

# Install required SWT libraries for running TOS
RUN \
  apt-get update && \
  apt-get install -y libswt-gtk-3-jni libswt-gtk-3-java && \
  rm -rf /var/lib/apt/lists/*

# Install firefox
RUN \
  apt-get update && \
  apt-get install -y firefox && \
  rm -rf /var/lib/apt/lists/*

# Configure Talend to use xulrunner
RUN \
  echo "\n-Dorg.eclipse.swt.browser.XULRunnerPath=/opt/xulrunner" \
  >> /opt/TOS_DI-20181026_1147-V7.1.1/TOS_DI-linux-gtk-x86_64.ini

# Install code generator plugin
COPY target/au.org.emii.talend.codegen-7.1.1.jar /opt/TOS_DI-20181026_1147-V7.1.1/plugins

# Add JAVA_HOME and add to path as required by TOS
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH $JAVA_HOME/bin:$PATH

# Default workspace to installed workspace (empty)

ENV TALEND_WORKSPACE /workspace

COPY files/* /opt/TOS_DI-20181026_1147-V7.1.1/
RUN chmod +x /opt/TOS_DI-20181026_1147-V7.1.1/*.sh

WORKDIR /opt/TOS_DI-20181026_1147-V7.1.1
ENTRYPOINT ["/bin/bash"]

