import os
import glob
import numpy as np
import pandas as pd

''' Function to load enhancement data as a function of etching rounds. '''
def load_enhancement_data():
    # Folder containing the .npy files.
    folder = 'Final Enhancement Results'
    file_list = sorted(glob.glob(os.path.join(folder, '*.npy')))
    # Filter out the unwanted file (old version of some data I processed).
    file_list = [f for f in file_list if os.path.basename(f) != 'Failed 3rd Round of Etching_old.npy']

    # Define a function to assign an order index based on the filename.
    # I want to create a bar plot first. The bars should be in the following order:
    #        1st round -> 2nd round -> failed 3rd round -> 3rd round
    # Index: 0         -> 1         -> 2                -> 3
    def file_index(filename):
        base = os.path.basename(filename)
        if '1st' in base:
            return 0
        elif '2nd' in base:
            return 1
        elif 'Failed' in base and '3rd' in base:
            return 2
        elif '3rd' in base:
            return 3
        else:
            return 4

    # Sort the files in the desired order.
    file_list.sort(key=file_index)

    # Prepare to load and store data for each etch round.
    etch_round_data = []
    number_of_patterns = 33  # Patterns are numbered 1 to 33.
    # Begin the loop.
    for file in file_list:
        # Load the file, assuming it was saved as a dictionary (which it was).
        print('Loading file "' + os.path.basename(file) + '".')
        data = np.load(file, allow_pickle=True).item()  
        pattern_numbers = data['ag_patternNumber']
        enhancements    = data['ag_enhancement']
        errors          = data['ag_error']
        flags           = data['ag_averagingFlag']

        # Create arrays of a fixed size (33 patterns), insert nan for missing data.
        # For example, the 1st round of etching is missing data for pattern 23.
        enhancement_array = np.full(number_of_patterns, np.nan, dtype=float)
        error_array       = np.full(number_of_patterns, np.nan, dtype=float)
        flag_array        = np.zeros(number_of_patterns, dtype=bool)

        # Loop over each measurement in the current file.
        for i, p in enumerate(pattern_numbers):
            # Only record if the pattern number is between 1 and 33 (which it is).
            if 1 <= p <= number_of_patterns:
                enhancement_array[int(p)-1] = enhancements[i]
                error_array[int(p)-1] = errors[i]
                flag_array[int(p)-1] = (flags[i] == 1)

        etch_round_data.append({
            'pattern_numbers': np.arange(1, 33+1), # This will work now that missing data has been filled.
            'enhancement': enhancement_array,
            'error': error_array,
            'flag': flag_array,
            'label': os.path.splitext(os.path.basename(file))[0]
        })
    print() # Newline.
    return etch_round_data

''' Function to select specific parts of the enhancement data. '''
def select_data(etch_round_data, indices):
    edited_etch_round_data = [] # Include only the data we want to keep.
    print('Keeping the following data:')
    for i in indices:
        print('\t"' + etch_round_data[i]['label'] + '"')
        edited_etch_round_data.append(etch_round_data[i])
    return edited_etch_round_data

''' Function to convert a list of flagged arrays into a boolean array. '''
def check_flag(flagged_etches, etch):
    flag_array = np.zeros(len(flagged_etches), dtype=bool)
    for i, etches in enumerate(flagged_etches):
        if etches is not np.nan and str(etch) in etches:
            flag_array[i] = 1
    return flag_array

''' Function to load length data as a function of etching rounds. '''
def load_length_data():
    # Load the CSV file.
    df = pd.read_csv('length_data_python.csv')

    # Convert each column in the DataFrame to an array and store in a dictionary.
    all_data = {col: df[col].to_numpy() for col in df.columns}
    
    # Loop through the rounds of etching and load the length data.
    # The intent is for the length data to be loaded in a similar fashion to the enhancement data.
    etch_round_data = []
    rounds = [1, 2, 3]
    labels = ['1st Round of Etching', '2nd Round of Etching', '3rd Round of Etching']
    for r, l in zip(rounds, labels):
        etch_round_data.append({
            'pattern_numbers': all_data['Pattern number'],
            'length': all_data[f'Etch {r} length'],
            'error': all_data[f'Etch {r} length error'],
            'flag': check_flag(all_data['Flagged etches'], r),
            'label': l
        })
    
    # Remaining design parameters.
    parameters = {
        'pattern_numbers': all_data['Pattern number'],
        'unit_cells': all_data['Number of unit cells'],
        'period': all_data['Period'],
        'power': all_data['Power'],
        'nominal_length': all_data['Nominal length']
    }
    return etch_round_data, parameters