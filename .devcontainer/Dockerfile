FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

RUN curl -L -o typst.tar.xz https://github.com/typst/typst/releases/download/v0.14.2/typst-aarch64-unknown-linux-musl.tar.xz && \
    tar -xf typst.tar.xz && \
    mv typst-aarch64-unknown-linux-musl/typst /usr/local/bin/ && \
    rm typst.tar.xz && \
    rm -rf typst-aarch64-unknown-linux-musl

RUN curl -L -o typstyle https://github.com/typstyle-rs/typstyle/releases/download/v0.14.4/typstyle-aarch64-unknown-linux-gnu && \
    mv typstyle /usr/local/bin/

RUN chmod +x /usr/local/bin/typst /usr/local/bin/typstyle
