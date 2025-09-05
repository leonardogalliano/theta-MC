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



# TANNING JULY 2025
## Start simulations for Ludo's sketch
## First: bulk equilibirum study of the model
## NPT for some configurations
## Monitor phi, theta, s(q)

# Equilibration
N=200
steps=10000000
Ps=(5.0 7.5 10.0 12.5 15.0 17.5 20.0 25.0 30.0 50.0 75.0 100.0 150.0 200.0)
init_file=data/SOURCES/NVT/phi0.7111927911351156/N200/M8/steps10000000/seed1/trajectories
for P in "${Ps[@]}"; do
    screen -S HD_P$P -dm julia --project=. -t 8 hard_disk_script.jl $steps $N $P --init_file $init_file -v --nblocks 100
done

## Single configurations for Ludo (Equilibration)
N=200
steps=20000000
Ps=(10.0 17.0 22.0)
init_file=data/SOURCES/NVT/phi0.7111927911351156/N200/M8/steps10000000/seed1/trajectories/1/lastframe.xyz
for P in "${Ps[@]}"; do
    screen -S HD_P$P -dm julia --project=. -t 1 hard_disk_script.jl $steps $N $P --init_file $init_file -v --nblocks 100
done

# Restart for steady state
N=200
steps=10000000
Ps=(5.0 7.5 10.0 12.5 15.0 17.5 20.0 25.0 30.0 50.0 75.0 100.0 150.0 200.0)
for P in "${Ps[@]}"; do
    init_file=data/HardDisks/NPT/P$P/rate0.0/N$N/M8/steps10000000/seed1/trajectories
    screen -S HD_P$P -dm julia --project=. -t 8 hard_disk_script.jl $steps $N $P --init_file $init_file -v --nblocks 100 --out_path data/HardDisksSteady
done

## Single configurations for Ludo (Run)
N=200
steps=50000000
Ps=(10.0 17.0 22.0)
init_file=data/HardDisks/NPT/P$P/rate0.0/N$N/M1/steps20000000/seed1/trajectories/1/lastframe.xyz
for P in "${Ps[@]}"; do
    screen -S HD_P$P -dm julia --project=. -t 1 hard_disk_script.jl $steps $N $P --init_file $init_file -v --nblocks 100 --out_path data/HardDisksSteady
done

# Postprocessing
paths="data/HardDisksSteady/NPT/P*/rate0.0/N200/M8/steps10000000/seed1/trajectories/*/trajectory.xyz"
screen -S fskt -dm parallel -j 60 pp.py --no-partial fskt --total --fix-cm ::: $paths
screen -S msd -dm parallel -j 60 pp.py --no-partial msd --fix-cm --func logx ::: $paths

# Restart for ageing
N=200
steps=20000000
Ps=(17.5 20.0 25.0 30.0)
for P in "${Ps[@]}"; do
    init_file=data/HardDisksSteady/NPT/P$P/rate0.0/N$N/M8/steps10000000/seed1/trajectories
    screen -S HD_P$P -dm julia --project=. -t 8 hard_disk_script.jl $steps $N $P --init_file $init_file -v --nblocks 100 --out_path data/HardDisksSteady
done

# Add Lambda
## We take the generated configurations and we optimise theta (at constant volume)
N=200
steps=10000000
lambda=200000.0
Ps=(5.0 10.0 15.0)
for P in "${Ps[@]}"; do
    init_file=data/HardDisksSteady/NPT/P$P/rate0.0/N$N/M8/steps10000000/seed1/trajectories
    screen -S US_P0_$P -dm julia --project=. -t 8 main.jl $init_file $steps --lambda $lambda -n 1 -v --nblocks 10 --out_path data/UmbrellaSampling/P0_$P 
done

