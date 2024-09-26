
source $(conda info --base)/etc/profile.d/conda.sh

conda init bash
# activate conda environment
conda activate /scratch/fs47816/workdir/bioinformatics/cdhit/cdhit_conda_env

# Specify the directory to search
dir_path="/work/tdmlab/codeathon_resources/pseudofinder_output"

# Output file
output_file="combined_sequences.fasta"

# Create or clear the output file within the script
> $output_file

# Loop through all subdirectories in the specified directory and concatenate *_pseudos.fasta files
find "$dir_path" -type f -name "*_pseudos.fasta" -exec cat {} >> $output_file \;

echo "All *_pseudos.fasta files from $dir_path have been concatenated into $output_file"

# run cd-hit-est
cd-hit-est -i ./combined_sequences.fasta -o clustered_output.fasta -c 0.95 -n 8 -T 0 -M 0

# presence absence output
python scripts/presence_absence_util.py
