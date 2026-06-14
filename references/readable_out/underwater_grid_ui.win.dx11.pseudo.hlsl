// Pseudo-HLSL generated from compiled shader bytecode.
// Source container: underwater_grid_ui.win.dx11.fxo
//
// This is reconstructed for reading only.
// It is not original HLSL and should not be treated as recompilable source.

// -----------------------------------------------------------------------------
// Shader 0
// Profile: vs_5_0
// Byte offset: 18420
// Byte length: 2188
// -----------------------------------------------------------------------------

// Reflected buffer definitions
cbuffer PerView
{
  row_major float4x4 g_viewProj;     // Offset:    0 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_prevFrameViewProj;// Offset:   64 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_invViewProj;  // Offset:  128 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_view;         // Offset:  192 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_prevFrameView;// Offset:  256 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_invView;      // Offset:  320 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_proj;         // Offset:  384 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_invProj;      // Offset:  448 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_cameraDirs;   // Offset:  512 Size:    64
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_cameraPos;                // Offset:  576 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_prevFrameCameraPos;       // Offset:  592 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float g_zoomFactor;                // Offset:  608 Size:     4 [unused]
     = 0x00000000 
  float g_nearPlane;                 // Offset:  612 Size:     4 [unused]
     = 0x00000000 
  float4 g_farPlane;                 // Offset:  624 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  bool g_clipPlaneEnable;            // Offset:  640 Size:     4 [unused]
     = 0x00000000 
  float4 g_clipPlane;                // Offset:  656 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_currPrevNDCOffsets;       // Offset:  672 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
}

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// PerView                           cbuffer      NA          NA            cb0      1

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// POSITION                 0   xyz         0     NONE   float   xyz

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float   xyzw
// TEXCOORD                 0   xyzw        1     NONE   float   xyzw
// TEXCOORD                 1   xy          2     NONE   float   xy

void vs_00_vs_5_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_globalFlags refactoringAllowed
    // dcl_constantbuffer CB0[36], immediateIndexed
    // dcl_input v0.xyz
    // dcl_output_siv o0.xyzw, position
    // dcl_output o1.xyzw
    // dcl_output o2.xy
    float4 r[3];
    o0.xyz = v0.xyzx;
    o0.w = l(1.000000);
    r0.xyz = -cb0[34].xyzx + cb0[35].xyzx;
    r1.xy = (v0.xyxx * l(0.500000, -0.500000, 0.000000, 0.000000)) + l(0.500000, 0.500000, 0.000000, 0.000000);
    r0.xyz = (r1.yyyy * r0.xyzx) + cb0[34].xyzx;
    r2.xyz = -cb0[32].xyzx + cb0[33].xyzx;
    r2.xyz = (r1.yyyy * r2.xyzx) + cb0[32].xyzx;
    r0.xyz = r0.xyzx + -r2.xyzx;
    o1.xyz = (r1.xxxx * r0.xyzx) + r2.xyzx;
    o2.xy = r1.xyxx;
    o1.w = l(0);
    return;
    // asm: // Approximately 12 instruction slots used
}

// -----------------------------------------------------------------------------
// Shader 1
// Profile: ps_5_0
// Byte offset: 20756
// Byte length: 14336
// -----------------------------------------------------------------------------

// Reflected buffer definitions
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
  } g_waterParams;                   // Offset:  768 Size:   436
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
  } g_underwaterHighlight;           // Offset: 1216 Size:    64
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
  float g_deltaTime;                 // Offset: 2056 Size:     4 [unused]
     = 0x00000000 
  float g_timeFromMapStart;          // Offset: 2060 Size:     4 [unused]
     = 0x00000000 
  uint g_frameIdx;                   // Offset: 2064 Size:     4 [unused]
     = 0x00000000 
  float g_uiBrightnessMultiplier;    // Offset: 2068 Size:     4 [unused]
     = 0x3f800000 
  uint g_playerRenderObjectID;       // Offset: 2072 Size:     4 [unused]
     = 0x00000000 
  bool g_isBinocularCamera;          // Offset: 2076 Size:     4
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
  float g_cameraBinocularFactor;     // Offset: 2100 Size:     4
     = 0x00000000 
  bool g_gpuVfxAccessPong;           // Offset: 2104 Size:     4 [unused]
     = 0x00000000 
}
cbuffer PerView
{
  row_major float4x4 g_viewProj;     // Offset:    0 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_prevFrameViewProj;// Offset:   64 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_invViewProj;  // Offset:  128 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_view;         // Offset:  192 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_prevFrameView;// Offset:  256 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_invView;      // Offset:  320 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_proj;         // Offset:  384 Size:    64
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_invProj;      // Offset:  448 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_cameraDirs;   // Offset:  512 Size:    64
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_cameraPos;                // Offset:  576 Size:    16
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_prevFrameCameraPos;       // Offset:  592 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float g_zoomFactor;                // Offset:  608 Size:     4 [unused]
     = 0x00000000 
  float g_nearPlane;                 // Offset:  612 Size:     4 [unused]
     = 0x00000000 
  float4 g_farPlane;                 // Offset:  624 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  bool g_clipPlaneEnable;            // Offset:  640 Size:     4 [unused]
     = 0x00000000 
  float4 g_clipPlane;                // Offset:  656 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_currPrevNDCOffsets;       // Offset:  672 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
}

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// g_RTPointSampler                  sampler      NA          NA             s0      1 
// g_depthTexSampler                 sampler      NA          NA             s1      1 
// g_depthTex                        texture  float4          2d             t0      1 
// g_normalsTexture                  texture  float4          2d             t1      1 
// PerFrame                          cbuffer      NA          NA            cb0      1 
// PerView                           cbuffer      NA          NA            cb1      1

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float       
// TEXCOORD                 0   xyzw        1     NONE   float       
// TEXCOORD                 1   xy          2     NONE   float   xy

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Target                0   xyzw        0   TARGET   float   xyzw

