# Matlab-Optimization

Matlab code for balance controller development. Files first uploaded from google drive - Jeremy& Graham Balance Controller MATLAB in folder FAll 2017/ Dynamic Balance Controls.

The files rhs.m, mainNavigation.m, and balanceControllerOptimizer.m are particularly important. rhs.m incorperates any sensor error. mainNavigation contains physical parameters about the bicycle. balanceControllerOptimizer uses a grid search to test a matrix of gains. The ranges for each gain, k1, k2, and k3 can be set. balanceControllerOptimizer can be run to make a list of viable gains.
