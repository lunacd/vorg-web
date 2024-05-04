FROM docker.io/debian:bookworm

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && \
    apt-get install -y curl zip

# Install bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="${PATH}:/root/.bun/bin"

# Install dependencies
COPY package.json package.json
RUN bun install

# Copy source
WORKDIR /workdir/
COPY tsconfig.json tailwind.config.ts postcss.config.js next.config.mjs ./
COPY src src

# Build frontend
RUN bun run build

FROM docker.io/nginx:latest

COPY --from=0 /workdir/out /public
COPY nginx.conf /etc/nginx/sites-available/vorg
RUN mkdir /etc/nginx/sites-enabled && \
    ln -s /etc/nginx/sites-available/vorg /etc/nginx/sites-enabled/

CMD ["nginx", "-g", "daemon off;"]
