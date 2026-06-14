// Pseudo-HLSL generated from compiled shader bytecode.
// Source container: fft128_cs.win.dx11.fxo
//
// This is reconstructed for reading only.
// It is not original HLSL and should not be treated as recompilable source.

// -----------------------------------------------------------------------------
// Shader 0
// Profile: cs_5_0
// Byte offset: 22936
// Byte length: 1848
// -----------------------------------------------------------------------------

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// g_readTexture                     texture  float2          2d             t0      1 
// g_writeTexture                        UAV  float2          2d             u0      1

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// no Input

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// no Output

[numthreads(128, 1, 1)]
void cs_00_cs_5_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_globalFlags refactoringAllowed
    // dcl_resource_texture2d (float,float,float,float) t0
    // dcl_uav_typed_texture2d (float,float,float,float) u0
    // dcl_input vThreadGroupID.x
    // dcl_input vThreadIDInGroup.x
    float4 r[6];
    // dcl_tgsm_structured g0, 1024, 2
    // numthreads(128, 1, 1)
    // asm: bfrev r0.x, vThreadIDInGroup.x
    r0.x = r0.x >> l(25);
    r0.x = r0.x << l(3);
    r1.x = vThreadGroupID.x;
    r1.y = vThreadIDInGroup.x;
    r1.zw = l(0,0,0,0);
    // asm: ld_indexable(texture2d)(float,float,float,float) r0.yz, r1.xyzw, t0.zxyw
    store_structured(g0.xy, l(0), r0.x, r0.yzyy);
    // asm: sync_g_t
    r0.x = vThreadIDInGroup.x << l(3);
    r0.yz = l(0,0,1,0);
    while (true) {
        r0.w = (l(7) < r0.z);
        if (r0.w) { break; }
        r0.w = l(1) << r0.z;
        r1.z = r0.w >> l(1);
        // asm: udiv r0.w, null, l(128), r0.w
        null = r0.w * r0.w;
        r0.w = r0.w & l(127);
        // asm: bfi r1.w, r0.z, l(0), l(0), vThreadIDInGroup.x
        r2.x = r1.z + l(-1);
        r2.x = r2.x & vThreadIDInGroup.x;
        r0.w = (float)r0.w;
        r0.w = r0.w * l(0.049087);
        sincos(r3.x, r4.x, r0.w);
        r0.w = r1.w + r2.x;
        r1.z = r1.z + r0.w;
        r1.w = r1.z << l(3);
        r1.w = load_structured(r0.y, r1.w, g0.xxxx);
        r1.z = (r1.z * l(8)) + l(4);
        r1.z = load_structured(r0.y, r1.z, g0.xxxx);
        r2.x = r0.w << l(3);
        r2.x = load_structured(r0.y, r2.x, g0.xxxx);
        r0.w = (r0.w * l(8)) + l(4);
        r2.y = load_structured(r0.y, r0.w, g0.xxxx);
        r0.y = -r0.y + l(1);
        r0.w = r1.z * r3.x;
        r5.x = (r4.x * r1.w) + -r0.w;
        r0.w = r1.z * r4.x;
        r5.y = (r3.x * r1.w) + r0.w;
        r1.zw = r2.xxxy + r5.xxxy;
        store_structured(g0.xy, r0.y, r0.x, r1.zwzz);
        // asm: sync_g_t
        r0.z = r0.z + l(1);
    }
    r0.xy = load_structured(l(1), r0.x, g0.xyxx);
    store_uav_typed(u0.xyzw, r1.yxxx, r0.xyxx);
    return;
    // asm: // Approximately 48 instruction slots used
}

// -----------------------------------------------------------------------------
// Shader 1
// Profile: cs_5_0
// Byte offset: 24884
// Byte length: 1592
// -----------------------------------------------------------------------------

// Reflected buffer definitions
cbuffer $Globals
{
  bool g_isTAAEnabledBranch;         // Offset:    0 Size:     4 [unused]
     = 0xffffffff 
  float g_fftPatchSize;              // Offset:    4 Size:     4 [unused]
  float g_fftChoppyScale;            // Offset:    8 Size:     4
  float g_tileSizeX2;                // Offset:   12 Size:     4 [unused]
  float g_waveFoamFadeRate;          // Offset:   16 Size:     4 [unused]
  float g_waveFoamCoverage;          // Offset:   20 Size:     4 [unused]
}

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// g_heightfieldTexture              texture  float2          2d             t0      1 
// g_choppyfieldTexture              texture  float2          2d             t1      1 
// g_displacementOutTexture              UAV  float4          2d             u0      1 
// $Globals                          cbuffer      NA          NA            cb0      1

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// no Input

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// no Output

