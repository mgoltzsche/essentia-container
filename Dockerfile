# Build build base image
FROM python:3-alpine3.19 AS buildbase
RUN apk add --update --no-cache git g++ pkgconf musl-dev qtchooser qt5-qtbase-dev eigen-dev yaml-dev

# Build Gaia
FROM buildbase AS gaia
RUN apk add --update --no-cache swig
# Gaia 2.4.6 + patches from master (python 3 support) from 2022
ARG GAIA_VERSION=0d0942bf4748b40069977702715454ae084063c9
RUN set -eux; \
	git clone -q https://github.com/MTG/gaia.git /gaia-src; \
	cd /gaia-src; \
	git checkout $GAIA_VERSION
WORKDIR /gaia-src
RUN set -eux; \
	[ ! `uname -m` = aarch64 ] || sed -i '/sse2/d' wscript; \
	./waf configure; \
	./waf; \
	./waf install --destdir /gaia

# Build essentia library and example extractors
FROM buildbase AS essentia
RUN apk add --update --no-cache fftw-dev ffmpeg4-dev libsamplerate-dev taglib-dev chromaprint-dev
COPY --from=gaia /gaia /
#ARG ESSENTIA_VERSION=v2.1_beta5
#RUN git clone -q --branch $ESSENTIA_VERSION --depth=1 https://github.com/MTG/essentia.git /essentia-src
ARG ESSENTIA_VERSION=95c996e312ad6de0530bc43772ee1677d9e738c7
RUN set -eux; \
	git clone -q https://github.com/MTG/essentia.git /essentia-src; \
	cd /essentia-src; \
	git checkout $ESSENTIA_VERSION
WORKDIR /essentia-src
RUN set -eux; \
	./waf configure --build-static --with-gaia --with-examples; \
	./waf; \
	./waf install --destdir /essentia

# Download SVM models
FROM alpine:3.19 AS models
ARG ESSENTIA_MODEL_VERSION=v2.1_beta5
RUN set -eux; \
	mkdir -p /tmp/svm-models; \
	wget -qO - https://essentia.upf.edu/svm_models/essentia-extractor-svm_models-${ESSENTIA_MODEL_VERSION}.tar.gz | tar -C /tmp/svm-models -xzf -; \
	mv /tmp/svm-models/essentia-extractor-svm_models-$ESSENTIA_MODEL_VERSION /svm-models

# Build container image without build dependencies
FROM alpine:3.19 AS final
RUN apk add --update --no-cache qt5-qtbase yaml fftw taglib libsamplerate \
	ffmpeg4 ffmpeg4-libavcodec ffmpeg4-libavformat ffmpeg4-libavutil \
	ffmpeg4-libswresample \
	chromaprint
COPY --from=essentia /essentia /
COPY --from=models /svm-models /var/lib/essentia/svm-models/beta5
COPY profile.yaml /etc/essentia/

# Verify that all libraries are linked without adding another image layer
FROM final
RUN ldd /usr/local/bin/essentia_streaming_extractor_music

FROM final
