# Back to the Drawing Board: Revisiting the Design of Optimal Location Privacy-preserving Mechanisms

In our CCS 2017 paper [Back to the Drawing Board](https://arxiv.org/pdf/1705.08779.pdf), we evaluate the performance of different location privacy-preserving mechanisms in both a realistic continuous scenario and a synthetic discrete scenario, in terms of different privacy metrics. This repository contains the Matlab files we used to perform this evaluation. The experiments are divided into two folders: `MatlabCCS17_Cont` and `MatlabCCS17_Disc`.

The former contains the files to run the experiments of the continuous scenario, explained in Section 5.1 in the paper, that produces the results in Figures 4, 5, 6, 7 and 11. The latter contains the files to run the experiments of the discrete synthetic scenario explained in Section 5.2 in the paper (Figures 9 and 10).

For further questions, please contact simonoya@gts.uvigo.es or any or the authors of the paper.

## CONTINUOUS SCENARIO (`MatlabCCS17_Cont`)

In this experiment, we evaluate the privacy and quality loss performance of different mechanisms with real data taken from datasets that contain points of interest and user check-ins inside the San Francisco region. The mechanisms evaluated are:
1. Planar Laplacian noise with remapping [1*] (Lap)
2. Bi-dimensional Gaussian noise with remapping (Gau)
3. Uniform circular noise with remapping (Cir)
4. The Exponential mechanism [2*] with remapping (Exp)
5. Exponential posterior mechanism with remapping (ExPost)
6. The Coin mechanism (Coin)

We first evaluate these mechanisms without worst-case quality loss constraints. Then, we evaluate them when a worst-case loss constraint has been imposed (we exclude the Coin mechanism in this case, as it is not compatible with this constraint).

We measure privacy as the average error using the Euclidean distance, using the Conditional Entropy (in bits) and Geo-Ind privacy, as defined in the paper. The script also computes results in other privacy metrics we do not show in the paper. We measure quality loss as the average loss in Euclidean distance.

### Overview of the experiment:
The simulation of each protection mechanism begins by loading data from a dataset, which can be `DATA_SF_Gowalla_parsed.mat` or `DATA_SF_Brightkite_parsed.mat`. With this data, each of the files numbered from s01 to s07 simulate the location obfuscation process and measure privacy and quality loss using auxiliary functions under the `auxiliary_functions` folder. When finished, they save the results under the `RESULTS` folder (the results we got for the Gowalla dataset are included under this folder in the repository, for reference). Finally, the scripts `PLOTS_RESULTS1.m` and `PLOT_RESULTS2.m` plot the results for the unbounded and bounded experiments respectively. The former requires the results generated by s01 to s04, and the latter the results of s05 to s07.

### Dataset files:
The files `DATA_SF_Gowalla_parsed.mat` or `DATA_SF_Brightkite_parsed.mat` contain data from the San Francisco region taken from Gowalla and Brightkite datasets (please see [our paper](https://arxiv.org/pdf/1705.08779.pdf) for more information). There are 4 variables in each of these files:
- Matrix of locations (`X`): this is an Nx2 matrix that contains the set of N Points of Interest (PoI), i.e., the possible locations of the users. Each row of the matrix contains the Cartesian coordinates of a location. These coordinates are expressed in kilometers and have been translated from the latitude and longitude coordinates using the center of the San Francisco region as reference and the Haversine Formula.
- Matrix of locations in latitude and longitude coordinates (`Xlatlon`): just for reference, this is an Nx2 matrix that contains the latitude and longitude coordinates of each PoI. This is not used in our experiments.
- User check-ins (`user_location_pairs`): this is an Lx2 matrix, where L is the total number of check-ins performed by all the users of the dataset in the San Francisco region. The first column of this matrix represents the user ID and the second one the location ID.
- Input prior (`priorX`): this is an Nx1 column vector containing the probability mass function (prior) of the users in the locations defined in X. This prior is computed empirically by counting the amount of check-ins per location ID and normalizing, as explained in the paper.

### Simulation files (s01 to s07):
Each of these files simulates one location privacy protection mechanism, measures its privacy and quality loss and saves the results under `RESULTS` folder. The scripts compute more privacy metrics than those that we finally used in the figures of the paper. In order to select which dataset to load, please comment/uncomment the corresponding line at the beginning of the script.
1. `s01_eval_theoretical_coin.m` computes the performance of the Coin mechanism. Since this mechanism only generates a discrete set of outputs, the performance is computed arithmetically, obtaining exact results (see the paper for more information).
2. `s02_eval_empirical_noise.m` computes the performance of Laplacian, Gaussian and Circular noise with remapping. These mechanisms can generate outputs in all the plane, and therefore we cannot compute exactly their performance. Instead, we compute it empirically by repeating the experiment and averaging the results.
3. `s03_eval_theoretical_ExPost.m` computes the exact performance of the Exponential Posterior mechanism proposed in the paper.
4. `s04_eval_theoretical_exponential.m` computes the exact performance of the Exponential mechanism with remapping.
5. `s05_eval_empirical_noise_QmaxWC.m` generates the results of the noise-generation mechanisms with a maximum worst-case loss constraint that we set to 1.5km.
6. `s06_eval_theoretical_ExPost_QmaxWC.m` computes the exact performance of the ExPost mechanism using the worst-case loss constraint.
7. `s07_eval_theoretical_exponential_QmaxWC.m` computes the exact performance of the Exponential mechanism with remapping using the worst-case loss constraint.

When the mechanism has a discrete number of outputs and inputs (i.e., in all the cases but the noise-generation mechanisms), the mechanism is represented by an MxN left stochastic matrix `f` whose (j,i)-th element is the probability of choosing the j-th output location when the user is in the i-th input location.

### Representation files
1. `PLOT_RESULTS1.m` requires the results of the scripts s01 to s04 under the `RESULTS` folder. It reads the results of the unbounded mechanisms and plots them.
2. `PLOT_RESULTS2.m` requires the results of the scripts s05 to s07 under the `RESULTS` folder. It reads the results of the bounded (worst-case loss constrained) mechanisms and plots them.

In order to select from which dataset we want to plot the results, comment/uncomment the corresponding line at the beginning of the script.


## DISCRETE SYNTHETIC EXPERIMENT (`MatlabCCS17_Disc`)

In this experiment, we evaluate the performance of Shokri's optimal mechanism [3*], ExPost mechanism and the Coin mechanism, in a synthetic discrete scenario. The map is a 5x5 grid of locations with a label assigned to each one. We measure quality loss as the average loss using the Euclidean distance, and measure privacy as:
1. The average adversary error using the Euclidean distance.
2. The average adversary error using the semantic distance.
3. The conditional entropy.

### Main variables used:
- Number of locations or Points of Interest (`N`): scalar.
- Matrix of locations (`X`): this is an Nx2 matrix that contains the possible locations of the users. Each row of the matrix contains the Cartesian coordinates of a location.
- Input prior (`priorX`): this is an Nx1 column vector containing the probability mass function (prior) of the users in the locations defined in X. For this experiment, we assume it is uniform.
- Distance matrix (`DP`, `DQ`): this is an NxN matrix whose (j,i)-th element is the distance between the i-th input location and the j-th output location (in this experiment, the input and output alphabet of locations is the same, so this matrix is symmetric). Depending on the type of distance metric we use, we get a different matrix. In this experiment, we use `DQ` to compute the average loss, so we define it using the Euclidean distance. We use `DP` to compute Shokri's optimal mechanism when privacy is measured as the average semantic distance, so we define it using this semantic distance.
- Mechanism (`f`): we store the mechanism in an NxN left stochastic matrix whose (j,i)-th element is the probability of choosing the j-th output location when the user is in the i-th input location.

### Description of the files:
Main scripts:
- `s01_evaluate_synthetic.m`: This file runs the experiment and saves the results in `RESULTS_EVALUATE.mat`.
- `s01_plot_results.m`: This file loads the results in `RESULTS_EVALUATE.mat` and plots them as in the paper.

Functions:
- `get_distance_matrix.m`: This function computes a distance matrix given a type of distance (e.g., Euclidean or semantic) and the input and output alphabets.
- `get_mechanism.m`: Computes the mechanism matrix (f). It calls other functions:
> - `get_mechanism_expost.m`: When we want to get the ExPost mechanism.
> - `get_optimal_mechanism_Shokri.m`: When we want to get Shokri's optimal mechanism (either by using the simplex or the interior-point algorithm).
- `compute_metrics.m`: it computes the privacy and quality loss metrics given a mechanism and other parameters.


## References
[1*] Chatzikokolakis, Konstantinos, Ehab ElSalamouny, and Catuscia Palamidessi. "Efficient Utility Improvement for Location Privacy." Proceedings on Privacy Enhancing Technologies 2017.4 (2017): 308-328.

[2*] Cynthia Dwork. 2008. Differential privacy: A survey of results. In International Conference on Theory and Applications of Models of Computation. Springer, 1–19.

[3*] Reza Shokri, George Theodorakopoulos, Carmela Troncoso, Jean-Pierre Hubaux, and Jean-Yves Le Boudec. 2012. Protecting location privacy: optimal strategy against localization attacks. In Proceedings of the 2012 ACM conference on Computer and communications security. ACM, 617–627.