[numthreads(16, 16, 1)]
void cs_01_cs_5_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_globalFlags refactoringAllowed
    // dcl_constantbuffer CB0[1], immediateIndexed
    // dcl_resource_texture2d (float,float,float,float) t0
    // dcl_resource_texture2d (float,float,float,float) t1
    // dcl_uav_typed_texture2d (float,float,float,float) u0
    // dcl_input vThreadID.xy
    float4 r[3];
    // numthreads(16, 16, 1)
    r0.xy = (l(128, 128, 0, 0) < vThreadID.xyxx);
    r0.x = r0.y | r0.x;
    if (r0.x) {
        return;
    }
    r0.x = vThreadID.y + vThreadID.x;
    r0.x = r0.x & l(1);
    r0.x = (r0.x == l(1));
    r0.x = (r0.x) ? l(-1.000000) : l(1.000000);
    r1.xy = vThreadID.xyxx;
    r1.zw = l(0,0,0,0);
    // asm: ld_indexable(texture2d)(float,float,float,float) r0.y, r1.xyww, t0.yxzw
    r2.x = r0.y * r0.x;
    // asm: ld_indexable(texture2d)(float,float,float,float) r0.yz, r1.xyzw, t1.zxyw
    r0.xy = r0.yzyy * r0.xxxx;
    r2.yz = r0.xxyx * cb0[0].zzzz;
    r2.w = l(0);
    store_uav_typed(u0.xyzw, vThreadID.xyyy, r2.xyzw);
    return;
    // asm: // Approximately 19 instruction slots used
}

// -----------------------------------------------------------------------------
// Shader 2
// Profile: cs_5_0
// Byte offset: 26608
// Byte length: 13008
// -----------------------------------------------------------------------------

