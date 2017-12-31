#include "__cf_Mathematica_model.h"
#include <math.h>
#include "Mathematica_model_acc.h"
#include "Mathematica_model_acc_private.h"
#include <stdio.h>
#include "simstruc.h"
#include "fixedpoint.h"
#define CodeFormat S-Function
#define AccDefine1 Accelerator_S-Function
void Mathematica_model_acc_BINARYSEARCH_real_T ( uint32_T * piLeft , uint32_T
* piRght , real_T u , const real_T * pData , uint32_T iHi ) { * piLeft = 0U ;
* piRght = iHi ; if ( u <= pData [ 0 ] ) { * piRght = 0U ; } else if ( u >=
pData [ iHi ] ) { * piLeft = iHi ; } else { uint32_T i ; while ( ( * piRght -
* piLeft ) > 1U ) { i = ( * piLeft + * piRght ) >> 1 ; if ( u < pData [ i ] )
{ * piRght = i ; } else { * piLeft = i ; } } } } void
Mathematica_model_acc_LookUp_real_T_real_T ( real_T * pY , const real_T *
pYData , real_T u , const real_T * pUData , uint32_T iHi ) { uint32_T iLeft ;
uint32_T iRght ; Mathematica_model_acc_BINARYSEARCH_real_T ( & ( iLeft ) , &
( iRght ) , u , pUData , iHi ) ; { real_T lambda ; if ( pUData [ iRght ] >
pUData [ iLeft ] ) { real_T num ; real_T den ; den = pUData [ iRght ] ; den =
den - pUData [ iLeft ] ; num = u ; num = num - pUData [ iLeft ] ; lambda =
num / den ; } else { lambda = 0.0 ; } { real_T yLeftCast ; real_T yRghtCast ;
yLeftCast = pYData [ iLeft ] ; yRghtCast = pYData [ iRght ] ; yLeftCast +=
lambda * ( yRghtCast - yLeftCast ) ; ( * pY ) = yLeftCast ; } } } real_T
look1_binlxpw ( real_T u0 , const real_T bp0 [ ] , const real_T table [ ] ,
uint32_T maxIndex ) { real_T frac ; uint32_T iRght ; uint32_T iLeft ;
uint32_T bpIdx ; if ( u0 <= bp0 [ 0U ] ) { iLeft = 0U ; frac = ( u0 - bp0 [
0U ] ) / ( bp0 [ 1U ] - bp0 [ 0U ] ) ; } else if ( u0 < bp0 [ maxIndex ] ) {
bpIdx = maxIndex >> 1U ; iLeft = 0U ; iRght = maxIndex ; while ( iRght -
iLeft > 1U ) { if ( u0 < bp0 [ bpIdx ] ) { iRght = bpIdx ; } else { iLeft =
bpIdx ; } bpIdx = ( iRght + iLeft ) >> 1U ; } frac = ( u0 - bp0 [ iLeft ] ) /
( bp0 [ iLeft + 1U ] - bp0 [ iLeft ] ) ; } else { iLeft = maxIndex - 1U ;
frac = ( u0 - bp0 [ maxIndex - 1U ] ) / ( bp0 [ maxIndex ] - bp0 [ maxIndex -
1U ] ) ; } return ( table [ iLeft + 1U ] - table [ iLeft ] ) * frac + table [
iLeft ] ; } uint32_T plook_u32d_bincka ( real_T u , const real_T bp [ ] ,
uint32_T maxIndex ) { uint32_T bpIndex ; if ( u <= bp [ 0U ] ) { bpIndex = 0U
; } else if ( u < bp [ maxIndex ] ) { bpIndex = binsearch_u32d ( u , bp ,
maxIndex >> 1U , maxIndex ) ; } else { bpIndex = maxIndex ; } return bpIndex
; } uint32_T binsearch_u32d ( real_T u , const real_T bp [ ] , uint32_T
startIndex , uint32_T maxIndex ) { uint32_T iRght ; uint32_T iLeft ; uint32_T
bpIdx ; bpIdx = startIndex ; iLeft = 0U ; iRght = maxIndex ; while ( iRght -
iLeft > 1U ) { if ( u < bp [ bpIdx ] ) { iRght = bpIdx ; } else { iLeft =
bpIdx ; } bpIdx = ( iRght + iLeft ) >> 1U ; } return iLeft ; } static void
mdlOutputs ( SimStruct * S , int_T tid ) { real_T ipzy52tsjm ; real_T * lastU
; uint32_T bpIdx ; real_T jsrb33onvn ; real_T nwt0melich ; boolean_T
c1b0nickn2 ; real_T hu04bcknxm ; real_T oc4syfl12j ; real_T jdsyj3d5mg ;
real_T ianoxpm2to ; real_T cozery1uhb [ 4 ] ; real_T jnd04y4uo0 ; real_T
ikotht2gwn ; real_T matskzvjnn ; real_T a5fqf0lxdr ; real_T dwix1kbzzd ;
real_T bt53q1mk0l ; real_T jv0w1abvo0 ; real_T n04ltm0id2 ; real_T fhpsffrpq0
; real_T nahok5afkw ; real_T cmnpewtbmg ; real_T egydygwzwx ; real_T
g5shvx2k3j ; real_T gfkdm5li5l ; int32_T i ; real_T a11cpol2oe_idx_0 ; real_T
a11cpol2oe_idx_1 ; real_T a11cpol2oe_idx_2 ; real_T ojevlhc50d_idx_0 ; real_T
ojevlhc50d_idx_1 ; real_T addm3fix4d_idx_0 ; real_T addm3fix4d_idx_1 ;
n3qi1whofz * _rtB ; loikxjbxjg * _rtP ; f1xhd02yjc * _rtX ; ew10rzwqr2 *
_rtDW ; _rtDW = ( ( ew10rzwqr2 * ) ssGetRootDWork ( S ) ) ; _rtX = ( (
f1xhd02yjc * ) ssGetContStates ( S ) ) ; _rtP = ( ( loikxjbxjg * )
ssGetDefaultParam ( S ) ) ; _rtB = ( ( n3qi1whofz * ) _ssGetBlockIO ( S ) ) ;
_rtB -> kswpmaz1vi = _rtX -> fegg43lhks ; _rtB -> bn3tvkigpo = _rtX ->
ahg30lzxlw ; if ( ssIsSampleHit ( S , 1 , 0 ) ) { jsrb33onvn = _rtP -> P_11 ;
_rtB -> bzxsirbyhy = _rtP -> P_10 * _rtP -> P_11 ; } nwt0melich = _rtX ->
ajdd05tawb ; if ( ssIsSampleHit ( S , 1 , 0 ) ) { for ( i = 0 ; i < 2132 ; i
++ ) { _rtB -> agc4piqcue [ i ] = _rtP -> P_16 [ i ] ; _rtB -> laajzplhha [ i
] = _rtP -> P_17 [ i ] ; _rtB -> gkqhssjlnx [ i ] = _rtP -> P_18 [ i ] ; } }
_rtB -> eqkhnszfp4 = _rtP -> P_13 * _rtX -> ajdd05tawb * _rtP -> P_14 * _rtP
-> P_15 * _rtP -> P_0 ; _rtB -> jkou0ptwft = _rtX -> hrc3gk15yp ; if (
ssIsSampleHit ( S , 1 , 0 ) ) { Mathematica_model_acc_LookUp_real_T_real_T (
& ( _rtB -> gcxxkhjea2 ) , & _rtB -> laajzplhha [ 0 ] , _rtB -> jkou0ptwft ,
& _rtB -> agc4piqcue [ 0 ] , 2131U ) ;
Mathematica_model_acc_LookUp_real_T_real_T ( & ( _rtB -> ityuxxqu0l ) , &
_rtB -> gkqhssjlnx [ 0 ] , _rtB -> jkou0ptwft , & _rtB -> agc4piqcue [ 0 ] ,
2131U ) ; _rtB -> ahq5gcmurb = _rtP -> P_2 * muDoubleScalarSin ( _rtB ->
ityuxxqu0l ) ; _rtB -> aldk3l210k = _rtP -> P_3 * muDoubleScalarCos ( _rtB ->
ityuxxqu0l ) ; _rtB -> iikndqn5wk = _rtB -> gcxxkhjea2 * _rtB -> gcxxkhjea2 *
_rtP -> P_4 ; } if ( ( _rtDW -> k1dxfaf3zd >= ssGetT ( S ) ) && ( _rtDW ->
kh1yodgegj >= ssGetT ( S ) ) ) { egydygwzwx = 0.0 ; } else { egydygwzwx =
_rtDW -> k1dxfaf3zd ; lastU = & _rtDW -> c2cajusgb4 ; if ( _rtDW ->
k1dxfaf3zd < _rtDW -> kh1yodgegj ) { if ( _rtDW -> kh1yodgegj < ssGetT ( S )
) { egydygwzwx = _rtDW -> kh1yodgegj ; lastU = & _rtDW -> mbk2ybugtm ; } }
else { if ( _rtDW -> k1dxfaf3zd >= ssGetT ( S ) ) { egydygwzwx = _rtDW ->
kh1yodgegj ; lastU = & _rtDW -> mbk2ybugtm ; } } egydygwzwx = ( _rtB ->
gcxxkhjea2 - * lastU ) / ( ssGetT ( S ) - egydygwzwx ) ; } _rtB -> f2ars3elcd
= ( ( ( _rtB -> ahq5gcmurb + _rtB -> aldk3l210k ) + _rtB -> iikndqn5wk ) +
_rtP -> P_5 * egydygwzwx ) * _rtP -> P_6 ; if ( ssIsSampleHit ( S , 5 , 0 ) )
{ _rtB -> flslcuehf5 [ 0 ] = _rtB -> eqkhnszfp4 ; _rtB -> flslcuehf5 [ 1 ] =
_rtB -> jkou0ptwft ; _rtB -> flslcuehf5 [ 2 ] = _rtB -> gcxxkhjea2 ; _rtB ->
flslcuehf5 [ 3 ] = _rtB -> f2ars3elcd ; _rtB -> flslcuehf5 [ 4 ] = _rtB ->
ityuxxqu0l ; { const char * errMsg = ( NULL ) ; void * fp = ( void * ) _rtDW
-> nqhkdtsogs . FilePtr ; if ( fp != ( NULL ) ) { { real_T t ; void * u ; t =
ssGetTaskTime ( S , 5 ) ; u = ( void * ) & _rtB -> flslcuehf5 [ 0 ] ; errMsg
= rtwH5LoggingCollectionWrite ( 1 , fp , 0 , t , u ) ; if ( errMsg != ( NULL
) ) { ssSetErrorStatus ( S , errMsg ) ; return ; } } } } } if ( ssIsSampleHit
( S , 1 , 0 ) ) { hu04bcknxm = _rtP -> P_7 * _rtB -> gcxxkhjea2 ; } _rtB ->
oygil0ecmi = _rtP -> P_19 * _rtB -> f2ars3elcd ; if ( ssIsSampleHit ( S , 1 ,
0 ) ) { _rtB -> mexdrqsmtt = _rtDW -> newtrtpz3a ; } ipzy52tsjm = _rtB ->
oygil0ecmi - _rtB -> mexdrqsmtt ; c1b0nickn2 = ( ipzy52tsjm > _rtB ->
bzxsirbyhy ) ; if ( ssIsSampleHit ( S , 1 , 0 ) ) { _rtB -> hgerpqd1j3 = _rtP
-> P_21 * jsrb33onvn ; } if ( ipzy52tsjm < _rtB -> hgerpqd1j3 ) { ipzy52tsjm
= _rtB -> hgerpqd1j3 ; } if ( c1b0nickn2 ) { ipzy52tsjm = _rtB -> bzxsirbyhy
; } _rtB -> oav2adr3rh = ipzy52tsjm + _rtB -> mexdrqsmtt ; if ( _rtB ->
oav2adr3rh > _rtP -> P_22 ) { _rtB -> cxiwmpnn0r = _rtP -> P_22 ; } else if (
_rtB -> oav2adr3rh < _rtP -> P_23 ) { _rtB -> cxiwmpnn0r = _rtP -> P_23 ; }
else { _rtB -> cxiwmpnn0r = _rtB -> oav2adr3rh ; } if ( ssIsSampleHit ( S , 5
, 0 ) ) { _rtB -> finrbdee5r [ 0 ] = _rtB -> kswpmaz1vi ; _rtB -> finrbdee5r
[ 1 ] = _rtB -> bn3tvkigpo ; _rtB -> finrbdee5r [ 2 ] = _rtB -> cxiwmpnn0r ;
{ const char * errMsg = ( NULL ) ; void * fp = ( void * ) _rtDW -> mpwfrlevgy
. FilePtr ; if ( fp != ( NULL ) ) { { real_T t ; void * u ; t = ssGetTaskTime
( S , 5 ) ; u = ( void * ) & _rtB -> finrbdee5r [ 0 ] ; errMsg =
rtwH5LoggingCollectionWrite ( 1 , fp , 0 , t , u ) ; if ( errMsg != ( NULL )
) { ssSetErrorStatus ( S , errMsg ) ; return ; } } } } } if ( ssIsSampleHit (
S , 1 , 0 ) ) { _rtB -> acjscjs2az = _rtP -> P_24 ; _rtB -> ktuntb4xv2 = _rtP
-> P_25 * hu04bcknxm * _rtP -> P_26 ; ssCallAccelRunBlock ( S , 1 , 29 ,
SS_CALL_MDL_OUTPUTS ) ; _rtB -> iv0airqo3c = _rtP -> P_27 * _rtB ->
acjscjs2az ; } ipzy52tsjm = ssGetT ( S ) ; if ( ssIsSampleHit ( S , 1 , 0 ) )
{ _rtB -> ikn5fqu0yi = _rtP -> P_28 ; } if ( ipzy52tsjm > _rtP -> P_29 ) {
oc4syfl12j = _rtB -> iv0airqo3c - nwt0melich ; } else { oc4syfl12j = _rtB ->
ikn5fqu0yi ; } jdsyj3d5mg = _rtP -> P_30 * oc4syfl12j + _rtX -> ifza04w3ha ;
if ( jdsyj3d5mg > _rtP -> P_32 ) { _rtB -> d1wkf01cwb = _rtP -> P_32 ; } else
if ( jdsyj3d5mg < _rtP -> P_33 ) { _rtB -> d1wkf01cwb = _rtP -> P_33 ; } else
{ _rtB -> d1wkf01cwb = jdsyj3d5mg ; } if ( ssIsSampleHit ( S , 4 , 0 ) ) {
_rtB -> krazezbzjm = _rtB -> d1wkf01cwb ; } addm3fix4d_idx_0 = _rtX ->
jmpnadb2xr [ 0 ] ; addm3fix4d_idx_1 = _rtX -> jmpnadb2xr [ 1 ] ; ianoxpm2to =
_rtX -> no2yvgjlkj ; if ( ssIsSampleHit ( S , 1 , 0 ) ) { _rtB -> j0kuvl3x1w
= _rtP -> P_36 ; } for ( i = 0 ; i < 4 ; i ++ ) { n04ltm0id2 = _rtP -> P_37 [
i + 12 ] * _rtB -> j0kuvl3x1w + ( _rtP -> P_37 [ i + 8 ] * _rtX -> no2yvgjlkj
+ ( _rtP -> P_37 [ i + 4 ] * _rtX -> jmpnadb2xr [ 1 ] + _rtP -> P_37 [ i ] *
_rtX -> jmpnadb2xr [ 0 ] ) ) ; cozery1uhb [ i ] = n04ltm0id2 ; } jnd04y4uo0 =
_rtX -> lfqrqvuobl ; ikotht2gwn = muDoubleScalarCos ( _rtX -> lfqrqvuobl ) ;
jsrb33onvn = muDoubleScalarSin ( _rtX -> lfqrqvuobl ) ; _rtB -> ljlinodzfo =
cozery1uhb [ 0 ] * ikotht2gwn - cozery1uhb [ 1 ] * jsrb33onvn ; matskzvjnn =
_rtP -> P_39 * _rtB -> ljlinodzfo ; jsrb33onvn = ( cozery1uhb [ 0 ] *
jsrb33onvn + cozery1uhb [ 1 ] * ikotht2gwn ) * _rtP -> P_40 ; _rtB ->
j253uqk442 = ( jsrb33onvn - matskzvjnn ) * _rtP -> P_41 ; _rtB -> fbwuybf2ua
= ( ( 0.0 - matskzvjnn ) - jsrb33onvn ) * _rtP -> P_42 ; if ( ssIsSampleHit (
S , 2 , 0 ) ) { a11cpol2oe_idx_0 = _rtB -> ljlinodzfo ; a11cpol2oe_idx_1 =
_rtB -> j253uqk442 ; a11cpol2oe_idx_2 = _rtB -> fbwuybf2ua ; g5shvx2k3j = (
0.0 - _rtP -> P_43 * _rtB -> ljlinodzfo ) - _rtP -> P_44 * _rtB -> fbwuybf2ua
; ojevlhc50d_idx_0 = _rtDW -> llxpp1ykom [ 0 ] ; ojevlhc50d_idx_1 = _rtDW ->
llxpp1ykom [ 1 ] ; a5fqf0lxdr = _rtB -> krazezbzjm - ( _rtDW -> llxpp1ykom [
0 ] * g5shvx2k3j - _rtDW -> llxpp1ykom [ 1 ] * _rtB -> ljlinodzfo ) * 3.0 ;
if ( a5fqf0lxdr >= _rtP -> P_47 ) { _rtDW -> nopx0p4yup = true ; } else { if
( a5fqf0lxdr <= _rtP -> P_48 ) { _rtDW -> nopx0p4yup = false ; } } if ( _rtDW
-> nopx0p4yup ) { nahok5afkw = _rtP -> P_49 ; } else { nahok5afkw = _rtP ->
P_50 ; } if ( a5fqf0lxdr >= _rtP -> P_51 ) { _rtDW -> akqxqxqobp = true ; }
else { if ( a5fqf0lxdr <= _rtP -> P_52 ) { _rtDW -> akqxqxqobp = false ; } }
if ( _rtDW -> akqxqxqobp ) { a5fqf0lxdr = _rtP -> P_53 ; } else { a5fqf0lxdr
= _rtP -> P_54 ; } egydygwzwx = _rtDW -> llxpp1ykom [ 0 ] * _rtDW ->
llxpp1ykom [ 0 ] + _rtDW -> llxpp1ykom [ 1 ] * _rtDW -> llxpp1ykom [ 1 ] ; if
( egydygwzwx < 0.0 ) { egydygwzwx = - muDoubleScalarSqrt ( - egydygwzwx ) ; }
else { egydygwzwx = muDoubleScalarSqrt ( egydygwzwx ) ; } dwix1kbzzd = _rtP
-> P_55 - egydygwzwx ; if ( dwix1kbzzd >= _rtP -> P_56 ) { _rtDW ->
kp200i1k21 = true ; } else { if ( dwix1kbzzd <= _rtP -> P_57 ) { _rtDW ->
kp200i1k21 = false ; } } if ( _rtDW -> kp200i1k21 ) { dwix1kbzzd = _rtP ->
P_58 ; } else { dwix1kbzzd = _rtP -> P_59 ; } gfkdm5li5l = ( nahok5afkw +
a5fqf0lxdr ) + dwix1kbzzd ; } matskzvjnn = _rtX -> no2yvgjlkj * cozery1uhb [
1 ] * _rtP -> P_60 ; hu04bcknxm = matskzvjnn - _rtB -> cxiwmpnn0r ; if (
ssIsSampleHit ( S , 1 , 0 ) ) { _rtB -> jcpjjczswg = _rtP -> P_62 ; }
jsrb33onvn = _rtX -> jnh1pz1wp3 / _rtB -> jcpjjczswg ; ikotht2gwn =
look1_binlxpw ( jsrb33onvn , _rtP -> P_64 , _rtP -> P_63 , 9U ) ; n04ltm0id2
= look1_binlxpw ( jsrb33onvn , _rtP -> P_66 , _rtP -> P_65 , 9U ) ;
bt53q1mk0l = _rtX -> gdtwlc2hyw ; jv0w1abvo0 = _rtP -> P_68 * _rtX ->
gdtwlc2hyw ; egydygwzwx = ( ( ikotht2gwn - n04ltm0id2 * jv0w1abvo0 ) - _rtX
-> hndb30sywl ) - _rtX -> i4wrodozug ; ikotht2gwn = look1_binlxpw (
jsrb33onvn , _rtP -> P_72 , _rtP -> P_71 , 9U ) ; fhpsffrpq0 = look1_binlxpw
( jsrb33onvn , _rtP -> P_74 , _rtP -> P_73 , 9U ) ; _rtB -> minv23qqqn =
jv0w1abvo0 / fhpsffrpq0 - _rtX -> hndb30sywl / ( ikotht2gwn * fhpsffrpq0 ) ;
fhpsffrpq0 = look1_binlxpw ( jsrb33onvn , _rtP -> P_76 , _rtP -> P_75 , 9U )
; jsrb33onvn = look1_binlxpw ( jsrb33onvn , _rtP -> P_78 , _rtP -> P_77 , 9U
) ; _rtB -> emrd5kbpva = jv0w1abvo0 / jsrb33onvn - _rtX -> i4wrodozug / (
fhpsffrpq0 * jsrb33onvn ) ; fhpsffrpq0 = _rtP -> P_79 * egydygwzwx ; _rtB ->
c42kxux45v = _rtP -> P_80 * jv0w1abvo0 ; if ( ssIsSampleHit ( S , 2 , 0 ) ) {
if ( _rtP -> P_81 > _rtP -> P_82 ) { dwix1kbzzd = _rtP -> P_81 ; } else {
dwix1kbzzd = gfkdm5li5l ; } nahok5afkw = muDoubleScalarAtan2 (
ojevlhc50d_idx_1 , ojevlhc50d_idx_0 ) ; a5fqf0lxdr = _rtP -> P_83 ; if ( ! (
nahok5afkw > _rtP -> P_84 ) ) { nahok5afkw += _rtP -> P_83 ; } bpIdx =
plook_u32d_bincka ( nahok5afkw , _rtP -> P_86 , 6U ) ; nahok5afkw = _rtP ->
P_85 [ bpIdx ] ; if ( _rtP -> P_85 [ bpIdx ] > 5.0 ) { egydygwzwx = 5.0 ; }
else if ( _rtP -> P_85 [ bpIdx ] < 0.0 ) { egydygwzwx = 0.0 ; } else {
egydygwzwx = _rtP -> P_85 [ bpIdx ] ; } egydygwzwx = muDoubleScalarFloor (
egydygwzwx ) ; if ( dwix1kbzzd > 5.0 ) { n04ltm0id2 = 5.0 ; } else if (
dwix1kbzzd < 0.0 ) { n04ltm0id2 = 0.0 ; } else { n04ltm0id2 = dwix1kbzzd ; }
n04ltm0id2 = muDoubleScalarFloor ( n04ltm0id2 ) ; if ( muDoubleScalarIsNaN (
egydygwzwx ) || muDoubleScalarIsInf ( egydygwzwx ) ) { egydygwzwx = 0.0 ; }
else { egydygwzwx = muDoubleScalarRem ( egydygwzwx , 4.294967296E+9 ) ; } if
( muDoubleScalarIsNaN ( n04ltm0id2 ) || muDoubleScalarIsInf ( n04ltm0id2 ) )
{ n04ltm0id2 = 0.0 ; } else { n04ltm0id2 = muDoubleScalarRem ( n04ltm0id2 ,
4.294967296E+9 ) ; } bpIdx = ( uint32_T ) egydygwzwx * 18U + ( uint32_T )
n04ltm0id2 * 3U ; _rtB -> nqhbke2np3 [ 0 ] = _rtP -> P_87 [ bpIdx ] ; _rtB ->
nqhbke2np3 [ 1 ] = _rtP -> P_87 [ 1U + bpIdx ] ; _rtB -> nqhbke2np3 [ 2 ] =
_rtP -> P_87 [ 2U + bpIdx ] ; } _rtB -> eghi4yaz5o = _rtP -> P_88 *
hu04bcknxm ; _rtB -> kic55nm4ka = cozery1uhb [ 1 ] / ianoxpm2to * _rtP ->
P_90 + _rtP -> P_89 * nwt0melich ; _rtB -> df4xullp0x = ( _rtP -> P_91 *
cozery1uhb [ 0 ] - ianoxpm2to ) * _rtP -> P_92 ; _rtB -> oighq2zty3 = _rtP ->
P_94 * _rtX -> hywybbkv4d ; if ( ssIsSampleHit ( S , 2 , 0 ) ) { nahok5afkw =
_rtP -> P_95 ; dwix1kbzzd = muDoubleScalarMax ( muDoubleScalarMax (
muDoubleScalarAbs ( a11cpol2oe_idx_0 ) , muDoubleScalarAbs ( a11cpol2oe_idx_1
) ) , muDoubleScalarAbs ( a11cpol2oe_idx_2 ) ) - _rtP -> P_95 ; if (
dwix1kbzzd >= _rtP -> P_96 ) { _rtDW -> nb5jsqhypm = true ; } else { if (
dwix1kbzzd <= _rtP -> P_97 ) { _rtDW -> nb5jsqhypm = false ; } } if (
ojevlhc50d_idx_1 >= _rtP -> P_100 ) { _rtDW -> f2urx2raq2 = true ; } else {
if ( ojevlhc50d_idx_1 <= _rtP -> P_101 ) { _rtDW -> f2urx2raq2 = false ; } }
if ( _rtDW -> nb5jsqhypm ) { egydygwzwx = _rtP -> P_98 [ 0 ] ; } else {
egydygwzwx = _rtP -> P_99 [ 0 ] ; } if ( _rtDW -> f2urx2raq2 ) { n04ltm0id2 =
_rtP -> P_102 [ 0 ] ; } else { n04ltm0id2 = _rtP -> P_103 [ 0 ] ; } _rtB ->
pddqz3qowf [ 0 ] = egydygwzwx * n04ltm0id2 ; if ( _rtDW -> nb5jsqhypm ) {
egydygwzwx = _rtP -> P_98 [ 1 ] ; } else { egydygwzwx = _rtP -> P_99 [ 1 ] ;
} if ( _rtDW -> f2urx2raq2 ) { n04ltm0id2 = _rtP -> P_102 [ 1 ] ; } else {
n04ltm0id2 = _rtP -> P_103 [ 1 ] ; } _rtB -> pddqz3qowf [ 1 ] = egydygwzwx *
n04ltm0id2 ; if ( _rtDW -> nb5jsqhypm ) { egydygwzwx = _rtP -> P_98 [ 2 ] ; }
else { egydygwzwx = _rtP -> P_99 [ 2 ] ; } if ( _rtDW -> f2urx2raq2 ) {
n04ltm0id2 = _rtP -> P_102 [ 2 ] ; } else { n04ltm0id2 = _rtP -> P_103 [ 2 ]
; } _rtB -> pddqz3qowf [ 2 ] = egydygwzwx * n04ltm0id2 ; } if ( ipzy52tsjm >
_rtP -> P_104 ) { _rtB -> o2m0ybbytk [ 0 ] = _rtB -> nqhbke2np3 [ 0 ] ; _rtB
-> o2m0ybbytk [ 1 ] = _rtB -> nqhbke2np3 [ 1 ] ; _rtB -> o2m0ybbytk [ 2 ] =
_rtB -> nqhbke2np3 [ 2 ] ; } else { _rtB -> o2m0ybbytk [ 0 ] = _rtB ->
pddqz3qowf [ 0 ] ; _rtB -> o2m0ybbytk [ 1 ] = _rtB -> pddqz3qowf [ 1 ] ; _rtB
-> o2m0ybbytk [ 2 ] = _rtB -> pddqz3qowf [ 2 ] ; } if ( ssIsSampleHit ( S , 3
, 0 ) ) { _rtB -> l4umbfzxmu [ 0 ] = _rtB -> o2m0ybbytk [ 0 ] ; _rtB ->
l4umbfzxmu [ 1 ] = _rtB -> o2m0ybbytk [ 1 ] ; _rtB -> l4umbfzxmu [ 2 ] = _rtB
-> o2m0ybbytk [ 2 ] ; } _rtB -> i5eazkoock = _rtP -> P_105 * _rtB ->
oighq2zty3 ; if ( ssIsSampleHit ( S , 2 , 0 ) ) { if ( _rtB -> l4umbfzxmu [ 2
] > _rtP -> P_106 ) { dwix1kbzzd = _rtB -> oighq2zty3 ; } else { dwix1kbzzd =
_rtB -> i5eazkoock ; } if ( _rtB -> l4umbfzxmu [ 1 ] > _rtP -> P_107 ) {
nahok5afkw = _rtB -> oighq2zty3 ; } else { nahok5afkw = _rtB -> i5eazkoock ;
} _rtB -> lnwno3l2lj = dwix1kbzzd - nahok5afkw ; } jv0w1abvo0 =
muDoubleScalarCos ( jnd04y4uo0 ) ; if ( ssIsSampleHit ( S , 2 , 0 ) ) { if (
_rtB -> l4umbfzxmu [ 0 ] > _rtP -> P_109 ) { a5fqf0lxdr = _rtB -> oighq2zty3
; } else { a5fqf0lxdr = _rtB -> i5eazkoock ; } _rtB -> l1yxh4zu3e = (
nahok5afkw - a5fqf0lxdr ) * _rtP -> P_110 + _rtP -> P_108 * _rtB ->
lnwno3l2lj ; } jnd04y4uo0 = muDoubleScalarSin ( jnd04y4uo0 ) ; if (
ssIsSampleHit ( S , 1 , 0 ) ) { _rtB -> olzd1ogypk [ 0 ] = _rtP -> P_112 [ 0
] ; _rtB -> olzd1ogypk [ 1 ] = _rtP -> P_112 [ 1 ] ; _rtB -> olzd1ogypk [ 2 ]
= _rtP -> P_112 [ 2 ] ; _rtB -> olzd1ogypk [ 3 ] = _rtP -> P_112 [ 3 ] ; }
_rtB -> dart3hvpjp [ 0 ] = ( ( _rtB -> lnwno3l2lj * jv0w1abvo0 + _rtB ->
l1yxh4zu3e * jnd04y4uo0 ) - _rtP -> P_111 * cozery1uhb [ 0 ] ) - ( _rtB ->
kic55nm4ka * _rtB -> olzd1ogypk [ 0 ] * addm3fix4d_idx_0 + _rtB -> kic55nm4ka
* _rtB -> olzd1ogypk [ 2 ] * addm3fix4d_idx_1 ) ; _rtB -> dart3hvpjp [ 1 ] =
( ( _rtB -> l1yxh4zu3e * jv0w1abvo0 - _rtB -> lnwno3l2lj * jnd04y4uo0 ) -
_rtP -> P_111 * cozery1uhb [ 1 ] ) - ( _rtB -> kic55nm4ka * _rtB ->
olzd1ogypk [ 1 ] * addm3fix4d_idx_0 + _rtB -> kic55nm4ka * _rtB -> olzd1ogypk
[ 3 ] * addm3fix4d_idx_1 ) ; _rtB -> kf3qltm3zh = ( _rtB -> d1wkf01cwb -
jdsyj3d5mg ) * _rtP -> P_114 + _rtP -> P_113 * oc4syfl12j ; _rtB ->
krvwdttey1 = ( ( bt53q1mk0l - _rtP -> P_115 * _rtX -> hywybbkv4d ) - ( ( _rtP
-> P_116 * _rtB -> ljlinodzfo * _rtB -> l4umbfzxmu [ 2 ] + _rtP -> P_116 *
_rtB -> j253uqk442 * _rtB -> l4umbfzxmu [ 1 ] ) + _rtP -> P_116 * _rtB ->
fbwuybf2ua * _rtB -> l4umbfzxmu [ 0 ] ) ) * _rtP -> P_117 ; _rtB ->
cgpl3hbsnw = ( fhpsffrpq0 - _rtX -> hywybbkv4d ) * _rtP -> P_118 ; if (
ssIsSampleHit ( S , 2 , 0 ) ) { cmnpewtbmg = a5fqf0lxdr - dwix1kbzzd ; } _rtB
-> jw4us4vceg = bt53q1mk0l * fhpsffrpq0 ; _rtB -> mvvn2pdaxj = matskzvjnn *
nwt0melich ; if ( ssIsSampleHit ( S , 2 , 0 ) ) { _rtB -> mdlihjfhr1 [ 0 ] =
_rtB -> lnwno3l2lj - _rtP -> P_121 * a11cpol2oe_idx_0 ; _rtB -> mdlihjfhr1 [
1 ] = ( ( 0.0 - _rtP -> P_119 * _rtB -> lnwno3l2lj ) - _rtP -> P_120 *
cmnpewtbmg ) - _rtP -> P_121 * g5shvx2k3j ; } UNUSED_PARAMETER ( tid ) ; }
#define MDL_UPDATE
static void mdlUpdate ( SimStruct * S , int_T tid ) { real_T * lastU ;
n3qi1whofz * _rtB ; loikxjbxjg * _rtP ; ew10rzwqr2 * _rtDW ; _rtDW = ( (
ew10rzwqr2 * ) ssGetRootDWork ( S ) ) ; _rtP = ( ( loikxjbxjg * )
ssGetDefaultParam ( S ) ) ; _rtB = ( ( n3qi1whofz * ) _ssGetBlockIO ( S ) ) ;
if ( _rtDW -> k1dxfaf3zd == ( rtInf ) ) { _rtDW -> k1dxfaf3zd = ssGetT ( S )
; lastU = & _rtDW -> c2cajusgb4 ; } else if ( _rtDW -> kh1yodgegj == ( rtInf
) ) { _rtDW -> kh1yodgegj = ssGetT ( S ) ; lastU = & _rtDW -> mbk2ybugtm ; }
else if ( _rtDW -> k1dxfaf3zd < _rtDW -> kh1yodgegj ) { _rtDW -> k1dxfaf3zd =
ssGetT ( S ) ; lastU = & _rtDW -> c2cajusgb4 ; } else { _rtDW -> kh1yodgegj =
ssGetT ( S ) ; lastU = & _rtDW -> mbk2ybugtm ; } * lastU = _rtB -> gcxxkhjea2
; if ( ssIsSampleHit ( S , 1 , 0 ) ) { _rtDW -> newtrtpz3a = _rtB ->
oav2adr3rh ; } if ( ssIsSampleHit ( S , 2 , 0 ) ) { _rtDW -> llxpp1ykom [ 0 ]
+= _rtP -> P_45 * _rtB -> mdlihjfhr1 [ 0 ] ; _rtDW -> llxpp1ykom [ 1 ] +=
_rtP -> P_45 * _rtB -> mdlihjfhr1 [ 1 ] ; } UNUSED_PARAMETER ( tid ) ; }
#define MDL_DERIVATIVES
static void mdlDerivatives ( SimStruct * S ) { n3qi1whofz * _rtB ; pqmvzr1kvu
* _rtXdot ; _rtXdot = ( ( pqmvzr1kvu * ) ssGetdX ( S ) ) ; _rtB = ( (
n3qi1whofz * ) _ssGetBlockIO ( S ) ) ; _rtXdot -> fegg43lhks = _rtB ->
jw4us4vceg ; _rtXdot -> ahg30lzxlw = _rtB -> mvvn2pdaxj ; _rtXdot ->
ajdd05tawb = _rtB -> eghi4yaz5o ; _rtXdot -> hrc3gk15yp = _rtB -> eqkhnszfp4
; _rtXdot -> ifza04w3ha = _rtB -> kf3qltm3zh ; _rtXdot -> jmpnadb2xr [ 0 ] =
_rtB -> dart3hvpjp [ 0 ] ; _rtXdot -> jmpnadb2xr [ 1 ] = _rtB -> dart3hvpjp [
1 ] ; _rtXdot -> no2yvgjlkj = _rtB -> df4xullp0x ; _rtXdot -> lfqrqvuobl =
_rtB -> kic55nm4ka ; _rtXdot -> jnh1pz1wp3 = _rtB -> c42kxux45v ; _rtXdot ->
gdtwlc2hyw = _rtB -> cgpl3hbsnw ; _rtXdot -> hndb30sywl = _rtB -> minv23qqqn
; _rtXdot -> i4wrodozug = _rtB -> emrd5kbpva ; _rtXdot -> hywybbkv4d = _rtB
-> krvwdttey1 ; } static void mdlInitializeSizes ( SimStruct * S ) {
ssSetChecksumVal ( S , 0 , 3575400345U ) ; ssSetChecksumVal ( S , 1 ,
161930439U ) ; ssSetChecksumVal ( S , 2 , 3019783971U ) ; ssSetChecksumVal (
S , 3 , 3932609387U ) ; { mxArray * slVerStructMat = NULL ; mxArray *
slStrMat = mxCreateString ( "simulink" ) ; char slVerChar [ 10 ] ; int status
= mexCallMATLAB ( 1 , & slVerStructMat , 1 , & slStrMat , "ver" ) ; if (
status == 0 ) { mxArray * slVerMat = mxGetField ( slVerStructMat , 0 ,
"Version" ) ; if ( slVerMat == NULL ) { status = 1 ; } else { status =
mxGetString ( slVerMat , slVerChar , 10 ) ; } } mxDestroyArray ( slStrMat ) ;
mxDestroyArray ( slVerStructMat ) ; if ( ( status == 1 ) || ( strcmp (
slVerChar , "8.3" ) != 0 ) ) { return ; } } ssSetOptions ( S ,
SS_OPTION_EXCEPTION_FREE_CODE ) ; if ( ssGetSizeofDWork ( S ) != sizeof (
ew10rzwqr2 ) ) { ssSetErrorStatus ( S ,
"Unexpected error: Internal DWork sizes do "
"not match for accelerator mex file." ) ; } if ( ssGetSizeofGlobalBlockIO ( S
) != sizeof ( n3qi1whofz ) ) { ssSetErrorStatus ( S ,
"Unexpected error: Internal BlockIO sizes do "
"not match for accelerator mex file." ) ; } { int ssSizeofParams ;
ssGetSizeofParams ( S , & ssSizeofParams ) ; if ( ssSizeofParams != sizeof (
loikxjbxjg ) ) { static char msg [ 256 ] ; sprintf ( msg ,
"Unexpected error: Internal Parameters sizes do "
"not match for accelerator mex file." ) ; } } _ssSetDefaultParam ( S , (
real_T * ) & o2iu0a2jke ) ; rt_InitInfAndNaN ( sizeof ( real_T ) ) ; } static
void mdlInitializeSampleTimes ( SimStruct * S ) { } static void mdlTerminate
( SimStruct * S ) { }
#include "simulink.c"