void ps_01_ps_5_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_globalFlags refactoringAllowed
    // dcl_constantbuffer CB0[132], immediateIndexed
    // dcl_constantbuffer CB1[37], immediateIndexed
    // dcl_sampler s0, mode_default
    // dcl_sampler s1, mode_default
    // dcl_resource_texture2d (float,float,float,float) t0
    // dcl_resource_texture2d (float,float,float,float) t1
    // dcl_input_ps linear v2.xy
    // dcl_output o0.xyzw
    float4 r[5];
    if (!(cb0[129].w)) {
        // asm: discard_nz l(-1)
    }
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r0.x, v2.xyxx, t0.xyzw, s1, l(0.000000)
    r0.y = r0.x + -cb1[26].z;
    r0.y = cb1[27].z / r0.y;
    r1.xyz = -cb1[32].xyzx + cb1[33].xyzx;
    r1.xyz = (v2.yyyy * r1.xyzx) + cb1[32].xyzx;
    r2.xyz = -cb1[34].xyzx + cb1[35].xyzx;
    r2.xyz = (v2.yyyy * r2.xyzx) + cb1[34].xyzx;
    r2.xyz = -r1.xyzx + r2.xyzx;
    r1.xyz = (v2.xxxx * r2.xyzx) + r1.xyzx;
    r2.xyz = (r1.xyzx * r0.yyyy) + cb1[36].xyzx;
    r0.z = (r2.y >= cb0[58].z);
    if (r0.z) {
        // asm: discard_nz l(-1)
    }
    r0.x = (r0.x >= l(0.000010));
    if (r0.x) {
        r0.x = dot(r1.xyzx, r1.xyzx);
        r0.x = rsqrt(r0.x);
        r0.xzw = r0.xxxx * r1.xxyz;
        r1.xyz = r2.xyzx + -cb0[77].xyzx;
        r1.x = dot(r1.xyzx, r1.xyzx);
        r1.x = sqrt(r1.x);
        r1.yz = (l(0.000000, 0.500000, 0.780000, 0.000000) < cb0[131].yyyy);
        r1.w = (cb0[131].y < l(0.780000));
        r1.y = r1.w & r1.y;
        // asm: mad_sat r3.xyzw, cb0[131].yyyy, l(3.571429, 3.571429, 5.263156, 5.263156), l(-1.785715, -1.785715, -4.105262, -4.105262)
        r3.xyzw = (r3.xyzw * l(60.000000, 50.000000, 80.000000, 180.000000)) + l(90.000000, 200.000000, 150.000000, 250.000000);
        r1.zw = (r1.zzzz) ? r3.zzzw : l(0,0,90.000000,200.000000);
        r1.yz = (r1.yyyy) ? r3.xxyx : r1.zzwz;
        r1.w = r1.y + l(100.000000);
        r2.w = r0.y + l(100.000000);
        r1.w = l(1.000000, 1.000000, 1.000000, 1.000000) / r1.w;
        // asm: mul_sat r1.w, r1.w, r2.w
        r2.w = (r1.w * l(-2.000000)) + l(3.000000);
        r1.w = r1.w * r1.w;
        r1.w = r1.w * r2.w;
        r1.z = -r1.y + r1.z;
        r0.y = r0.y + -r1.y;
        r1.y = l(1.000000, 1.000000, 1.000000, 1.000000) / r1.z;
        // asm: mul_sat r0.y, r0.y, r1.y
        r1.y = (r0.y * l(-2.000000)) + l(3.000000);
        r0.y = r0.y * r0.y;
        r0.y = (-r1.y * r0.y) + l(1.000000);
        r0.y = r0.y * r1.w;
        r1.y = cb0[58].z + l(-3.000000);
        r1.z = -r1.y + cb0[58].z;
        r1.y = -r1.y + r2.y;
        r1.z = l(1.000000, 1.000000, 1.000000, 1.000000) / r1.z;
        // asm: mul_sat r1.y, r1.z, r1.y
        r1.z = (r1.y * l(-2.000000)) + l(3.000000);
        r1.y = r1.y * r1.y;
        r1.y = (-r1.z * r1.y) + l(1.000000);
        r0.y = r0.y * r1.y;
        r1.yz = (r2.xxzx * l(0.000000, 2.000000, 2.000000, 0.000000)) + r2.yyyy;
        r1.y = dot2(r1.yzyy, l(12.989800, 78.233002, 0.000000, 0.000000));
        sincos(r1.y, null, r1.y);
        r1.y = r1.y * l(43758.546875);
        r1.y = frac(r1.y);
        r1.y = r0.y * r1.y;
        r1.y = r1.y * l(0.001000);
        r1.yzw = (r0.yyyy * l(0.000000, 0.000000, 0.006000, 0.010000)) + r1.yyyy;
        // asm: sample_l_indexable(texture2d)(float,float,float,float) r2.xy, v2.xyxx, t1.xyzw, s0, l(0.000000)
        r2.xy = (r2.xyxx * l(2.000000, 2.000000, 0.000000, 0.000000)) + l(-1.000000, -1.000000, 0.000000, 0.000000);
        r3.xyz = -|r2.xyxx| + l(1.000000, 1.000000, 1.000000, 0.000000);
        r4.z = -|r2.y| + r3.x;
        r2.z = (r4.z >= l(0.000000));
        r3.xw = (r2.xxxy >= l(0.000000, 0.000000, 0.000000, 0.000000));
        r3.xw = (r3.xxxw) ? l(1.000000,0,0,1.000000) : l(-1.000000,0,0,-1.000000);
        r3.xy = r3.xwxx * r3.yzyy;
        r4.xy = (r2.zzzz) ? r2.xyxx : r3.xyxx;
        r2.x = dot(r4.xyzx, r4.xyzx);
        r2.x = rsqrt(r2.x);
        r2.xyz = r2.xxxx * r4.xyzx;
        r2.w = dot(r2.xyzx, r2.xyzx);
        r2.w = (r2.w < l(0.001000));
        r2.xyz = (r2.wwww) ? -r0.xzwx : r2.xyzx;
        // asm: dp3_sat r0.x, -r0.xzwx, r2.xyzx
        r0.x = -r0.x + l(1.000000);
        r0.z = r0.x * r0.x;
        r0.z = r0.z * r0.z;
        r0.x = r0.z * r0.x;
        r0.x = r0.x * r0.y;
        r0.xyz = (r0.xxxx * l(0.000000, 0.012000, 0.020000, 0.000000)) + r1.yzwy;
        r0.w = dot(r0.xyzx, l(0.212500, 0.715400, 0.072100, 0.000000));
        r0.w = r0.w + l(1.000000);
        r0.xyz = r0.xyzx / r0.wwww;
        o0.xyz = r0.xyzx * l(0.300000, 0.300000, 0.300000, 0.000000);
        r0.x = r1.x * l(0.005714);
        r0.x = min(r0.x, l(1.000000));
        // asm: mad_sat r0.y, r1.x, l(0.010526), l(-0.578947)
        r0.y = -r0.y + l(1.000000);
        r0.x = r0.y * r0.x;
        o0.w = r0.x * l(0.950000);
    else
        o0.xyzw = l(0,0,0,0);
    }
    return;
    // asm: // Approximately 100 instruction slots used
}

