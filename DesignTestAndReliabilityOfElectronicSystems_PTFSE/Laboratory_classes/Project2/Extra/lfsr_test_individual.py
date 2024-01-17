primitive_inputs = [4, 3, 1, 0] # Primitive polynomial - do not put 5 in the beginning!
n_inputs = 5 # Number of bits
bits_selected_inputs = [1, 2, 3, 4] # 4 bits to use for inputs
seed_inputs = [0, 0, 1, 1, 0] # Seed
x_inputs = seed_inputs.copy()
x_n_inputs = 0 # XOR variable

primitive_state = [2, 0] # Primitive polynomial - do not put 3 in the beginning!
n_state = 3
bit_select_state = 0
seed_state = [0, 0, 1]
x_state = seed_state.copy()
x_n_state = 0

# The bits of the inputs LFSR only need to change every 2 clocks
control_variable = 1 # [rest, always]

# In practice, we don't need the state 11
discard_11 = 0 # [do not discard, discard]

# Initial XOR values
for k in primitive_inputs:
    x_n_inputs = x_inputs[k]^x_n_inputs
for k in primitive_state:
    x_n_state = x_state[k]^x_n_state

list_possibilities = [] # Store unique test vectors

file_test_vectors = open("Individual_test_vectors.txt", 'w+')
file_unique_test_vectors = open("Individual_unique_test_vectors.txt", 'w+')

for i in range(1, 2048):
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
            # Vector for this iteration
            file_test_vectors.write(str([x_inputs.copy()[l] for l in bits_selected_inputs]+[x_state_prev]+[x_state.copy()[bit_select_state]]) + "\n")
            # Unique vector
            if ([x_inputs.copy()[l] for l in bits_selected_inputs]+[x_state_prev]+[x_state.copy()[bit_select_state]]) not in list_possibilities:
                list_possibilities.append([x_inputs.copy()[l] for l in bits_selected_inputs]+[x_state_prev]+[x_state.copy()[bit_select_state]])
                file_unique_test_vectors.write(str([x_inputs.copy()[l] for l in bits_selected_inputs]+[x_state_prev]+[x_state.copy()[bit_select_state]]) + "\n")
        if (len(list_possibilities)==64):
            break

    # Discarding state 11, only 48 possibilities needed
    elif discard_11==1:
        if (i%2 != 0):
            # Vector for this iteration
            file_test_vectors.write(str([x_inputs.copy()[l] for l in bits_selected_inputs]+[x_state_prev]+[x_state.copy()[bit_select_state]]) + "\n")
            # Unique vector
            if (([x_inputs.copy()[l] for l in bits_selected_inputs]+[x_state_prev]+[x_state.copy()[bit_select_state]]) not in list_possibilities) and (([x_state_prev]+[x_state.copy()[bit_select_state]])!=[1, 1]):
                list_possibilities.append([x_inputs.copy()[l] for l in bits_selected_inputs]+[x_state_prev]+[x_state.copy()[bit_select_state]])
                file_unique_test_vectors.write(str([x_inputs.copy()[l] for l in bits_selected_inputs]+[x_state_prev]+[x_state.copy()[bit_select_state]]) + "\n")
        if (len(list_possibilities)==48):
            break

file_test_vectors.close()
file_unique_test_vectors.close()

print("\nNumber of test vectors: ", int((i+1)/2), "\n")