FROM public.ecr.aws/x8v8d7g8/mars-base:latest

ENV PATH="/root/.local/bin:${PATH}"
ENV UV_HTTP_TIMEOUT=300

WORKDIR /app

RUN uv pip install --system --no-cache \
    annotated-types==0.7.0 \
    anyio==4.13.0 \
    attrs==26.1.0 \
    certifi==2026.5.20 \
    cffi==2.0.0 \
    charset-normalizer==3.4.7 \
    click==8.4.1 \
    cryptography==48.0.0 \
    distro==1.9.0 \
    google-auth==2.53.0 \
    google-genai==2.8.0 \
    h11==0.16.0 \
    httpcore==1.0.9 \
    httpx==0.28.1 \
    httpx-sse==0.4.3 \
    idna==3.18 \
    iniconfig==2.3.0 \
    jiter==0.15.0 \
    jsonschema==4.26.0 \
    jsonschema-specifications==2025.9.1 \
    mcp==1.27.2 \
    openai==2.41.0 \
    packaging==26.2 \
    pluggy==1.6.0 \
    pyasn1==0.6.3 \
    pyasn1-modules==0.4.2 \
    pycparser==3.0 \
    pydantic==2.13.4 \
    pydantic-core==2.46.4 \
    pydantic-settings==2.14.1 \
    pygments==2.20.0 \
    pyjwt==2.13.0 \
    pytest==9.0.3 \
    pytest-asyncio==1.4.0 \
    pytest-mock==3.15.1 \
    python-dotenv==1.2.2 \
    python-multipart==0.0.32 \
    referencing==0.37.0 \
    requests==2.34.2 \
    rpds-py==2026.5.1 \
    sniffio==1.3.1 \
    sse-starlette==3.4.4 \
    starlette==1.2.1 \
    tenacity==9.1.4 \
    tqdm==4.68.0 \
    typing-extensions==4.15.0 \
    typing-inspection==0.4.2 \
    urllib3==2.7.0 \
    uvicorn==0.49.0 \
    websockets==16.0

COPY . .

RUN printf '%s\n' \
    '# Production image definition for PAL MCP Server.' \
    'FROM python:3.11-slim AS builder' \
    'WORKDIR /app' \
    'COPY requirements.txt ./' \
    'RUN python -m venv /opt/venv' \
    'ENV PATH="/opt/venv/bin:$PATH"' \
    'RUN pip install --no-cache-dir -r requirements.txt' \
    '' \
    'FROM python:3.11-slim AS runtime' \
    'RUN groupadd -r paluser && useradd -r -g paluser paluser' \
    'COPY --from=builder /opt/venv /opt/venv' \
    'ENV PATH="/opt/venv/bin:$PATH"' \
    'WORKDIR /app' \
    'COPY --chown=paluser:paluser . .' \
    'COPY --chown=paluser:paluser docker/scripts/healthcheck.py /usr/local/bin/healthcheck.py' \
    'RUN chmod +x /usr/local/bin/healthcheck.py' \
    'USER paluser' \
    'HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \' \
    '    CMD python /usr/local/bin/healthcheck.py' \
    'ENV PYTHONUNBUFFERED=1' \
    'ENV PYTHONPATH=/app' \
    'CMD ["python", "server.py"]' \
    > Dockerfile

ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

CMD ["/bin/bash"]
