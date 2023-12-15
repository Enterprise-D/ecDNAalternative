## Alternative Method

We recently developed a neural network-based method to achieve a more specific and efficient ecDNA detection.

Before running the script, please have **PyTorch** and **scipy** installed in addition to the packages listed above.

```bash
python ecdna_detect_nn.py <INPUT_PATH> <OUTPUT_PATH> <PROB_CUTOFF> <NUM_PROCESSES>
```
The script will output a file which can also be processed by `CMPlot.R` to generate a Manhattan plot.

The model currently runs on CPU that allows for multiprocessing.

### Performance Comparison

The performance of prediction measured by ROC curve is significantly improved by the neural network model
on both our validation dataset (10% of our LC499/LC500 brain tumor dataset) and a separate dataset that represents colon cancer with distinct Hi-C pattern
that is hard to distinguish from ecDNA:

* **for validation dataset**:

![ROC1_NN.png](images%2FROC1_NN.png)

* **for LC676/LC677 dataset**:

![ROC2_NN.png](images%2FROC2_NN.png)

### Probability Cutoff Selection

Probability cutoff selection is a trade-off between sensitivity and specificity. 
For logistic regression, we chose 0.95 for minimized false positive rate. 
However, our current neural network model tends to reject more uncertain ecDNA candidates 
and pushes their predicted probability to a small number. Below is a comparison of the predicted probability on
a single cell (LC500_ACTAGGTGTTACCCAA) at different chromosomal bins (upper: logistic regression; lower: neural network):

* **linear model**:

![LC500_ACTAGGTGTTACCCAA_LM.png](images%2FLC500_ACTAGGTGTTACCCAA_LM.png)

* **neural model**:

![LC500_ACTAGGTGTTACCCAA_NN.png](images%2FLC500_ACTAGGTGTTACCCAA_NN.png)

On our validation dataset, we tested how different probability cutoffs affect prediction of positive and negative samples.
Figure below shows the difference between the true positive rate on positive samples and the false positive rate on negative samples.

![Delta.png](images%2FDelta.png)

Ideally this value should be maximized. However, choosing 0.05 as the cutoff will result in more false positives,
even though the true positive rate is at about 0.98 and the false positive rate is at about 0.02. 
Thus, we generally recommend a cutoff of 0.1 to 0.3 for the neural network model, depending on the desired sensitivity.
Figures below demonstrates effect on the Manhattan plot by choosing different cutoff using a mixed positive-negative dataset:

![Rect_Manhtn.0.05.jpg](images%2FRect_Manhtn.0.05.jpg)

![Rect_Manhtn.0.10.jpg](images%2FRect_Manhtn.0.10.jpg)

![Rect_Manhtn.0.15.jpg](images%2FRect_Manhtn.0.15.jpg)

![Rect_Manhtn.0.20.jpg](images%2FRect_Manhtn.0.20.jpg)

![Rect_Manhtn.0.30.jpg](images%2FRect_Manhtn.0.30.jpg)

![Rect_Manhtn.0.40.jpg](images%2FRect_Manhtn.0.40.jpg)

![Rect_Manhtn.0.50.jpg](images%2FRect_Manhtn.0.50.jpg)

## References

* O. Tange (2011): GNU Parallel - The Command-Line Power Tool, The USENIX Magazine, February 2011:42-47.
* Yin, L. et al. rMVP: A Memory-efficient, Visualization-enhanced, and Parallel-accelerated tool for Genome-Wide Association Study, Genomics, Proteomics & Bioinformatics (2021), doi: 10.1016/j.gpb.2020.10.007.
* The pandas development team (2020). pandas-dev/pandas: Pandas (Version latest). doi:10.5281/zenodo.3509134.
* Harris, C.R., Millman, K.J., van der Walt, S.J. et al. Array programming with NumPy. Nature 585, 357–362 (2020). DOI: 10.1038/s41586-020-2649-2.
* mckib2. (n.d.). Mckib2/Pygini: Compute the gini index. GitHub. https://github.com/mckib2/pygini

#### For alternative method:

* Adam Paszke, Sam Gross, Francisco Massa, Adam Lerer, James Bradbury, Gregory Chanan, Trevor Killeen, Zeming Lin, Natalia Gimelshein, Luca Antiga, Alban Desmaison, Andreas Köpf, Edward Yang, Zach DeVito, Martin Raison, Alykhan Tejani, Sasank Chilamkurthy, Benoit Steiner, Lu Fang, Junjie Bai, and Soumith Chintala. 2019. PyTorch: an imperative style, high-performance deep learning library. Proceedings of the 33rd International Conference on Neural Information Processing Systems. Curran Associates Inc., Red Hook, NY, USA, Article 721, 8026–8037.
* Pauli Virtanen, Ralf Gommers, Travis E. Oliphant, Matt Haberland, Tyler Reddy, David Cournapeau, Evgeni Burovski, Pearu Peterson, Warren Weckesser, Jonathan Bright, Stéfan J. van der Walt, Matthew Brett, Joshua Wilson, K. Jarrod Millman, Nikolay Mayorov, Andrew R. J. Nelson, Eric Jones, Robert Kern, Eric Larson, CJ Carey, İlhan Polat, Yu Feng, Eric W. Moore, Jake VanderPlas, Denis Laxalde, Josef Perktold, Robert Cimrman, Ian Henriksen, E.A. Quintero, Charles R Harris, Anne M. Archibald, Antônio H. Ribeiro, Fabian Pedregosa, Paul van Mulbregt, and SciPy 1.0 Contributors. (2020) SciPy 1.0: Fundamental Algorithms for Scientific Computing in Python. Nature Methods, 17(3), 261-272.

## Contact Us

For any question, contact Ming Hu (hum@ccf.org), Jiachen Sun (jxs2269@case.edu), or submit an issue on GitHub.