## Higher lambda
N=200
steps=10000000
lambda=500000.0
Ps=(5.0 10.0 15.0)
for P in "${Ps[@]}"; do
    init_file=data/HardDisksSteady/NPT/P$P/rate0.0/N$N/M8/steps10000000/seed1/trajectories
    screen -S US_P0_$P -dm julia --project=. -t 8 main.jl $init_file $steps --lambda $lambda -n 1 -v --nblocks 10 --out_path data/UmbrellaSampling/P0_$P 
done

## Single configurations for Ludo (Lambda)
N=200
steps=50000000
lambda=500000.0
Ps=(10.0 17.0 22.0)
for P in "${Ps[@]}"; do
    init_file=data/HardDisksSteady/NPT/P$P/rate0.0/N$N/M1/steps50000000/seed1/trajectories/1/lastframe.xyz
    screen -S US_P0_$P -dm julia --project=. -t 8 main.jl $init_file $steps --lambda $lambda -n 1 -v --nblocks 10 --out_path data/UmbrellaSampling/P0_$P 
done

## Restart on squid
N=200
steps=50000000
lambda=500000.0
Ps=(10.0 17.0 22.0)
for P in "${Ps[@]}"; do
    init_file=/home/berthier/HYPERUNIFORM/theta-MC/data/UmbrellaSampling/P0_$P/NVT/lambda$lambda/n1/N$N/M1/steps50000000/seed1/trajectories/1/lastframe.xyz 
    qsub -N US$P -pe orte 1 run.sh $init_file $steps --lambda $lambda -n 1 --nblocks 10 --out_path /home/berthier/HYPERUNIFORM/theta-MC/data/UmbrellaSampling_RESTART/P0_$P
done

## Restart 2 on squid
N=200
steps=100000000
lambda=500000.0
Ps=(10.0 17.0 22.0)
for P in "${Ps[@]}"; do
    init_file=/home/berthier/HYPERUNIFORM/theta-MC/data/UmbrellaSampling_RESTART/P0_$P/NVT/lambda$lambda/n1/N$N/M1/steps50000000/seed1/trajectories/1/lastframe.xyz 
    qsub -N US$P -pe orte 1 run.sh $init_file $steps --lambda $lambda -n 1 --nblocks 10 --out_path /home/berthier/HYPERUNIFORM/theta-MC/data/UmbrellaSampling_RESTART_2/P0_$P
done


## Restart 3 on squid
N=200
steps=200000000
lambda=500000.0
Ps=(10.0 17.0 22.0)
for P in "${Ps[@]}"; do
    init_file=/home/berthier/HYPERUNIFORM/theta-MC/data/UmbrellaSampling_RESTART_2/P0_$P/NVT/lambda$lambda/n1/N$N/M1/steps100000000/seed1/trajectories/1/lastframe.xyz 
    qsub -N US$P -pe orte 1 run.sh $init_file $steps --lambda $lambda -n 1 --nblocks 10 --out_path /home/berthier/HYPERUNIFORM/theta-MC/data/UmbrellaSampling_RESTART_3/P0_$P
done

## Restart 4 on squid
N=200
steps=100000000
lambda=500000.0
Ps=(10.0 17.0 22.0)
for P in "${Ps[@]}"; do
    init_file=/home/berthier/HYPERUNIFORM/theta-MC/data/UmbrellaSampling_RESTART_3/P0_$P/NVT/lambda$lambda/n1/N$N/M1/steps200000000/seed1/trajectories/1/lastframe.xyz 
    qsub -N US$P -pe orte 1 run.sh $init_file $steps --lambda $lambda -n 1 --nblocks 10 --out_path /home/berthier/HYPERUNIFORM/theta-MC/data/UmbrellaSampling_RESTART_4/P0_$P
done


## Redo lambda test (single configuraiton) SOURCES
N=200
steps=100000000
P=17.0
lambdas=(0.0 2500.0 5000.0 7500.0 10000.0 15000.0 20000.0)
n=5
for lambda in "${lambdas[@]}"; do
    init_file=data/HardDisksSteady/NPT/P$P/rate0.0/N$N/M1/steps50000000/seed1/trajectories/1/lastframe.xyz
    sbatch -J HD -n 1 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 1 main.jl $init_file $steps --lambda $lambda -n $n -v --nblocks 10 --out_path data/UmbrellaSampling_SOURCES/P0_$P"
