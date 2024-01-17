def filter_file(input_file, output_file, target_word):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            if target_word in line:
                outfile.write(line)

# Example usage:
input_filename = 'fault_report.txt'  # Replace with your input file name
output_filename = 'fault_undetected.txt'  # Replace with your output file name
specific_word = 'UNDETECTED'  # Replace with the word you want to keep in each line

filter_file(input_filename, output_filename, specific_word)