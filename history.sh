# Hard disks

julia --project=. -t auto hard_disk_script.jl 10000000 200 25.0 --init_file data/CM/SOURCES/NVT/phi0.7111927911351156/N200/M8/steps10000000/seed1/trajectories --delta_V 1.0 -v

sbatch -J HD -n 8 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 8 hard_disk_script.jl 10000000 200 25.0 -x 0.65 -M 8 --nblocks 10 -v"

# Single compression

sbatch -J HD -n 1 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. hard_disk_script.jl 10000000 200 10.0 --init_file data/HardDisks/NPT/P10.0/N200/M8/steps10000000/seed1/trajectories/1/lastframe.xyz --nblocks 10 --compression_rate 0.000001 -v"