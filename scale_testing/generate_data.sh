#!/bin/bash

# Function to create directories if they don't exist
create_directories() {
    mkdir -p csv parquet/uncompressed parquet/compressed
}

# Function to generate data and save in different formats
generate_data() {
    local num_records=$1
    local output_prefix=$2

    # DuckDB query to generate random data
    duckdb -c "
    CREATE TABLE random_data AS 
    SELECT 
        random() * 180 - 90 AS lat,
        random() * 360 - 180 AS lon,
        random() * 1000 AS random_number1,
        random() * 100 AS random_number2,
        chr(65 + (random() * 26)::INTEGER) || chr(65 + (random() * 26)::INTEGER) || chr(65 + (random() * 26)::INTEGER) AS random_string1,
        chr(97 + (random() * 26)::INTEGER) || chr(97 + (random() * 26)::INTEGER) || chr(97 + (random() * 26)::INTEGER) AS random_string2
    FROM range($num_records);

    -- Export as CSV
    COPY random_data TO 'csv/${output_prefix}.csv' (HEADER, DELIMITER ',');

    -- Export as uncompressed Parquet
    COPY random_data TO 'parquet/uncompressed/${output_prefix}.parquet' (FORMAT PARQUET);

    -- Export as compressed Parquet
    COPY random_data TO 'parquet/compressed/${output_prefix}.parquet' (FORMAT PARQUET, CODEC 'ZSTD');

    DROP TABLE random_data;
    "

    echo "Generated $num_records records in csv/${output_prefix}.csv, parquet/uncompressed/${output_prefix}.parquet, and parquet/compressed/${output_prefix}.parquet"
}

# Create directories
create_directories

# Array of dataset sizes
sizes=(10000 100000 1000000 10000000 50000000)

# Generate datasets for each size
for size in "${sizes[@]}"; do
    generate_data $size "random_data_${size}"
done

echo "All datasets generated successfully!"