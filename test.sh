cd /app && source activate SE3nv
./scripts/run_inference.py 'contigmap.contigs=[A59-80/0 10-100]' inference.input_pdb=/app/examples/input_pdbs/insulin_target.pdb inference.output_prefix=/outputs/insulin_design.pdb inference.num_designs=10 denoiser.noise_scale_ca=0 denoiser.noise_scale_frame=0