// Reflected buffer definitions
cbuffer $Globals
{
  bool g_isTAAEnabledBranch;         // Offset:    0 Size:     4 [unused]
     = 0xffffffff 
  float g_fftPatchSize;              // Offset:    4 Size:     4
  float g_fftChoppyScale;            // Offset:    8 Size:     4
  float g_tileSizeX2;                // Offset:   12 Size:     4
  float g_waveFoamFadeRate;          // Offset:   16 Size:     4
  float g_waveFoamCoverage;          // Offset:   20 Size:     4
}
cbuffer PerFrame
{
  struct SunLight
  {
      float4 color;                  // Offset:    0
      float4 direction;              // Offset:   16
      float4 tangentDir;             // Offset:   32
      float4 bitangentDir;           // Offset:   48
  } g_sunLight;                      // Offset:    0 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_lightsListParams;         // Offset:   64 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_lightsCameraParams;       // Offset:   80 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  struct FogParams
  {
      float4 fogColorDensity;        // Offset:   96
      float4 fogFalloffDistanceREM;  // Offset:  112
      float4 sunColorPower;          // Offset:  128
      float4 scatterStartEnabledSky; // Offset:  144
      float4 shipParticleAlpha;      // Offset:  160
  } g_fogParams;                     // Offset:   96 Size:    80 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_particleLightingFactor;   // Offset:  176 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_environmentLightingFactors;// Offset:  192 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_bloomParams;              // Offset:  208 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float2 g_tonemapParams;            // Offset:  224 Size:     8 [unused]
     = 0x00000000 0x00000000 
  float4 g_avgLumParams;             // Offset:  240 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_gammaCorrection;          // Offset:  256 Size:    16 [unused]
     = 0x3f800000 0x3f800000 0x3f800000 0x00000000 
  struct DynamicShadowParams
  {
      struct ShadowSplitParams
      {
          row_major float4x4 textureMatrix;// Offset:  272
          float2 textureUsage;       // Offset:  336
          float2 minBlurRadius;      // Offset:  344
          float2 maxBlurRadiusNear;  // Offset:  352
          float2 maxBlurRadiusFar;   // Offset:  360
          float nearPlaneSubFrustrumVS;// Offset:  368
          float farPlaneSubFrustrumVS;// Offset:  372
          float nearFarProjectionDistWS;// Offset:  376
          float texelSize;           // Offset:  380
      } splitParams[4];              // Offset:  272
      float shadowResolution;        // Offset:  720
      float shadowResolutionRcp;     // Offset:  724
      float contactHardeningWSDistance;// Offset:  728
      float _pad;                    // Offset:  732
  } g_shadowParams;                  // Offset:  272 Size:   464 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  struct PackedSeaShadowParameters
  {
      float4 surfaceShadowParams;    // Offset:  736
      float4 volumetricShadowParams; // Offset:  752
  } g_seaShadows;                    // Offset:  736 Size:    32 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  struct WaterSharedData
  {
      float4 kAbsorption;            // Offset:  768
      float4 subSurfaceColor;        // Offset:  784
      float4 turbidColor;            // Offset:  800
      float4 turbidColor2;           // Offset:  816
      float4 turbidColorDesaturated; // Offset:  832
      float4 underwaterTurbidColor;  // Offset:  848
      float4 underwaterREMMultColor; // Offset:  864
      float4 underwaterDirectLightInscatter;// Offset:  880
      float4 underwaterShaftsSecondaryColor;// Offset:  896
      float4 maxWavesAmplitude;      // Offset:  912
      float2 windDir;                // Offset:  928
      float seaLevel;                // Offset:  936
      float deformFoamDisplaceMult;  // Offset:  940
      float3 wavesUVScale;           // Offset:  944
      float variationMapOffset;      // Offset:  956
      float3 wavesUVBias;            // Offset:  960
      float variationMapPower;       // Offset:  972
      float variationMapThreshold;   // Offset:  976
      float variationMapScale;       // Offset:  980
      float variationMapMinWave2Val; // Offset:  984
      float variationMapThresholdSmooth;// Offset:  988
      float deformationsScale;       // Offset:  992
      float absorbtionBase;          // Offset:  996
      float lightAbsorbtionScale;    // Offset: 1000
      float depthAbsorbtionScale;    // Offset: 1004
      float waterScatteringSkyFactor;// Offset: 1008
      float reflectionInscatterMult; // Offset: 1012
      float refractionAbsorbtionScale;// Offset: 1016
      float underwaterRefractionIndex;// Offset: 1020
      float underwaterRefractionDistortion;// Offset: 1024
      float underwaterShaftsAmount;  // Offset: 1028
      float underwaterShaftsAmountSecondary;// Offset: 1032
      float underwaterShaftsDepthFading;// Offset: 1036
      float underwaterREMMultColorFactor;// Offset: 1040
      float underwaterDirectLightInscatterExp;// Offset: 1044
      float causticsIntensity;       // Offset: 1048
      float causticsInvScale;        // Offset: 1052
      float causticsAnimSpeed;       // Offset: 1056
      float causticsDepthFading;     // Offset: 1060
      float causticsMoveSpeed;       // Offset: 1064
      float causticsMaxHeight;       // Offset: 1068
      float underwaterMaxDepth;      // Offset: 1072
      float reflectionMapSpecIntensity;// Offset: 1076
      float turbidLocalLightsBrightness;// Offset: 1080
      float reflectionMapSpecRoughness;// Offset: 1084
      float reflectionMapSpecSharpness;// Offset: 1088
      float momentsFresnelInfluence; // Offset: 1092
      float momentsFresnelInfluenceStartDist;// Offset: 1096
      float shorelineWaveLength;     // Offset: 1100
      float shorelineWaveLengthFoam; // Offset: 1104
      float shorelineMaxWindDir;     // Offset: 1108
      float shorelineWaveDeformAmplitude;// Offset: 1112
      float shorelineFoamWaveDeformAmplitude;// Offset: 1116
      float shorelineFoamWaveIntensity;// Offset: 1120
      float shorelineFoamWaveAddDensity;// Offset: 1124
      float shorelineWaveParallelness;// Offset: 1128
      float shorelineWaveSpeed;      // Offset: 1132
      float shorelineFoamWaveSpeedMult;// Offset: 1136
      float shorelineMaxShoreDist;   // Offset: 1140
      float shorelineFoamSparsity;   // Offset: 1144
      float shorelineFoamArrowness;  // Offset: 1148
      float localSimDisturbMult;     // Offset: 1152
      float pad[3];                  // Offset: 1168
  } g_waterParams;                   // Offset:  768 Size:   436 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 
  struct UnderwaterHighlight
  {
      float3 highlightColor;         // Offset: 1216
      float highlightMinUnderwaterHeight;// Offset: 1228
      float3 highlightCenter;        // Offset: 1232
      float highlightDepthFade;      // Offset: 1244
      float highlightHeightFade;     // Offset: 1248
      float highlightSpeed;          // Offset: 1252
      float highlightStartFade;      // Offset: 1256
      float highlightFinishFade;     // Offset: 1260
      float highlightPeriod;         // Offset: 1264
      float isHighlightEnabled;      // Offset: 1268
      float highlightStartTime;      // Offset: 1272
      float padding;                 // Offset: 1276
  } g_underwaterHighlight;           // Offset: 1216 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  struct PackedCloudsShadowsParameters
  {
      float4 intensityScaleOffset[2];// Offset: 1280
      float4 fade;                   // Offset: 1312
      float4 waterIntensityMult;     // Offset: 1328
  } g_cloudsShadowsParameters;       // Offset: 1280 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_PMREMResolutionAndMipsNumber;// Offset: 1344 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_GlobalREMSH[7];           // Offset: 1360 Size:   112 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  struct PbsExtras
  {
      float microShadowsIntensity;   // Offset: 1472
      float specularMult;            // Offset: 1476
      float overallWetness;          // Offset: 1480
      float coastlineHeight;         // Offset: 1484
      float coastlineFalloff;        // Offset: 1488
      float microShadowsIntensityShips;// Offset: 1492
      float aoPower;                 // Offset: 1496
      float soPower;                 // Offset: 1500
      float aoAdditionalPowerForNonShips;// Offset: 1504
      float lakeSpecularIntensity;   // Offset: 1508
      float lakeSpecularPower;       // Offset: 1512
      float pmremSupressByShadow;    // Offset: 1516
      float4 wetnessColor;           // Offset: 1520
      float4 auroraTint;             // Offset: 1536
      float4 cloudPlaneLighting;     // Offset: 1552
      float indirectMultShips;       // Offset: 1568
      float indirectMultMisc;        // Offset: 1572
      float _pad[2];                 // Offset: 1584
  } g_pbsExtras;                     // Offset: 1472 Size:   132 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 
  struct ShipData
  {
      row_major float4x4 worldMat;   // Offset: 1616
      row_major float4x4 worldInvMat;// Offset: 1680
      row_major float4x4 worldPrevMat;// Offset: 1744
      row_major float4x4 worldPrevInvMat;// Offset: 1808
      float4 size;                   // Offset: 1872
      float speed;                   // Offset: 1888
      float speedSmooth;             // Offset: 1892
      uint isSubmarine;              // Offset: 1896
      float movement;                // Offset: 1900
      float movementSmooth;          // Offset: 1904
      float movementForward;         // Offset: 1908
      float2 _pad;                   // Offset: 1912
  } g_playerShipData;                // Offset: 1616 Size:   304 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  float g_weatherTransitionFactor;   // Offset: 1920 Size:     4 [unused]
     = 0x00000000 
  struct LightMapParameters
  {
      float4 numBlocksInAtlas;       // Offset: 1936
      float4 numBlocksInSpace;       // Offset: 1952
      float4 packedParams;           // Offset: 1968
  } g_lightMapIndirectionParameters; // Offset: 1936 Size:    48 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_chunkSpaceTransform;      // Offset: 1984 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_forestLodProfile;         // Offset: 2000 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float3 g_treeShadowParams;         // Offset: 2016 Size:    12 [unused]
     = 0x00000000 0x00000000 0x00000000 
  float4 g_randomMapScale;           // Offset: 2032 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float g_time;                      // Offset: 2048 Size:     4 [unused]
     = 0x00000000 
  float g_timePrev;                  // Offset: 2052 Size:     4 [unused]
     = 0x00000000 
  float g_deltaTime;                 // Offset: 2056 Size:     4
     = 0x00000000 
  float g_timeFromMapStart;          // Offset: 2060 Size:     4 [unused]
     = 0x00000000 
  uint g_frameIdx;                   // Offset: 2064 Size:     4 [unused]
     = 0x00000000 
  float g_uiBrightnessMultiplier;    // Offset: 2068 Size:     4 [unused]
     = 0x3f800000 
  uint g_playerRenderObjectID;       // Offset: 2072 Size:     4 [unused]
     = 0x00000000 
  bool g_isBinocularCamera;          // Offset: 2076 Size:     4 [unused]
     = 0x00000000 
  bool g_isSubmarine;                // Offset: 2080 Size:     4 [unused]
     = 0x00000000 
  bool g_isCameraAboveWaterForGeom;  // Offset: 2084 Size:     4 [unused]
     = 0x00000000 
  bool g_isSpaceSdfExists;           // Offset: 2088 Size:     4 [unused]
     = 0x00000000 
  bool g_isInGameUiVisible;          // Offset: 2092 Size:     4 [unused]
     = 0x00000000 
  bool g_isBinocMaskVisible;         // Offset: 2096 Size:     4 [unused]
     = 0x00000000 
  float g_cameraBinocularFactor;     // Offset: 2100 Size:     4 [unused]
     = 0x00000000 
  bool g_gpuVfxAccessPong;           // Offset: 2104 Size:     4 [unused]
     = 0x00000000 
}

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// g_bilinearWrapSampler             sampler      NA          NA             s0      1 
// g_displacementTexture             texture  float4          2d             t0      1 
// g_foamEnergyInTexture             texture   float          2d             t1      1 
// g_gradientsOutTexture                 UAV  float4          2d             u0      1 
// g_momentsOutTexture                   UAV  float4          2d             u1      1 
// g_foamEnergyOutTexture                UAV   float          2d             u2      1 
// $Globals                          cbuffer      NA          NA            cb0      1 
// PerFrame                          cbuffer      NA          NA            cb1      1

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// no Input

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// no Output

