Capstone Project: A MATLAB App Using Third Party APIs
=====================================================

This is my capstone project which is about the implementation of 
simple optimization algorithms and connections to APIs in order to
perform optimizations on designs remotely and autonomously without 
having to constantly tweak the parameters in simulation software 
such as HFSS and CST. 

As of now, the app is only able to run by selecting the dipole model.
The user can enter three frequency values and configure the number of
iteration before commencing the optimisation process. The user inputs
will be parsed to the program, and the program will run until either 
the target frequency has been found or the program has hit the upper
limit for the number of iterations predefined by the user.  

In the current version, only the HFSS API is being used. The API is 
developed by yuip. There are plans to add API for CST as well in 
the near future. Beyond that, there is also the next level of using
python instead of MATLAB, which requires a complete makeover of the 
app.

The link to yuip's page for the API is [here](https://github.com/yuip/hfss-api)
