// Pseudo-HLSL generated from compiled shader bytecode.
// Source container: shoreline_gen.win.dx11.fxo
//
// This is reconstructed for reading only.
// It is not original HLSL and should not be treated as recompilable source.

// -----------------------------------------------------------------------------
// Shader 0
// Profile: vs_5_0
// Byte offset: 18732
// Byte length: 636
// -----------------------------------------------------------------------------

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// POSITION                 0   xyz         0     NONE   float   xyz 
// TEXCOORD                 0   xy          1     NONE   float   xy

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float   xyzw
// TEXCOORD                 0   xy          1     NONE   float   xy

void vs_00_vs_5_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_globalFlags refactoringAllowed
    // dcl_input v0.xyz
    // dcl_input v1.xy
    // dcl_output_siv o0.xyzw, position
    // dcl_output o1.xy
    o0.xyz = v0.xyzx;
    o0.w = l(1.000000);
    o1.xy = v1.xyxx;
    return;
    // asm: // Approximately 4 instruction slots used
}

// -----------------------------------------------------------------------------
// Shader 1
// Profile: ps_5_0
// Byte offset: 19500
// Byte length: 22620
// -----------------------------------------------------------------------------

// Reflected buffer definitions
cbuffer $Globals
{
  bool g_isTAAEnabledBranch;         // Offset:    0 Size:     4 [unused]
     = 0xffffffff 
  float g_foamSurfaceRampMin;        // Offset:    4 Size:     4
  float g_foamTextureScale;          // Offset:    8 Size:     4
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
  float4 g_chunkSpaceTransform;      // Offset: 1984 Size:    16
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
  bool g_isSpaceSdfExists;           // Offset: 2088 Size:     4
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
// g_pointClampSampler               sampler      NA          NA             s0      1 
// g_trilinearClampSampler           sampler      NA          NA             s1      1 
// g_trilinearWrapSampler            sampler      NA          NA             s2      1 
// g_foamSampler                     sampler      NA          NA             s3      1 
// g_spaceVariationTexture           texture  float4          2d             t0      1 
// g_spaceSdfDistTexture             texture   float          2d             t1      1 
// g_spaceSdfDirTexture              texture   float          2d             t2      1 
// g_foamLowFreq                     texture  float4          2d             t3      1 
// g_foamHighFreq                    texture  float4          2d             t4      1 
// g_fftWave0GradTexture             texture  float4          2d             t5      1 
// g_fftWave1GradTexture             texture  float4          2d             t6      1 
// g_fftWave2GradTexture             texture  float4          2d             t7      1 
// g_fftWave0Moments1Texture         texture  float4          2d             t8      1 
// g_fftWave1Moments1Texture         texture  float4          2d             t9      1 
// g_fftWave2Moments1Texture         texture  float4          2d            t10      1 
// $Globals                          cbuffer      NA          NA            cb0      1 
// PerFrame                          cbuffer      NA          NA            cb1      1 
// PerView                           cbuffer      NA          NA            cb2      1

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float       
// TEXCOORD                 0   xy          1     NONE   float   xy

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Target                0   xy          0   TARGET   float   xy

void ps_01_ps_5_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_globalFlags refactoringAllowed
    // dcl_constantbuffer CB0[1], immediateIndexed
    // dcl_constantbuffer CB1[131], immediateIndexed
    // dcl_constantbuffer CB2[37], immediateIndexed
    // dcl_sampler s0, mode_default
    // dcl_sampler s1, mode_default
    // dcl_sampler s2, mode_default
    // dcl_sampler s3, mode_default
    // dcl_resource_texture2d (float,float,float,float) t0
    // dcl_resource_texture2d (float,float,float,float) t1
    // dcl_resource_texture2d (float,float,float,float) t2
    // dcl_resource_texture2d (float,float,float,float) t3
    // dcl_resource_texture2d (float,float,float,float) t4
    // dcl_resource_texture2d (float,float,float,float) t5
    // dcl_resource_texture2d (float,float,float,float) t6
    // dcl_resource_texture2d (float,float,float,float) t7
    // dcl_resource_texture2d (float,float,float,float) t8
    // dcl_resource_texture2d (float,float,float,float) t9
    // dcl_resource_texture2d (float,float,float,float) t10
    // dcl_input_ps linear v1.xy
    // dcl_output o0.xy
    float4 r[8];
    r0.xy = v1.xyxx + l(-0.500000, -0.500000, 0.000000, 0.000000);
    r0.xy = (r0.xyxx * l(1.250000, 1.250000, 0.000000, 0.000000)) + l(0.500000, 0.500000, 0.000000, 0.000000);
    r1.xyz = -cb2[32].xyzx + cb2[33].xyzx;
    r1.xyz = (r0.yyyy * r1.xyzx) + cb2[32].xyzx;
    r2.xyz = -cb2[34].xyzx + cb2[35].xyzx;
    r0.yzw = (r0.yyyy * r2.xxyz) + cb2[34].xxyz;
    r0.yzw = -r1.xxyz + r0.yyzw;
    r0.xyz = (r0.xxxx * r0.yzwy) + r1.xyzx;
    r0.w = dot(r0.xyzx, r0.xyzx);
    r0.w = rsqrt(r0.w);
    r0.xyz = r0.wwww * r0.xyzx;
    r0.w = -cb1[58].z + cb2[36].y;
    r0.y = -r0.w / r0.y;
    r1.x = (l(0.000000) < r0.y);
    r2.xyzw = (r0.xzxz * r0.yyyy) + cb2[36].xzxz;
    r0.xz = (r2.zzwz * cb1[124].xxyx) + cb1[124].zzwz;
    // asm: deriv_rtx_coarse r1.yz, r0.xxzx
    // asm: deriv_rty_coarse r3.xy, r0.xzxx
    r3.zw = (r0.xxxz >= l(0.000000, 0.000000, 0.000000, 0.000000));
    r1.x = r1.x & r3.z;
    r4.xy = (l(1.000000, 1.000000, 0.000000, 0.000000) >= r0.xzxx);
    r1.x = r1.x & r4.x;
    r1.x = r3.w & r1.x;
    r1.x = r4.y & r1.x;
    if (r1.x) {
        if (cb1[130].z) {
            // asm: sample_d_indexable(texture2d)(float,float,float,float) r1.x, r0.xzxx, t1.xyzw, s1, r1.yzyy, r3.xyxx
            r1.w = (l(0.040450) < r1.x);
            r3.z = r1.x * l(0.077399);
            r1.x = (r1.x * l(0.947867)) + l(0.052133);
            r1.x = log2(r1.x);
            r1.x = r1.x * l(2.400000);
            r1.x = exp2(r1.x);
            r1.x = (r1.w) ? r1.x : r3.z;
            r1.x = r1.x * r1.x;
            // asm: resinfo_indexable(texture2d)(float,float,float,float)_uint r3.zw, l(0), t2.zwxy
            r3.zw = (float)r3.zzzw;
            r4.xy = l(1.000000, 1.000000, 1.000000, 1.000000) / r3.zwzz;
            r3.zw = (r0.xxxz * r3.zzzw) + l(0.000000, 0.000000, -0.500000, -0.500000);
            r4.zw = frac(r3.zzzw);
            r3.zw = floor(r3.zzzw);
            r3.zw = r3.zzzw + l(0.000000, 0.000000, 1.000000, 1.000000);
            r3.zw = r4.xxxy * r3.zzzw;
            // asm: gather4_indexable(texture2d)(float,float,float,float) r5.xyzw, r3.zwzz, t2.xyzw, s0.x
            r6.xyzw = (l(0.040450, 0.040450, 0.040450, 0.040450) < r5.xyzw);
            r3.zw = r5.xxxy * l(0.000000, 0.000000, 0.077399, 0.077399);
            r4.xy = (r5.xyxx * l(0.947867, 0.947867, 0.000000, 0.000000)) + l(0.052133, 0.052133, 0.000000, 0.000000);
            r4.xy = log2(r4.xyxx);
            r4.xy = r4.xyxx * l(2.400000, 2.400000, 0.000000, 0.000000);
            r4.xy = exp2(r4.xyxx);
            r3.zw = (r6.xxxy) ? r4.xxxy : r3.zzzw;
            r4.xy = r5.zwzz * l(0.077399, 0.077399, 0.000000, 0.000000);
            r5.xy = (r5.zwzz * l(0.947867, 0.947867, 0.000000, 0.000000)) + l(0.052133, 0.052133, 0.000000, 0.000000);
            r5.xy = log2(r5.xyxx);
            r5.xy = r5.xyxx * l(2.400000, 2.400000, 0.000000, 0.000000);
            r5.xy = exp2(r5.xyxx);
            r4.xy = (r6.zwzz) ? r5.xyxx : r4.xyxx;
            r3.zw = -r3.zzzw + l(0.000000, 0.000000, 1.000000, 1.000000);
            r3.zw = r3.zzzw * l(0.000000, 0.000000, 6.283185, 6.283185);
            r4.xy = -r4.xyxx + l(1.000000, 1.000000, 0.000000, 0.000000);
            r4.xy = r4.xyxx * l(6.283185, 6.283185, 0.000000, 0.000000);
            sincos(r5.xy, r6.xy, r3.zwzz);
            sincos(r4.xy, r7.xy, r4.xyxx);
            r7.xz = r7.yyxy;
            r7.yw = r4.yyyx;
            r3.zw = -r7.xxxy + r7.zzzw;
            r3.zw = (r4.zzzz * r3.zzzw) + r7.xxxy;
            r6.xz = r6.xxyx;
            r6.yw = r5.xxxy;
            r4.xy = -r6.xyxx + r6.zwzz;
            r4.xy = (r4.zzzz * r4.xyxx) + r6.xyxx;
            r4.xy = -r3.zwzz + r4.xyxx;
            r3.zw = (r4.wwww * r4.xxxy) + r3.zzzw;
            r1.w = dot2(r3.zwzz, r3.zwzz);
            r1.w = rsqrt(r1.w);
            r3.zw = r1.wwww * r3.zzzw;
            r4.xy = l(1.000000, 1.000000, 1.000000, 1.000000) / cb1[124].xyxx;
            r4.z = -r4.y;
            r4.xy = r3.zwzz * r4.xzxx;
            r1.w = dot2(r4.xyxx, r4.xyxx);
            r1.w = sqrt(r1.w);
            r1.x = r1.x * r1.w;
        else
            r3.zw = cb1[58].xxxy;
            r1.x = l(20000.000000);
        }
        // asm: sample_d_indexable(texture2d)(float,float,float,float) r0.x, r0.xzxx, t0.zxyw, s2, r1.yzyy, r3.xyxx
    else
        // asm: discard_nz l(-1)
        r0.x = l(1.000000);
    }
    // asm: mad_sat r0.z, |r0.w|, l(0.003333), l(-0.100000)
    r0.z = -r0.z + l(1.000000);
    r0.w = l(1.000000, 1.000000, 1.000000, 1.000000) / cb1[71].y;
    // asm: mul_sat r0.w, r0.w, r1.x
    r1.y = (r0.w * l(-2.000000)) + l(3.000000);
    r0.w = r0.w * r0.w;
    r0.w = (-r1.y * r0.w) + l(1.000000);
    r0.z = r0.z * r0.w;
    r0.w = (r0.z < l(0.000100));
    // asm: discard_nz r0.w
    r0.w = dot2(r3.zwzz, cb1[58].xyxx);
    r1.y = cb1[69].y * l(0.650000);
    // asm: mad_sat r0.w, r0.w, l(0.500000), l(0.500000)
    r0.w = (-cb1[69].y * l(0.350000)) + r0.w;
    r1.y = l(1.000000, 1.000000, 1.000000, 1.000000) / r1.y;
    // asm: mul_sat r0.w, r0.w, r1.y
    r1.y = (r0.w * l(-2.000000)) + l(3.000000);
    r0.w = r0.w * r0.w;
    r0.w = r0.w * r1.y;
    r1.y = dot2(r2.zwzz, -cb1[58].xyxx);
    r1.zw = r2.zzzw * l(0.000000, 0.000000, 0.500000, 0.500000);
    r1.zw = r1.zzzw / cb1[68].wwww;
    r1.zw = (cb1[128].xxxx * l(0.000000, 0.000000, 0.300000, 0.400000)) + r1.zzzw;
    sincos(r1.zw, null, r1.zzzw);
    r1.z = r1.z * l(0.500000);
    r1.z = (r1.z * r1.w) + l(0.500000);
    r1.w = dot2(r2.zwzz, r2.zwzz);
    r1.w = rsqrt(r1.w);
    r3.xy = r1.wwww * r2.zwzz;
    r1.w = dot2(r3.zwzz, r3.xyxx);
    r3.x = cb1[71].w * l(10.000000);
    r3.y = r1.x + l(10.000000);
    // asm: mul_sat r3.y, r3.y, l(0.026316)
    r3.z = (r3.y * l(-2.000000)) + l(3.000000);
    r3.y = r3.y * r3.y;
    r3.y = (-r3.z * r3.y) + l(1.000000);
    r3.z = (-cb1[71].w * l(10.000000)) + l(1.000000);
    r3.x = (r3.y * r3.z) + r3.x;
    r1.w = log2(|r1.w|);
    r1.w = r1.w * r3.x;
    r1.w = exp2(r1.w);
    r1.w = min(r1.w, l(1.000000));
    r1.y = -r1.x + r1.y;
    r1.x = (cb1[70].z * r1.y) + r1.x;
    r1.x = r1.x * l(6.283185);
    r1.x = r1.x / cb1[69].x;
    r3.xy = r2.zwzz + r2.zwzz;
    r3.zw = (r2.zzzw * l(0.000000, 0.000000, 2.000000, 2.000000)) + l(0.000000, 0.000000, 1.000000, 1.000000);
    r4.xyzw = floor(r3.zwxy);
    r3.xy = frac(r3.xyxx);
    r3.zw = r3.xxxy * r3.xxxy;
    r3.xy = (-r3.xyxx * l(2.000000, 2.000000, 0.000000, 0.000000)) + l(3.000000, 3.000000, 0.000000, 0.000000);
    r3.xy = r3.xyxx * r3.zwzz;
    r1.y = dot2(r4.zwzz, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r1.y, null, r1.y);
    r1.y = r1.y * l(43758.546875);
    r1.y = frac(r1.y);
    r3.z = dot2(r4.xwxx, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r3.z, null, r3.z);
    r3.z = r3.z * l(43758.546875);
    r3.z = frac(r3.z);
    r3.z = -r1.y + r3.z;
    r1.y = (r3.x * r3.z) + r1.y;
    r3.z = dot2(r4.zyzz, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r3.z, null, r3.z);
    r3.z = r3.z * l(43758.546875);
    r3.w = dot2(r4.xyxx, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r3.w, null, r3.w);
    r3.w = r3.w * l(43758.546875);
    r3.zw = frac(r3.zzzw);
    r3.w = -r3.z + r3.w;
    r3.x = (r3.x * r3.w) + r3.z;
    r3.x = -r1.y + r3.x;
    r1.y = (r3.y * r3.x) + r1.y;
    r1.y = r1.y * r1.y;
    r1.y = r1.y * r1.y;
    r3.x = cb1[70].w * cb1[71].x;
    r1.x = (r3.x * cb1[128].x) + r1.x;
    r1.x = (-r1.w * l(0.800000)) + r1.x;
    r1.x = (r1.y * l(0.600000)) + r1.x;
    r0.x = r0.x * r0.z;
    r0.x = r0.w * r0.x;
    r0.z = l(1.000000, 1.000000, 1.000000, 1.000000) / cb1[71].z;
    // asm: mul_sat r0.z, r0.z, r1.w
    r0.w = (r0.z * l(-2.000000)) + l(3.000000);
    r0.z = r0.z * r0.z;
    r0.z = r0.z * r0.w;
    r0.x = r0.z * r0.x;
    r0.z = r1.z * r1.z;
    r0.x = r0.x * r0.z;
    // asm: deriv_rtx_coarse r3.xyzw, r2.zwzw
    // asm: deriv_rty_coarse r4.xyzw, r2.zwzw
    r5.xyzw = (r2.zwzw * cb1[59].xxyy) + cb1[60].xxyy;
    r6.xyzw = r3.zwzw * cb1[59].xxyy;
    r7.xyzw = r4.zwzw * cb1[59].xxyy;
    // asm: sample_d_indexable(texture2d)(float,float,float,float) r0.z, r5.xyxx, t5.xyzw, s3, r6.xyxx, r7.xyxx
    // asm: sample_d_indexable(texture2d)(float,float,float,float) r0.w, r5.xyxx, t8.xyzw, s3, r6.xyxx, r7.xyxx
    // asm: sample_d_indexable(texture2d)(float,float,float,float) r1.y, r5.zwzz, t6.xzyw, s3, r6.zwzz, r7.zwzz
    r0.z = r0.z + r1.y;
    // asm: sample_d_indexable(texture2d)(float,float,float,float) r1.y, r5.zwzz, t9.xwyz, s3, r6.zwzz, r7.zwzz
    r0.w = r0.w + r1.y;
    r1.yz = (r2.zzwz * cb1[59].zzzz) + cb1[60].zzzz;
    r5.xy = r3.zwzz * cb1[59].zzzz;
    r5.zw = r4.zzzw * cb1[59].zzzz;
    // asm: sample_d_indexable(texture2d)(float,float,float,float) r1.w, r1.yzyy, t7.xywz, s3, r5.xyxx, r5.zwzz
    r0.z = r0.z + r1.w;
    // asm: sample_d_indexable(texture2d)(float,float,float,float) r1.y, r1.yzyy, t10.xwyz, s3, r5.xyxx, r5.zwzz
    r0.w = r0.w + r1.y;
    r5.xyzw = cb0[0].zzzz * l(0.500000, 0.500000, 4.000000, 4.000000);
    r2.xyzw = r2.xyzw * r5.xyzw;
    r3.xyzw = r3.xyzw * r5.xyzw;
    r4.xyzw = r4.xyzw * r5.xyzw;
    // asm: sample_d_indexable(texture2d)(float,float,float,float) r1.yz, r2.xyxx, t3.zxyw, s3, r3.xyxx, r4.xyxx
    // asm: sample_d_indexable(texture2d)(float,float,float,float) r2.xy, r2.zwzz, t4.xyzw, s3, r3.zwzz, r4.zwzz
    r1.w = -cb0[0].y + l(1.000000);
    r0.z = r0.z + -cb0[0].y;
    r1.w = l(1.000000, 1.000000, 1.000000, 1.000000) / r1.w;
    // asm: mul_sat r0.z, r0.z, r1.w
    r1.w = (r0.z * l(-2.000000)) + l(3.000000);
    r0.z = r0.z * r0.z;
    r2.z = r1.x * l(0.159155);
    r2.w = (r2.z >= -r2.z);
    r2.z = frac(|r2.z|);
    r2.z = (r2.w) ? r2.z : -r2.z;
    r2.zw = (r2.zzzz * l(0.000000, 0.000000, 6.283185, 6.283185)) + l(0.000000, 0.000000, -1.000000, -5.780530);
    r2.zw = r2.zzzw * l(0.000000, 0.000000, -1.111111, 1.989436);
    // asm: mov_sat r2.z, r2.z
    r3.x = (r2.z * l(-2.000000)) + l(3.000000);
    r2.z = r2.z * r2.z;
    r2.w = max(r2.w, l(0.000000));
    r3.y = (r2.w * l(-2.000000)) + l(3.000000);
    r2.w = r2.w * r2.w;
    r2.w = r2.w * r3.y;
    r2.z = (r3.x * r2.z) + r2.w;
    r2.z = min(r2.z, l(1.000000));
    // asm: add_sat r2.z, r2.z, cb1[70].y
    r2.zw = (r2.zzzz * l(0.000000, 0.000000, -0.250000, 0.700000)) + l(0.000000, 0.000000, 0.650000, 0.100000);
    r3.xy = r1.yzyy + -r2.zzzz;
    // asm: mad_sat r3.xy, r1.wwww, r0.zzzz, r3.xyxx
    r3.xy = r3.xyxx * r3.xyxx;
    r3.xy = r3.xyxx * l(8.000000, 8.000000, 0.000000, 0.000000);
    r3.x = r3.y + r3.x;
    r2.z = -r2.z + r2.x;
    // asm: mad_sat r0.z, r1.w, r0.z, r2.z
    r0.z = (r0.z * l(4.000000)) + r3.x;
    r3.xy = r0.wwww + l(-1.000000, 3.000000, 0.000000, 0.000000);
    // asm: mul_sat r3.xy, r3.xyxx, l(0.200000, 0.200000, 0.000000, 0.000000)
    r3.zw = (r3.xxxy * l(0.000000, 0.000000, -2.000000, -2.000000)) + l(0.000000, 0.000000, 3.000000, 3.000000);
    r3.xy = r3.xyxx * r3.xyxx;
    r1.w = r3.x * r3.z;
    r2.z = (-r3.w * r3.y) + l(1.000000);
    r0.z = (-r1.w * l(0.200000)) + r0.z;
    r0.z = max(r0.z, l(0.000000));
    r3.x = (r2.z * l(0.800000)) + l(1.000000);
    r2.x = r2.x * r2.z;
    r0.z = (r0.z * r3.x) + r2.x;
    // asm: mul_sat r0.w, r0.w, l(0.250000)
    r0.w = (r0.w * l(0.500000)) + l(0.300000);
    r0.w = -r0.w + r2.y;
    // asm: add_sat r0.w, r0.w, r0.w
    // asm: mul_sat r0.z, r0.w, r0.z
    r1.yz = r1.yyzy + l(0.000000, -0.100000, -0.100000, 0.000000);
    // asm: mul_sat r1.yz, r1.yyzy, l(0.000000, 1.111111, 1.111111, 0.000000)
    r2.xy = (r1.yzyy * l(-2.000000, -2.000000, 0.000000, 0.000000)) + l(3.000000, 3.000000, 0.000000, 0.000000);
    r1.yz = r1.yyzy * r1.yyzy;
    r1.yz = r1.yyzy * r2.xxyx;
    r0.w = r1.z * r1.y;
    r0.y = r0.y + l(-30.000000);
    // asm: mul_sat r0.y, r0.y, l(0.011111)
    r1.y = (r0.y * l(-2.000000)) + l(3.000000);
    r0.y = r0.y * r0.y;
    r0.y = r0.y * r1.y;
    r1.y = -r2.w + l(0.800000);
    r1.y = (r0.y * r1.y) + r2.w;
    r0.y = (r0.y * l(-0.700000)) + l(1.000000);
    r0.y = r0.y * r0.z;
    r0.y = (r0.w * r1.y) + r0.y;
    r0.z = (r1.w * l(0.500000)) + r1.x;
    r0.z = r0.z * l(0.500000);
    sincos(r1.x, r2.x, r0.z);
    r0.z = r2.x * l(-0.970000);
    r0.w = -|r0.z| + l(1.000000);
    r0.w = sqrt(r0.w);
    r1.y = (|r0.z| * l(-0.018729)) + l(0.074261);
    r1.y = (r1.y * |r0.z|) + l(-0.212114);
    r1.y = (r1.y * |r0.z|) + l(1.570729);
    r1.z = r0.w * r1.y;
    r1.z = (r1.z * l(-2.000000)) + l(3.141593);
    r0.z = (r0.z < -r0.z);
    r0.z = r0.z & r1.z;
    r0.z = (r1.y * r0.w) + r0.z;
    r0.z = (-r0.z * l(0.636620)) + l(1.000000);
    r0.w = r1.x * l(33.333336);
    r1.x = min(|r0.w|, l(1.000000));
    r1.y = max(|r0.w|, l(1.000000));
    r1.y = l(1.000000, 1.000000, 1.000000, 1.000000) / r1.y;
    r1.x = r1.y * r1.x;
    r1.y = r1.x * r1.x;
    r1.z = (r1.y * l(0.020835)) + l(-0.085133);
    r1.z = (r1.y * r1.z) + l(0.180141);
    r1.z = (r1.y * r1.z) + l(-0.330299);
    r1.y = (r1.y * r1.z) + l(0.999866);
    r1.z = r1.y * r1.x;
    r1.w = (l(1.000000) < |r0.w|);
    r1.z = (r1.z * l(-2.000000)) + l(1.570796);
    r1.z = r1.w & r1.z;
    r1.x = (r1.x * r1.y) + r1.z;
    r0.w = min(r0.w, l(1.000000));
    r0.w = (r0.w < -r0.w);
    r0.w = (r0.w) ? -r1.x : r1.x;
    r0.z = r0.z * r0.w;
    r0.z = (-r0.z * l(0.636620)) + l(1.000000);
    r0.xw = r0.xxxz * r0.yyyz;
    r0.y = (r0.z * r0.z) + l(-0.800000);
    // asm: mul_sat r0.y, r0.y, l(0.312500)
    r0.z = (r0.y * l(-2.000000)) + l(3.000000);
    r0.y = r0.y * r0.y;
    r0.y = r0.y * r0.z;
    r0.y = r0.x * r0.y;
    r0.y = r0.y * l(8.000000);
    r0.x = (r0.x * r0.w) + r0.y;
    // asm: mul_sat r0.x, r0.x, cb1[70].x
    r0.y = (r0.x < l(1.000000));
    r0.x = -r0.x + l(1.000000);
    r0.x = log2(r0.x);
    r0.x = r0.x * l(0.693147);
    o0.x = (r0.y) ? r0.x : l(-65504.000000);
    o0.y = l(0);
    return;
    // asm: // Approximately 320 instruction slots used
}

