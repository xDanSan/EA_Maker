import os
import subprocess
import streamlit as st

# Check if Wine is already installed
wine_check = subprocess.run(['which', 'wine'], capture_output=True)
if wine_check.returncode != 0:
    # Wine is not installed, so install it
    subprocess.run(['sudo', 'dpkg', '--add-architecture', 'i386'], check=True)
    subprocess.run(['wget', '-nc', 'https://dl.winehq.org/wine-builds/winehq.key'], check=True)
    subprocess.run(['sudo', 'apt-key', 'add', 'winehq.key'], check=True)
    subprocess.run(['sudo', 'add-apt-repository', 'deb', 'https://dl.winehq.org/wine-builds/ubuntu/', 'focal', 'main'], check=True)
    subprocess.run(['sudo', 'apt-get', 'update'], check=True)
    subprocess.run(['sudo', 'apt-get', '-y', 'install', 'winehq-stable'], check=True)

# Define the path to the MetaEditor application
metaeditor_path = os.path.join(os.getcwd(), 'metaeditor.exe')

# Set the Wine display environment variable
os.environ['DISPLAY'] = ':0'

# Create a file uploader widget
mq4_file = st.file_uploader('Upload your MQ4 file', type='mq4')

if mq4_file is not None:
    # Save the uploaded file to disk
    with open('uploaded_file.mq4', 'wb') as f:
        f.write(mq4_file.read())

    # Compile the uploaded file using MetaEditor and Wine
    cmd = ['wine', metaeditor_path, '/compile', 'uploaded_file.mq4']
    subprocess.run(cmd, check=True)

    # Display a message when the file is compiled
    st.success('Compilation successful!')
