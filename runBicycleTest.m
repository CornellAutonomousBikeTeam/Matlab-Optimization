function [success, allStates] = runBicycleTest(x0,y0,v0,delta0,phi0, ...
                phi_dot0,psi0, K, delta_offset, numTimeSteps, graph)
%function to simulate a bicycle for given intial conditions and gains
%   similiar to the function mainNavigation developed in previous semesters
%   (look in Fall17_Jeremy_and_Graham folder)
%   written by Dylan Meehan (dem292), Spring 2018

% ARGUEMENTS:
% x0,y0: intial location
% v0: initial speed
% delta0: intial steer angle
% phi0: intial lean angle
% phi_dot0: intial derivative of lean angle
% psi0: intial yaw angle (heading)
% K: vector of gains (k1, k2, k3) 
    %reasonable gains are [70, 10, -20]
%delta_offset can be either a scalar (a constant offset), or a vector of
%   offsets (the bike will attempt to hit delta_offset(n) at the nth
%   timestep
%numTimeSteps is the number of time steps to run the simulation for
% graph: 1=  draws graph, 0 =does not

%define parameters
   p.g = 9.81; %acceleration due to gravity
   p.l = 1.02; %length of wheel base 
   p.b = 0.33; %distance from rear wheel to COM projected onto ground
   p.h = 0.516; %height of COM in point mass model
    % h is not the same as the height of COM of the bicycle, h is
    % calculated to place the center of mass so that the point
    % mass model and the real bicycle fall with the same frequency.
    % see ABT Fall 2017 report for further discussion.
   p.c = 0;   %trail

%simulation variables
timestep = 1/50;  %seconds
p.pause = timestep; %time to pause for animation

%handle scalar(constat) or vector (variable) delta_offset
if isscalar(delta_offset)
    delta_offset = ones(numTimeSteps,1).*delta_offset; 
end
%calculate lean correction for desired steer
phi_offset = v0^2/p.l/p.g.*delta_offset; %steady state relation between phi & delta
    %assumes constant velocity (v0)
   
%initialize arrays of state and actuator data
count = 1;
success = 1;
tstart = 0;
currentState = [tstart x0 y0 phi0 psi0 delta0 phi_dot0 v0];

%intialize arrays before going into loop
allStates = zeros(numTimeSteps,8);
motCommands = zeros(numTimeSteps,1);

%add initial values to arrays
allStates(1,:) = currentState; %keep track of the state at each timestep
motCommands(1) = 0; %command steer angle rate (delta dot) of front motor
 

 while (count < numTimeSteps)    
    count = count+1;
   [zdot, u] = rhs(currentState,p,K, delta_offset(count), phi_offset(count)); 
    %calculate derivatives based on EOM
    %also calculate u=delta_dot, the desired steer rate the keep balance
    %(count+1) gives rhs the delta_offset that the bike should be at the 
    %next timestep
 
   % If the lean angle is too high, the test should count as a failure,
   % ie, the bicycle falls over
   phi = currentState(4);
   if abs(phi)>=pi/4
       fprintf('Bike has Fallen; Test Failure\n')
       success = 0; %failure
       break;
   end
   
   %update state
   previousState = currentState;
   currentState(1,1) = previousState(1,1) + timestep; %update time
   currentState(1,2:end) = previousState(1,2:end) + zdot*timestep; %Euler integrate
   allStates(count,:) =  currentState; %record state
   motCommands(count) = u; %record motor commands
  
 end

 if graph == 1
     clf
     animateBike(allStates,p,motCommands,delta_offset, phi_offset);
     %animateBike is a rename of simulateBike from older MATLAB versions
 end

end

