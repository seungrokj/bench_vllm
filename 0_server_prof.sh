export LLAMA_DIR=/models/Llama-3.1-70B-Instruct

HSA_NO_SCRATCH_RECLAIM=1 VLLM_USE_V1=1 VLLM_WORKER_MULTIPROC_METHOD=spawn SAFETENSORS_FAST_GPU=1  VLLM_TORCH_PROFILER_DIR=./vllm_mi300x_random_req64_con64_isl1000_osl10_HSA vllm serve $LLAMA_DIR \
     --tensor-parallel-size 8 \
     --gpu-memory-utilization 0.9 \
     --disable-log-requests \
     --swap-space 16 \
     --no-enable-prefix-caching \
     --max-num-batched-tokens 8192 \
     --max-num-seqs 1024 
