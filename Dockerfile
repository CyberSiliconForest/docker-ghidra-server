FROM openjdk:17-jdk-slim

ENV GHIDRA_VERSION 10.2.3
ENV GHIDRA_FLAVOR PUBLIC
ENV GHIDRA_BUILDDATE 20230208
ENV GHIDRA_SHA daf4d85ec1a8ca55bf766e97ec43a14b519cbd1060168e4ec45d429d23c31c38

ENV DL https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${GHIDRA_VERSION}_build/ghidra_${GHIDRA_VERSION}_${GHIDRA_FLAVOR}_${GHIDRA_BUILDDATE}.zip


# Install tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

RUN apt-get update && apt-get install -y wget unzip dnsutils --no-install-recommends \
    && wget --progress=bar:force -O /tmp/ghidra.zip ${DL} \
    && echo "$GHIDRA_SHA /tmp/ghidra.zip" | sha256sum -c - \
    && unzip /tmp/ghidra.zip \
    && mv ghidra_${GHIDRA_VERSION}_${GHIDRA_FLAVOR} /ghidra \
    && chmod +x /ghidra/ghidraRun \
    && echo "===> Clean up unnecessary files..." \
    && apt-get purge -y --auto-remove wget unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives /tmp/* /var/tmp/* /ghidra/docs /ghidra/Extensions/Eclipse /ghidra/licenses

WORKDIR /ghidra

COPY entrypoint.sh /entrypoint.sh
COPY certificate.sh /ghidra/server/certificate.sh
COPY server.conf /ghidra/server/server.conf
COPY jaas.conf.template /ghidra/server/jaas.conf.template

EXPOSE 13100 13101 13102

RUN mkdir /repos
RUN mkdir /certs

ENTRYPOINT ["/tini", "--", "/entrypoint.sh"]
CMD ["server"]