// -----------------------------------------------------------------------------
// Shader 2
// Profile: ps_5_0
// Byte offset: 35320
// Byte length: 13520
// -----------------------------------------------------------------------------

// Reflected buffer definitions
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
  } g_waterParams;                   // Offset:  768 Size:   436
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
  } g_underwaterHighlight;           // Offset: 1216 Size:    64
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
  float g_time;                      // Offset: 2048 Size:     4
     = 0x00000000 
  float g_timePrev;                  // Offset: 2052 Size:     4 [unused]
     = 0x00000000 
  float g_deltaTime;                 // Offset: 2056 Size:     4 [unused]
     = 0x00000000 
  float g_timeFromMapStart;          // Offset: 2060 Size:     4 [unused]
     = 0x00000000 
  uint g_frameIdx;                   // Offset: 2064 Size:     4 [unused]
     = 0x00000000 
  float g_uiBrightnessMultiplier;    // Offset: 2068 Size:     4 [unused]
     = 0x3f800000 
  uint g_playerRenderObjectID;       // Offset: 2072 Size:     4 [unused]
     = 0x00000000 
  bool g_isBinocularCamera;          // Offset: 2076 Size:     4
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
cbuffer PerView
{
  row_major float4x4 g_viewProj;     // Offset:    0 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_prevFrameViewProj;// Offset:   64 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_invViewProj;  // Offset:  128 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_view;         // Offset:  192 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_prevFrameView;// Offset:  256 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_invView;      // Offset:  320 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_proj;         // Offset:  384 Size:    64
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_invProj;      // Offset:  448 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_cameraDirs;   // Offset:  512 Size:    64
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_cameraPos;                // Offset:  576 Size:    16
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_prevFrameCameraPos;       // Offset:  592 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float g_zoomFactor;                // Offset:  608 Size:     4 [unused]
     = 0x00000000 
  float g_nearPlane;                 // Offset:  612 Size:     4 [unused]
     = 0x00000000 
  float4 g_farPlane;                 // Offset:  624 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  bool g_clipPlaneEnable;            // Offset:  640 Size:     4 [unused]
     = 0x00000000 
  float4 g_clipPlane;                // Offset:  656 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_currPrevNDCOffsets;       // Offset:  672 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
}

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// g_depthTexSampler                 sampler      NA          NA             s0      1 
// g_depthTex                        texture  float4          2d             t0      1 
// PerFrame                          cbuffer      NA          NA            cb0      1 
// PerView                           cbuffer      NA          NA            cb1      1

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float       
// TEXCOORD                 0   xyzw        1     NONE   float       
// TEXCOORD                 1   xy          2     NONE   float   xy

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Target                0   xyzw        0   TARGET   float   xyzw

