import pandas as pd

def parse_clstr(clstr_file):
    clusters = {}
    with open(clstr_file, 'r') as file:
        cluster_id = None
        for line in file:
            if line.startswith(">Cluster"):
                cluster_id = line.strip().split()[-1]  # Get the cluster number
                clusters[cluster_id] = []
            else:
                sequence_id = line.split(">")[1].split("...")[0]  # Extract sequence name
                clusters[cluster_id].append(sequence_id)
    return clusters

def create_presence_absence_matrix(clusters):
    # Extract all unique sequences
    sequences = sorted(set(seq for cl in clusters.values() for seq in cl))
    
    # Create DataFrame with sequences as rows and clusters as columns
    matrix = pd.DataFrame(0, index=sequences, columns=[f"Cluster {cl}" for cl in clusters])
    
    # Fill the matrix with 1 where sequence is present in a cluster
    for cl, seqs in clusters.items():
        for seq in seqs:
            matrix.at[seq, f"Cluster {cl}"] = 1
    
    return matrix

# Load the .clstr file
clstr_file = "clustered_output.fasta.clstr"  # Path to your .clstr file
clusters = parse_clstr(clstr_file)

# Create the presence-absence matrix
matrix = create_presence_absence_matrix(clusters)

# Export to .tsv file
output_file = "presence_absence_matrix.tsv"
matrix.to_csv(output_file, sep='\t')

print(f"Presence-absence matrix saved to {output_file}")

