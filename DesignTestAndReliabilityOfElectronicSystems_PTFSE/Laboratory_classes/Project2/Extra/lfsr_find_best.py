# Generate all possible seeds, in order to iterate over them later on
# Initial conditions inputs
primitive_inputs_seeds = [3, 0] # Primitive coefficients - do not place 5, não dá jeito no código, é simply saída do XOR
n_inputs = 5 # Number of inputs
x_inputs_seeds = [1, 1, 1, 1, 1] # Seed
x_n_inputs = 0 # Initial XOR value
list_seeds_inputs = [] # List for all possible seeds

# Initial conditions state
primitive_state_seeds = [2, 0]
n_state = 3
x_state_seeds = [1, 1, 1]
x_n_state = 0
list_seeds_state = []

for k in primitive_inputs_seeds:
    x_n_inputs = x_inputs_seeds[k]^x_n_inputs # Initial XOR

for k in primitive_state_seeds:
    x_n_state = x_state_seeds[k]^x_n_state

# Generate all possible seeds for inputs - stored in list_seeds_inputs
for i in  range(1, 2**n_inputs):
    for j in range(0, n_inputs-1):
        x_inputs_seeds[j] = x_inputs_seeds[j+1]
    x_inputs_seeds[n_inputs-1] = x_n_inputs
    x_n_inputs = 0
    for k in primitive_inputs_seeds:
        x_n_inputs = x_inputs_seeds[k]^x_n_inputs
    list_seeds_inputs.append(x_inputs_seeds.copy())

# Generate all possible seeds for state - stored in list_seeds_state
for i in  range(1, 2**n_state):
    for j in range(0, n_state-1):
        x_state_seeds[j] = x_state_seeds[j+1]
    x_state_seeds[n_state-1] = x_n_state
    x_n_state = 0
    for k in primitive_state_seeds:
        x_n_state = x_state_seeds[k]^x_n_state
    list_seeds_state.append(x_state_seeds.copy())

# ---------------------- Main part

# https://mathworld.wolfram.com/PrimitivePolynomial.html - all possible primitive polynomials
list_primitive_inputs = [[3, 0], [2, 0], [3, 2, 1, 0], [4, 3, 1, 0], [4, 3, 2, 0], [4, 2, 1, 0]] 
n_inputs = 5 # Number of bits in LFSR
bits_selected_inputs_list = [[1, 2, 3, 4], [0, 2, 3, 4], [0, 1, 3, 4], [0, 1, 2, 4], [0, 1, 2, 3]] # All possibilities of 4 bits to use for inputs

list_primitive_state = [[2, 0], [1, 0]]
n_state = 3
bit_select_state_list = [0, 1, 2] # All possibilities of 1 bit to use for state

# The bits of the inputs LFSR only need to change every 2 clocks, not every single clock, as opposed to the state
# Therefore, "rest" leads to updates in this LFSR only every 2 clocks, while the LFSR is constantly updated in "always"
control_variable_list = [0, 1] # [rest, always]

# In practice, we don't need the state 11, so the results are also obtained if we do not consider it 
discard_11_list = [0, 1] # [do not discard, discard]

# Store information for every case (list of lists)
# [Number of test vectors, Iteration, control_variable, discard_11, seed_state, seed_inputs, bit_select_state, bits_selected_inputs, primitive_state, primitive_inputs]
list_iterations_discard0 = []
list_iterations_discard1 = []

iteration = 1

