# Gradient Scheme Optimization for PRESS-Localized Edited MRS Using Weighted Pathway Suppression

This repository contains MATLAB code implementing a weighted DOTCOPS (Dephasing Optimization Through Coherence Order Pathway Selection) framework for optimizing crusher gradient schemes in PRESS-localized edited magnetic resonance spectroscopy (MRS).

The optimization was developed to reduce out-of-voxel (OOV) artifacts arising from insufficient suppression of unwanted coherence transfer pathways (CTPs). A volume-based likelihood model is used to prioritize pathway suppression according to the probability of OOV signal generation. The optimization employs a genetic algorithm with a dual-penalty objective function to maximize pathway-specific dephasing while respecting scanner hardware and sequence timing constraints.

The optimized gradient schemes were validated using simulations and in vivo edited MRS acquisitions in the posterior cingulate cortex (PCC), thalamus, and medial prefrontal cortex (mPFC). Results demonstrated substantially improved k-space crushing efficiency and significant reductions in OOV artifacts, particularly in regions highly susceptible to OOV contamination.
