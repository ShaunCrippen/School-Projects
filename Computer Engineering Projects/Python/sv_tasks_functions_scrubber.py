"""
sv_tasks_functions_scrubber.py - Creates .txt file with list of SystemVerilog files in directory and which functions/tasks were declared or called.
    
Input:
    NO INPUT
    
Output:
    sv_function_task_hierarchy.txt

NOTE: requires os & re libraries 

Created by Shaun Crippen & Michael Zarubin, 5/21/2021
"""

import os, re

# .txt search function
def sv_tasks_functions_scrubber():
    
    declaration_list = []           # list to hold function/task decalarations
    sv_file_tasks_functions = {}    # dictionary key = .sv filename,
                                    # dictionary value = list for functions/tasks declared or called in file
                                    # NOTE: IF function/task has port list = Declaration
                                    #                         no port list = function/task call
    
    # Check for user string in each file in current directory
    for file in os.listdir("."):
        
        # Search only .sv files
        if file[-3:] == ".sv":
            
            # Open .sv file
            with open(file, 'r') as file_h:
                
                # Check each line in file for function and task declarations
                for line in file_h:
                    
                    # Find function/task declarations
                    # IF current line from file has SV keyword "function" or "task",
                    if(re.search("function", line) or re.search("task", line)):
                        
                        # Ignores SystemVerilog "new" class constructor
                        if(re.search("new", line)):
                            continue
                        
                        # Split line at whitespaces into list for parsing
                        line_list = line.split()
                        
                        # Iterate through list, keeping of list index and element value
                        for index, element in enumerate(line_list):
                            
                            # IF there was a space between function/task name and portlist,
                            # THEN function/task name is known to be previous element in list 
                            # since current element starts with a "(".
                            # Add function/task name to declaration list for call search
                            # Add function/task name to function/task dictionary with declaration tag.
                            if element[0] == '(':
                                declaration_list.append(line_list[index - 1])
                                if file in sv_file_tasks_functions:
                                    sv_file_tasks_functions[file].append(line_list[index - 1] + " (DECLARED)")
                                else:
                                    sv_file_tasks_functions[file] = [(line_list[index - 1] + " (DECLARED)")]
                                break   # Found function/task name, so get next line in file
                            
                            # Otherwise, check element for "(" character.
                            for i, char in enumerate(element):
                                
                                # IF "(" character is found in list element,
                                # THEN trim string from "(" and,
                                # Add function/task name to declaration list for call search
                                # Add function/task name to function/task dictionary with declaration tag.
                                if char == '(':
                                    declaration_list.append(element[:i])
                                    if file in sv_file_tasks_functions:
                                        sv_file_tasks_functions[file].append(element[:i] + " (DECLARED)")
                                    else:
                                        sv_file_tasks_functions[file] = [(element[:i] + " (DECLARED)")]

                # Open .sv file second time to find where function/tasks are called
                with open(file, 'r') as file_h:
 
                    # Check each line in file for function and task calls
                    for line in file_h:
                        
                        # Skip function declarations since already stored
                        if(re.search("function", line) or re.search("task", line)):
                            continue
                        
                        # For each function/task declaration found,
                        for name in declaration_list:
                            
                            # search SV files in directory for the calls of
                            # each functin/task declared.
                            if(re.search(name, line)):
                                
                                # IF filename (key) already exists in dictionary (meaning function/task was declared here)
                                # THEN append function/task call (value) to filename in dictionary
                                # ELSE add filename and function/task call to dictionary
                                if file in sv_file_tasks_functions:
                                    sv_file_tasks_functions[file].append(name)
                                else:
                                    sv_file_tasks_functions[file] = [name]

    # Remove duplicate function/task calls from dictionary    
    for key, value in sv_file_tasks_functions.items():
        sv_file_tasks_functions[key]= set(value)

    ############################################
    # DISPLAY RESULTS
    ############################################
    
    # Create .txt file for writing SV project directory parsing results
    with open("sv_function_task_hierarchy.txt", 'w') as results_file_h:
        for key, value in sv_file_tasks_functions.items():
            results_file_h.write("%s\n" % key)
            
            # Underline filename with "-".  Underline is length of longest
            # function/task decalaration/call in file or filename, 
            # Whichever is longer.
            max_width = max(len(element) for element in value)
            if max_width < len(key):
                max_width = len(key)
            for i in range(max_width):
                results_file_h.write("-")
            results_file_h.write("\n")
            
            # List function/task declaration and calls in single column list 
            # under file found in.
            for element in value:
                results_file_h.write("%s\n" % element)
            results_file_h.write("\n\n")
            
# Main 
if __name__ == '__main__':
    sv_tasks_functions_scrubber()