[numthreads(16, 16, 1)]
void cs_02_cs_5_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_globalFlags refactoringAllowed
    // dcl_constantbuffer CB0[2], immediateIndexed
    // dcl_constantbuffer CB1[129], immediateIndexed
    // dcl_sampler s0, mode_default
    // dcl_resource_texture2d (float,float,float,float) t0
    // dcl_resource_texture2d (float,float,float,float) t1
    // dcl_uav_typed_texture2d (float,float,float,float) u0
    // dcl_uav_typed_texture2d (float,float,float,float) u1
    // dcl_uav_typed_texture2d (float,float,float,float) u2
    // dcl_input vThreadID.xy
    float4 r[7];
    // numthreads(16, 16, 1)
    // asm: ige r0.xy, vThreadID.xyxx, l(128, 128, 0, 0)
    r0.x = r0.y | r0.x;
    if (r0.x) {
        return;
    }
    r0.xyzw = vThreadID.xyxy + l(-1, 0, 1, 0);
    r0.xyzw = r0.zwxy & l(127, 127, 127, 127);
    r1.xyzw = vThreadID.xyxy + l(0, -1, 0, 1);
    r1.xyzw = r1.zwxy & l(127, 127, 127, 127);
    r2.xy = r0.zwzz;
    r2.zw = l(0,0,0,0);
    // asm: ld_indexable(texture2d)(float,float,float,float) r2.xyz, r2.xyzw, t0.xyzw
    r0.zw = l(0,0,0,0);
    // asm: ld_indexable(texture2d)(float,float,float,float) r0.xyz, r0.xyzw, t0.xyzw
    r3.xy = r1.zwzz;
    r3.zw = l(0,0,0,0);
    // asm: ld_indexable(texture2d)(float,float,float,float) r3.xyz, r3.xyzw, t0.xyzw
    r1.zw = l(0,0,0,0);
    // asm: ld_indexable(texture2d)(float,float,float,float) r1.xyz, r1.xyzw, t0.xyzw
    r4.x = -r0.x + r2.x;
    r4.y = -r1.x + r3.x;
    r0.x = l(1.000000, 1.000000, 1.000000, 1.000000) / cb0[0].w;
    r4.xy = r0.xxxx * r4.xyxx;
    r0.x = l(128.000000) / cb0[0].y;
    r1.xw = -r2.yyyz + r0.yyyz;
    r1.xw = r0.xxxx * r1.xxxw;
    r0.w = r1.w * cb0[0].z;
    r2.xw = -r3.yyyz + r1.yyyz;
    r2.xw = r0.xxxx * r2.xxxw;
    r0.x = r2.x * cb0[0].z;
    r1.x = (r1.x * cb0[0].z) + l(1.000000);
    r1.w = (r2.w * cb0[0].z) + l(1.000000);
    r0.x = r0.x * r0.w;
    r5.w = (r1.x * r1.w) + -r0.x;
    r0.xw = (float)vThreadID.xxxy;
    r0.xw = r0.xxxw + l(0.500000, 0.000000, 0.000000, 0.500000);
    r6.xy = r0.xwxx * l(0.007812, 0.007812, 0.000000, 0.000000);
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r0.w, r6.xyxx, t1.yzwx, s0, l(0.000000)
    r6.zw = (r0.xxxx * l(0.000000, 0.000000, 0.007812, 0.007812)) + l(0.000000, 0.000000, -0.007812, 0.007812);
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r0.x, r6.zyzz, t1.xyzw, s0, l(0.000000)
    r0.x = r0.x * l(0.050000);
    r0.x = (r0.w * l(0.900000)) + r0.x;
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r0.w, r6.wyww, t1.yzwx, s0, l(0.000000)
    r0.x = (r0.w * l(0.050000)) + r0.x;
    r0.w = min(cb1[128].z, l(0.040000));
    r1.x = (-cb0[1].x * r0.w) + l(1.000000);
    r1.x = max(r1.x, l(0.000000));
    r1.w = (-cb0[1].y * l(5.000000)) + r5.w;
    r1.w = r1.w + l(5.000000);
    // asm: mul_sat r1.w, r1.w, l(0.200000)
    r2.x = (r1.w * l(-2.000000)) + l(3.000000);
    r1.w = r1.w * r1.w;
    r1.w = (-r2.x * r1.w) + l(1.000000);
    r0.w = r0.w * r1.w;
    r4.z = (r0.x * r1.x) + r0.w;
    // asm: mov_sat r0.x, r4.z
    store_uav_typed(u2.xyzw, vThreadID.xyyy, r0.xxxx);
    r0.xy = r0.yzyy + r2.yzyy;
    r0.xy = r3.yzyy + r0.xyxx;
    r0.xy = r1.yzyy + r0.xyxx;
    r0.x = dot2(r0.xyxx, r0.xyxx);
    r0.x = sqrt(r0.x);
    r0.x = r0.x * l(0.250000);
    r0.x = min(r0.x, l(1.700000));
    r0.y = r5.w + l(1.200000);
    // asm: mul_sat r0.y, r0.y, l(0.333333)
    r0.z = (r0.y * l(-2.000000)) + l(3.000000);
    r0.y = r0.y * r0.y;
    r0.x = (-r0.z * r0.y) + r0.x;
    r0.x = r0.x + l(1.000000);
    r4.w = r0.x * l(0.300000);
    store_uav_typed(u0.xyzw, vThreadID.xyyy, r4.xyzw);
    r5.xyz = r4.xyyx * r4.xyxx;
    store_uav_typed(u1.xyzw, vThreadID.xyyy, r5.xyzw);
    return;
    // asm: // Approximately 75 instruction slots used
}

