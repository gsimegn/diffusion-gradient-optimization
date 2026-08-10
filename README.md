🧠 Gradient Scheme Optimization for Edited MRS

A research implementation of gradient-scheme optimization for PRESS-localized, MEGA-edited magnetic resonance spectroscopy (MRS). The project focuses on suppressing unwanted out-of-voxel (OOV) artifacts by optimizing crusher gradients according to the likelihood of unwanted coherence transfer pathways (CTPs).

Based on:

Simegn GL, Shams Z, Murali-Manohar S, et al. Gradient Scheme Optimization for PRESS-Localized Edited MRS Using Weighted Pathway Suppression. NMR in Biomedicine. 2026;39(1).

DOI: 10.1002/nbm.70182

Paper: https://pubmed.ncbi.nlm.nih.gov/41261502/

🎯 Overview

In edited MRS, unwanted coherence transfer pathways can produce out-of-voxel signals that contaminate spectra. This project develops an optimized crusher-gradient scheme that gives greater priority to pathways that are more likely to contribute to unwanted signal.

The method combines:

Volume-based CTP likelihood weighting

DOTCOPS gradient optimization

Genetic algorithm (GA) optimization

Hardware and sequence constraints

Analytical k-space crushing simulation

Diffusion-weighting analysis

🔬 Optimization Pipeline

PRESS / MEGA-edited Sequence
            │
            ▼
       Enumerate CTPs
            │
            ▼
      81 Possible Pathways
            │
            ▼
   Estimate CTP Likelihood
            │
            ▼
      Assign Weights
            │
            ▼
     DOTCOPS Framework
            │
            ▼
    Genetic Algorithm
            │
            ▼
 Optimize Gradient Amplitudes
        across X, Y, Z
            │
            ▼
   Calculate Crusher Moments
            │
            ▼
 Evaluate k-space Crushing
            │
            ▼
   Optimized Gradient Scheme

🧬 CTP Likelihood Model

The five-RF-pulse sequence produces 81 detectable coherence transfer pathways (CTPs).

Transition

Interpretation

Δp = ±2

180°-like refocusing

Δp = ±1

90°-like transition

Δp = 0

Outside the pulse's effective band

Relative probabilities used in the volume-based model include:

Within-slice: 1

Slice-edge: 0.2

Out-of-slice: 10

Within-edit: 1

Edit-transition: 1

Edit-off: 5

The pathway likelihood is calculated as:

Lᵢ = ∏ P(Tᵢ,ₙ)

and converted into optimization weights:

wᵢ = 0.1 + 0.9 × Lᵢ / Lmax

This allows the optimizer to prioritize pathways according to their estimated likelihood of contributing to unwanted signal.

⚙️ Gradient Optimization

The optimization uses a genetic algorithm in MATLAB's Global Optimization Toolbox.

Gradient durations are first determined from the available sequence delays. The GA then optimizes gradient amplitudes across the three spatial axes:

        Gradient Scheme
              │
      ┌───────┼───────┐
      ▼       ▼       ▼
      X       Y       Z
      │       │       │
      └───────┼───────┘
              ▼
       Sequence Delays

The cost function balances:

Suppression of the least-crushed pathway

Overall pathway suppression

📐 k-Space Crushing

The optimized scheme is evaluated using analytical k-space trajectories.

k⃗ = Σ G⃗ᵢ · Δpᵢ

Conceptually:

Large k-space displacement
        ↓
Strong phase dispersion
        ↓
Strong pathway crushing

while a small displacement indicates weaker suppression.


📊 Reported Results

The optimized gradient scheme demonstrated:

197% average improvement in k-space crushing efficiency

Reduced OOV artifacts across the tested brain regions

Particularly strong improvement in the thalamus and medial prefrontal cortex (mPFC)

Greatest improvements around 4.3 ppm

Significant OOV artifact reduction with p < 0.001

In-vivo validation was performed in:

Posterior cingulate cortex (PCC)

Thalamus

Medial prefrontal cortex (mPFC)

The optimized scheme was compared with the previous “two-last, increased-area” gradient scheme.

🧠 Why the Optimization Matters

Instead of treating every CTP equally, the proposed method asks:

Which unwanted pathways are most likely?
                │
                ▼
      Give them higher priority
                │
                ▼
      Optimize gradient crushing
                │
                ▼
       Reduce OOV artifacts

This makes the gradient design more pathway-aware and volume-aware.

🛠️ Technologies

MATLAB

MATLAB Global Optimization Toolbox

Genetic Algorithms

Magnetic Resonance Spectroscopy (MRS)

k-space crushing distance analysis

Gradient moment calculations

Diffusion / b-value calculations

▶️ Reproduction Workflow

1. Define the PRESS / MEGA-edited sequence
2. Generate the possible CTPs
3. Determine Δp for each RF pulse
4. Assign transition probabilities
5. Calculate CTP likelihoods
6. Convert likelihoods into pathway weights
7. Define gradient-duration constraints
8. Define gradient-amplitude limits
9. Construct the optimization cost function
10. Run the genetic algorithm
11. Calculate pathway crusher moments
12. Evaluate k-space crushing
13. Compare optimized and reference schemes

Exact implementation parameters should be taken from the accompanying code rather than assumed from the paper.

⚠️ Limitations

The study notes that:

The optimized scheme requires a minimum TE of 80 ms.

Gradient limits and delay times are scanner/vendor specific.

Experimental validation was performed on a Philips scanner.

Additional validation is needed on other platforms such as Siemens and GE.

Future work could incorporate diffusion-related signal loss directly into optimization.

📖 Citation

Simegn GL, Shams Z, Murali-Manohar S, Simicic D, Gad A, Song Y,
Yedavalli V, Davies-Jenkins CW, Gudmundson AT, Zöllner HJ,
Oeltzschner G, Edden RAE.

Gradient Scheme Optimization for PRESS-Localized Edited MRS
Using Weighted Pathway Suppression.

NMR in Biomedicine. 2026;39(1):e70182.
doi:10.1002/nbm.70182

🔗 Reference

https://pubmed.ncbi.nlm.nih.gov/41261502/
