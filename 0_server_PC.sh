export LLAMA_DIR=/models/Llama-3.1-70B-Instruct

HSA_NO_SCRATCH_RECLAIM=1 VLLM_USE_V1=1 VLLM_WORKER_MULTIPROC_METHOD=spawn SAFETENSORS_FAST_GPU=1 vllm serve $LLAMA_DIR \
     --tensor-parallel-size 8 \
     --gpu-memory-utilization 0.9 \
     --disable-log-requests \
     --swap-space 16 \
     --max-num-batched-tokens 8192 \
     --max-num-seqs 1024 &

     #--no-enable-prefix-caching \