// -----------------------------------------------------------------------------
// Shader 3
// Profile: cs_5_0
// Byte offset: 39812
// Byte length: 12888
// -----------------------------------------------------------------------------

// Reflected buffer definitions
cbuffer $Globals
{
  bool g_isTAAEnabledBranch;         // Offset:    0 Size:     4 [unused]
     = 0xffffffff 
  float g_fftPatchSize;              // Offset:    4 Size:     4
  float g_fftChoppyScale;            // Offset:    8 Size:     4
  float g_tileSizeX2;                // Offset:   12 Size:     4
  float g_waveFoamFadeRate;          // Offset:   16 Size:     4
  float g_waveFoamCoverage;          // Offset:   20 Size:     4
}
cbuffer PerFrame
{
  struct SunLight
  {
      float4 color;                  // Offset:    0
      float4 direction;              // Offset:   16
      float4 tangentDir;             // Offset:   32
      float4 bitangentDir;           // Offset:   48
  } g_sunLight;                      // Offset:    0 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_lightsListParams;         // Offset:   64 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_lightsCameraParams;       // Offset:   80 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  struct FogParams
  {
      float4 fogColorDensity;        // Offset:   96
      float4 fogFalloffDistanceREM;  // Offset:  112
      float4 sunColorPower;          // Offset:  128
      float4 scatterStartEnabledSky; // Offset:  144
      float4 shipParticleAlpha;      // Offset:  160
  } g_fogParams;                     // Offset:   96 Size:    80 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_particleLightingFactor;   // Offset:  176 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_environmentLightingFactors;// Offset:  192 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_bloomParams;              // Offset:  208 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float2 g_tonemapParams;            // Offset:  224 Size:     8 [unused]
     = 0x00000000 0x00000000 
  float4 g_avgLumParams;             // Offset:  240 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_gammaCorrection;          // Offset:  256 Size:    16 [unused]
     = 0x3f800000 0x3f800000 0x3f800000 0x00000000 
  struct DynamicShadowParams
  {
      struct ShadowSplitParams
      {
          row_major float4x4 textureMatrix;// Offset:  272
          float2 textureUsage;       // Offset:  336
          float2 minBlurRadius;      // Offset:  344
          float2 maxBlurRadiusNear;  // Offset:  352
          float2 maxBlurRadiusFar;   // Offset:  360
          float nearPlaneSubFrustrumVS;// Offset:  368
          float farPlaneSubFrustrumVS;// Offset:  372
          float nearFarProjectionDistWS;// Offset:  376
          float texelSize;           // Offset:  380
      } splitParams[4];              // Offset:  272
      float shadowResolution;        // Offset:  720
      float shadowResolutionRcp;     // Offset:  724
      float contactHardeningWSDistance;// Offset:  728
      float _pad;                    // Offset:  732
  } g_shadowParams;                  // Offset:  272 Size:   464 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  struct PackedSeaShadowParameters
  {
      float4 surfaceShadowParams;    // Offset:  736
      float4 volumetricShadowParams; // Offset:  752
  } g_seaShadows;                    // Offset:  736 Size:    32 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  struct WaterSharedData
  {
      float4 kAbsorption;            // Offset:  768
      float4 subSurfaceColor;        // Offset:  784
      float4 turbidColor;            // Offset:  800
      float4 turbidColor2;           // Offset:  816
      float4 turbidColorDesaturated; // Offset:  832
      float4 underwaterTurbidColor;  // Offset:  848
      float4 underwaterREMMultColor; // Offset:  864
      float4 underwaterDirectLightInscatter;// Offset:  880
      float4 underwaterShaftsSecondaryColor;// Offset:  896
      float4 maxWavesAmplitude;      // Offset:  912
      float2 windDir;                // Offset:  928
      float seaLevel;                // Offset:  936
      float deformFoamDisplaceMult;  // Offset:  940
      float3 wavesUVScale;           // Offset:  944
      float variationMapOffset;      // Offset:  956
      float3 wavesUVBias;            // Offset:  960
      float variationMapPower;       // Offset:  972
      float variationMapThreshold;   // Offset:  976
      float variationMapScale;       // Offset:  980
      float variationMapMinWave2Val; // Offset:  984
      float variationMapThresholdSmooth;// Offset:  988
      float deformationsScale;       // Offset:  992
      float absorbtionBase;          // Offset:  996
      float lightAbsorbtionScale;    // Offset: 1000
      float depthAbsorbtionScale;    // Offset: 1004
      float waterScatteringSkyFactor;// Offset: 1008
      float reflectionInscatterMult; // Offset: 1012
      float refractionAbsorbtionScale;// Offset: 1016
      float underwaterRefractionIndex;// Offset: 1020
      float underwaterRefractionDistortion;// Offset: 1024
      float underwaterShaftsAmount;  // Offset: 1028
      float underwaterShaftsAmountSecondary;// Offset: 1032
      float underwaterShaftsDepthFading;// Offset: 1036
      float underwaterREMMultColorFactor;// Offset: 1040
      float underwaterDirectLightInscatterExp;// Offset: 1044
      float causticsIntensity;       // Offset: 1048
      float causticsInvScale;        // Offset: 1052
      float causticsAnimSpeed;       // Offset: 1056
      float causticsDepthFading;     // Offset: 1060
      float causticsMoveSpeed;       // Offset: 1064
      float causticsMaxHeight;       // Offset: 1068
      float underwaterMaxDepth;      // Offset: 1072
      float reflectionMapSpecIntensity;// Offset: 1076
      float turbidLocalLightsBrightness;// Offset: 1080
      float reflectionMapSpecRoughness;// Offset: 1084
      float reflectionMapSpecSharpness;// Offset: 1088
      float momentsFresnelInfluence; // Offset: 1092
      float momentsFresnelInfluenceStartDist;// Offset: 1096
      float shorelineWaveLength;     // Offset: 1100
      float shorelineWaveLengthFoam; // Offset: 1104
      float shorelineMaxWindDir;     // Offset: 1108
      float shorelineWaveDeformAmplitude;// Offset: 1112
      float shorelineFoamWaveDeformAmplitude;// Offset: 1116
      float shorelineFoamWaveIntensity;// Offset: 1120
      float shorelineFoamWaveAddDensity;// Offset: 1124
      float shorelineWaveParallelness;// Offset: 1128
      float shorelineWaveSpeed;      // Offset: 1132
      float shorelineFoamWaveSpeedMult;// Offset: 1136
      float shorelineMaxShoreDist;   // Offset: 1140
      float shorelineFoamSparsity;   // Offset: 1144
      float shorelineFoamArrowness;  // Offset: 1148
      float localSimDisturbMult;     // Offset: 1152
      float pad[3];                  // Offset: 1168
  } g_waterParams;                   // Offset:  768 Size:   436 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 
  struct UnderwaterHighlight
  {
      float3 highlightColor;         // Offset: 1216
      float highlightMinUnderwaterHeight;// Offset: 1228
      float3 highlightCenter;        // Offset: 1232
      float highlightDepthFade;      // Offset: 1244
      float highlightHeightFade;     // Offset: 1248
      float highlightSpeed;          // Offset: 1252
      float highlightStartFade;      // Offset: 1256
      float highlightFinishFade;     // Offset: 1260
      float highlightPeriod;         // Offset: 1264
      float isHighlightEnabled;      // Offset: 1268
      float highlightStartTime;      // Offset: 1272
      float padding;                 // Offset: 1276
  } g_underwaterHighlight;           // Offset: 1216 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  struct PackedCloudsShadowsParameters
  {
      float4 intensityScaleOffset[2];// Offset: 1280
      float4 fade;                   // Offset: 1312
      float4 waterIntensityMult;     // Offset: 1328
  } g_cloudsShadowsParameters;       // Offset: 1280 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_PMREMResolutionAndMipsNumber;// Offset: 1344 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_GlobalREMSH[7];           // Offset: 1360 Size:   112 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  struct PbsExtras
  {
      float microShadowsIntensity;   // Offset: 1472
      float specularMult;            // Offset: 1476
      float overallWetness;          // Offset: 1480
      float coastlineHeight;         // Offset: 1484
      float coastlineFalloff;        // Offset: 1488
      float microShadowsIntensityShips;// Offset: 1492
      float aoPower;                 // Offset: 1496
      float soPower;                 // Offset: 1500
      float aoAdditionalPowerForNonShips;// Offset: 1504
      float lakeSpecularIntensity;   // Offset: 1508
      float lakeSpecularPower;       // Offset: 1512
      float pmremSupressByShadow;    // Offset: 1516
      float4 wetnessColor;           // Offset: 1520
      float4 auroraTint;             // Offset: 1536
      float4 cloudPlaneLighting;     // Offset: 1552
      float indirectMultShips;       // Offset: 1568
      float indirectMultMisc;        // Offset: 1572
      float _pad[2];                 // Offset: 1584
  } g_pbsExtras;                     // Offset: 1472 Size:   132 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 
  struct ShipData
  {
      row_major float4x4 worldMat;   // Offset: 1616
      row_major float4x4 worldInvMat;// Offset: 1680
      row_major float4x4 worldPrevMat;// Offset: 1744
      row_major float4x4 worldPrevInvMat;// Offset: 1808
      float4 size;                   // Offset: 1872
      float speed;                   // Offset: 1888
      float speedSmooth;             // Offset: 1892
      uint isSubmarine;              // Offset: 1896
      float movement;                // Offset: 1900
      float movementSmooth;          // Offset: 1904
      float movementForward;         // Offset: 1908
      float2 _pad;                   // Offset: 1912
  } g_playerShipData;                // Offset: 1616 Size:   304 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  float g_weatherTransitionFactor;   // Offset: 1920 Size:     4 [unused]
     = 0x00000000 
  struct LightMapParameters
  {
      float4 numBlocksInAtlas;       // Offset: 1936
      float4 numBlocksInSpace;       // Offset: 1952
      float4 packedParams;           // Offset: 1968
  } g_lightMapIndirectionParameters; // Offset: 1936 Size:    48 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_chunkSpaceTransform;      // Offset: 1984 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_forestLodProfile;         // Offset: 2000 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float3 g_treeShadowParams;         // Offset: 2016 Size:    12 [unused]
     = 0x00000000 0x00000000 0x00000000 
  float4 g_randomMapScale;           // Offset: 2032 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float g_time;                      // Offset: 2048 Size:     4 [unused]
     = 0x00000000 
  float g_timePrev;                  // Offset: 2052 Size:     4 [unused]
     = 0x00000000 
  float g_deltaTime;                 // Offset: 2056 Size:     4
     = 0x00000000 
  float g_timeFromMapStart;          // Offset: 2060 Size:     4 [unused]
     = 0x00000000 
  uint g_frameIdx;                   // Offset: 2064 Size:     4 [unused]
     = 0x00000000 
  float g_uiBrightnessMultiplier;    // Offset: 2068 Size:     4 [unused]
     = 0x3f800000 
  uint g_playerRenderObjectID;       // Offset: 2072 Size:     4 [unused]
     = 0x00000000 
  bool g_isBinocularCamera;          // Offset: 2076 Size:     4 [unused]
     = 0x00000000 
  bool g_isSubmarine;                // Offset: 2080 Size:     4 [unused]
     = 0x00000000 
  bool g_isCameraAboveWaterForGeom;  // Offset: 2084 Size:     4 [unused]
     = 0x00000000 
  bool g_isSpaceSdfExists;           // Offset: 2088 Size:     4 [unused]
     = 0x00000000 
  bool g_isInGameUiVisible;          // Offset: 2092 Size:     4 [unused]
     = 0x00000000 
  bool g_isBinocMaskVisible;         // Offset: 2096 Size:     4 [unused]
     = 0x00000000 
  float g_cameraBinocularFactor;     // Offset: 2100 Size:     4 [unused]
     = 0x00000000 
  bool g_gpuVfxAccessPong;           // Offset: 2104 Size:     4 [unused]
     = 0x00000000 
}

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// g_bilinearWrapSampler             sampler      NA          NA             s0      1 
// g_displacementTexture             texture  float4          2d             t0      1 
// g_foamEnergyInTexture             texture   float          2d             t1      1 
// g_gradientsOutTexture                 UAV  float4          2d             u0      1 
// g_foamEnergyOutTexture                UAV   float          2d             u1      1 
// $Globals                          cbuffer      NA          NA            cb0      1 
// PerFrame                          cbuffer      NA          NA            cb1      1

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// no Input

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// no Output

