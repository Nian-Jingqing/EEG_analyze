function [outputArg1,outputArg2] = pizzaPlot()
%           Author: Anany Dwivedi
%           Date  : Jul-11-18
%           The University of Auckland
%      This script is used to for Single Trial Classification Task
%%
a = 0:30:360;
for i = 1:length(a)
    a(i)
    rd = deg2rad(a(i));
    a1 = 2*pi*rd;  % A random direction
    rad2deg(a1);
    theta = deg2rad(30);
    a2 = a1 + theta;
    t = linspace(a1,a2);
    x0 = 0;
    y0 = 0;
    r = 1;
    x = x0 + r*cos(t);
    y = y0 + r*sin(t);
    hold on
    fill([x0,x,x0],[y0,y,y0],'-y')
    colormap winter
    axis equal
    pause
end





end

