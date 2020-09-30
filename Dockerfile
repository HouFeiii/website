FROM cm2network/csgo

ENV METAMOD_VERSION 1.10
ENV SOURCEMOD_VERSION 1.10
ENV NANNYURL \
https://gzzhangjieke:2fb90b400ea8c2c321adf39dfa60494b3ebc1f98@nanny.netease.com/gzzhangjieke/csgo-comm-server/raw/master/entry.sh

ENV SOURCEMOD_ADMIN=""


RUN set -x \
		&& cd "${HOMEDIR}"\
		&& rm -f "${HOMEDIR}/entry.sh"\
		&& wget "${NANNYURL}"\
		&& chmod +x "${HOMEDIR}/entry.sh"\
		&& rm -fr csgo-comm-server\
