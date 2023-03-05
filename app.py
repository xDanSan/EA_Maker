import streamlit as st
import os
import subprocess
Lines = []
# Define a function to get the session state
def get_session_state():
    # Create a new session state dictionary if it doesn't exist
    if "session_state" not in st.session_state:
        st.session_state["session_state"] = {}
    # Return the session state dictionary
    return st.session_state["session_state"]
# Get the session state dictionary
session_state = get_session_state()

#helpers
def show_log_file(filename):
    if "filename" in session_state:
        with open(session_state['filename'], mode="rb") as file:
            if file == None:
                return
            log_contents = file.read().decode("utf-16-le")
            st.success(log_contents)
  
def show_log_file2():
    # Open the log file and read its contents
    with open('generatedfile.log', 'r') as f:
        content = f.read().decode("utf-8", errors="replace")
        st.write(content)

    # Display the log file contents using Streamlit
    #st.code(log_content)

def compile_mq4_file(mq4_file_pathh):
    mq4_file_path=os.path.join(os.path.dirname(__file__), mq4_file_pathh)
    print(mq4_file_path)
    # Get the path to the MetaEditor executable
    metaeditor_path = os.path.join(os.path.dirname(__file__), "metaeditor.exe")
    print('metaeditor_path',metaeditor_path)
    # Get the path to the MQ4 file directory
    mq4_file_dir = os.path.dirname(mq4_file_path)
    print('mq4_file_dir',mq4_file_dir)
    # Set the output directory to the MQ4 file directory
    output_dir = mq4_file_dir
    # Set the path to the output EX4 file
    ex4_file_path = os.path.join(output_dir, os.path.splitext(os.path.basename(mq4_file_path))[0] + ".ex4")
    print('ex4_file_path',ex4_file_path)
    # Build the command to compile the MQ4 file to EX4
    command = f'metaeditor.exe /compile:"{mq4_file_path}" /log /outdir:"{output_dir}"'
    # Execute the command and capture the output
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    output, error = process.communicate()
    
    # Check if compilation succeeded
    if os.path.isfile(ex4_file_path):
        return ex4_file_path
    else:
        print(f"Compilation of {mq4_file_path} failed. Error message: {error.decode('utf-8')}")
        return None

def get_value_type(value_str):
    try:
        if value_str == 'true' or value_str == 'false':
            return 'bool'
        value = eval(value_str)
        value_type = type(value).__name__
        return value_type
    except:
        return "str"

def python_to_mql4_type(python_type):
    mql4_type = None
    if python_type == "bool":
        mql4_type = "bool"
    elif python_type == "int":
        mql4_type = "int"
    elif python_type == "float":
        mql4_type = "double"
    elif python_type == "complex":
        mql4_type = "complex"
    elif python_type == "str":
        mql4_type = "string"
    elif python_type == "list":
        mql4_type = "int[]" # Assumes list contains only ints
    elif python_type == "tuple":
        mql4_type = "int[]" # Assumes tuple contains only ints
    elif python_type == "dict":
        mql4_type = "int[]" # Assumes dict contains only ints as keys
    else:
        mql4_type = "UNKNOWN"
    return mql4_type
# Define function to handle uploaded files
def handle_files(set_file, ex4_file):
    # Read contents of .set file
    set_contents = None
    if set_file is not None:
        set_contents = set_file.read().decode("utf-8")
        Lines = set_contents.strip().split('\n')
        Keys = [[i[:i.find('=')], i[i.find('=')] ,i[i.find('=')+1:].strip(),python_to_mql4_type(get_value_type(i[i.find('=')+1:].strip()))] for i in Lines if len(i)>0]
        for k in Keys:
            if k[3] =='string':
                k[2] = "\""+k[2]+"\""
        Inputs = [f'input {i[3]} {i[0]} = {i[2]} ;//{i[0]}' for i in Keys]
        Inputs.insert(0,f'input string IndName = "{ex4_file.name}";')
        Params = [i[0] for i in Keys]
        scope = "\n".join(Inputs)
        pars = "\n,".join(Params)
        call = f'double read = iCustom(_Symbol,0,IndName,{pars},index,bar);'
        funcs ="".join( [f'double ReadInd(int index,int bar=1)',"\n{\n",call,'return read;',"}"])
    # Do something with the files
    st.write(f"You uploaded {set_file.name} and {ex4_file.name}")
    st.write("Contents of .set file:")
    session_state['scope'] = scope
    session_state['funcs'] = funcs
# Define the Streamlit app
def main():
    # Set app title
    st.title("EA and Indicator Maker")
    st.title("File Uploader")
    # Create file uploader components
    set_file = st.file_uploader("Upload .set file", type=["set"])
    ex4_file = st.file_uploader("Upload .ex4 file", type=["ex4"])
    #st.write(set_file)
    #st.write(ex4_file)
    # Handle uploaded files when button is clicked
    if st.button("Process Files"):
        if set_file is not None and ex4_file is not None:
            handle_files(set_file, ex4_file)
        else:
            st.warning("Please upload both .set and .ex4 files.")
    if st.button("Generate the Data"):
        content = session_state['scope'] + "\n\n" + session_state['funcs']
        session_state['content'] = content
        st.write(content[:300])
        st.write(f"Data is created")
    if st.button("Generate the EA"):
        base = ''
        with open('temp_ea.mq4','r') as f:
            base = f.read()
        base = base.replace('//[Scope]//',session_state['scope'])
        base = base.replace('//[FUNC]//',session_state['funcs'])
        with open('generatedfile.mq4','w') as f:
            f.write(base)
            f.close()
            st.write(f"file is created at {f.name}")
            session_state['filename'] = f.name
    if st.button("Compile the EA"):
        ex444 = compile_mq4_file('generatedfile.mq4')
        if len(ex444)>2:
            st.write(f"file is downloadable at {ex444}")
            session_state['ex444'] = ex444
    else:
        st.write(f"error getting the file ")
        
    #download_button(session_state['ex4file'],"Download the EA now")
    show_log_file('generatedfile.log')
    if 'ex444' in session_state:
        with open(session_state['ex444'], "rb") as file:
            btn = st.download_button(
                    label="Download EA",
                    data=file,
                    file_name=ex4_file.name[:-4]+'_AUTO_EA'+'.ex4',
                )
    st.write(session_state)
# Run the app
if __name__ == "__main__":
    main()
