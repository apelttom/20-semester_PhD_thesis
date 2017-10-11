function MWS = setup_HPC(MWS)
%		T-MATS -- setup_HPC.m
% *************************************************************************
% written by Jeffryes Chapman
% NASA Glenn Research Center, Cleveland, OH
% Dec 18th, 2012
%
% This function creates the properties of the HPC component for the Plant model
% example.
% *************************************************************************
            
  
 MWS.HPC.NcVec = [0.500 0.600 0.700 0.750 0.800 0.850 0.900 0.925...
                   0.950 0.975 1.000 1.025 1.050 2];

 MWS.HPC.RlineVec = [    1.000    1.200    1.400    1.600    1.800    2.000...
                       2.200    2.400    2.600    2.800    3.000 ];


%========== Wc = f(NcMap, RlineMap) ==================
 MWS.HPC.WcArray = [ 22.7411  24.0487  25.1548  26.0615  26.7738  27.2992...
                    27.6470  27.8286  27.8634  27.8634  27.8634;
                    31.7548  33.1181  34.2670  35.2054  35.9397  36.4783...
                    36.8308  37.0085  37.0362  37.0362  37.0362;
                    46.1066  47.4088  48.5066  49.4046  50.1096  50.6291...
                    50.9717  51.1469  51.1757  51.1757  51.1757;
                    56.7268  58.0480  59.1608  60.0704  60.7837  61.3084...
                    61.6527  61.8260  61.8517  61.8517  61.8517;
                    70.1448  71.5163  72.6688  73.6088  74.3429  74.8795...
                    75.2269  75.3943  75.4134  75.4134  75.4134;
                    89.3764  90.9746  92.3098  93.3900  94.2232  94.8199...
                    95.1897  95.3442  95.3504  95.3504  95.3504;
                    118.0620 120.1207 121.8253 123.1867 124.2166 124.9292...
                    125.3385 125.4609 125.4609 125.4609 125.4609;
                    138.5093 140.8966 142.8639 144.4238 145.5916 146.3836...
                    146.8174 146.9192 146.9192 146.9192 146.9192;
                    160.6243 162.5676 164.1805 165.4722 166.4536 167.1370...
                    167.5334 167.6563 167.6563 167.6563 167.6563;
                    181.7993 183.4993 184.9150 186.0545 186.9260 187.5389...
                    187.9029 188.0273 188.0271 188.0271 188.0271;
                    202.6315 203.5858 204.3958 205.0661 205.5998 206.0000...
                    206.2702 206.4145 206.4418 206.4418 206.4418;
                    209.9986 210.5917 211.1029 211.5321 211.8825 212.1554...
                    212.3516 212.4735 212.5220 212.5227 212.5227;
                    216.6847 217.0279 217.3287 217.5860 217.8015 217.9767...
                    218.1106 218.2041 218.2586 218.2739 218.2739 ;
                    216.6847 217.0279 217.3287 217.5860 217.8015 217.9767...
                    218.1106 218.2041 218.2586 218.2739 218.2739];
							  				      							       							      							       				   
%========== eff = f(NcMap, RlineMap) ==================
 MWS.HPC.EffArray = [0.6753 0.6913 0.7016 0.7050 0.7004 0.6864 0.6570...
                        0.6044 0.5236 0.4075 0.2467;
                        0.6953 0.7094 0.7184 0.7214 0.7176 0.7058 0.6812...
                        0.6378 0.5717 0.4783 0.3512 ;
                        0.7248 0.7359 0.7429 0.7452 0.7424 0.7335 0.7154...
                        0.6838 0.6366 0.5713 0.4848 ;
                        0.7427 0.7533 0.7600 0.7627 0.7606 0.7533 0.7379...
                        0.7108 0.6703 0.6147 0.5414 ;
                        0.7634 0.7736 0.7804 0.7834 0.7822 0.7762 0.7630...
                        0.7394 0.7041 0.6556 0.5920 ;
                        0.7891 0.8008 0.8090 0.8134 0.8136 0.8092 0.7974...
                        0.7754 0.7417 0.6950 0.6335 ;
                        0.8139 0.8280 0.8385 0.8449 0.8469 0.8439 0.8333...
                        0.8117 0.7779 0.7303 0.6671 ;
                        0.8206 0.8356 0.8469 0.8541 0.8567 0.8544 0.8442...
                        0.8229 0.7892 0.7416 0.6783 ;
                        0.8403 0.8512 0.8593 0.8643 0.8660 0.8641 0.8566...
                        0.8415 0.8179 0.7852 0.7423 ;
                        0.8408 0.8492 0.8552 0.8588 0.8597 0.8578 0.8516...
                        0.8394 0.8209 0.7954 0.7624 ;
                        0.8470 0.8505 0.8529 0.8539 0.8536 0.8520 0.8483...
                        0.8418 0.8324 0.8200 0.8043 ;
                        0.8350 0.8364 0.8371 0.8370 0.8362 0.8346 0.8318...
                        0.8275 0.8217 0.8141 0.8049 ;
                        0.8202 0.8203 0.8201 0.8195 0.8185 0.8171 0.8152...
                        0.8124 0.8088 0.8045 0.7992 ;
                        0.8202 0.8203 0.8201 0.8195 0.8185 0.8171 0.8152...
                        0.8124 0.8088 0.8045 0.7992];

