export LLAMA_DIR=/models/Llama-3.1-70B-Instruct

CON="1 2 4 8 16 32 64"
backend="vllm"

date=$(date +"%Y-%m-%d")
LOG="temp"
LOG_sum="benchmark_sharegpt_${backend}_${date}"

printf "%-15s" prompts                 2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" isl                     2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" osl                     2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" con                     2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" req_throughput          2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" median_e2e              2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" median_ttft             2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" median_tpot             2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" median_itl              2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" output_tps              2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" total_tps               2>&1 | tee -a ${LOG_sum}.log
printf "\n"                            2>&1 | tee -a ${LOG_sum}.log

for con in $CON; do
    prompts=$((2 * $con))

    echo "[RUNNING] prompts $prompts isl $isl osl $osl con $con"
    python3 /app/vllm/benchmarks/benchmark_serving.py \
        --model $LLAMA_DIR \
        --dataset-name sharegpt \
        --dataset-path ./ShareGPT_V3_unfiltered_cleaned_split.json \
        --num-prompts $prompts \
        --max-concurrency $con \
        --port 8000 \
	    --ignore-eos \
        --percentile-metrics ttft,tpot,itl,e2el \
        2>&1 | tee ${LOG}.log

    rTh=$(grep -E "Request throughput" ${LOG}.log)
    e2eLat=$(grep -E "Median E2EL" ${LOG}.log)
    ttftLat=$(grep -E "Median TTFT" ${LOG}.log)
    tpotLat=$(grep -E "Median TPOT" ${LOG}.log)
    itlLat=$(grep -E "Median ITL" ${LOG}.log)
    outTh=$(grep -E "Output token throughput" ${LOG}.log)
    totTh=$(grep -E "Total Token throughput" ${LOG}.log)

    rTh_sp=(${rTh//:/ })
    e2eLat_sp=(${e2eLat//:/ })
    ttftLat_sp=(${ttftLat//:/ })
    tpotLat_sp=(${tpotLat//:/ })
    itlLat_sp=(${itlLat//:/ })
    outTh_sp=(${outTh//:/ })
    totTh_sp=(${totTh//:/ })

    rTh_val=${rTh_sp[3]}
    e2eLat_val=${e2eLat_sp[3]}
    ttftLat_val=${ttftLat_sp[3]}
    tpotLat_val=${tpotLat_sp[3]}
    itlLat_val=${itlLat_sp[3]}
    outTh_val=${outTh_sp[4]}
    totTh_val=${totTh_sp[4]}

    printf "%-15s" $prompts        2>&1 | tee -a ${LOG_sum}.log
    printf "%-15s" $isl            2>&1 | tee -a ${LOG_sum}.log
    printf "%-15s" $osl            2>&1 | tee -a ${LOG_sum}.log
    printf "%-15s" $con            2>&1 | tee -a ${LOG_sum}.log
    printf "%-15s" $rTh_val        2>&1 | tee -a ${LOG_sum}.log
    printf "%-15s" $e2eLat_val     2>&1 | tee -a ${LOG_sum}.log
    printf "%-15s" $ttftLat_val    2>&1 | tee -a ${LOG_sum}.log
    printf "%-15s" $tpotLat_val    2>&1 | tee -a ${LOG_sum}.log
    printf "%-15s" $itlLat_val     2>&1 | tee -a ${LOG_sum}.log
    printf "%-15s" $outTh_val      2>&1 | tee -a ${LOG_sum}.log
    printf "%-15s" $totTh_val      2>&1 | tee -a ${LOG_sum}.log
    printf "\n"                    2>&1 | tee -a ${LOG_sum}.log
done
