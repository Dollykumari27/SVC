# Error Rate Analysis of Sparse Vector Coding withDiversity Techniques in the Presence of TransceiverHardware Impairments
Manuscript ID: IEEE LAT Submission ID: 10879  Authors:

Dolly Kumari
Maddu Narasimha
Pradeep Kumar Rathore
Shravan Kumar Bandari 
## 📁 Description 
Research and simulation of Sparse Vector Coding (SVC) for 6G URLLC. Focused on the error rate analysis of short-packet communications using diversity techniques to meet strict reliability requirements.
System Model:In the short-packet regime, communication is performed using finite and relatively small blocklengths, where each transmitted packet contains only a limited number of symbols. Unlike classical information theory, which assumes infinitely long codewords, practical systems such as URLLC operate under strict latency constraints that require short packets.
As a result, reliable communication becomes more challenging because:

1. There is limited redundancy for error correction
2. The impact of noise and fading is more pronounced
3. Coding and detection must be highly efficient and low-latency

Sparse Vector Coding (SVC) is particularly well-suited for this regime, as it leverages sparsity to enable reliable transmission with short packets and reduced decoding complexity.

Coding Technique: Sparse Vector Coding (SVC) represents information using a high-dimensional sparse signal, where only a small number of elements are active while the rest remain zero. The information is jointly conveyed by the indices of the active elements (support) and their modulated values.

At the transmitter, an input bit sequence is divided into two parts. The first part selects the positions of K non-zero elements within a vector of length N, while the second part determines the complex symbols (e.g., QPSK) assigned to those positions. This results in a sparse vector

x∈CN,K≪N

which is transmitted over m time/frequency resources.

At the receiver, the signal is affected by fading and noise. Diversity combining techniques such as Maximum Ratio Combining (MRC), Equal Gain Combining (EGC), or Selection Combining (SC) are first applied to improve the effective SNR. The receiver then performs sparse detection to identify:

1.The active positions (support recovery)
2.The transmitted symbol values

Detection is typically based on correlation or maximum likelihood criteria, exploiting the sparsity structure of the transmitted vector.

This approach improves reliability because the energy is concentrated on a few components, making SVC particularly suitable for short-packet and ultra-reliable communication scenarios.
Diversity Mechanism: Detail the specific diversity (MRC, EGC, and SC) being aided by SVC.

Metrics: Focus on Block Error Rate (BLER) vs. Signal-to-Noise Ratio (SNR).

## 📁 Included Scripts
This repository contains all scripts required to reproduce the simulation and numerical results.

## 📁 Included Scripts

| Script | Related Figure(s) | Description |
## 📁 Included Scripts

| Script | Related Figure(s) | Description |
| :--- | :--- | :--- |
| `main_svc_diversity_simulation.m` | Fig. 2 (a, b, c) & Fig. 3 (a, b, c) | Evaluates and plots BLER vs. SNR performance comparing **MRC**, **EGC**, and **SC** under realistic channel models (EPA/EVA) and transceiver hardware impairments. |
| `svc_diversity_combiner.m` | Core Function | Modular combining function implementing Maximal Ratio Combining (MRC), Equal Gain Combining (EGC), and Selection Combining (SC). |
| `islsp_EstMMP_BF_reuse.m` | Helper / Core | Implements the Multipath Matching Pursuit (MMP) sparse signal recovery algorithm. |
| `algo_mmp.m` | Helper / Core | Implements the Multipath Matching Pursuit (MMP) sparse recovery algorithm. |
| `channel.m` | Helper | Simulates multipath fading channel realizations across standard profiles (EPA, EVA, ETU, Rayleigh, AWGN). |
| `Ideal_vs_nonideal.m` | Core| Modular combining implementing Maximal Ratio Combining (MRC) with hardware impairment |
| `Latency_SVC_DiversityComb.m` | Core | Latency implementing Maximal Ratio Combining (MRC), Equal Gain Combining (EGC), and Selection Combining (SC), and SVC|
| `bler_mrc_impcsi_eva.m.m` | Core |Plots BLER vs. SNR for SVC-MRC under perfect CSI (\epsilon = 0) and imperfect CSI (\epsilon = 0.2, 0.7)|
## 📂 Required Files

-channel_models.m and svc_encoder_decoder.m must remain in the working directory or be added to the MATLAB path.
-Hardware Impairment Parameters: Residual error vector magnitude (EVM) parameters $\kappa_{tx}$ and $\kappa_{rx}$ are configured inside sim_epa_diversity.m and sim_eva_diversity.m.
-All scripts are self-contained and generate synthetic channel realizations on the fly.

## 💻 Requirements

- MATLAB R2025a or later.
- Communications Toolbox
- Signal Processing Toolbox

## ✉️ Contact

For questions or replication of results, contact: dolly27sep@gmail.com
  
