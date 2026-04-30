# SVC
Research and simulation of Sparse Vector Coding (SVC) for 6G URLLC. Focused on the error rate analysis of short-packet communications using diversity techniques to meet strict reliability requirements.
System Model: Define the short-packet regime (finite blocklength).

Coding Technique:Sparse Vector Coding (SVC) represents information using a high-dimensional sparse signal, where only a small number of elements are active while the rest remain zero. The information is jointly conveyed by the indices of the active elements (support) and their modulated values.

At the transmitter, an input bit sequence is divided into two parts. The first part selects the positions of K non-zero elements within a vector of length N, while the second part determines the complex symbols (e.g., QPSK) assigned to those positions. This results in a sparse vector

x∈C
N
,K≪N

which is transmitted over m time/frequency resources.

At the receiver, the signal is affected by fading and noise. Diversity combining techniques such as Maximum Ratio Combining (MRC), Equal Gain Combining (EGC), or Selection Combining (SC) are first applied to improve the effective SNR. The receiver then performs sparse detection to identify:

The active positions (support recovery)
The transmitted symbol values

Detection is typically based on correlation or maximum likelihood criteria, exploiting the sparsity structure of the transmitted vector.

This approach improves reliability because the energy is concentrated on a few components, making SVC particularly suitable for short-packet and ultra-reliable communication scenarios.
Diversity Mechanism: Detail the specific diversity (MRC, EGC, and SC) being aided by SVC.

Metrics: Focus on Block Error Rate (BLER) vs. Signal-to-Noise Ratio (SNR).