void ps_02_ps_5_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_globalFlags refactoringAllowed
    // dcl_constantbuffer CB0[130], immediateIndexed
    // dcl_constantbuffer CB1[37], immediateIndexed
    // dcl_sampler s0, mode_default
    // dcl_resource_texture2d (float,float,float,float) t0
    // dcl_input_ps linear v2.xy
    // dcl_output o0.xyzw
    float4 r[4];
    r0.x = (l(0.000000, 0.000000, 0.000000, 0.000000) != cb0[79].y);
    if (!(r0.x)) {
        // asm: discard_nz l(-1)
    }
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r0.x, v2.xyxx, t0.xyzw, s0, l(0.000000)
    r0.y = r0.x + -cb1[26].z;
    r0.y = cb1[27].z / r0.y;
    r1.xyz = -cb1[32].xyzx + cb1[33].xyzx;
    r1.xyz = (v2.yyyy * r1.xyzx) + cb1[32].xyzx;
    r2.xyz = -cb1[34].xyzx + cb1[35].xyzx;
    r2.xyz = (v2.yyyy * r2.xyzx) + cb1[34].xyzx;
    r2.xyz = -r1.xyzx + r2.xyzx;
    r1.xyz = (v2.xxxx * r2.xyzx) + r1.xyzx;
    r0.yzw = (r1.xxyz * r0.yyyy) + cb1[36].xxyz;
    r0.x = (r0.x < l(0.000010));
    r1.x = (r0.z >= cb0[58].z);
    r0.x = r0.x | r1.x;
    if (r0.x) {
        // asm: discard_nz l(-1)
    }
    r0.x = -cb0[79].z + cb0[128].x;
    r0.x = r0.x / cb0[79].x;
    r1.x = (r0.x >= -r0.x);
    r0.x = frac(|r0.x|);
    r0.x = (r1.x) ? r0.x : -r0.x;
    r0.x = r0.x * cb0[79].x;
    r1.xyz = r0.yzwy + -cb0[77].xyzx;
    r0.y = dot(r1.xyzx, r1.xyzx);
    r0.w = sqrt(r0.y);
    r1.x = (cb0[129].w) ? l(0.200000) : l(0.300000);
    r1.y = (r0.x * cb0[78].y) + -r0.w;
    // asm: mul_sat r1.yzw, r1.yyyy, l(0.000000, 0.016667, 0.142857, 0.022222)
    r2.xy = log2(r1.yzyy);
    r2.xy = r2.xyxx * cb0[78].zzzz;
    r2.xy = exp2(r2.xyxx);
    r1.yz = -r1.yyzy + l(0.000000, 1.000000, 1.000000, 0.000000);
    r1.yz = log2(r1.yyzy);
    r1.yz = r1.yyzy * cb0[78].wwww;
    r1.yz = exp2(r1.yyzy);
    r1.yz = r1.yyzy * r2.xxyx;
    r0.y = r0.y * l(0.000800);
    r0.y = min(r0.y, l(1.000000));
    r0.y = r0.y * r1.y;
    r1.y = (r1.w * l(-2.000000)) + l(3.000000);
    r1.w = r1.w * r1.w;
    r1.y = (-r1.y * r1.w) + l(1.000000);
    r2.xyz = r1.yyyy * l(0.000000, 0.100000, 0.500000, 0.000000);
    r3.xyz = (r1.yyyy * l(0.000000, 0.100000, 0.500000, 0.000000)) + l(0.000000, 0.220000, 0.700000, 0.000000);
    r0.y = r0.y * l(7.000000);
    r1.y = -r0.w / cb0[77].w;
    r1.y = (r1.y * l(0.031250)) + l(1.000000);
    r1.y = r1.y * r1.y;
    r1.y = r1.y * r1.y;
    r1.y = r1.y * r1.y;
    r1.y = r1.y * r1.y;
    r1.y = r1.y * r1.y;
    r1.x = r1.y * r1.x;
    r0.z = r0.z * cb0[78].x;
    r0.z = (r0.z * l(0.031250)) + l(1.000000);
    r0.z = r0.z * r0.z;
    r0.z = r0.z * r0.z;
    r0.z = r0.z * r0.z;
    r0.z = r0.z * r0.z;
    r0.z = (-r0.z * r0.z) + l(1.000000);
    r0.z = r0.z * r1.x;
    r0.x = r0.x / cb0[79].x;
    r0.x = r0.x * r0.x;
    r0.x = (-r0.x * r0.x) + l(1.000000);
    r0.x = r0.x * r0.z;
    r0.y = r0.y * r0.x;
    r0.y = r0.y * l(0.300000);
    r0.x = dot2(r0.xxxx, r1.zzzz);
    r0.z = r0.w + l(-5.000000);
    // asm: mul_sat r0.z, r0.z, l(0.250000)
    r0.w = (r0.z * l(-2.000000)) + l(3.000000);
    r0.z = r0.z * r0.z;
    r0.z = r0.z * r0.w;
    r0.xy = r0.zzzz * r0.xyxx;
    r0.xzw = r0.xxxx * r2.xxyz;
    o0.xyz = (r3.xyzx * r0.yyyy) + r0.xzwx;
    o0.w = l(0);
    return;
    // asm: // Approximately 82 instruction slots used
}

// -----------------------------------------------------------------------------
// Shader 3
// Profile: ps_5_0
// Byte offset: 49036
// Byte length: 15040
// -----------------------------------------------------------------------------

