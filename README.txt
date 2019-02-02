3D Model of High Frequency Radar Systems Propagated Through the Ionosphere

Author:
    Kyle Ruzic

Date:
    August 30th 2018

========================================================================

This package generates a 3D model of SuperDARN Saskatoon's gain pattern propagated through the International Reference Ionosphere (IRI), an empirical model of the ionosphere.

========================================================================

Motivation

========================================================================

This project's motivation was to create a model that could be used to better understand high frequency (HF) radiowave propagation in the ionosphere. Specifically the goal was to create a model that could be used to compare to the data received by the radio receiver instrument (RRI), which is one of the eight scientific instruments that make up the enhanced Polar Outflow Probe (e-POP). The ability to compare the model to the data received by RRI will give us a better understanding of the data, and allow us to further explore regions of the ionosphere where we find discrepancies between the modelled data and the data received by RRI.

========================================================================

Methods

========================================================================

The first step in generating the model is to generate an ionospheric model, this is done using the IRI which is produced for a specific time, date, and region using a PHaRLAP routine. The next step in order to create the 3D model uses a technique know as raytracing, which is a computational efficient way of computing the path of light propagating through a medium with a non-uniform index of refraction, such as the ionosphere in the HF radiowave spectrum. To compute the path of the rays we use the Provision of High-frequency Raytracing LAboratory for Propagation studies (PHaRLAP), which is required to use this package but not included. To generate the model we create a 3D grid which represents latitudes, longitudes, and altitudes. We then trace the paths of roughly 100000 rays, then we implement a 3D binning algorithm which takes each point along the ray's path and places the power of the light in the bin corresponding to the points latitude, longitude, and altitude. To compute the power at each point of the ray we use the radar equation

P_r = P_s / (4 * pi * R^2)

Where P_s is the power of the radar at the source, and R is the length of the path that the ray has taken from the source. After this is completed for every ray the generation of the model is finished. In order to make comparisons of to RRI data an interpolant of the model needs to be made in order to compare the high sampling frequency of RRI, to the relatively low resolution of the model. The points along the path of RRI are queried against the interpolant and then that can be compared to RRI's data.  

========================================================================

How to use?

========================================================================

The basics of generating the model involve first generating the ionospheric grid, then calling the raytracer and the binning function. An example of how this would look is

[iono_struct, general_struct] = gen_iono_ns(UT)
rad_grid = rayCaller(dimensions, iono_struct, general_struct)

iono_struct is the structure containing the ionospheric grid and other necessary information, general_struct is the structure containing the general information that is necessary for ray tracing, and rad_grid is the generated 3D model. More information regarding these can be in found the documentation for these files. Examples of use are included.