[numthreads(16, 16, 1)]
void cs_03_cs_5_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_globalFlags refactoringAllowed
    // dcl_constantbuffer CB0[2], immediateIndexed
    // dcl_constantbuffer CB1[129], immediateIndexed
    // dcl_sampler s0, mode_default
    // dcl_resource_texture2d (float,float,float,float) t0
    // dcl_resource_texture2d (float,float,float,float) t1
    // dcl_uav_typed_texture2d (float,float,float,float) u0
    // dcl_uav_typed_texture2d (float,float,float,float) u1
    // dcl_input vThreadID.xy
    float4 r[6];
    // numthreads(16, 16, 1)
    // asm: ige r0.xy, vThreadID.xyxx, l(128, 128, 0, 0)
    r0.x = r0.y | r0.x;
    if (r0.x) {
        return;
    }
    r0.xyzw = vThreadID.xyxy + l(-1, 0, 1, 0);
    r0.xyzw = r0.zwxy & l(127, 127, 127, 127);
    r1.xyzw = vThreadID.xyxy + l(0, -1, 0, 1);
    r1.xyzw = r1.zwxy & l(127, 127, 127, 127);
    r2.xy = r0.zwzz;
    r2.zw = l(0,0,0,0);
    // asm: ld_indexable(texture2d)(float,float,float,float) r2.xyz, r2.xyzw, t0.xyzw
    r0.zw = l(0,0,0,0);
    // asm: ld_indexable(texture2d)(float,float,float,float) r0.xyz, r0.xyzw, t0.xyzw
    r3.xy = r1.zwzz;
    r3.zw = l(0,0,0,0);
    // asm: ld_indexable(texture2d)(float,float,float,float) r3.xyz, r3.xyzw, t0.xyzw
    r1.zw = l(0,0,0,0);
    // asm: ld_indexable(texture2d)(float,float,float,float) r1.xyz, r1.xyzw, t0.xyzw
    r4.x = -r0.x + r2.x;
    r4.y = -r1.x + r3.x;
    r0.x = l(1.000000, 1.000000, 1.000000, 1.000000) / cb0[0].w;
    r4.xy = r0.xxxx * r4.xyxx;
    r0.x = l(128.000000) / cb0[0].y;
    r1.xw = -r2.yyyz + r0.yyyz;
    r1.xw = r0.xxxx * r1.xxxw;
    r0.w = r1.w * cb0[0].z;
    r2.xw = -r3.yyyz + r1.yyyz;
    r2.xw = r0.xxxx * r2.xxxw;
    r0.x = r2.x * cb0[0].z;
    r1.x = (r1.x * cb0[0].z) + l(1.000000);
    r1.w = (r2.w * cb0[0].z) + l(1.000000);
    r0.x = r0.x * r0.w;
    r0.x = (r1.x * r1.w) + -r0.x;
    r1.xw = (float)vThreadID.xxxy;
    r1.xw = r1.xxxw + l(0.500000, 0.000000, 0.000000, 0.500000);
    r5.xy = r1.xwxx * l(0.007812, 0.007812, 0.000000, 0.000000);
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r0.w, r5.xyxx, t1.yzwx, s0, l(0.000000)
    r5.zw = (r1.xxxx * l(0.000000, 0.000000, 0.007812, 0.007812)) + l(0.000000, 0.000000, -0.007812, 0.007812);
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r1.x, r5.zyzz, t1.xyzw, s0, l(0.000000)
    r1.x = r1.x * l(0.050000);
    r0.w = (r0.w * l(0.900000)) + r1.x;
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r1.x, r5.wyww, t1.xyzw, s0, l(0.000000)
    r0.w = (r1.x * l(0.050000)) + r0.w;
    r1.x = min(cb1[128].z, l(0.040000));
    r1.w = (-cb0[1].x * r1.x) + l(1.000000);
    r1.w = max(r1.w, l(0.000000));
    r2.x = (-cb0[1].y * l(5.000000)) + r0.x;
    r2.x = r2.x + l(5.000000);
    // asm: mul_sat r2.x, r2.x, l(0.200000)
    r2.w = (r2.x * l(-2.000000)) + l(3.000000);
    r2.x = r2.x * r2.x;
    r2.x = (-r2.w * r2.x) + l(1.000000);
    r1.x = r1.x * r2.x;
    r4.z = (r0.w * r1.w) + r1.x;
    // asm: mov_sat r0.w, r4.z
    store_uav_typed(u1.xyzw, vThreadID.xyyy, r0.wwww);
    r0.yz = r0.yyzy + r2.yyzy;
    r0.yz = r3.yyzy + r0.yyzy;
    r0.yz = r1.yyzy + r0.yyzy;
    r0.y = dot2(r0.yzyy, r0.yzyy);
    r0.y = sqrt(r0.y);
    r0.y = r0.y * l(0.250000);
    r0.y = min(r0.y, l(1.700000));
    r0.x = r0.x + l(1.200000);
    // asm: mul_sat r0.x, r0.x, l(0.333333)
    r0.z = (r0.x * l(-2.000000)) + l(3.000000);
    r0.x = r0.x * r0.x;
    r0.x = (-r0.z * r0.x) + r0.y;
    r0.x = r0.x + l(1.000000);
    r4.w = r0.x * l(0.300000);
    store_uav_typed(u0.xyzw, vThreadID.xyyy, r4.xyzw);
    return;
    // asm: // Approximately 73 instruction slots used
}