// Reflected buffer definitions
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
  } g_waterParams;                   // Offset:  768 Size:   436
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
  } g_underwaterHighlight;           // Offset: 1216 Size:    64
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
  float g_time;                      // Offset: 2048 Size:     4
     = 0x00000000 
  float g_timePrev;                  // Offset: 2052 Size:     4 [unused]
     = 0x00000000 
  float g_deltaTime;                 // Offset: 2056 Size:     4 [unused]
     = 0x00000000 
  float g_timeFromMapStart;          // Offset: 2060 Size:     4 [unused]
     = 0x00000000 
  uint g_frameIdx;                   // Offset: 2064 Size:     4 [unused]
     = 0x00000000 
  float g_uiBrightnessMultiplier;    // Offset: 2068 Size:     4 [unused]
     = 0x3f800000 
  uint g_playerRenderObjectID;       // Offset: 2072 Size:     4 [unused]
     = 0x00000000 
  bool g_isBinocularCamera;          // Offset: 2076 Size:     4
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
cbuffer PerScreen
{
  float4 g_screen;                   // Offset:    0 Size:    16
     = 0x00000000 0x00000000 0x00000000 0x00000000 
}
cbuffer PerView
{
  row_major float4x4 g_viewProj;     // Offset:    0 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_prevFrameViewProj;// Offset:   64 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_invViewProj;  // Offset:  128 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_view;         // Offset:  192 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_prevFrameView;// Offset:  256 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_invView;      // Offset:  320 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_proj;         // Offset:  384 Size:    64
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_invProj;      // Offset:  448 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_cameraDirs;   // Offset:  512 Size:    64
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_cameraPos;                // Offset:  576 Size:    16
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_prevFrameCameraPos;       // Offset:  592 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float g_zoomFactor;                // Offset:  608 Size:     4 [unused]
     = 0x00000000 
  float g_nearPlane;                 // Offset:  612 Size:     4 [unused]
     = 0x00000000 
  float4 g_farPlane;                 // Offset:  624 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  bool g_clipPlaneEnable;            // Offset:  640 Size:     4 [unused]
     = 0x00000000 
  float4 g_clipPlane;                // Offset:  656 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_currPrevNDCOffsets;       // Offset:  672 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
}

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// g_depthTexSampler                 sampler      NA          NA             s0      1 
// g_depthTex                        texture  float4          2d             t0      1 
// PerFrame                          cbuffer      NA          NA            cb0      1 
// PerScreen                         cbuffer      NA          NA            cb1      1 
// PerView                           cbuffer      NA          NA            cb2      1

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float       
// TEXCOORD                 0   xyzw        1     NONE   float       
// TEXCOORD                 1   xy          2     NONE   float   xy

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Target                0   xyzw        0   TARGET   float   xyzw

