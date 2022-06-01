## Paper (under review) 

E. Cookson and R.L. Detwiler (2022). Global patterns and temporal trends of perfluoroalkyl substances (PFAS) in Wastewater.  Manuscript submitted for publication to Water Research


## Overview

We present a meta-analysis of PFAS in wastewater reported in 44 peer-reviewed publications that include 460 influent and 528 effluent samples, collected from 21 countries, for which some or all of five PFCAs (PFHxA, PFHpA, PFOA, PFNA, PFDA) and three PFSA (PFBS, PFHxS, PFOS) were measured. 

We use linear mixed effect regression models of PFAS concentrations measured in wastewater effluent (collected from 2004 to 2020) to determine temporal trends of global wastewater effluent concentrations of each individual PFAS by country. 

We also show that national economic output is correlated with PFAS concentrations in municipal wastewater.

Lastly, we compare PFAS concentrations between (i) influent and effluent samples, (ii) samples with different source types, and (iii) liquid and solid suspended particulate matter samples collected from wastewater treatment plants. 


### data

------ Table_S1.xlsx ------	
Includes the entire meta-dataset of PFAS measured in wastewater.
	Used for Temporal regression.

------ Table_S2.xlsx ------	
Meta-dataset of PFAS measured in wastewater. Includes only reported mean concentrations or measurements of PFAS that could be connected to a specific sample. Because the temporal regression analysis considered each PFAS independently, we could use all reported data for that analysis. 
	Used for correlating PFAS or comparing between samples

------ Table_S3.xlsx ------	
Meta-dataset of PFAS concentrations measured in liquid [ng/L] and mass of PFAS adsorbed to suspended particulate matter per volume of wastewater [ng/L] within WWTPs. 
	Used for liquid-particulate partitioning 

------ GDP_per_cap_ALL.xlsx ------	
Includes national mean GDP per capita (in constant 2015 US$).  
(The World Bank, 2020. GDP per capita., https://data.worldbank.org/indicator/NY.GDP.PCAP.CD. Accessed: 2021-09-27)
	Used for GDP per capita analysis

### code

------ RunRegressionAnalysis.m (run) ------
Performs linear mixed effect regressions on log PFAS effluent concentrations.

LME1: Random effect intercepts (mean log concentrations by country) and fixed effect slope (global mean trend). 
	Performed on data from 17 countries 

LME2: Random effect intercepts (mean log concentrations by country) and random effect slope (country specific trend)
	Performed on subset of data from 5 countries

------ plotTemporalRegression.m (function) ------
Plots observations, linear model, and 2 linear mixed effect model regression results with respect to sample time. 

------ LME_TableResults.m (function) ------
Generates table of LME1 and LME2 parameter estimates for each individual PFAS and country. 
	
------ plot_bprime.m (function) ------
Generates figure of LME1 and LME2 estimated intercepts (by country and global mean), where the intercept represents the mean concentration in 2012. 

------ plot_mprime.m (function) ------
Generates figure of LME1 and LME2 estimated slopes (by country and global mean), where the slope indicates the estimated change in log concentration of each individual PFAS per year. 

------ plotUSandChina.m (function) ------
Generates figure of LME2 modeled PFAS concentrations for US and China. 

------ plotGDPpercapRegression.m (function) ------
Performs linear regression of log PFAS concentrations with respect to national GDP per capita during the sample period and generates figure. 


------ liq_particulate.m (run)------
Plots PFAS concentrations measured in liquid vs. adsorbed to particulate matter in wastewater.

------ inf_vs_eff (run) ------
Plots effluent concentrations vs influent concentrations

------ SourceType_PCA.m (run)------
Principal component analysis of PFAS effluent concentrations, plots with respect to wastewater source type

------ cell_str_2_num.m (function) ------ 
Converts ND values from '<LOD' to 0.5*LOD	 

------ magma.m (function) ------ 
Ander Biguri (2022). Perceptually uniform colormaps (https://www.mathworks.com/matlabcentral/fileexchange/51986-perceptually-uniform-colormaps), MATLAB Central File Exchange. Retrieved April 1, 2022.

