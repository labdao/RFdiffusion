# Use the specified PyTorch image
FROM pytorch/pytorch:1.9.0-cuda11.1-cudnn8-devel

# Set the working directory
WORKDIR /app

# Fetch Key
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub

# Install wget and other required tools
RUN apt-get update && \
    apt-get install -y wget git

# Install miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh && \
    chmod +x Miniconda3-py39_4.10.3-Linux-x86_64.sh && \
    ./Miniconda3-py39_4.10.3-Linux-x86_64.sh -b -p /app/miniconda && \
    rm Miniconda3-py39_4.10.3-Linux-x86_64.sh

# Set the path to include miniconda
ENV PATH /app/miniconda/bin:$PATH

# Clone the RFdiffusion repository
RUN git clone https://github.com/RosettaCommons/RFdiffusion.git .

# Download the model weights
RUN mkdir models && cd models && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/6f5902ac237024bdd0c176cb93063dc4/Base_ckpt.pt && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/e29311f6f1bf1af907f9ef9f44b8328b/Complex_base_ckpt.pt && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/60f09a193fb5e5ccdc4980417708dbab/Complex_Fold_base_ckpt.pt && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/74f51cfb8b440f50d70878e05361d8f0/InpaintSeq_ckpt.pt && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/76d00716416567174cdb7ca96e208296/InpaintSeq_Fold_ckpt.pt && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/5532d2e1f3a4738decd58b19d633b3c3/ActiveSite_ckpt.pt && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/12fc204edeae5b57713c5ad7dcb97d39/Base_epoch8_ckpt.pt && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/f572d396fae9206628714fb2ce00f72e/Complex_beta_ckpt.pt

# Create and activate the SE3nv conda environment
COPY env/SE3nv.yml /app/env/SE3nv.yml
RUN conda env create -f env/SE3nv.yml
SHELL ["conda", "run", "-n", "SE3nv", "/bin/bash", "-c"]

# Install SE3-Transformer and RFdiffusion
RUN cd env/SE3Transformer && \
    pip install --no-cache-dir -r requirements.txt && \
    python setup.py install && \
    cd ../.. && \
    pip install -e .

# Untar the provided scaffold files
RUN tar -xvf examples/ppi_scaffolds_subset.tar.gz -C examples/

# Keep the container running
CMD ["bash"]
