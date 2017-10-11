// mypid.sce
// Scilab.Ninja  August 2014
// setup script for mypidx.zcos
// in Scilab Recipe 3 article

s=poly(0,'s');
P = syslin('c',2/(s*(s+0.5)));

// impulse input creation
r.time = (0.01:0.01:10)';
r.values=zeros(1000,1); // start with all zeros
r.values(1:10,1) = 100; // r = 100, 0 < t <=0.1
r.values(501:510,1) = -100; // r = -100, 5.0 < t <= 5.1