// -----------------------------------------------------------------------------
// Shader 2
// Profile: ps_5_0
// Byte offset: 42524
// Byte length: 24632
// -----------------------------------------------------------------------------

// Reflected buffer definitions
cbuffer $Globals
{
  bool g_isTAAEnabledBranch;         // Offset:    0 Size:     4 [unused]
     = 0xffffffff 
  float g_foamSurfaceRampMin;        // Offset:    4 Size:     4
  float g_foamTextureScale;          // Offset:    8 Size:     4
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
  float4 g_chunkSpaceTransform;      // Offset: 1984 Size:    16
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
  bool g_isSpaceSdfExists;           // Offset: 2088 Size:     4
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
// g_pointClampSampler               sampler      NA          NA             s0      1 
// g_trilinearClampSampler           sampler      NA          NA             s1      1 
// g_trilinearWrapSampler            sampler      NA          NA             s2      1 
// g_foamSampler                     sampler      NA          NA             s3      1 
// g_spaceVariationTexture           texture  float4          2d             t0      1 
// g_spaceSdfDistTexture             texture   float          2d             t1      1 
// g_spaceSdfDirTexture              texture   float          2d             t2      1 
// g_foamLowFreq                     texture  float4          2d             t3      1 
// g_foamHighFreq                    texture  float4          2d             t4      1 
// g_fftWave0GradTexture             texture  float4          2d             t5      1 
// g_fftWave1GradTexture             texture  float4          2d             t6      1 
// g_fftWave2GradTexture             texture  float4          2d             t7      1 
// g_fftWave0Moments1Texture         texture  float4          2d             t8      1 
// g_fftWave1Moments1Texture         texture  float4          2d             t9      1 
// g_fftWave2Moments1Texture         texture  float4          2d            t10      1 
// $Globals                          cbuffer      NA          NA            cb0      1 
// PerFrame                          cbuffer      NA          NA            cb1      1 
// PerView                           cbuffer      NA          NA            cb2      1

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float       
// TEXCOORD                 0   xy          1     NONE   float   xy

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Target                0   xy          0   TARGET   float   xy

void ps_02_ps_5_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_globalFlags refactoringAllowed
    // dcl_constantbuffer CB0[1], immediateIndexed
    // dcl_constantbuffer CB1[131], immediateIndexed
    // dcl_constantbuffer CB2[37], immediateIndexed
    // dcl_sampler s0, mode_default
    // dcl_sampler s1, mode_default
    // dcl_sampler s2, mode_default
    // dcl_sampler s3, mode_default
    // dcl_resource_texture2d (float,float,float,float) t0
    // dcl_resource_texture2d (float,float,float,float) t1
    // dcl_resource_texture2d (float,float,float,float) t2
    // dcl_resource_texture2d (float,float,float,float) t3
    // dcl_resource_texture2d (float,float,float,float) t4
    // dcl_resource_texture2d (float,float,float,float) t5
    // dcl_resource_texture2d (float,float,float,float) t6
    // dcl_resource_texture2d (float,float,float,float) t7
    // dcl_resource_texture2d (float,float,float,float) t8
    // dcl_resource_texture2d (float,float,float,float) t9
    // dcl_resource_texture2d (float,float,float,float) t10
    // dcl_input_ps linear v1.xy
    // dcl_output o0.xy
    float4 r[9];
    r0.xy = v1.xyxx + l(-0.500000, -0.500000, 0.000000, 0.000000);
    r0.xy = (r0.xyxx * l(1.250000, 1.250000, 0.000000, 0.000000)) + l(0.500000, 0.500000, 0.000000, 0.000000);
    r1.xyz = -cb2[32].xyzx + cb2[33].xyzx;
    r1.xyz = (r0.yyyy * r1.xyzx) + cb2[32].xyzx;
    r2.xyz = -cb2[34].xyzx + cb2[35].xyzx;
    r0.yzw = (r0.yyyy * r2.xxyz) + cb2[34].xxyz;
    r0.yzw = -r1.xxyz + r0.yyzw;
    r0.xyz = (r0.xxxx * r0.yzwy) + r1.xyzx;
    r0.w = dot(r0.xyzx, r0.xyzx);
    r0.w = rsqrt(r0.w);
    r0.xyz = r0.wwww * r0.xyzx;
    r0.w = -cb1[58].z + cb2[36].y;
    r0.y = -r0.w / r0.y;
    r1.x = (l(0.000000) < r0.y);
    r2.xyzw = (r0.xzxz * r0.yyyy) + cb2[36].xzxz;
    r0.xz = (r2.zzwz * cb1[124].xxyx) + cb1[124].zzwz;
    // asm: deriv_rtx_coarse r1.yz, r0.xxzx
    // asm: deriv_rty_coarse r3.xy, r0.xzxx
    r3.zw = (r0.xxxz >= l(0.000000, 0.000000, 0.000000, 0.000000));
    r1.x = r1.x & r3.z;
    r4.xy = (l(1.000000, 1.000000, 0.000000, 0.000000) >= r0.xzxx);
    r1.x = r1.x & r4.x;
    r1.x = r3.w & r1.x;
    r1.x = r4.y & r1.x;
    if (r1.x) {
        if (cb1[130].z) {
            // asm: sample_d_indexable(texture2d)(float,float,float,float) r1.x, r0.xzxx, t1.xyzw, s1, r1.yzyy, r3.xyxx
            r1.w = (l(0.040450) < r1.x);
            r3.z = r1.x * l(0.077399);
            r1.x = (r1.x * l(0.947867)) + l(0.052133);
            r1.x = log2(r1.x);
            r1.x = r1.x * l(2.400000);
            r1.x = exp2(r1.x);
            r1.x = (r1.w) ? r1.x : r3.z;
            r1.x = r1.x * r1.x;
            // asm: resinfo_indexable(texture2d)(float,float,float,float)_uint r3.zw, l(0), t2.zwxy
            r3.zw = (float)r3.zzzw;
            r4.xy = l(1.000000, 1.000000, 1.000000, 1.000000) / r3.zwzz;
            r3.zw = (r0.xxxz * r3.zzzw) + l(0.000000, 0.000000, -0.500000, -0.500000);
            r4.zw = frac(r3.zzzw);
            r3.zw = floor(r3.zzzw);
            r3.zw = r3.zzzw + l(0.000000, 0.000000, 1.000000, 1.000000);
            r3.zw = r4.xxxy * r3.zzzw;
            // asm: gather4_indexable(texture2d)(float,float,float,float) r5.xyzw, r3.zwzz, t2.xyzw, s0.x
            r6.xyzw = (l(0.040450, 0.040450, 0.040450, 0.040450) < r5.xyzw);
            r3.zw = r5.xxxy * l(0.000000, 0.000000, 0.077399, 0.077399);
            r4.xy = (r5.xyxx * l(0.947867, 0.947867, 0.000000, 0.000000)) + l(0.052133, 0.052133, 0.000000, 0.000000);
            r4.xy = log2(r4.xyxx);
            r4.xy = r4.xyxx * l(2.400000, 2.400000, 0.000000, 0.000000);
            r4.xy = exp2(r4.xyxx);
            r3.zw = (r6.xxxy) ? r4.xxxy : r3.zzzw;
            r4.xy = r5.zwzz * l(0.077399, 0.077399, 0.000000, 0.000000);
            r5.xy = (r5.zwzz * l(0.947867, 0.947867, 0.000000, 0.000000)) + l(0.052133, 0.052133, 0.000000, 0.000000);
            r5.xy = log2(r5.xyxx);
            r5.xy = r5.xyxx * l(2.400000, 2.400000, 0.000000, 0.000000);
            r5.xy = exp2(r5.xyxx);
            r4.xy = (r6.zwzz) ? r5.xyxx : r4.xyxx;
            r3.zw = -r3.zzzw + l(0.000000, 0.000000, 1.000000, 1.000000);
            r3.zw = r3.zzzw * l(0.000000, 0.000000, 6.283185, 6.283185);
            r4.xy = -r4.xyxx + l(1.000000, 1.000000, 0.000000, 0.000000);
            r4.xy = r4.xyxx * l(6.283185, 6.283185, 0.000000, 0.000000);
            sincos(r5.xy, r6.xy, r3.zwzz);
            sincos(r4.xy, r7.xy, r4.xyxx);
            r7.xz = r7.yyxy;
            r7.yw = r4.yyyx;
            r3.zw = -r7.xxxy + r7.zzzw;
            r3.zw = (r4.zzzz * r3.zzzw) + r7.xxxy;
            r6.xz = r6.xxyx;
            r6.yw = r5.xxxy;
            r4.xy = -r6.xyxx + r6.zwzz;
            r4.xy = (r4.zzzz * r4.xyxx) + r6.xyxx;
            r4.xy = -r3.zwzz + r4.xyxx;
            r3.zw = (r4.wwww * r4.xxxy) + r3.zzzw;
            r1.w = dot2(r3.zwzz, r3.zwzz);
            r1.w = rsqrt(r1.w);
            r3.zw = r1.wwww * r3.zzzw;
            r4.xy = l(1.000000, 1.000000, 1.000000, 1.000000) / cb1[124].xyxx;
            r4.z = -r4.y;
            r4.xy = r3.zwzz * r4.xzxx;
            r1.w = dot2(r4.xyxx, r4.xyxx);
            r1.w = sqrt(r1.w);
            r1.x = r1.x * r1.w;
        else
            r3.zw = cb1[58].xxxy;
            r1.x = l(20000.000000);
        }
        // asm: sample_d_indexable(texture2d)(float,float,float,float) r0.x, r0.xzxx, t0.zxyw, s2, r1.yzyy, r3.xyxx
    else
        // asm: discard_nz l(-1)
        r0.x = l(1.000000);
    }
    // asm: mad_sat r0.z, |r0.w|, l(0.003333), l(-0.100000)
    r0.z = -r0.z + l(1.000000);
    r0.w = l(1.000000, 1.000000, 1.000000, 1.000000) / cb1[71].y;
    // asm: mul_sat r0.w, r0.w, r1.x
    r1.y = (r0.w * l(-2.000000)) + l(3.000000);
    r0.w = r0.w * r0.w;
    r0.w = (-r1.y * r0.w) + l(1.000000);
    r0.z = r0.z * r0.w;
    r0.w = (r0.z < l(0.000100));
    // asm: discard_nz r0.w
    r0.w = dot2(r3.zwzz, cb1[58].xyxx);
    r1.y = cb1[69].y * l(0.650000);
    // asm: mad_sat r0.w, r0.w, l(0.500000), l(0.500000)
    r0.w = (-cb1[69].y * l(0.350000)) + r0.w;
    r1.y = l(1.000000, 1.000000, 1.000000, 1.000000) / r1.y;
    // asm: mul_sat r0.w, r0.w, r1.y
    r1.y = (r0.w * l(-2.000000)) + l(3.000000);
    r0.w = r0.w * r0.w;
    r0.w = r0.w * r1.y;
    r1.y = dot2(r2.zwzz, -cb1[58].xyxx);
    r1.y = -r1.x + r1.y;
    r1.z = (r1.y * l(0.900000)) + r1.x;
    r1.z = r1.z * l(6.283185);
    r1.z = r1.z / cb1[68].w;
    r1.w = cb1[70].w * cb1[128].x;
    r1.z = (r1.w * l(0.500000)) + r1.z;
    r1.z = r1.z * l(0.333333);
    sincos(null, r1.z, r1.z);
    r1.z = (r1.z * l(0.500000)) + l(0.500000);
    r3.xy = r2.zwzz * l(0.500000, 0.500000, 0.000000, 0.000000);
    r3.xy = r3.xyxx / cb1[68].wwww;
    r3.xy = (cb1[128].xxxx * l(0.300000, 0.400000, 0.000000, 0.000000)) + r3.xyxx;
    sincos(r3.xy, null, r3.xyxx);
    r1.w = r3.x * l(0.500000);
    r1.w = (r1.w * r3.y) + l(0.500000);
    r3.x = r0.z * r1.w;
    r3.x = r0.w * r3.x;
    r1.z = r1.z * r3.x;
    r1.y = (cb1[70].z * r1.y) + r1.x;
    r1.y = r1.y * l(6.283185);
    r3.x = r1.y / cb1[68].w;
    r3.y = r0.x * cb1[69].z;
    r3.x = (cb1[70].w * cb1[128].x) + r3.x;
    sincos(r3.x, null, r3.x);
    r3.x = r3.y * r3.x;
    r3.y = dot2(r2.zwzz, r2.zwzz);
    r3.y = rsqrt(r3.y);
    r4.xy = r2.zwzz * r3.yyyy;
    r3.y = dot2(r3.zwzz, r4.xyxx);
    r3.z = cb1[71].w * l(10.000000);
    r4.xy = r1.xxxx + l(10.000000, 2.000000, 0.000000, 0.000000);
    // asm: mul_sat r4.xy, r4.xyxx, l(0.026316, 0.083333, 0.000000, 0.000000)
    r4.zw = (r4.xxxy * l(0.000000, 0.000000, -2.000000, -2.000000)) + l(0.000000, 0.000000, 3.000000, 3.000000);
    r4.xy = r4.xyxx * r4.xyxx;
    r1.x = r4.y * r4.w;
    r3.w = (-r4.z * r4.x) + l(1.000000);
    r4.x = (-cb1[71].w * l(10.000000)) + l(1.000000);
    r3.z = (r3.w * r4.x) + r3.z;
    r3.y = log2(|r3.y|);
    r3.y = r3.y * r3.z;
    r3.y = exp2(r3.y);
    r3.y = min(r3.y, l(1.000000));
    r1.y = r1.y / cb1[69].x;
    r3.zw = r2.zzzw + r2.zzzw;
    r4.zw = floor(r3.zzzw);
    r5.xy = (r2.zwzz * l(2.000000, 2.000000, 0.000000, 0.000000)) + l(1.000000, 1.000000, 0.000000, 0.000000);
    r4.xy = floor(r5.xyxx);
    r3.zw = frac(r3.zzzw);
    r5.xy = r3.zwzz * r3.zwzz;
    r3.zw = (-r3.zzzw * l(0.000000, 0.000000, 2.000000, 2.000000)) + l(0.000000, 0.000000, 3.000000, 3.000000);
    r3.zw = r3.zzzw * r5.xxxy;
    r5.x = dot2(r4.zwzz, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r5.x, null, r5.x);
    r5.x = r5.x * l(43758.546875);
    r5.x = frac(r5.x);
    r4.w = dot2(r4.xwxx, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r4.w, null, r4.w);
    r4.w = r4.w * l(43758.546875);
    r4.w = frac(r4.w);
    r4.w = -r5.x + r4.w;
    r4.w = (r3.z * r4.w) + r5.x;
    r4.z = dot2(r4.zyzz, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r4.z, null, r4.z);
    r4.z = r4.z * l(43758.546875);
    r4.x = dot2(r4.xyxx, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r4.x, null, r4.x);
    r4.x = r4.x * l(43758.546875);
    r4.xz = frac(r4.xxzx);
    r4.x = -r4.z + r4.x;
    r3.z = (r3.z * r4.x) + r4.z;
    r3.z = -r4.w + r3.z;
    r3.z = (r3.w * r3.z) + r4.w;
    r3.z = r3.z * r3.z;
    r3.z = r3.z * r3.z;
    r3.w = cb1[70].w * cb1[71].x;
    r1.y = (r3.w * cb1[128].x) + r1.y;
    r1.y = (-r3.y * l(0.800000)) + r1.y;
    r1.y = (r3.z * l(0.600000)) + r1.y;
    r0.x = r0.x * r0.z;
    r0.x = r0.w * r0.x;
    r0.z = l(1.000000, 1.000000, 1.000000, 1.000000) / cb1[71].z;
    // asm: mul_sat r0.z, r0.z, r3.y
    r0.w = (r0.z * l(-2.000000)) + l(3.000000);
    r0.z = r0.z * r0.z;
    r0.z = r0.z * r0.w;
    r0.x = r0.z * r0.x;
    r0.z = r1.w * r1.w;
    r0.x = r0.x * r0.z;
    // asm: deriv_rtx_coarse r4.xyzw, r2.zwzw
    // asm: deriv_rty_coarse r5.xyzw, r2.zwzw
    r6.xyzw = (r2.zwzw * cb1[59].xxyy) + cb1[60].xxyy;
    r7.xyzw = r4.zwzw * cb1[59].xxyy;
    r8.xyzw = r5.zwzw * cb1[59].xxyy;
    // asm: sample_d_indexable(texture2d)(float,float,float,float) r0.z, r6.xyxx, t5.xyzw, s3, r7.xyxx, r8.xyxx
    // asm: sample_d_indexable(texture2d)(float,float,float,float) r0.w, r6.xyxx, t8.xyzw, s3, r7.xyxx, r8.xyxx
    // asm: sample_d_indexable(texture2d)(float,float,float,float) r1.w, r6.zwzz, t6.xywz, s3, r7.zwzz, r8.zwzz
    r0.z = r0.z + r1.w;
    // asm: sample_d_indexable(texture2d)(float,float,float,float) r1.w, r6.zwzz, t9.xyzw, s3, r7.zwzz, r8.zwzz
    r0.w = r0.w + r1.w;
    r3.yz = (r2.zzwz * cb1[59].zzzz) + cb1[60].zzzz;
    r6.xy = r4.zwzz * cb1[59].zzzz;
    r6.zw = r5.zzzw * cb1[59].zzzz;
    // asm: sample_d_indexable(texture2d)(float,float,float,float) r1.w, r3.yzyy, t7.xywz, s3, r6.xyxx, r6.zwzz
    r0.z = r0.z + r1.w;
    // asm: sample_d_indexable(texture2d)(float,float,float,float) r1.w, r3.yzyy, t10.xyzw, s3, r6.xyxx, r6.zwzz
    r0.w = r0.w + r1.w;
    r6.xyzw = cb0[0].zzzz * l(0.500000, 0.500000, 4.000000, 4.000000);
    r2.xyzw = r2.xyzw * r6.xyzw;
    r4.xyzw = r4.xyzw * r6.xyzw;
    r5.xyzw = r5.xyzw * r6.xyzw;
    // asm: sample_d_indexable(texture2d)(float,float,float,float) r2.xy, r2.xyxx, t3.xyzw, s3, r4.xyxx, r5.xyxx
    // asm: sample_d_indexable(texture2d)(float,float,float,float) r2.zw, r2.zwzz, t4.zwxy, s3, r4.zwzz, r5.zwzz
    r1.w = -cb0[0].y + l(1.000000);
    r0.z = r0.z + -cb0[0].y;
    r1.w = l(1.000000, 1.000000, 1.000000, 1.000000) / r1.w;
    // asm: mul_sat r0.z, r0.z, r1.w
    r1.w = (r0.z * l(-2.000000)) + l(3.000000);
    r0.z = r0.z * r0.z;
    r3.yz = r1.yyyy * l(0.000000, 0.159155, 0.500000, 0.000000);
    r3.w = (r3.y >= -r3.y);
    r3.y = frac(|r3.y|);
    r3.y = (r3.w) ? r3.y : -r3.y;
    r3.yw = (r3.yyyy * l(0.000000, 6.283185, 0.000000, 6.283185)) + l(0.000000, -1.000000, 0.000000, -5.780530);
    r3.yw = r3.yyyw * l(0.000000, -1.111111, 0.000000, 1.989436);
    // asm: mov_sat r3.y, r3.y
    r4.x = (r3.y * l(-2.000000)) + l(3.000000);
    r3.y = r3.y * r3.y;
    r3.w = max(r3.w, l(0.000000));
    r4.y = (r3.w * l(-2.000000)) + l(3.000000);
    r3.w = r3.w * r3.w;
    r3.w = r3.w * r4.y;
    r3.y = (r4.x * r3.y) + r3.w;
    r3.y = min(r3.y, l(1.000000));
    // asm: add_sat r3.y, r3.y, cb1[70].y
    r3.yw = (r3.yyyy * l(0.000000, -0.250000, 0.000000, 0.700000)) + l(0.000000, 0.650000, 0.000000, 0.100000);
    r4.xy = r2.xyxx + -r3.yyyy;
    // asm: mad_sat r4.xy, r1.wwww, r0.zzzz, r4.xyxx
    r4.xy = r4.xyxx * r4.xyxx;
    r4.xy = r4.xyxx * l(8.000000, 8.000000, 0.000000, 0.000000);
    r4.x = r4.y + r4.x;
    r3.y = r2.z + -r3.y;
    // asm: mad_sat r0.z, r1.w, r0.z, r3.y
    r0.z = (r0.z * l(4.000000)) + r4.x;
    r4.xy = r0.wwww + l(-1.000000, 3.000000, 0.000000, 0.000000);
    // asm: mul_sat r4.xy, r4.xyxx, l(0.200000, 0.200000, 0.000000, 0.000000)
    r4.zw = (r4.xxxy * l(0.000000, 0.000000, -2.000000, -2.000000)) + l(0.000000, 0.000000, 3.000000, 3.000000);
    r4.xy = r4.xyxx * r4.xyxx;
    r1.w = r4.x * r4.z;
    r3.y = (-r4.w * r4.y) + l(1.000000);
    r0.z = (-r1.w * l(0.200000)) + r0.z;
    r0.z = max(r0.z, l(0.000000));
    r4.x = (r3.y * l(0.800000)) + l(1.000000);
    r2.z = r2.z * r3.y;
    r0.z = (r0.z * r4.x) + r2.z;
    // asm: mul_sat r0.w, r0.w, l(0.250000)
    r0.w = (r0.w * l(0.500000)) + l(0.300000);
    r0.w = -r0.w + r2.w;
    // asm: add_sat r0.w, r0.w, r0.w
    // asm: mul_sat r0.z, r0.w, r0.z
    r2.xy = r2.xyxx + l(-0.100000, -0.100000, 0.000000, 0.000000);
    // asm: mul_sat r2.xy, r2.xyxx, l(1.111111, 1.111111, 0.000000, 0.000000)
    r2.zw = (r2.xxxy * l(0.000000, 0.000000, -2.000000, -2.000000)) + l(0.000000, 0.000000, 3.000000, 3.000000);
    r2.xy = r2.xyxx * r2.xyxx;
    r2.xy = r2.xyxx * r2.zwzz;
    r0.w = r2.y * r2.x;
    r2.xy = r0.yyyy + l(-30.000000, -60.000000, 0.000000, 0.000000);
    // asm: mul_sat r2.xy, r2.xyxx, l(0.011111, 0.016667, 0.000000, 0.000000)
    r2.zw = (r2.xxxy * l(0.000000, 0.000000, -2.000000, -2.000000)) + l(0.000000, 0.000000, 3.000000, 3.000000);
    r2.xy = r2.xyxx * r2.xyxx;
    r2.xy = r2.xyxx * r2.zwzz;
    r0.y = -r3.w + l(0.800000);
    r0.y = (r2.x * r0.y) + r3.w;
    r2.x = (r2.x * l(-0.700000)) + l(1.000000);
    r0.z = r0.z * r2.x;
    r0.y = (r0.w * r0.y) + r0.z;
    r0.z = (r1.w * l(0.500000)) + r1.y;
    r0.z = r0.z * l(0.500000);
    sincos(r2.x, r4.x, r0.z);
    r0.z = r4.x * l(-0.970000);
    r0.w = -|r0.z| + l(1.000000);
    r0.w = sqrt(r0.w);
    r1.y = (|r0.z| * l(-0.018729)) + l(0.074261);
    r1.y = (r1.y * |r0.z|) + l(-0.212114);
    r1.y = (r1.y * |r0.z|) + l(1.570729);
    r1.w = r0.w * r1.y;
    r1.w = (r1.w * l(-2.000000)) + l(3.141593);
    r0.z = (r0.z < -r0.z);
    r0.z = r0.z & r1.w;
    r0.z = (r1.y * r0.w) + r0.z;
    r0.z = (-r0.z * l(0.636620)) + l(1.000000);
    r0.w = r2.x * l(33.333336);
    r1.y = min(|r0.w|, l(1.000000));
    r1.w = max(|r0.w|, l(1.000000));
    r1.w = l(1.000000, 1.000000, 1.000000, 1.000000) / r1.w;
    r1.y = r1.w * r1.y;
    r1.w = r1.y * r1.y;
    r2.x = (r1.w * l(0.020835)) + l(-0.085133);
    r2.x = (r1.w * r2.x) + l(0.180141);
    r2.x = (r1.w * r2.x) + l(-0.330299);
    r1.w = (r1.w * r2.x) + l(0.999866);
    r2.x = r1.w * r1.y;
    r2.z = (l(1.000000) < |r0.w|);
    r2.x = (r2.x * l(-2.000000)) + l(1.570796);
    r2.x = r2.z & r2.x;
    r1.y = (r1.y * r1.w) + r2.x;
    r0.w = min(r0.w, l(1.000000));
    r0.w = (r0.w < -r0.w);
    r0.w = (r0.w) ? -r1.y : r1.y;
    r0.z = r0.z * r0.w;
    r0.z = (-r0.z * l(0.636620)) + l(1.000000);
    r0.yw = r0.xxxz * r0.yyyz;
    r0.z = (r0.z * r0.z) + l(-0.800000);
    // asm: mul_sat r0.z, r0.z, l(0.312500)
    r1.y = (r0.z * l(-2.000000)) + l(3.000000);
    r0.z = r0.z * r0.z;
    r0.z = r0.z * r1.y;
    r0.z = r0.y * r0.z;
    r0.z = r0.z * l(8.000000);
    r0.y = (r0.y * r0.w) + r0.z;
    // asm: mul_sat r0.y, r0.y, cb1[70].x
    sincos(r2.x, r4.x, r3.z);
    r0.z = r4.x * l(-0.950000);
    r0.w = -|r0.z| + l(1.000000);
    r0.w = sqrt(r0.w);
    r1.y = (|r0.z| * l(-0.018729)) + l(0.074261);
    r1.y = (r1.y * |r0.z|) + l(-0.212114);
    r1.y = (r1.y * |r0.z|) + l(1.570729);
    r1.w = r0.w * r1.y;
    r1.w = (r1.w * l(-2.000000)) + l(3.141593);
    r0.z = (r0.z < -r0.z);
    r0.z = r0.z & r1.w;
    r0.z = (r1.y * r0.w) + r0.z;
    r0.z = (-r0.z * l(0.636620)) + l(1.000000);
    r0.w = r2.x * l(20.000000);
    r1.y = min(|r0.w|, l(1.000000));
    r1.w = max(|r0.w|, l(1.000000));
    r1.w = l(1.000000, 1.000000, 1.000000, 1.000000) / r1.w;
    r1.y = r1.w * r1.y;
    r1.w = r1.y * r1.y;
    r2.x = (r1.w * l(0.020835)) + l(-0.085133);
    r2.x = (r1.w * r2.x) + l(0.180141);
    r2.x = (r1.w * r2.x) + l(-0.330299);
    r1.w = (r1.w * r2.x) + l(0.999866);
    r2.x = r1.w * r1.y;
    r2.z = (l(1.000000) < |r0.w|);
    r2.x = (r2.x * l(-2.000000)) + l(1.570796);
    r2.x = r2.z & r2.x;
    r1.y = (r1.y * r1.w) + r2.x;
    r0.w = min(r0.w, l(1.000000));
    r0.w = (r0.w < -r0.w);
    r0.w = (r0.w) ? -r1.y : r1.y;
    r0.z = r0.z * r0.w;
    r0.z = (-r0.z * l(0.636620)) + l(1.000000);
    r0.x = r0.x * r0.z;
    r0.x = r1.x * r0.x;
    r0.x = r0.x * cb1[69].w;
    r0.x = (r1.z * r3.x) + r0.x;
    r0.z = min(r0.x, l(0.050000));
    r0.z = -r0.x + r0.z;
    r0.x = (r2.y * r0.z) + r0.x;
    r0.z = (r0.y < l(1.000000));
    r0.w = -r0.y + l(1.000000);
    r0.w = log2(r0.w);
    r0.w = r0.w * l(0.693147);
    o0.x = (r0.z) ? r0.w : l(-65504.000000);
    r0.y = r0.y * cb1[58].w;
    o0.y = (r0.y * l(0.500000)) + r0.x;
    return;
    // asm: // Approximately 379 instruction slots used
}

