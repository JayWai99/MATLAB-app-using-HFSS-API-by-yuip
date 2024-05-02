##Capstone Project: A MATLAB App Using Third Party APIs
=====================================================

This is my capstone project which is about the implementation of 
simple optimization algorithms and connections to APIs in order to
perform optimizations on designs remotely and autonomously without 
having to constantly tweak the parameters in simulation software 
such as HFSS and CST. 

As of now, the app is capable of taking only three parameters: the
target frequency, the lower limit of the frequency range and the 
higher limit of the frequency range. These parameters will be parsed
into the program and it will start running the optimization algorithm
an arbitrary amount of times (currently set to 15) or until the best
value has been reached. A plot figure containing all of the attempts
will be generated after the algorithm has ended.

In the current version, only the HFSS API is being used. The API is 
developed by yuip. There are plans to add API for CST as well in 
the near future. Beyond that, there is also the next level of using
python instead of MATLAB, which requires a complete makeover of the 
app.