# Genetic Algorithm Optimization of Diffusion MRI Gradient Waveforms

## Overview

This repository contains a MATLAB implementation of a genetic algorithm (GA) framework for optimizing diffusion MRI gradient waveforms under hardware constraints.

The optimization searches for gradient amplitudes that maximize diffusion encoding efficiency while satisfying gradient balance constraints and scanner-specific limits.

## Features

* Genetic Algorithm optimization using MATLAB Global Optimization Toolbox
* Support for scanner-specific gradient limits
* Weighted optimization of diffusion encoding pathways
* Automatic selection of top-performing gradient schemes
* Visualization of optimization convergence
* Visualization of optimized gradient amplitudes

## Requirements

* MATLAB R2022a or later
* Global Optimization Toolbox
* Parallel Computing Toolbox (optional)

## Usage

Run:

```matlab
run_opt_ga_gize_goodsch
```

The script:

1. Defines gradient constraints.
2. Builds diffusion encoding pathway matrices.
3. Executes repeated GA optimization.
4. Selects the best solutions.
5. Visualizes optimization performance.

## Citation

If you use this code, please cite:

Gradient waveform optimization for diffusion MRI. PMID: 41261502.

## Disclaimer

This repository is provided for research and educational purposes. Users are responsible for validating results before clinical or scientific use.