// -----------------------------------------------------------------------------
// Shader 3
// Profile: ps_5_0
// Byte offset: 67560
// Byte length: 14220
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
  float4 g_chunkSpaceTransform;      // Offset: 1984 Size:    16
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
  bool g_isSpaceSdfExists;           // Offset: 2088 Size:     4
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
// g_pointClampSampler               sampler      NA          NA             s0      1 
// g_trilinearClampSampler           sampler      NA          NA             s1      1 
// g_spaceSdfDistTexture             texture   float          2d             t0      1 
// g_spaceSdfDirTexture              texture   float          2d             t1      1 
// PerFrame                          cbuffer      NA          NA            cb0      1 
// PerView                           cbuffer      NA          NA            cb1      1

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float       
// TEXCOORD                 0   xy          1     NONE   float   xy

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Target                0   xy          0   TARGET   float   xy

void ps_03_ps_5_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_globalFlags refactoringAllowed
    // dcl_constantbuffer CB0[131], immediateIndexed
    // dcl_constantbuffer CB1[37], immediateIndexed
    // dcl_sampler s0, mode_default
    // dcl_sampler s1, mode_default
    // dcl_resource_texture2d (float,float,float,float) t0
    // dcl_resource_texture2d (float,float,float,float) t1
    // dcl_input_ps linear v1.xy
    // dcl_output o0.xy
    float4 r[5];
    r0.xy = v1.xyxx + l(-0.500000, -0.500000, 0.000000, 0.000000);
    r0.xy = (r0.xyxx * l(1.250000, 1.250000, 0.000000, 0.000000)) + l(0.500000, 0.500000, 0.000000, 0.000000);
    r1.xyz = -cb1[32].xyzx + cb1[33].xyzx;
    r1.xyz = (r0.yyyy * r1.xyzx) + cb1[32].xyzx;
    r2.xyz = -cb1[34].xyzx + cb1[35].xyzx;
    r0.yzw = (r0.yyyy * r2.xxyz) + cb1[34].xxyz;
    r0.yzw = -r1.xxyz + r0.yyzw;
    r0.xyz = (r0.xxxx * r0.yzwy) + r1.xyzx;
    r0.w = dot(r0.xyzx, r0.xyzx);
    r0.w = rsqrt(r0.w);
    r0.xyz = r0.wwww * r0.xyzx;
    r0.w = -cb0[58].z + cb1[36].y;
    r0.y = -r0.w / r0.y;
    r1.x = (l(0.000000) < r0.y);
    r0.xy = (r0.xzxx * r0.yyyy) + cb1[36].xzxx;
    r0.xy = (r0.xyxx * cb0[124].xyxx) + cb0[124].zwzz;
    r1.yz = (r0.xxyx >= l(0.000000, 0.000000, 0.000000, 0.000000));
    r0.z = r1.y & r1.x;
    r1.xy = (l(1.000000, 1.000000, 0.000000, 0.000000) >= r0.xyxx);
    r0.z = r0.z & r1.x;
    r0.z = r1.z & r0.z;
    r0.z = r1.y & r0.z;
    // asm: deriv_rtx_coarse r1.xy, r0.xyxx
    // asm: deriv_rty_coarse r1.zw, r0.xxxy
    if (r0.z) {
        if (cb0[130].z) {
            // asm: sample_d_indexable(texture2d)(float,float,float,float) r0.z, r0.xyxx, t0.yzxw, s1, r1.xyxx, r1.zwzz
            r1.x = (l(0.040450) < r0.z);
            r1.y = r0.z * l(0.077399);
            r0.z = (r0.z * l(0.947867)) + l(0.052133);
            r0.z = log2(r0.z);
            r0.z = r0.z * l(2.400000);
            r0.z = exp2(r0.z);
            r0.z = (r1.x) ? r0.z : r1.y;
            r0.z = r0.z * r0.z;
            // asm: resinfo_indexable(texture2d)(float,float,float,float)_uint r1.xy, l(0), t1.xyzw
            r1.xy = (float)r1.xyxx;
            r1.zw = l(1.000000, 1.000000, 1.000000, 1.000000) / r1.xxxy;
            r0.xy = (r0.xyxx * r1.xyxx) + l(-0.500000, -0.500000, 0.000000, 0.000000);
            r1.xy = frac(r0.xyxx);
            r0.xy = floor(r0.xyxx);
            r0.xy = r0.xyxx + l(1.000000, 1.000000, 0.000000, 0.000000);
            r0.xy = r1.zwzz * r0.xyxx;
            // asm: gather4_indexable(texture2d)(float,float,float,float) r2.xyzw, r0.xyxx, t1.xyzw, s0.x
            r3.xyzw = (l(0.040450, 0.040450, 0.040450, 0.040450) < r2.xyzw);
            r0.xy = r2.xyxx * l(0.077399, 0.077399, 0.000000, 0.000000);
            r1.zw = (r2.xxxy * l(0.000000, 0.000000, 0.947867, 0.947867)) + l(0.000000, 0.000000, 0.052133, 0.052133);
            r1.zw = log2(r1.zzzw);
            r1.zw = r1.zzzw * l(0.000000, 0.000000, 2.400000, 2.400000);
            r1.zw = exp2(r1.zzzw);
            r0.xy = (r3.xyxx) ? r1.zwzz : r0.xyxx;
            r1.zw = r2.zzzw * l(0.000000, 0.000000, 0.077399, 0.077399);
            r2.xy = (r2.zwzz * l(0.947867, 0.947867, 0.000000, 0.000000)) + l(0.052133, 0.052133, 0.000000, 0.000000);
            r2.xy = log2(r2.xyxx);
            r2.xy = r2.xyxx * l(2.400000, 2.400000, 0.000000, 0.000000);
            r2.xy = exp2(r2.xyxx);
            r1.zw = (r3.zzzw) ? r2.xxxy : r1.zzzw;
            r0.xy = -r0.xyxx + l(1.000000, 1.000000, 0.000000, 0.000000);
            r0.xy = r0.xyxx * l(6.283185, 6.283185, 0.000000, 0.000000);
            r1.zw = -r1.zzzw + l(0.000000, 0.000000, 1.000000, 1.000000);
            r1.zw = r1.zzzw * l(0.000000, 0.000000, 6.283185, 6.283185);
            sincos(r0.xy, r2.xy, r0.xyxx);
            sincos(r3.xy, r4.xy, r1.zwzz);
            r4.xz = r4.yyxy;
            r4.yw = r3.yyyx;
            r1.zw = -r4.xxxy + r4.zzzw;
            r1.zw = (r1.xxxx * r1.zzzw) + r4.xxxy;
            r2.xz = r2.xxyx;
            r2.yw = r0.xxxy;
            r0.xy = -r2.xyxx + r2.zwzz;
            r0.xy = (r1.xxxx * r0.xyxx) + r2.xyxx;
            r0.xy = -r1.zwzz + r0.xyxx;
            r0.xy = (r1.yyyy * r0.xyxx) + r1.zwzz;
            r1.x = dot2(r0.xyxx, r0.xyxx);
            r1.x = rsqrt(r1.x);
            r0.xy = r0.xyxx * r1.xxxx;
            r1.xy = l(1.000000, 1.000000, 1.000000, 1.000000) / cb0[124].xyxx;
            r1.z = -r1.y;
            r0.xy = r0.xyxx * r1.xzxx;
            r0.x = dot2(r0.xyxx, r0.xyxx);
            r0.x = sqrt(r0.x);
            r0.x = r0.z * r0.x;
        else
            r0.x = l(20000.000000);
        }
    else
        // asm: discard_nz l(-1)
    }
    // asm: mad_sat r0.y, |r0.w|, l(0.003333), l(-0.100000)
    r0.y = -r0.y + l(1.000000);
    r0.z = l(1.000000, 1.000000, 1.000000, 1.000000) / cb0[71].y;
    // asm: mul_sat r0.x, r0.z, r0.x
    r0.z = (r0.x * l(-2.000000)) + l(3.000000);
    r0.x = r0.x * r0.x;
    r0.x = (-r0.z * r0.x) + l(1.000000);
    r0.x = r0.y * r0.x;
    r0.x = (r0.x < l(0.000100));
    // asm: discard_nz r0.x
    o0.xy = l(0,0,0,0);
    return;
    // asm: // Approximately 100 instruction slots used
}