void ps_03_ps_5_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_globalFlags refactoringAllowed
    // dcl_immediateConstantBuffer { { 1.000000, 0, 0, 0},
    // asm: { 0, 1.000000, 0, 0},
    // asm: { 0, 0, 1.000000, 0},
    // asm: { 0, 0, 0, 1.000000} }
    // dcl_constantbuffer CB0[130], immediateIndexed
    // dcl_constantbuffer CB1[1], immediateIndexed
    // dcl_constantbuffer CB2[37], immediateIndexed
    // dcl_sampler s0, mode_default
    // dcl_resource_texture2d (float,float,float,float) t0
    // dcl_input_ps linear v2.xy
    // dcl_output o0.xyzw
    float4 r[5];
    r0.x = (l(0.000000, 0.000000, 0.000000, 0.000000) != cb0[79].y);
    if (!(r0.x)) {
        // asm: discard_nz l(-1)
    }
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r0.x, v2.xyxx, t0.xyzw, s0, l(0.000000)
    r0.y = r0.x + -cb2[26].z;
    r0.y = cb2[27].z / r0.y;
    r1.xyz = -cb2[32].xyzx + cb2[33].xyzx;
    r1.xyz = (v2.yyyy * r1.xyzx) + cb2[32].xyzx;
    r2.xyz = -cb2[34].xyzx + cb2[35].xyzx;
    r2.xyz = (v2.yyyy * r2.xyzx) + cb2[34].xyzx;
    r2.xyz = -r1.xyzx + r2.xyzx;
    r1.xyz = (v2.xxxx * r2.xyzx) + r1.xyzx;
    r1.xyz = (r1.xyzx * r0.yyyy) + cb2[36].xyzx;
    r0.x = (r0.x < l(0.000010));
    r0.z = (r1.y >= cb0[58].z);
    r0.x = r0.x | r0.z;
    if (r0.x) {
        // asm: discard_nz l(-1)
    }
    r0.x = -cb0[79].z + cb0[128].x;
    r0.x = r0.x / cb0[79].x;
    r0.z = (r0.x >= -r0.x);
    r0.x = frac(|r0.x|);
    r0.x = (r0.z) ? r0.x : -r0.x;
    r0.x = r0.x * cb0[79].x;
    r2.xyz = r1.xyzx + -cb0[77].xyzx;
    r0.z = dot(r2.xyzx, r2.xyzx);
    r0.w = sqrt(r0.z);
    // asm: deriv_rtx_coarse r2.xyz, r1.zxyz
    // asm: deriv_rty_coarse r3.xyz, r1.yzxy
    r4.xyz = r2.xyzx * r3.xyzx;
    r2.xyz = (r2.zxyz * r3.yzxy) + -r4.xyzx;
    r1.w = dot(r2.xyzx, r2.xyzx);
    r1.w = rsqrt(r1.w);
    r2.xyz = r1.wwww * r2.xyzx;
    r1.w = (cb0[129].w) ? l(0.200000) : l(0.300000);
    r2.w = (r0.x * cb0[78].y) + -r0.w;
    // asm: mul_sat r3.xyz, r2.wwww, l(0.016667, 0.142857, 0.022222, 0.000000)
    r4.xy = log2(r3.xyxx);
    r4.xy = r4.xyxx * cb0[78].zzzz;
    r4.xy = exp2(r4.xyxx);
    r3.xy = -r3.xyxx + l(1.000000, 1.000000, 0.000000, 0.000000);
    r3.xy = log2(r3.xyxx);
    r3.xy = r3.xyxx * cb0[78].wwww;
    r3.xy = exp2(r3.xyxx);
    r3.xy = r3.xyxx * r4.xyxx;
    r0.z = r0.z * l(0.000800);
    r0.z = min(r0.z, l(1.000000));
    r0.z = r0.z * r3.x;
    r2.w = (r3.z * l(-2.000000)) + l(3.000000);
    r3.x = r3.z * r3.z;
    r2.w = (-r2.w * r3.x) + l(1.000000);
    r3.xzw = r2.wwww * l(0.000000, 0.000000, 0.100000, 0.500000);
    r4.xyz = (r2.wwww * l(0.000000, 0.100000, 0.500000, 0.000000)) + l(0.000000, 0.220000, 0.700000, 0.000000);
    r2.w = (|r2.x| < |r2.y|);
    r2.w = r2.w & l(1);
    r2.x = dot2(|r2.xyxx|, icb[r2.w + 0].xyxx);
    r2.x = (r2.x < |r2.z|);
    r2.x = (r2.x) ? l(2) : r2.w;
    r2.y = l(1.000000, 1.000000, 1.000000, 1.000000) / cb2[25].y;
    r2.y = r2.y * cb1[0].w;
    r0.y = r0.y * r2.y;
    r0.yz = r0.yyzy * l(0.000000, 3.500000, 7.000000, 0.000000);
    r0.y = max(r0.y, l(0.030000));
    r0.y = min(r0.y, l(0.600000));
    r2.yzw = r1.xxyz * l(0.000000, 6.060606, 6.060606, 6.060606);
    r2.yzw = round(r2.yyzw);
    r2.yzw = (-r2.yyzw * l(0.000000, 0.165000, 0.165000, 0.165000)) + r1.xxyz;
    r2.yzw = |r2.yyzw| / r0.yyyy;
    r2.yzw = r2.yyzw * l(0.000000, 0.666667, 0.666667, 0.666667);
    r2.yzw = min(r2.yyzw, l(0.000000, 1.000000, 1.000000, 1.000000));
    r2.yzw = -r2.yyzw + l(0.000000, 1.000000, 1.000000, 1.000000);
    r1.xz = r2.xxxx + l(1, 0, 2, 0);
    // asm: udiv null, r1.xz, r1.xxzx, l(3, 0, 3, 0)
    r0.y = dot(r2.yzwy, icb[r1.x + 0].xyzx);
    r1.x = dot(r2.yzwy, icb[r1.z + 0].xyzx);
    r0.y = r0.y * r1.x;
    r0.y = r0.y * l(1.450000);
    r1.x = r0.w * l(0.014286);
    r1.x = min(r1.x, l(1.000000));
    r1.z = (r1.x * l(-2.000000)) + l(3.000000);
    r1.x = r1.x * r1.x;
    r2.x = r1.x * r1.z;
    r1.x = (-r1.z * r1.x) + l(1.000000);
    r0.y = r0.y * r1.x;
    r1.x = (r2.x * l(10.000000)) + l(8.000000);
    r1.x = r3.y * r1.x;
    r0.y = r0.y * r1.x;
    r0.y = (r2.x * -r0.y) + r0.y;
    r1.x = -r0.w / cb0[77].w;
    r1.x = (r1.x * l(0.031250)) + l(1.000000);
    r1.x = r1.x * r1.x;
    r1.x = r1.x * r1.x;
    r1.x = r1.x * r1.x;
    r1.x = r1.x * r1.x;
    r1.x = r1.x * r1.x;
    r1.y = r1.y * cb0[78].x;
    r1.y = (r1.y * l(0.031250)) + l(1.000000);
    r1.xy = r1.xyxx * r1.wyww;
    r1.y = r1.y * r1.y;
    r1.y = r1.y * r1.y;
    r1.y = r1.y * r1.y;
    r1.y = (-r1.y * r1.y) + l(1.000000);
    r1.x = r1.y * r1.x;
    r0.x = r0.x / cb0[79].x;
    r0.x = r0.x * r0.x;
    r0.x = (-r0.x * r0.x) + l(1.000000);
    r0.x = r0.x * r1.x;
    r0.z = r0.z * r0.x;
    r0.z = r0.z * l(0.300000);
    r0.x = dot2(r0.xxxx, r0.yyyy);
    r0.y = r0.w + l(-5.000000);
    // asm: mul_sat r0.y, r0.y, l(0.250000)
    r0.w = (r0.y * l(-2.000000)) + l(3.000000);
    r0.y = r0.y * r0.y;
    r0.y = r0.y * r0.w;
    r0.xz = r0.yyyy * r0.xxzx;
    r0.xyw = r0.xxxx * r3.xzxw;
    o0.xyz = (r4.xyzx * r0.zzzz) + r0.xywx;
    o0.w = l(0);
    return;
    // asm: // Approximately 122 instruction slots used
}

// -----------------------------------------------------------------------------
// Shader 4
// Profile: vs_5_0
// Byte offset: 64288
// Byte length: 11520
// -----------------------------------------------------------------------------