print("\nRunning... (takes about 90 seconds)")
for primitive_inputs in list_primitive_inputs:
    for primitive_state in list_primitive_state:
        for bits_selected_inputs in bits_selected_inputs_list:
            for bit_select_state in bit_select_state_list:

                for seed_inputs in list_seeds_inputs:
                    x_inputs = seed_inputs.copy()
                    x_n_inputs = 0
                    for k in primitive_inputs:
                        x_n_inputs = x_inputs[k]^x_n_inputs # Initial XOR value
                    x_n_inputs_initial = x_n_inputs
                        
                    for seed_state in list_seeds_state:
                        x_state = seed_state.copy()
                        x_n_state = 0
                        for k in primitive_state:
                            x_n_state = x_state[k]^x_n_state # Initial XOR value
                        x_n_state_initial = x_n_state

                        for control_variable in control_variable_list:
                            for discard_11 in discard_11_list:

                                # Reinitialize stuff
                                x_inputs = seed_inputs.copy()
                                x_n_inputs = x_n_inputs_initial
                                x_state = seed_state.copy()
                                x_n_state = x_n_state_initial
                                list_possibilities_discard0 = [] # Store unique test vectors generated in each case
                                list_possibilities_discard1 = []

                                #for i in range(1, 2048): -> put less, otherwise very long simulation, bad solutions not needed anyways
                                for i in range(1, 400):
                    
                                    x_state_prev = x_state[bit_select_state] # Previous bit injected in scan

                                    # Update LFSR values
                                    # Example: x[0](t) = x[1](t-1), x[1] = x[2](t-1), ...
                                    if control_variable==1 or i%2==0:
                                        for j in range(0, n_inputs-1):
                                            x_inputs[j] = x_inputs[j+1]
                                    for j in range(0, n_state-1):
                                        x_state[j] = x_state[j+1]

                                    # Transfer XOR value to MSB
                                    if control_variable==1 or i%2==0:
                                        x_inputs[n_inputs-1] = x_n_inputs
                                    x_state[n_state-1] = x_n_state

                                    # XOR values for next iteration
                                    if control_variable==1 or i%2==0:
                                        x_n_inputs = 0
                                        for k in primitive_inputs:
                                            x_n_inputs = x_inputs[k]^x_n_inputs
                                    x_n_state = 0
                                    for k in primitive_state:
                                        x_n_state = x_state[k]^x_n_state

                                    # Considering state 11
                                    if discard_11==0:
                                        if (i%2 != 0):
                                            if ([x_inputs.copy()[l] for l in bits_selected_inputs]+[x_state_prev]+[x_state.copy()[bit_select_state]]) not in list_possibilities_discard0:
                                                list_possibilities_discard0.append([x_inputs.copy()[l] for l in bits_selected_inputs]+[x_state_prev]+[x_state.copy()[bit_select_state]])
                                        if (len(list_possibilities_discard0)==64):
                                            break

                                    # Discarding state 11, only 48 possibilities needed
                                    elif discard_11==1:
                                        if (i%2 != 0):
                                            if (([x_inputs.copy()[l] for l in bits_selected_inputs]+[x_state_prev]+[x_state.copy()[bit_select_state]]) not in list_possibilities_discard1) and (([x_state_prev]+[x_state.copy()[bit_select_state]])!=[1, 1]):
                                                list_possibilities_discard1.append([x_inputs.copy()[l] for l in bits_selected_inputs]+[x_state_prev]+[x_state.copy()[bit_select_state]])
                                        if (len(list_possibilities_discard1)==48):
                                            break

                                # Store all best solutions, to be sorted and written in files
                                if (((i+1)/2)<145) and (discard_11==0):
                                    list_iterations_discard0.append([(i+1)/2, iteration, control_variable, discard_11] + seed_state + seed_inputs + [bit_select_state] + bits_selected_inputs + primitive_state + primitive_inputs)
                                elif (((i+1)/2)<145) and (discard_11==1):
                                    list_iterations_discard1.append([(i+1)/2, iteration, control_variable, discard_11] + seed_state + seed_inputs + [bit_select_state] + bits_selected_inputs + primitive_state + primitive_inputs)
                                iteration+=1
print("Finished!")

# Store information for best results in this file, ordenados por number of test vectors
# Considering state 11
file_final_results_discard0 = open("Final_results_discard0.txt", 'w+')
list_iterations_discard0.sort()
for iteration_results in list_iterations_discard0:
    file_final_results_discard0.write("Iteration " + str(iteration_results[1]) + "\n\
    Number of test vectors: " + str(iteration_results[0]) + "\n\
    Inputs LFSR always updating (0=no, 1=yes)? : " + str(iteration_results[2]) + "\n\
    Discard state 11 (0=no, 1=yes)? : " + str(iteration_results[3]) + "\n\
    Seed state [yi_0 yi_1 yi_2]: " + str(iteration_results[4:7]) + "\n\
    Seed inputs [xi_0 xi_1 xi_2 xi_3 xi_4]: " + str(iteration_results[7:12]) + "\n\
    Bit used for state LFSR: y_" + str(iteration_results[12]) + "\n\
    Bits used for inputs LFSR: [x_" + str(iteration_results[13]) + ", x_" + str(iteration_results[14]) + ", x_" + str(iteration_results[15]) +", x_" + str(iteration_results[16]) + "]\n\
    Primitive for state LFSR: " + str([3] + iteration_results[17:19]) + "\n\
    Primitive for inputs LFSR: " + str([5] + iteration_results[19:]) + "\n\
    \n---------------------------------------------------------------------------------------\n\n")
file_final_results_discard0.close()
print("\nThe best solution without discarding the state 11 requires", int(list_iterations_discard0[0][0]), "test vectors.\n")

# Discarding state 11
file_final_results_discard1 = open("Final_results_discard1.txt", 'w+')
list_iterations_discard1.sort()
for iteration_results in list_iterations_discard1:
    file_final_results_discard1.write("Iteration " + str(iteration_results[1]) + "\n\
    Number of test vectors: " + str(iteration_results[0]) + "\n\
    Inputs LFSR always updating (0=no, 1=yes)? : " + str(iteration_results[2]) + "\n\
    Discard state 11 (0=no, 1=yes)? : " + str(iteration_results[3]) + "\n\
    Seed state [yi_0 yi_1 yi_2]: " + str(iteration_results[4:7]) + "\n\
    Seed inputs [xi_0 xi_1 xi_2 xi_3 xi_4]: " + str(iteration_results[7:12]) + "\n\
    Bit used for state LFSR: y_" + str(iteration_results[12]) + "\n\
    Bits used for inputs LFSR: [x_" + str(iteration_results[13]) + ", x_" + str(iteration_results[14]) + ", x_" + str(iteration_results[15]) +", x_" + str(iteration_results[16]) + "]\n\
    Primitive for state LFSR: " + str([3] + iteration_results[17:19]) + "\n\
    Primitive for inputs LFSR: " + str([5] + iteration_results[19:]) + "\n\
    \n---------------------------------------------------------------------------------------\n\n")
file_final_results_discard1.close()
print("The best solution discarding the state 11 requires", int(list_iterations_discard1[0][0]), "test vectors.\n")