// -----------------------------------------------------------------------------
// Shader 4
// Profile: ps_5_0
// Byte offset: 81992
// Byte length: 18980
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
  float4 g_chunkSpaceTransform;      // Offset: 1984 Size:    16
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
  bool g_isSpaceSdfExists;           // Offset: 2088 Size:     4
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
// g_pointClampSampler               sampler      NA          NA             s0      1 
// g_trilinearClampSampler           sampler      NA          NA             s1      1 
// g_trilinearWrapSampler            sampler      NA          NA             s2      1 
// g_spaceVariationTexture           texture  float4          2d             t0      1 
// g_spaceSdfDistTexture             texture   float          2d             t1      1 
// g_spaceSdfDirTexture              texture   float          2d             t2      1 
// PerFrame                          cbuffer      NA          NA            cb0      1 
// PerView                           cbuffer      NA          NA            cb1      1

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float       
// TEXCOORD                 0   xy          1     NONE   float   xy

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Target                0   xy          0   TARGET   float   xy

void ps_04_ps_5_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_globalFlags refactoringAllowed
    // dcl_constantbuffer CB0[131], immediateIndexed
    // dcl_constantbuffer CB1[37], immediateIndexed
    // dcl_sampler s0, mode_default
    // dcl_sampler s1, mode_default
    // dcl_sampler s2, mode_default
    // dcl_resource_texture2d (float,float,float,float) t0
    // dcl_resource_texture2d (float,float,float,float) t1
    // dcl_resource_texture2d (float,float,float,float) t2
    // dcl_input_ps linear v1.xy
    // dcl_output o0.xy
    float4 r[8];
    r0.xy = v1.xyxx + l(-0.500000, -0.500000, 0.000000, 0.000000);
    r0.xy = (r0.xyxx * l(1.250000, 1.250000, 0.000000, 0.000000)) + l(0.500000, 0.500000, 0.000000, 0.000000);
    r1.xyz = -cb1[32].xyzx + cb1[33].xyzx;
    r1.xyz = (r0.yyyy * r1.xyzx) + cb1[32].xyzx;
    r2.xyz = -cb1[34].xyzx + cb1[35].xyzx;
    r0.yzw = (r0.yyyy * r2.xxyz) + cb1[34].xxyz;
    r0.yzw = -r1.xxyz + r0.yyzw;
    r0.xyz = (r0.xxxx * r0.yzwy) + r1.xyzx;
    r0.w = dot(r0.xyzx, r0.xyzx);
    r0.w = rsqrt(r0.w);
    r0.xyz = r0.wwww * r0.xyzx;
    r0.w = -cb0[58].z + cb1[36].y;
    r0.y = -r0.w / r0.y;
    r1.x = (l(0.000000) < r0.y);
    r0.xz = (r0.xxzx * r0.yyyy) + cb1[36].xxzx;
    r1.yz = (r0.xxzx * cb0[124].xxyx) + cb0[124].zzwz;
    // asm: deriv_rtx_coarse r2.xy, r1.yzyy
    // asm: deriv_rty_coarse r2.zw, r1.yyyz
    r3.xy = (r1.yzyy >= l(0.000000, 0.000000, 0.000000, 0.000000));
    r1.x = r1.x & r3.x;
    r3.xz = (l(1.000000, 0.000000, 1.000000, 0.000000) >= r1.yyzy);
    r1.x = r1.x & r3.x;
    r1.x = r3.y & r1.x;
    r1.x = r3.z & r1.x;
    if (r1.x) {
        if (cb0[130].z) {
            // asm: sample_d_indexable(texture2d)(float,float,float,float) r1.x, r1.yzyy, t1.xyzw, s1, r2.xyxx, r2.zwzz
            r1.w = (l(0.040450) < r1.x);
            r3.x = r1.x * l(0.077399);
            r1.x = (r1.x * l(0.947867)) + l(0.052133);
            r1.x = log2(r1.x);
            r1.x = r1.x * l(2.400000);
            r1.x = exp2(r1.x);
            r1.x = (r1.w) ? r1.x : r3.x;
            r1.x = r1.x * r1.x;
            // asm: resinfo_indexable(texture2d)(float,float,float,float)_uint r3.xy, l(0), t2.xyzw
            r3.xy = (float)r3.xyxx;
            r3.zw = l(1.000000, 1.000000, 1.000000, 1.000000) / r3.xxxy;
            r3.xy = (r1.yzyy * r3.xyxx) + l(-0.500000, -0.500000, 0.000000, 0.000000);
            r4.xy = frac(r3.xyxx);
            r3.xy = floor(r3.xyxx);
            r3.xy = r3.xyxx + l(1.000000, 1.000000, 0.000000, 0.000000);
            r3.xy = r3.zwzz * r3.xyxx;
            // asm: gather4_indexable(texture2d)(float,float,float,float) r3.xyzw, r3.xyxx, t2.xyzw, s0.x
            r5.xyzw = (l(0.040450, 0.040450, 0.040450, 0.040450) < r3.xyzw);
            r4.zw = r3.xxxy * l(0.000000, 0.000000, 0.077399, 0.077399);
            r3.xy = (r3.xyxx * l(0.947867, 0.947867, 0.000000, 0.000000)) + l(0.052133, 0.052133, 0.000000, 0.000000);
            r3.xy = log2(r3.xyxx);
            r3.xy = r3.xyxx * l(2.400000, 2.400000, 0.000000, 0.000000);
            r3.xy = exp2(r3.xyxx);
            r3.xy = (r5.xyxx) ? r3.xyxx : r4.zwzz;
            r4.zw = r3.zzzw * l(0.000000, 0.000000, 0.077399, 0.077399);
            r3.zw = (r3.zzzw * l(0.000000, 0.000000, 0.947867, 0.947867)) + l(0.000000, 0.000000, 0.052133, 0.052133);
            r3.zw = log2(r3.zzzw);
            r3.zw = r3.zzzw * l(0.000000, 0.000000, 2.400000, 2.400000);
            r3.zw = exp2(r3.zzzw);
            r3.zw = (r5.zzzw) ? r3.zzzw : r4.zzzw;
            r3.xyzw = -r3.xyzw + l(1.000000, 1.000000, 1.000000, 1.000000);
            r3.xyzw = r3.xyzw * l(6.283185, 6.283185, 6.283185, 6.283185);
            sincos(r3.xy, r5.xy, r3.xyxx);
            sincos(r6.xy, r7.xy, r3.zwzz);
            r7.xz = r7.yyxy;
            r7.yw = r6.yyyx;
            r3.zw = -r7.xxxy + r7.zzzw;
            r3.zw = (r4.xxxx * r3.zzzw) + r7.xxxy;
            r5.xz = r5.xxyx;
            r5.yw = r3.xxxy;
            r3.xy = -r5.xyxx + r5.zwzz;
            r3.xy = (r4.xxxx * r3.xyxx) + r5.xyxx;
            r3.xy = -r3.zwzz + r3.xyxx;
            r3.xy = (r4.yyyy * r3.xyxx) + r3.zwzz;
            r1.w = dot2(r3.xyxx, r3.xyxx);
            r1.w = rsqrt(r1.w);
            r3.xy = r1.wwww * r3.xyxx;
            r4.xy = l(1.000000, 1.000000, 1.000000, 1.000000) / cb0[124].xyxx;
            r4.z = -r4.y;
            r3.zw = r3.xxxy * r4.xxxz;
            r1.w = dot2(r3.zwzz, r3.zwzz);
            r1.w = sqrt(r1.w);
            r1.x = r1.x * r1.w;
        else
            r3.xy = cb0[58].xyxx;
            r1.x = l(20000.000000);
        }
        // asm: sample_d_indexable(texture2d)(float,float,float,float) r1.y, r1.yzyy, t0.xzyw, s2, r2.xyxx, r2.zwzz
    else
        // asm: discard_nz l(-1)
        r1.y = l(1.000000);
    }
    // asm: mad_sat r0.w, |r0.w|, l(0.003333), l(-0.100000)
    r0.w = -r0.w + l(1.000000);
    r1.z = l(1.000000, 1.000000, 1.000000, 1.000000) / cb0[71].y;
    // asm: mul_sat r1.z, r1.z, r1.x
    r1.w = (r1.z * l(-2.000000)) + l(3.000000);
    r1.z = r1.z * r1.z;
    r1.z = (-r1.w * r1.z) + l(1.000000);
    r0.w = r0.w * r1.z;
    r1.z = (r0.w < l(0.000100));
    // asm: discard_nz r1.z
    r1.z = dot2(r3.xyxx, cb0[58].xyxx);
    r1.w = cb0[69].y * l(0.650000);
    // asm: mad_sat r1.z, r1.z, l(0.500000), l(0.500000)
    r1.z = (-cb0[69].y * l(0.350000)) + r1.z;
    r1.w = l(1.000000, 1.000000, 1.000000, 1.000000) / r1.w;
    // asm: mul_sat r1.z, r1.w, r1.z
    r1.w = (r1.z * l(-2.000000)) + l(3.000000);
    r1.z = r1.z * r1.z;
    r1.z = r1.z * r1.w;
    r1.w = dot2(r0.xzxx, -cb0[58].xyxx);
    r1.w = -r1.x + r1.w;
    r2.x = (r1.w * l(0.900000)) + r1.x;
    r2.x = r2.x * l(6.283185);
    r2.x = r2.x / cb0[68].w;
    r2.y = cb0[70].w * cb0[128].x;
    r2.x = (r2.y * l(0.500000)) + r2.x;
    r2.x = r2.x * l(0.333333);
    sincos(null, r2.x, r2.x);
    r2.x = (r2.x * l(0.500000)) + l(0.500000);
    r2.yz = r0.xxzx * l(0.000000, 0.500000, 0.500000, 0.000000);
    r2.yz = r2.yyzy / cb0[68].wwww;
    r2.yz = (cb0[128].xxxx * l(0.000000, 0.300000, 0.400000, 0.000000)) + r2.yyzy;
    sincos(r2.yz, null, r2.yyzy);
    r2.y = r2.y * l(0.500000);
    r2.y = (r2.y * r2.z) + l(0.500000);
    r2.z = r0.w * r2.y;
    r2.z = r1.z * r2.z;
    r2.x = r2.z * r2.x;
    r1.w = (cb0[70].z * r1.w) + r1.x;
    r1.w = r1.w * l(6.283185);
    r2.z = r1.w / cb0[68].w;
    r2.w = r1.y * cb0[69].z;
    r2.z = (cb0[70].w * cb0[128].x) + r2.z;
    sincos(r2.z, null, r2.z);
    r2.z = r2.w * r2.z;
    r2.w = dot2(r0.xzxx, r0.xzxx);
    r2.w = rsqrt(r2.w);
    r3.zw = r0.xxxz * r2.wwww;
    r2.w = dot2(r3.xyxx, r3.zwzz);
    r3.x = cb0[71].w * l(10.000000);
    r3.yz = r1.xxxx + l(0.000000, 10.000000, 2.000000, 0.000000);
    // asm: mul_sat r3.yz, r3.yyzy, l(0.000000, 0.026316, 0.083333, 0.000000)
    r4.xy = (r3.yzyy * l(-2.000000, -2.000000, 0.000000, 0.000000)) + l(3.000000, 3.000000, 0.000000, 0.000000);
    r3.yz = r3.yyzy * r3.yyzy;
    r1.x = r3.z * r4.y;
    r3.y = (-r4.x * r3.y) + l(1.000000);
    r3.z = (-cb0[71].w * l(10.000000)) + l(1.000000);
    r3.x = (r3.y * r3.z) + r3.x;
    r2.w = log2(|r2.w|);
    r2.w = r2.w * r3.x;
    r2.w = exp2(r2.w);
    r2.w = min(r2.w, l(1.000000));
    r1.w = r1.w / cb0[69].x;
    r3.xy = r0.xzxx + r0.xzxx;
    r4.zw = floor(r3.xxxy);
    r0.xz = (r0.xxzx * l(2.000000, 0.000000, 2.000000, 0.000000)) + l(1.000000, 0.000000, 1.000000, 0.000000);
    r4.xy = floor(r0.xzxx);
    r0.xz = frac(r3.xxyx);
    r3.xy = r0.xzxx * r0.xzxx;
    r0.xz = (-r0.xxzx * l(2.000000, 0.000000, 2.000000, 0.000000)) + l(3.000000, 0.000000, 3.000000, 0.000000);
    r0.xz = r0.xxzx * r3.xxyx;
    r3.x = dot2(r4.zwzz, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r3.x, null, r3.x);
    r3.x = r3.x * l(43758.546875);
    r3.y = dot2(r4.xwxx, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r3.y, null, r3.y);
    r3.y = r3.y * l(43758.546875);
    r3.xy = frac(r3.xyxx);
    r3.y = -r3.x + r3.y;
    r3.x = (r0.x * r3.y) + r3.x;
    r3.y = dot2(r4.zyzz, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r3.y, null, r3.y);
    r3.y = r3.y * l(43758.546875);
    r3.z = dot2(r4.xyxx, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r3.z, null, r3.z);
    r3.z = r3.z * l(43758.546875);
    r3.yz = frac(r3.yyzy);
    r3.z = -r3.y + r3.z;
    r0.x = (r0.x * r3.z) + r3.y;
    r0.x = -r3.x + r0.x;
    r0.x = (r0.z * r0.x) + r3.x;
    r0.x = r0.x * r0.x;
    r0.x = r0.x * r0.x;
    r0.z = cb0[70].w * cb0[71].x;
    r0.z = (r0.z * cb0[128].x) + r1.w;
    r0.z = (-r2.w * l(0.800000)) + r0.z;
    r0.x = (r0.x * l(0.600000)) + r0.z;
    r0.z = r1.y * r0.w;
    r0.z = r1.z * r0.z;
    r0.w = l(1.000000, 1.000000, 1.000000, 1.000000) / cb0[71].z;
    // asm: mul_sat r0.w, r0.w, r2.w
    r1.y = (r0.w * l(-2.000000)) + l(3.000000);
    r0.w = r0.w * r0.w;
    r0.w = r0.w * r1.y;
    r0.z = r0.w * r0.z;
    r0.w = r2.y * r2.y;
    r0.z = r0.z * r0.w;
    r0.x = r0.x * l(0.500000);
    sincos(r0.x, r3.x, r0.x);
    r0.w = r3.x * l(-0.950000);
    r1.y = -|r0.w| + l(1.000000);
    r1.y = sqrt(r1.y);
    r1.z = (|r0.w| * l(-0.018729)) + l(0.074261);
    r1.z = (r1.z * |r0.w|) + l(-0.212114);
    r1.z = (r1.z * |r0.w|) + l(1.570729);
    r1.w = r1.y * r1.z;
    r1.w = (r1.w * l(-2.000000)) + l(3.141593);
    r0.w = (r0.w < -r0.w);
    r0.w = r0.w & r1.w;
    r0.w = (r1.z * r1.y) + r0.w;
    r0.w = (-r0.w * l(0.636620)) + l(1.000000);
    r0.x = r0.x * l(20.000000);
    r1.y = min(|r0.x|, l(1.000000));
    r1.z = max(|r0.x|, l(1.000000));
    r1.z = l(1.000000, 1.000000, 1.000000, 1.000000) / r1.z;
    r1.y = r1.z * r1.y;
    r1.z = r1.y * r1.y;
    r1.w = (r1.z * l(0.020835)) + l(-0.085133);
    r1.w = (r1.z * r1.w) + l(0.180141);
    r1.w = (r1.z * r1.w) + l(-0.330299);
    r1.z = (r1.z * r1.w) + l(0.999866);
    r1.w = r1.z * r1.y;
    r2.y = (l(1.000000) < |r0.x|);
    r1.w = (r1.w * l(-2.000000)) + l(1.570796);
    r1.w = r2.y & r1.w;
    r1.y = (r1.y * r1.z) + r1.w;
    r0.x = min(r0.x, l(1.000000));
    r0.x = (r0.x < -r0.x);
    r0.x = (r0.x) ? -r1.y : r1.y;
    r0.x = r0.w * r0.x;
    r0.x = (-r0.x * l(0.636620)) + l(1.000000);
    r0.x = r0.z * r0.x;
    r0.x = r1.x * r0.x;
    r0.x = r0.x * cb0[69].w;
    r0.x = (r2.x * r2.z) + r0.x;
    r0.y = r0.y + l(-60.000000);
    // asm: mul_sat r0.y, r0.y, l(0.016667)
    r0.z = (r0.y * l(-2.000000)) + l(3.000000);
    r0.y = r0.y * r0.y;
    r0.y = r0.y * r0.z;
    r0.z = min(r0.x, l(0.050000));
    r0.z = -r0.x + r0.z;
    o0.y = (r0.y * r0.z) + r0.x;
    o0.x = l(0);
    return;
    // asm: // Approximately 244 instruction slots used
}