%========== PR = f(NcMap, RlineMap) ==================
 MWS.HPC.PRArray = [ 2.4769  2.4288  2.3620  2.2778  2.1774  2.0627... 
                        1.9284  1.7711  1.5958  1.4083  1.2146 ;
                        3.4633  3.3778  3.2643  3.1248  2.9619  2.7787...
                        2.5679  2.3253  2.0595  1.7802  1.4973 ;
                        5.0821  4.9375  4.7554  4.5391  4.2923  4.0194... 
                        3.7106  3.3602  2.9800  2.5826  2.1813 ;
                        6.3490  6.1658  5.9371  5.6667  5.3594  5.0204...
                        4.6377  4.2042  3.7342  3.2431  2.7467 ;
                        8.0021  7.7686  7.4792  7.1388  6.7532  6.3287...
                        5.8504  5.3097  4.7237  4.1114  3.4919 ;
                        10.4899 10.1976  9.8249  9.3786  8.8669  8.2989...
                        7.6539  6.9201  6.1229  5.2899  4.4495 ;
                        14.4564 14.0970 13.6074 12.9977 12.2808 11.4715...
                        10.5377  9.4621  8.2878  7.0614  5.8306 ;
                        17.4426 17.0500 16.4870 15.7661 14.9034 13.9183...
                        12.7692 11.4347  9.9718  8.4425  6.9104 ;
                        20.7403 20.2486 19.6093 18.8329 17.9324 16.9227...
                        15.7626 14.4263 12.9562 11.3983  9.8011 ;
                        23.8298 23.2601 22.5536 21.7200 20.7705 19.7178...
                        18.5212 17.1524 15.6466 14.0424 12.3810 ;
                        26.6962 26.0933 25.4175 24.6733 23.8656 22.9999...
                        22.0495 20.9930 19.8436 18.6163 17.3267 ;
                        27.6439 27.0687 26.4522 25.7969 25.1052 24.3798...
                        23.6033 22.7614 21.8600 20.9058 19.9057 ;
                        28.4663 27.9667 27.4460 26.9054 26.3460 25.7690...
                        25.1640 24.5225 23.8472 23.1399 22.4038 ;
                        28.4663 27.9667 27.4460 26.9054 26.3460 25.7690...
                        25.1640 24.5225 23.8472 23.1399 22.4038];

%------ scaler for corrected flow -------------
MWS.HPC.s_Wc = 0.4953;

%--------- scaler for pressure ratio ----------
MWS.HPC.s_PR = 0.8636; 

%--------- scaler for efficiency ----------  
MWS.HPC.s_eff = 0.9977;

%--------- scaler for corrected HPC speed ----------
 MWS.HPC.s_Nc = 1/ 0.0001;

 %--------- Define surge line ----------
 MWS.HPC.WcMapSurge = [22.7411 31.7548 46.1066 56.7268 70.1448 89.376...
                       118.062 138.509 160.624 181.799 202.631 209.9986...
                       216.684 218.2739];
 MWS.HPC.PRMapSurge =[2.4769    3.4633    5.0821    6.3490    8.0021...  
                      10.4899   14.4564   17.4426   20.7403   23.8298...
                      26.6962   27.6439   28.4663   28.6619];
 