// Reflected buffer definitions
cbuffer $Globals
{
  bool g_isTAAEnabledBranch;         // Offset:    0 Size:     4 [unused]
     = 0xffffffff 
  float g_smoothBinocularFactor;     // Offset:    4 Size:     4 [unused]
  float3 g_mapBorderSize;            // Offset:   16 Size:    12
  float3 g_mapBorderCenter;          // Offset:   32 Size:    12
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
  } g_waterParams;                   // Offset:  768 Size:   436
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
  float g_deltaTime;                 // Offset: 2056 Size:     4 [unused]
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
cbuffer PerView
{
  row_major float4x4 g_viewProj;     // Offset:    0 Size:    64
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_prevFrameViewProj;// Offset:   64 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_invViewProj;  // Offset:  128 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_view;         // Offset:  192 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_prevFrameView;// Offset:  256 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_invView;      // Offset:  320 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_proj;         // Offset:  384 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_invProj;      // Offset:  448 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_cameraDirs;   // Offset:  512 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_cameraPos;                // Offset:  576 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_prevFrameCameraPos;       // Offset:  592 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float g_zoomFactor;                // Offset:  608 Size:     4 [unused]
     = 0x00000000 
  float g_nearPlane;                 // Offset:  612 Size:     4 [unused]
     = 0x00000000 
  float4 g_farPlane;                 // Offset:  624 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  bool g_clipPlaneEnable;            // Offset:  640 Size:     4 [unused]
     = 0x00000000 
  float4 g_clipPlane;                // Offset:  656 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_currPrevNDCOffsets;       // Offset:  672 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
}

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// $Globals                          cbuffer      NA          NA            cb0      1 
// PerFrame                          cbuffer      NA          NA            cb1      1 
// PerView                           cbuffer      NA          NA            cb2      1

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// POSITION                 0   xyz         0     NONE   float   xyz 
// SV_VertexID              0   x           1   VERTID    uint

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float   xyzw
// TEXCOORD                 0   xyz         1     NONE   float   xyz

void vs_04_vs_5_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_globalFlags refactoringAllowed
    // dcl_constantbuffer CB0[3], immediateIndexed
    // dcl_constantbuffer CB1[59], immediateIndexed
    // dcl_constantbuffer CB2[4], immediateIndexed
    // dcl_input v0.xyz
    // dcl_output_siv o0.xyzw, position
    // dcl_output o1.xyz
    float4 r[2];
    r0.xyz = (v0.xyzx * cb0[1].xyzx) + cb0[2].xyzx;
    r0.w = min(r0.y, cb1[58].z);
    r1.xyzw = r0.wwww * cb2[1].xyzw;
    o1.xyz = r0.xwzx;
    r1.xyzw = (r0.xxxx * cb2[0].xyzw) + r1.xyzw;
    r0.xyzw = (r0.zzzz * cb2[2].xyzw) + r1.xyzw;
    o0.xyzw = r0.xyzw + cb2[3].xyzw;
    return;
    // asm: // Approximately 8 instruction slots used
}

// -----------------------------------------------------------------------------
// Shader 5
// Profile: ps_5_0
// Byte offset: 75988
// Byte length: 13616
// -----------------------------------------------------------------------------

// Reflected buffer definitions
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
  } g_waterParams;                   // Offset:  768 Size:   436
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
  } g_underwaterHighlight;           // Offset: 1216 Size:    64
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
  float g_time;                      // Offset: 2048 Size:     4
     = 0x00000000 
  float g_timePrev;                  // Offset: 2052 Size:     4 [unused]
     = 0x00000000 
  float g_deltaTime;                 // Offset: 2056 Size:     4 [unused]
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
cbuffer PerScreen
{
  float4 g_screen;                   // Offset:    0 Size:    16
     = 0x00000000 0x00000000 0x00000000 0x00000000 
}
cbuffer PerView
{
  row_major float4x4 g_viewProj;     // Offset:    0 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_prevFrameViewProj;// Offset:   64 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_invViewProj;  // Offset:  128 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_view;         // Offset:  192 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_prevFrameView;// Offset:  256 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_invView;      // Offset:  320 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_proj;         // Offset:  384 Size:    64
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_invProj;      // Offset:  448 Size:    64 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  row_major float4x4 g_cameraDirs;   // Offset:  512 Size:    64
     = 0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
       0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_cameraPos;                // Offset:  576 Size:    16
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_prevFrameCameraPos;       // Offset:  592 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float g_zoomFactor;                // Offset:  608 Size:     4 [unused]
     = 0x00000000 
  float g_nearPlane;                 // Offset:  612 Size:     4 [unused]
     = 0x00000000 
  float4 g_farPlane;                 // Offset:  624 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  bool g_clipPlaneEnable;            // Offset:  640 Size:     4 [unused]
     = 0x00000000 
  float4 g_clipPlane;                // Offset:  656 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
  float4 g_currPrevNDCOffsets;       // Offset:  672 Size:    16 [unused]
     = 0x00000000 0x00000000 0x00000000 0x00000000 
}

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// g_depthTexSampler                 sampler      NA          NA             s0      1 
// g_depthTex                        texture  float4          2d             t0      1 
// PerFrame                          cbuffer      NA          NA            cb0      1 
// PerScreen                         cbuffer      NA          NA            cb1      1 
// PerView                           cbuffer      NA          NA            cb2      1

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float   xy  
// TEXCOORD                 0   xyz         1     NONE   float   xyz

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Target                0   xyzw        0   TARGET   float   xyzw

