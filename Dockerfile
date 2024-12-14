# Stage 1: Build
FROM --platform=amd64 alpine:3.21 as builder
WORKDIR /app

RUN wget -O zig-linux-x86_64.tar.xz https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz \
    && tar -xf ./zig-linux-x86_64.tar.xz \
    && mv ./zig-linux-x86_64*/* /app

COPY ["./build.zig", "./build.zig.zon", "/app/"]
COPY ./src /app/src
RUN /app/zig build -Doptimize=ReleaseSafe
# RUN /app/zig build -Doptimize=ReleaseSmall

# Stage 2: Production
# Either of them are Ok to use
# FROM alpine:3.21
FROM gcr.io/distroless/cc
COPY --from=builder /app/zig-out/bin/neal /
CMD [ "./neal" ]

