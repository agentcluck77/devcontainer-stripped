ARG BASE_IMAGE=ghcr.io/agentcluck77/devcontainer-stripped-makers-gpu-cudatoolkit:main
FROM ${BASE_IMAGE}

USER root

ARG LLAMA_CPP_REPO=https://github.com/ggml-org/llama.cpp.git
ARG LLAMA_CPP_REF=master
ARG LLAMA_CPP_DIR=/opt/llama.cpp

RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    ninja-build \
    pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    rm -rf "${LLAMA_CPP_DIR}"; \
    git clone --depth 1 --branch "${LLAMA_CPP_REF}" "${LLAMA_CPP_REPO}" "${LLAMA_CPP_DIR}"; \
    cuda_stub_dir=""; \
    for candidate in /usr/local/cuda/lib64/stubs /usr/local/cuda/targets/x86_64-linux/lib/stubs; do \
      if [ -f "${candidate}/libcuda.so" ]; then \
        cuda_stub_dir="${candidate}"; \
        break; \
      fi; \
    done; \
    if [ -z "${cuda_stub_dir}" ]; then \
      echo "CUDA driver stub libcuda.so not found" >&2; \
      exit 1; \
    fi; \
    ln -sf "${cuda_stub_dir}/libcuda.so" "${cuda_stub_dir}/libcuda.so.1"; \
    export LIBRARY_PATH="${cuda_stub_dir}:${LIBRARY_PATH:-}"; \
    export LD_LIBRARY_PATH="${cuda_stub_dir}:${LD_LIBRARY_PATH:-}"; \
    cmake -S "${LLAMA_CPP_DIR}" -B "${LLAMA_CPP_DIR}/build" \
      -G Ninja \
      -DGGML_CUDA=ON \
      -DGGML_NATIVE=OFF \
      -DLLAMA_BUILD_TESTS=OFF \
      -DGGML_BUILD_TESTS=OFF \
      -DCUDAToolkit_ROOT=/usr/local/cuda \
      -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath-link,${cuda_stub_dir}" \
      -DCMAKE_SHARED_LINKER_FLAGS="-Wl,-rpath-link,${cuda_stub_dir}" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_C_COMPILER=/usr/bin/cc \
      -DCMAKE_CXX_COMPILER=/usr/bin/c++; \
    cmake --build "${LLAMA_CPP_DIR}/build" --config Release -j"$(nproc)"; \
    for binary in "${LLAMA_CPP_DIR}"/build/bin/llama-*; do \
      if [ -x "${binary}" ]; then \
        install -m 0755 "${binary}" /usr/local/bin/; \
      fi; \
    done; \
    chown -R dev-user:dev-user "${LLAMA_CPP_DIR}"

ENV LLAMA_CPP_HOME=/opt/llama.cpp

USER dev-user
