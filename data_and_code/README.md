# Meta-Analysis of Pre/Post Correlations

## Introduction

The aim of the analysis is to calculate pre/post correlation for treatment and control groups in Randomised Controlled Trials (RCT) which aimed to evaluate effectivness of interventions trying to decrease the degree of loneliness. The correlation is calculated based on the following steps:

1. Calculate the standard deviation of change scores \( SD_{\text{change}} \).
2. Calculate the final correlation \( r \).
3. Convert the **F** value to a **t** value if necessary.

## Source of Equations

The equations used in this analysis were obtained from [Matthew B. Jane's blog post](https://matthewbjane.com/blog-posts/blog-post-3.html). The equations are as follows:

## Equations


1. **Standard Deviation of Change Scores**:
   <br>
   <img src="https://latex.codecogs.com/svg.latex?S_{\text{change}}=\frac{M_{\text{change}}\cdot\sqrt{N}}{t}" alt="S_{\text{change}}=\frac{M_{\text{change}}\cdot\sqrt{N}}{t}">

2. **Final Correlation**:
   <br>
   <img src="https://latex.codecogs.com/svg.latex?r=\frac{S_{\text{pre}}^2+S_{\text{post}}^2-S_{\text{change}}^2}{2\cdot{S_{\text{pre}}}\cdot{S_{\text{post}}}}" alt="r=\frac{S_{\text{pre}}^2+S_{\text{post}}^2-S_{\text{change}}^2}{2\cdot{S_{\text{pre}}}\cdot{S_{\text{post}}}}">

3. **Convert F to t**:
   <br>
   <img src="https://latex.codecogs.com/svg.latex?t=\sqrt{F}" alt="t=\sqrt{F}">