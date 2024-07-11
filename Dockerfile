# Use an intermediate image to build samtools
FROM debian:bullseye-slim AS builder

RUN apt-get update && \
   apt-get install -y upx-ucl git libbrotli-dev liblzma-dev libbz2-dev make gcc zlib1g-dev libssl-dev libcurl4-openssl-dev binutils make csh g++ sed gawk autoconf automake autotools-dev libncurses5-dev

# clone samtools and htslib
RUN git clone https://github.com/samtools/samtools.git && \
   cd samtools && \
   git clone https://github.com/samtools/htslib.git && \
   cd htslib && \
   git submodule update --init --recursive && \
   autoreconf && \
   ./configure && \
   make -j && \
   cd .. && \
   autoreconf &&\
   ./configure && \
   make -j && \
   for LIB in $(ldd samtools | awk '{if (match($3,"/")){ print $3 }}'); do  LIB_NAME=$(basename "$LIB") cp "$LIB" "./$LIB_NAME"; done && \
   strip samtools && \
   strip *.so* && \
   upx samtools  
   
   

# Use a distroless base image
FROM gcr.io/distroless/base

# Copy the samtools binary from the builder image
COPY --from=builder /samtools/samtools /usr/local/bin/samtools
# Copy the shared libraries from the builder image
COPY --from=builder /samtools/libssh2.so.1 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libncursesw.so.6 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/librtmp.so.1 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libz.so.1 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libidn2.so.0 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/liblzma.so.5 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libbz2.so.1.0 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libcurl.so.4 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libtinfo.so.6 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libnghttp2.so.14 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libpsl.so.5 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libgssapi_krb5.so.2 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libldap_r-2.4.so.2 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/liblber-2.4.so.2 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libbrotlidec.so.1 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libunistring.so.2 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libgnutls.so.30 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libhogweed.so.6 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libnettle.so.8 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libgmp.so.10 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libgcrypt.so.20 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libkrb5.so.3 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libk5crypto.so.3 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libcom_err.so.2 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libkrb5support.so.0 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libresolv.so.2 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libsasl2.so.2 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libbrotlicommon.so.1 /lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libp11-kit.so.0 /usr/lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libtasn1.so.6 /usr/lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libgpg-error.so.0 /usr/lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libkeyutils.so.1 /usr/lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libffi.so.7 /usr/lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libcrypto.so.1.1 /usr/lib/x86_64-linux-gnu/
COPY --from=builder /samtools/libssl.so.1.1 /usr/lib/x86_64-linux-gnu/



# Set the entrypoint to the samtools binary
ENTRYPOINT ["/usr/local/bin/samtools"]