done

## Steady
N=200
steps=10000000
P=17.0
lambdas=(0.0 2500.0 5000.0 7500.0 10000.0 15000.0 20000.0)
n=5
for lambda in "${lambdas[@]}"; do
    init_file=data/UmbrellaSampling_SOURCES/P0_$P/NVT/lambda$lambda/n$n/N$N/M1/steps100000000/seed1/trajectories/1/lastframe.xyz
    sbatch -J HD -n 1 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 1 main.jl $init_file $steps --lambda $lambda -n $n -v --linear_store 1000 --nblocks2 1 --out_path data/UmbrellaSampling_STEADY/P0_$P"
done

## Steady Restart
N=200
steps=10000000
P=17.0
lambdas=(0.0 2500.0 5000.0 7500.0 10000.0 15000.0 20000.0)
n=5
for lambda in "${lambdas[@]}"; do
    init_file=data/UmbrellaSampling_STEADY/P0_$P/NVT/lambda$lambda/n$n/N$N/M1/steps10000000/seed1/trajectories/1/lastframe.xyz
    sbatch -J HD -n 1 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 1 main.jl $init_file $steps --lambda $lambda -n $n -v --linear_store 100 --nblocks2 1 --out_path data/UmbrellaSampling_STEADY_2/P0_$P"
done

## Steady Restart 3
N=200
steps=50000000
P=17.0
lambdas=(0.0 2500.0 5000.0 7500.0 10000.0 15000.0 20000.0)
n=5
for lambda in "${lambdas[@]}"; do
    init_file=data/UmbrellaSampling_STEADY_2/P0_$P/NVT/lambda$lambda/n$n/N$N/M1/steps10000000/seed1/trajectories/1/lastframe.xyz
    sbatch -J HD -n 1 --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t 1 main.jl $init_file $steps --lambda $lambda -n $n -v --linear_store 100 --nblocks2 1 --out_path data/UmbrellaSampling_STEADY_3/P0_$P"
done

## REDO multiple configurations
N=200
steps=20000000
P=17.0
M=24
init_file=data/NO_OVERLAPS/eta1.4/eps0.2/phi0.5/N$N
sbatch -J HD -n $M --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t $M hard_disk_script.jl $steps $N $P --init_file $init_file -M $M --nblocks 10 -v --out_path data/SOURCES"

## Multiple configurations for clean theta vs t
N=200
steps=100000000
P=17.0
M=24
lambdas=(0.0 2500.0 5000.0 7500.0 10000.0 15000.0 20000.0)
n=5
for lambda in "${lambdas[@]}"; do
    init_file=data/SOURCES/NPT/P$P/rate0.0/N$N/M$M/steps20000000/seed1/trajectories/
    sbatch -J HD -n $M --output=./log_output/%x.o%j --error=./log_error/%x.e%j --wrap "/home/galliano/julia-1.9.0/bin/julia --project=. -t $M main.jl $init_file $steps --lambda $lambda -n $n -v --nblocks 1 --out_path data/UmbrellaSampling_MULTI/P0_$P"
done

## Multiple configurations for clean theta vs t TANNING
N=200
steps=100000000
P=17.0
M=24
n=5
# lambdas=(0.0 2500.0 5000.0 7500.0 10000.0 15000.0 20000.0)
lambdas=(7500.0 10000.0 15000.0 20000.0)
for lambda in "${lambdas[@]}"; do
    init_file=data/SOURCES/NPT/P$P/rate0.0/N$N/M$M/steps20000000/seed1/trajectories/
    screen -S US_P0_$P -dm julia --project=. -t $M main.jl $init_file $steps --lambda $lambda -n $n -v --nblocks 1 --out_path data/UmbrellaSampling_MULTI/P0_$P
done