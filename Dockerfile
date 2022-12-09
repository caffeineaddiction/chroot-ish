FROM alpine:3.17 AS build
RUN set -eux; \
  apk add --no-cache \
  bash \
  gcc \
  linux-headers \
  make \
  musl-dev \
  openssh ;

WORKDIR /toybox

# https://landley.net/toybox/downloads/?C=M;O=D
# https://github.com/landley/toybox/releases
ENV TOYBOX_VERSION 0.8.8

RUN set -eux; \
  wget -O toybox.tgz "https://landley.net/toybox/downloads/toybox-$TOYBOX_VERSION.tar.gz"; \
  tar -xf toybox.tgz --strip-components=1; \
  rm toybox.tgz

RUN make root BUILTIN=1
# (we set "BUILTIN=1" to avoid cpio / initramfs creation because we aren't building / don't need a kernel)

RUN mkdir -p /toybox/root/host/fs/usr/lib/ssh && \
  cp /usr/bin/scp /toybox/root/host/fs/usr/bin/ && \
  cp /usr/lib/ssh/sftp-server /toybox/root/host/fs/usr/lib/ssh/ && \
  ln -sf ./ssh /toybox/root/host/fs/usr/lib/openssh && \
  cp -R /usr/lib/bash /toybox/root/host/fs/usr/lib/ && \
  cp /lib/ld-musl-x86_64.so.1 /toybox/root/host/fs/usr/lib/ && \
  cp /usr/lib/libformw.so.6.3 /toybox/root/host/fs/usr/lib/ && \
  cp /usr/lib/libmenuw.so.6.3 /toybox/root/host/fs/usr/lib/ && \
  cp /usr/lib/libncursesw.so.6.3 /toybox/root/host/fs/usr/lib/ && \
  cp /usr/lib/libpanelw.so.6.3 /toybox/root/host/fs/usr/lib/ && \
  cp /usr/lib/libreadline.so.8.2 /toybox/root/host/fs/usr/lib/ && \
  ln -sf ./libreadline.so.8.2 /toybox/root/host/fs/usr/lib/libreadline.so.8 && \
  ln -sf ./libncursesw.so.6.3 /toybox/root/host/fs/usr/lib/libncursesw.so.6 && \
  rm /toybox/root/host/fs/usr/bin/bash && \
  cp /bin/bash /toybox/root/host/fs/usr/bin/ && \
  cp /etc/inputrc /toybox/root/host/fs/etc/ && \
  cp -R /etc/bash /toybox/root/host/fs/etc/ && \
  cp -R /etc/terminfo /toybox/root/host/fs/etc/

FROM scratch
COPY --from=build /toybox/root/host/fs/ /
CMD ["bash"]

