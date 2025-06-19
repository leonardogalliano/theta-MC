# Hard disks

julia --project=. -t auto hard_disk_script.jl 10000000 200 25.0 --init_file data/CM/SOURCES/NVT/phi0.7111927911351156/N200/M8/steps10000000/seed1/trajectories --delta_V 1.0 -v

sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 10000000 200 25.0 -x 0.65 -M 8 --nblocks 10 -v"

# Single compression

sbatch -J HD -n 1 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. hard_disk_script.jl 10000000 200 10.0 --init_file data/HardDisks/NPT/P10.0/N200/M8/steps10000000/seed1/trajectories/1/lastframe.xyz --nblocks 10 --compression_rate 0.000001 -v"

# Multiple compression

sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 25000000 200 15.0 --init_file data/SOURCES/NVT/phi0.7590633912507699/N200/M8/steps10000000/seed1/trajectories -M 8 --nblocks 10 --compression_rate 0.00004 -v"
sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 50000000 200 15.0 --init_file data/SOURCES/NVT/phi0.7590633912507699/N200/M8/steps10000000/seed1/trajectories -M 8 --nblocks 10 --compression_rate 0.00002 -v"
sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 100000000 200 15.0 --init_file data/SOURCES/NVT/phi0.7590633912507699/N200/M8/steps10000000/seed1/trajectories -M 8 --nblocks 10 --compression_rate 0.00001 -v"
sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 100000000 200 20.0 --init_file data/SOURCES/NVT/phi0.7860370308274995/N200/M8/steps10000000/seed1/trajectories -M 8 --nblocks 10 --compression_rate 0.000005 -v"
sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 200000000 200 20.0 --init_file data/SOURCES/NVT/phi0.7860370308274995/N200/M8/steps10000000/seed1/trajectories -M 8 --nblocks 10 --compression_rate 0.0000025 -v"

sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 100000000 200 20.0 --init_file data/SOURCES/NVT/phi0.7860370308274995/N200/M8/steps10000000/seed1/trajectories -M 8 --nblocks 10 --compression_rate 0.00001 -v"



# Quenches

sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 50000000 200 10.0 --init_file data/HardDisks/NVT/phi0.7111927911351156/N200/M8/steps10000000/seed1/trajectories -M 8 --nblocks 50 -v --out_path data/Quenches/phi0_0.7111927911351156"
sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 50000000 200 15.0 --init_file data/HardDisks/NVT/phi0.7111927911351156/N200/M8/steps10000000/seed1/trajectories -M 8 --nblocks 50 -v --out_path data/Quenches/phi0_0.7111927911351156"
sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 50000000 200 25.0 --init_file data/HardDisks/NVT/phi0.7111927911351156/N200/M8/steps10000000/seed1/trajectories -M 8 --nblocks 50 -v --out_path data/Quenches/phi0_0.7111927911351156"

sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 50000000 200 30.0 --init_file data/Quenches/phi0_0.7111927911351156/NPT/P10.0/rate0.0/N200/M8/steps50000000/seed1/trajectories -M 8 --nblocks 50 -v --out_path data/Quenches/P0_10.0"
sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 50000000 200 50.0 --init_file data/Quenches/phi0_0.7111927911351156/NPT/P10.0/rate0.0/N200/M8/steps50000000/seed1/trajectories -M 8 --nblocks 50 -v --out_path data/Quenches/P0_10.0"
sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 50000000 200 75.0 --init_file data/Quenches/phi0_0.7111927911351156/NPT/P10.0/rate0.0/N200/M8/steps50000000/seed1/trajectories -M 8 --nblocks 50 -v --out_path data/Quenches/P0_10.0"
sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 50000000 200 100.0 --init_file data/Quenches/phi0_0.7111927911351156/NPT/P10.0/rate0.0/N200/M8/steps50000000/seed1/trajectories -M 8 --nblocks 50 -v --out_path data/Quenches/P0_10.0"
sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 50000000 200 150.0 --init_file data/Quenches/phi0_0.7111927911351156/NPT/P10.0/rate0.0/N200/M8/steps50000000/seed1/trajectories -M 8 --nblocks 50 -v --out_path data/Quenches/P0_10.0"

sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 50000000 200 30.0 --init_file data/Quenches/phi0_0.7111927911351156/NPT/P15.0/rate0.0/N200/M8/steps50000000/seed1/trajectories -M 8 --nblocks 50 -v --out_path data/Quenches/P0_15.0"
sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 50000000 200 50.0 --init_file data/Quenches/phi0_0.7111927911351156/NPT/P15.0/rate0.0/N200/M8/steps50000000/seed1/trajectories -M 8 --nblocks 50 -v --out_path data/Quenches/P0_15.0"
sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 50000000 200 75.0 --init_file data/Quenches/phi0_0.7111927911351156/NPT/P15.0/rate0.0/N200/M8/steps50000000/seed1/trajectories -M 8 --nblocks 50 -v --out_path data/Quenches/P0_15.0"
sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 50000000 200 100.0 --init_file data/Quenches/phi0_0.7111927911351156/NPT/P15.0/rate0.0/N200/M8/steps50000000/seed1/trajectories -M 8 --nblocks 50 -v --out_path data/Quenches/P0_15.0"
sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 50000000 200 150.0 --init_file data/Quenches/phi0_0.7111927911351156/NPT/P15.0/rate0.0/N200/M8/steps50000000/seed1/trajectories -M 8 --nblocks 50 -v --out_path data/Quenches/P0_15.0"

sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 50000000 200 30.0 --init_file data/Quenches/phi0_0.7111927911351156/NPT/P25.0/rate0.0/N200/M8/steps50000000/seed1/trajectories -M 8 --nblocks 50 -v --out_path data/Quenches/P0_25.0"
sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 50000000 200 50.0 --init_file data/Quenches/phi0_0.7111927911351156/NPT/P25.0/rate0.0/N200/M8/steps50000000/seed1/trajectories -M 8 --nblocks 50 -v --out_path data/Quenches/P0_25.0"
sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 50000000 200 75.0 --init_file data/Quenches/phi0_0.7111927911351156/NPT/P25.0/rate0.0/N200/M8/steps50000000/seed1/trajectories -M 8 --nblocks 50 -v --out_path data/Quenches/P0_25.0"
sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 50000000 200 100.0 --init_file data/Quenches/phi0_0.7111927911351156/NPT/P25.0/rate0.0/N200/M8/steps50000000/seed1/trajectories -M 8 --nblocks 50 -v --out_path data/Quenches/P0_25.0"
sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 50000000 200 150.0 --init_file data/Quenches/phi0_0.7111927911351156/NPT/P25.0/rate0.0/N200/M8/steps50000000/seed1/trajectories -M 8 --nblocks 50 -v --out_path data/Quenches/P0_25.0"


# Theta compressions
sbatch -J theta -w cm01 -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 main.jl data/SOURCES/Theta_pressure_restart_2/P50.0/lambda200000.0/n1/N200/M8/steps10000000/seed1/trajectories 20000000 --lambda 200000.0 -n 1 -v --out_path data/Quenches/Theta/P0_25.0 --pressure 50.0 --nblocks 10"
sbatch -J theta -w cm02 -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 main.jl data/SOURCES/Theta_pressure_restart_2/P100.0/lambda200000.0/n1/N200/M8/steps10000000/seed1/trajectories 20000000 --lambda 200000.0 -n 1 -v --out_path data/Quenches/Theta/P0_25.0 --pressure 100.0 --nblocks 10"
sbatch -J theta -w cm03 -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 main.jl data/SOURCES/Theta_pressure_restart_2/P150.0/lambda200000.0/n1/N200/M8/steps10000000/seed1/trajectories 20000000 --lambda 200000.0 -n 1 -v --out_path data/Quenches/Theta/P0_25.0 --pressure 150.0 --nblocks 10"


# The Glass Equation of State
## Sources
sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 200000000 200 200.0 --init_file data/Quenches/phi0_0.7111927911351156/NPT/P25.0/rate0.0/N200/M8/steps50000000/seed1/trajectories -M 8 --nblocks 50 -v --out_path data/Quenches/P0_25.0"
sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 200000000 200 200.0 --init_file data/Quenches/phi0_0.7111927911351156/NPT/P10.0/rate0.0/N200/M8/steps50000000/seed1/trajectories -M 8 --nblocks 50 -v --out_path data/Quenches/P0_10.0"
## EOS
# sbatch -J EOS -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 200000000 200 200.0 --init_file data/Quenches/P0_25.0/NPT/P200.0/rate0.0/N200/M8/steps200000000/seed1/trajectories -M 8 --nblocks 50 --compression_rate -0.000001 -v --out_path data/EOS/P00_25.0"
# sbatch -J EOS -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 200000000 200 200.0 --init_file data/Quenches/P0_10.0/NPT/P200.0/rate0.0/N200/M8/steps200000000/seed1/trajectories -M 8 --nblocks 50 --compression_rate -0.000001 -v --out_path data/EOS/P00_10.0"
