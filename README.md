# Process Control
# Control Strategies for Two-Tank Systems: PID vs. Intelligent Methods
## Table of content
* [Overview](#overview)
* [Control Strategies](#control-strategies)
* [Simulation Results](#simulation-results)
* [Members of group 5](#members-of-group-5)
## Overview
This project focuses on researching and applying the Deep Deterministic Policy Gradient (DDPG) reinforcement learning algorithm to a process control system, specifically a dual-tank water system model. The primary objective is to control the liquid temperature in the second tank ($T_4$) by adjusting the inflow rate ($F_3$).
Alongside DDPG, the project also develops and optimizes traditional and enhanced PID controllers to conduct direct performance comparisons and evaluations within the MATLAB/Simulink environment.
## Control Strategies
The project implements and compares 5 different control structures:
* **Conventional PID**: The standard PID controller.
* **Anti-windup PID**: Integrates an integral anti-windup mechanism (back-calculation method) to prevent saturation.
* **Kp-adaptive PID**: A PID controller with a proportional gain ($K_p$) that automatically adjusts based on the magnitude of the feedback error.
* **Kp-adaptive Anti-windup PID**: Combines both adaptive gain and anti-windup techniques to optimize response time and long-term stability.
* **Deep Deterministic Policy Gradient (DDPG)**: A model-free reinforcement learning algorithm utilizing an Actor-Critic neural network architecture to self-learn and generate optimal continuous control signals.
## Simulation Results
DDPG demonstrates vastly superior performance compared to all PID variants in terms of both response 
time and accuracy. It drives the liquid temperature to the desired setpoint in approximately 55 seconds, which is twice as fast as the best-tuned PID controller.  

| Criterion | DDPG | Conventional PID | PID + Anti-windup | PID + Adaptive Kp | PID + Adaptive Kp + Anti-windup |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Rise time (10-90%) [s]** | ~55 | ~120 | ~80 | 140 | 75 |
| **Overshoot [%]** | ~0 | ~5.4 | ~0 | 5.6 | ~0 |
| **Settling time [s]** | 70 | 175 | 250 | 160 | 260 |
| **Steady-state error** | ~0.0001 | ~0.03 | ~0.02 | ~0.05 | ~0.05 |

Data extracted from Table 1 in the project report.
## Members of group 5
Lai Quoc Dat, Nguyen Minh Anh, Hoang Phuc Lam, Tran Tung Lam (EE-TN-K67)