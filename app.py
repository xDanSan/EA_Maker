import os
import streamlit as st
import subprocess

# Set execute permission on the metaeditor.exe file
os.chmod("metaeditor.exe", 0o755)

# Define the path to the metaeditor.exe file
metaeditor_path = os.path.join(os.getcwd(), "metaeditor.exe")

# Define the function to compile the MQ4 file
def compile_mq4(mq4_file_path):
    # Define the path to the output EX4 file
    ex4_file_path = os.path.splitext(mq4_file_path)[0] + ".ex4"

    # Call the metaeditor.exe file using Wine to compile the MQ4 file
    process = subprocess.Popen(["wine", metaeditor_path, "/compile:%s" % mq4_file_path])
    process.wait()

    # Check if the EX4 file was created
    if not os.path.exists(ex4_file_path):
        st.error("Compilation failed. Could not create the EX4 file.")
    else:
        st.success("Compilation successful. Download the EX4 file below.")
        # Add a download link for the compiled EX4 file
        with open(ex4_file_path, "rb") as ex4_file:
            ex4_file_contents = ex4_file.read()
            st.download_button("Download compiled EX4 file", ex4_file_contents, "compiled_file.ex4")

# Define the Streamlit app
def app():
    st.title("MQ4 Compiler")

    # Add a file upload widget
    mq4_file = st.file_uploader("Upload your MQ4 file", type="mq4")

    # Check if a file was uploaded
    if mq4_file is not None:
        # Save the MQ4 file to a temporary location
        with open("temp.mq4", "wb") as temp_file:
            temp_file.write(mq4_file.getvalue())

        # Compile the MQ4 file
        compile_mq4("temp.mq4")

# Run the app
if __name__ == "__main__":
    app()