void ps_05_ps_5_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_globalFlags refactoringAllowed
    // dcl_constantbuffer CB0[129], immediateIndexed
    // dcl_constantbuffer CB1[1], immediateIndexed
    // dcl_constantbuffer CB2[37], immediateIndexed
    // dcl_sampler s0, mode_default
    // dcl_resource_texture2d (float,float,float,float) t0
    // dcl_input_ps_siv linear noperspective v0.xy, position
    // dcl_input_ps linear v1.xyz
    // dcl_output o0.xyzw
    float4 r[3];
    r0.xy = cb0[58].zzzz + l(-0.100000, -30.100000, 0.000000, 0.000000);
    r0.x = (r0.x < v1.y);
    r0.y = (v1.y < r0.y);
    r0.x = r0.y | r0.x;
    // asm: discard_nz r0.x
    r0.xy = v0.xyxx * cb1[0].zwzz;
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r0.z, r0.xyxx, t0.yzxw, s0, l(0.000000)
    r0.z = r0.z + -cb2[26].z;
    r0.z = cb2[27].z / r0.z;
    r1.xyz = -cb2[32].xyzx + cb2[33].xyzx;
    r1.xyz = (r0.yyyy * r1.xyzx) + cb2[32].xyzx;
    r2.xyz = -cb2[34].xyzx + cb2[35].xyzx;
    r2.xyz = (r0.yyyy * r2.xyzx) + cb2[34].xyzx;
    r2.xyz = -r1.xyzx + r2.xyzx;
    r0.xyw = (r0.xxxx * r2.xyxz) + r1.xyxz;
    r0.xyz = (r0.xywx * r0.zzzz) + cb2[36].xyzx;
    r1.xyz = v1.xyzx + -cb0[77].xyzx;
    r0.w = dot(r1.xyzx, r1.xyzx);
    r0.w = sqrt(r0.w);
    r1.xyz = v1.xyzx + -cb2[36].xyzx;
    r1.x = dot(r1.xyzx, r1.xyzx);
    r1.x = sqrt(r1.x);
    r2.xyzw = cb0[58].zzzz + l(-20.100000, -3.100000, -1.100000, -0.600000);
    r2.xyzw = -r2.xyzw + v1.yyyy;
    // asm: mul_sat r1.yz, r2.xxyx, l(0.000000, 0.058824, 0.333333, 0.000000)
    r2.xy = (r1.yzyy * l(-2.000000, -2.000000, 0.000000, 0.000000)) + l(3.000000, 3.000000, 0.000000, 0.000000);
    r1.yz = r1.yyzy * r1.yyzy;
    r1.y = r1.y * r2.x;
    r1.z = (-r2.y * r1.z) + l(1.000000);
    r1.y = r1.z * r1.y;
    r1.y = r1.y * l(0.200000);
    r1.z = r0.w + l(-3.000000);
    // asm: mul_sat r1.z, r1.z, l(0.027027)
    r1.w = (r1.z * l(-2.000000)) + l(3.000000);
    r1.z = r1.z * r1.z;
    r1.z = (-r1.w * r1.z) + l(1.000000);
    r0.w = r0.w * l(0.166667);
    r0.w = min(r0.w, l(1.000000));
    r1.w = (r0.w * l(-2.000000)) + l(3.000000);
    r0.w = r0.w * r0.w;
    r0.w = r0.w * r1.w;
    r0.w = r0.w * r1.z;
    r0.w = r0.w * r1.y;
    r1.x = r1.x + l(-0.100000);
    // asm: mul_sat r1.x, r1.x, l(1.111111)
    r1.y = (r1.x * l(-2.000000)) + l(3.000000);
    r1.x = r1.x * r1.x;
    r1.x = r1.x * r1.y;
    r0.w = r0.w * r1.x;
    // asm: add_sat r1.xy, r2.zwzz, r2.zwzz
    r1.zw = (r1.xxxy * l(0.000000, 0.000000, -2.000000, -2.000000)) + l(0.000000, 0.000000, 3.000000, 3.000000);
    r1.xy = r1.xyxx * r1.xyxx;
    r1.x = r1.x * r1.z;
    r1.x = r1.x * l(3.000000);
    r1.y = (-r1.w * r1.y) + l(1.000000);
    r1.xyz = (r1.xxxx * r1.yyyy) + l(0.000000, 0.220000, 0.700000, 0.000000);
    sincos(null, r1.w, cb0[128].x);
    r1.w = (r1.w * l(0.500000)) + l(0.500000);
    r1.w = (r1.w * l(0.700000)) + l(0.300000);
    r0.w = r0.w * r1.w;
    r0.xyz = -r0.xyzx + v1.xyzx;
    r0.x = dot(r0.xyzx, r0.xyzx);
    r0.x = sqrt(r0.x);
    r0.y = r0.x * l(3.333333);
    r0.y = min(r0.y, l(1.000000));
    r0.z = (r0.y * l(-2.000000)) + l(3.000000);
    r0.y = r0.y * r0.y;
    r0.y = r0.y * r0.z;
    r0.x = r0.x + r0.x;
    r0.x = min(r0.x, l(1.000000));
    r0.z = (r0.x * l(-2.000000)) + l(3.000000);
    r0.xy = r0.xyxx * r0.xwxx;
    r0.x = (-r0.z * r0.x) + l(1.000000);
    r0.xzw = r0.xxxx + r1.xxyz;
    o0.xyz = r0.yyyy * r0.xzwx;
    o0.w = r0.y;
    return;
    // asm: // Approximately 77 instruction slots used
}

