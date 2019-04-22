---
layout: default
title: State configuration
parent: /histogram-analysis/panels.html
grand_parent: /histogram-analysis.html
nav_order: 3
---

# State configuration
{: .no_toc }

<a href="../../assets/images/gui/HA-panel-state-configuration.png"><img src="../../assets/images/gui/HA-panel-state-configuration.png" style="max-width: 166px;"/></a>

## Panel components
{: .no_toc .text-delta }

1. TOC
{:toc}


---

## Maximum number of Gaussians

Defines the maximum model complexity to consider for model fitting, *i.e.*, the maximum number of Gaussian in the Gaussian mixture models to infer; see 
[Determine the most sufficient state configuration](../workflow.html#determine-the-most-sufficient-state-configuration) in Histogram analysis worklow for more information about state configuration analysis.

The maximum number of Gaussian in the model s the only parameter necessary to infer models. 
Press 
![Start analysis](../../assets/images/gui/HA-but-start-analysis.png) to start model inference.

**<u>default</u>:** 10


---

## Model penalty

Use this interface to define model overfitting penalty.

<img src="../../assets/images/gui/HA-panel-state-configuration-penalty.png" style="max-width: 160px;"/>

The overfitting penalty can be modified before or after inferring the different models, *i.e.*, before or after pressing 
![Start analysis](../../assets/images/gui/HA-but-start-analysis.png).

Model overfitting can be penalized in two ways:
* Minimum improvement in likelihood, by activating the option in **(a)** 
* using the Bayesian information criterion (BIC), by activating the option in **(c)**


### Defined improvement in likelihood
{: .no_toc }

With this penalty, a certain improvement in the model likelihood is expected when adding a new component to the model. 
The improvement is expressed as a multiplication factor that can be set in **(b)**: *e. g.* 1.2 for an improvement of 20%.

The most sufficient model is the first model for which adding a component does not fulfil this requirement.


### Bayesian information criterion
{: .no_toc }

With the BIC penalty, the BIC are used to rank models according to their sufficiency, with the most sufficient model having the lowest 
[*BIC*](){: .math_var }.

The 
[*BIC*](){: .math_var } is similar to a penalized likelihood and is expressed such as:

{: .equation }
<img src="../../assets/images/equations/HA-eq-bic.gif" alt="BIC = p(J) \times log( N_{\textup{total}} ) - \textup{log}\left [ likelihood( J ) \right ]">

with 
[*p*<sub>*J*</sub>](){: .math_var } the number of parameters necessary to describe the model with 
[*J*](){: .math_var } components and
[*N*<sub>total</sub>](){: .math_var } the total number of counts in the histogram.
The number of parameters necessary to describe the model includes the number of Gaussian means, 
[*p*<sub>means</sub>](){: .math_var }, standard deviations, 
[*p*<sub>widths</sub>](){: .math_var } and weights, 
[*p*<sub>weights</sub>](){: .math_var }, and is calculated such as:

{: .equation }
<img src="../../assets/images/equations/HA-eq-bic-02.gif" alt="p_{J} = p_{\textup{means}} + p_{\textup{widths}} + p_{\textup{weights}} = 3J - 1">


---

## Inferred models

Use this interface to visualize the results of state configuration analysis.

<img src="../../assets/images/gui/HA-panel-state-configuration-models.png" style="max-width: 150px;"/>

The number of components in the most sufficient model according to the 
[Model penalty](#model-penalty) is displayed in **(a)**.

Other inferred models can be visualized in the 
[Top axes](area-visualization.html#top-axes) by selecting the corresponding number of components in the list **(b)**. 
The log-likelihood and BIC of the selected model is then respectively displayed in **(c)** and **(d)**.

The parameters of any model can be imported in 
[Thresholding](panel-state-populations#thresholding) or 
[Gaussian fitting](panel-state-populations#gaussian-fitting) as starting guess for state population analysis, by pressing 
![>>](../../assets/images/gui/HA-but-supsup.png ">>").

Analysis results are summarized in a bar plot where the BIC or the increase in likelihood is presented, depending on the chosen 
[Model penalty](#model-penalty), in function of the number of components.

<img src="../../assets/images/gui/HA-panel-state-configuration-bic.png" style="max-width: 294px;"/>