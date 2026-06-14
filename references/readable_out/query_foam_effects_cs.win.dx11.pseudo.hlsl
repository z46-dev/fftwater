// Pseudo-HLSL generated from compiled shader bytecode.
// Source container: query_foam_effects_cs.win.dx11.fxo
//
// This is reconstructed for reading only.
// It is not original HLSL and should not be treated as recompilable source.

// -----------------------------------------------------------------------------
// Shader 0
// Profile: cs_5_0
// Byte offset: 18308
// Byte length: 18248
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
Resource bind info for g_resultFoamPos
{
  float4 $Element;                   // Offset:    0 Size:    16
}

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// g_bilinearClampSampler            sampler      NA          NA             s0      1 
// g_trilinearWrapSampler            sampler      NA          NA             s1      1 
// g_RTPointSampler                  sampler      NA          NA             s2      1 
// g_depthTexSampler                 sampler      NA          NA             s3      1 
// g_depthTex                        texture  float4          2d             t0      1 
// g_variationTexture                texture  float4          2d             t1      1 
// g_spaceVariationTexture           texture  float4          2d             t2      1 
// g_waterDataZBuf                   texture  float4          2d             t3      1 
// g_waterDataWaveTexCoordGradBuf    texture  float4          2d             t4      1 
// g_fftWave0GradTexture             texture  float4          2d             t5      1 
// g_fftWave1GradTexture             texture  float4          2d             t6      1 
// g_fftWave2GradTexture             texture  float4          2d             t7      1 
// g_foamLowFreq                     texture  float4          2d             t8      1 
// g_foamHighFreq                    texture  float4          2d             t9      1 
// g_resultFoamPos                       UAV  struct         r/w             u0      1 
// $Globals                          cbuffer      NA          NA            cb0      1 
// PerFrame                          cbuffer      NA          NA            cb1      1 
// PerScreen                         cbuffer      NA          NA            cb2      1 
// PerView                           cbuffer      NA          NA            cb3      1

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// no Input

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// no Output

[numthreads(16, 16, 1)]
void cs_00_cs_5_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_globalFlags refactoringAllowed
    // dcl_constantbuffer CB0[1], immediateIndexed
    // dcl_constantbuffer CB1[132], immediateIndexed
    // dcl_constantbuffer CB2[1], immediateIndexed
    // dcl_constantbuffer CB3[37], immediateIndexed
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
    // dcl_uav_structured u0, 16
    // dcl_input vThreadID.xy
    float4 r[15];
    // numthreads(16, 16, 1)
    r0.xyz = vThreadID.yxyy << l(4, 2, 2, 0);
    r0.x = r0.x + vThreadID.x;
    r1.xyzw = cb2[0].xyxy * l(0.015625, 0.015625, 0.009375, 0.009375);
    r2.xyzw = max(r1.zwzw, l(1.000000, 1.000000, 1.000000, 1.000000));
    r0.w = frac(cb1[128].x);
    r0.w = r0.w * l(100.000000);
    r0.w = (uint)r0.w;
    r3.xyz = -cb3[32].xyzx + cb3[33].xyzx;
    r4.xyz = -cb3[34].xyzx + cb3[35].xyzx;
    r1.z = cb1[61].y * l(0.001000);
    // asm: mad_sat r1.w, cb1[131].y, l(2.000000), l(-1.000000)
    r3.w = -cb1[58].z + cb3[36].y;
    r4.w = (-cb1[61].x * cb1[61].w) + cb1[61].x;
    r4.w = l(1.000000, 1.000000, 1.000000, 1.000000) / r4.w;
    // asm: mad_sat r3.w, |r3.w|, l(0.003333), l(-0.100000)
    r5.x = -cb1[60].w + l(1.000000);
    r6.xyzw = cb0[0].zzzz * l(0.500000, 0.500000, 4.000000, 4.000000);
    r5.y = -cb0[0].y + l(1.000000);
    r5.y = l(1.000000, 1.000000, 1.000000, 1.000000) / r5.y;
    r7.y = l(0x000041a7);
    r8.xyz = l(0,0,0,0);
    r5.zw = l(0,0,0,0);
    r9.x = l(0);
    while (true) {
        // asm: ige r7.w, r9.x, l(4)
        if (r7.w) { break; }
        r10.yzw = r8.xxyz;
        r7.w = r5.z;
        r10.x = r5.w;
        r9.y = l(0);
        while (true) {
            // asm: ige r9.z, r9.y, l(4)
            if (r9.z) { break; }
            r9.zw = r0.yyyz + r9.xxxy;
            r11.x = r9.w << l(6);
            r11.x = r9.z + r11.x;
            r11.x = r0.w + r11.x;
            r9.zw = (float)r9.zzzw;
            r9.zw = r9.zzzw + l(0.000000, 0.000000, 0.500000, 0.500000);
            r11.y = r11.x << l(13);
            r11.x = r11.x ^ r11.y;
            null = r11.y * r11.x;
            r11.y = (r11.y * l(0x00003d73)) + l(0x000c0ae5);
            r7.x = (r11.x * r11.y) + l(0x5208dd0d);
            null = r7.z * r7.x;
            null = r7.xz * r7.xxzx;
            r7.xz = r7.xxzx & l(0x7fffffff, 0, 0x7fffffff, 0);
            r7.xz = (float)r7.xxzx;
            r7.xz = (r7.xxzx * l(0.000000, 0.000000, 0.000000, 0.000000)) + l(-0.500000, 0.000000, -0.500000, 0.000000);
            r7.xz = (r7.xxzx * r1.xxyx) + r9.zzwz;
            r11.y = r7.x * l(0.015625);
            // asm: mad_sat r11.z, r7.z, l(0.015625), l(-0.200000)
            // asm: sample_l_indexable(texture2d)(float,float,float,float) r7.x, r11.yzyy, t3.xyzw, s2, l(0.000000)
            r7.x = r7.x + -cb3[26].z;
            r7.x = cb3[27].z / r7.x;
            r7.z = (l(3000.000000) < r7.x);
            if (r7.z) {
                r7.z = r11.z + l(0.400000);
                r11.w = min(r7.z, l(1.000000));
                // asm: sample_l_indexable(texture2d)(float,float,float,float) r7.z, r11.ywyy, t3.yzxw, s2, l(0.000000)
                r7.z = r7.z + -cb3[26].z;
                r7.x = cb3[27].z / r7.z;
                r7.z = (l(3000.000000) < r7.x);
                if (r7.z) {
                    r7.z = r9.y + l(1);
                    r9.y = r7.z;
                    continue;
                }
                r11.x = r11.w;
            else
                r11.x = r11.z;
            }
            // asm: sample_l_indexable(texture2d)(float,float,float,float) r7.z, r11.yxyy, t0.yzxw, s3, l(0.000000)
            r7.z = r7.z + -cb3[26].z;
            r7.z = cb3[27].z / r7.z;
            r7.z = (r7.z < r7.x);
            if (r7.z) {
                r7.z = r9.y + l(1);
                r9.y = r7.z;
                continue;
            }
            r12.xyz = (r11.xxxx * r3.xyzx) + cb3[32].xyzx;
            r13.xyz = (r11.xxxx * r4.xyzx) + cb3[34].xyzx;
            r13.xyz = -r12.xyzx + r13.xyzx;
            r12.xyz = (r11.yyyy * r13.xyzx) + r12.xyzx;
            r12.yzw = (r12.xxyz * r7.xxxx) + cb3[36].xxyz;
            // asm: sample_l_indexable(texture2d)(float,float,float,float) r11.xyzw, r11.yxyy, t4.xyzw, s2, l(0.000000)
            r11.xyzw = r2.xyzw * r11.xyzw;
            r13.xyz = -r12.yzwy + cb3[36].xyzx;
            r7.z = dot(r13.xyzx, r13.xyzx);
            r7.z = sqrt(r7.z);
            r9.zw = r1.zzzz * r12.yyyw;
            r13.xyzw = r1.zzzz * r11.xyzw;
            // asm: sample_d_indexable(texture2d)(float,float,float,float) r9.z, r9.zwzz, t1.yzxw, s1, r13.xyxx, r13.zwzz
            // asm: add_sat r9.z, r9.z, cb1[59].w
            r9.w = (-cb1[61].x * cb1[61].w) + r9.z;
            // asm: mul_sat r9.w, r4.w, r9.w
            r13.x = (r9.w * l(-2.000000)) + l(3.000000);
            r9.w = r9.w * r9.w;
            r9.w = (r13.x * r9.w) + r3.w;
            // asm: mad_sat r7.z, r7.z, l(0.005000), l(-2.000000)
            r7.z = (r1.w * r7.z) + r9.w;
            r7.z = min(r7.z, l(1.000000));
            r7.z = (r7.z * r5.x) + cb1[60].w;
            r9.z = log2(r9.z);
            r7.z = r7.z * r9.z;
            r7.z = exp2(r7.z);
            r9.zw = (r12.yyyw * cb1[124].xxxy) + cb1[124].zzzw;
            r13.xy = (r9.zwzz >= l(0.000000, 0.000000, 0.000000, 0.000000));
            r13.zw = (l(0.000000, 0.000000, 1.000000, 1.000000) >= r9.zzzw);
            r13.x = r13.z & r13.x;
            r13.x = r13.y & r13.x;
            r13.x = r13.w & r13.x;
            if (r13.x) {
                // asm: sample_l_indexable(texture2d)(float,float,float,float) r9.z, r9.zwzz, t2.yzxw, s0, l(0.000000)
            else
                r9.z = l(1.000000);
            }
            r13.xyzw = (r12.ywyw * cb1[59].xxyy) + cb1[60].xxyy;
            r14.xyzw = r11.xyzw * cb1[59].xxxx;
            // asm: sample_d_indexable(texture2d)(float,float,float,float) r9.w, r13.xyxx, t5.xywz, s1, r14.xyxx, r14.zwzz
            r14.xyzw = r11.xyzw * cb1[59].yyyy;
            // asm: sample_d_indexable(texture2d)(float,float,float,float) r13.x, r13.zwzz, t6.zxyw, s1, r14.xyxx, r14.zwzz
            r9.w = r9.w + r13.x;
            r13.xy = (r12.ywyy * cb1[59].zzzz) + cb1[60].zzzz;
            r14.xyzw = r11.xyzw * cb1[59].zzzz;
            // asm: sample_d_indexable(texture2d)(float,float,float,float) r13.x, r13.xyxx, t7.zxyw, s1, r14.xyxx, r14.zwzz
            r9.w = r9.w + r13.x;
            // asm: dp2_sat r7.z, r7.zzzz, r9.zzzz
            r13.xyzw = r6.xyzw * r12.ywyw;
            r14.xyzw = r6.yyyy * r11.xyzw;
            // asm: sample_d_indexable(texture2d)(float,float,float,float) r13.xy, r13.xyxx, t8.xyzw, s1, r14.xyxx, r14.zwzz
            r11.xyzw = r6.wwww * r11.xyzw;
            // asm: sample_d_indexable(texture2d)(float,float,float,float) r9.z, r13.zwzz, t9.yzxw, s1, r11.xyxx, r11.zwzz
            r7.z = (r9.w * r7.z) + -cb0[0].y;
            // asm: mul_sat r7.z, r5.y, r7.z
            r9.w = (r7.z * l(-2.000000)) + l(3.000000);
            r7.z = r7.z * r7.z;
            r11.xy = (r9.wwww * r7.zzzz) + r13.xyxx;
            // asm: add_sat r11.xy, r11.xyxx, l(-1.000000, -1.000000, 0.000000, 0.000000)
            r11.xy = r11.xyxx * r11.xyxx;
            r11.xy = r11.xyxx * l(8.000000, 8.000000, 0.000000, 0.000000);
            r11.x = r11.y + r11.x;
            r7.z = (r9.w * r7.z) + r9.z;
            // asm: add_sat r7.z, r7.z, l(-1.000000)
            r7.z = (r7.z * l(4.000000)) + r11.x;
            r9.zw = r12.yyyw * l(0.000000, 0.000000, 0.100000, 0.100000);
            r11.zw = floor(r9.zzzw);
            r13.xy = (r12.ywyy * l(0.100000, 0.100000, 0.000000, 0.000000)) + l(1.000000, 1.000000, 0.000000, 0.000000);
            r11.xy = floor(r13.xyxx);
            r9.zw = frac(r9.zzzw);
            r13.xy = r9.zwzz * r9.zwzz;
            r9.zw = (-r9.zzzw * l(0.000000, 0.000000, 2.000000, 2.000000)) + l(0.000000, 0.000000, 3.000000, 3.000000);
            r9.zw = r9.zzzw * r13.xxxy;
            r13.x = dot2(r11.zwzz, l(12.989800, 78.233002, 0.000000, 0.000000));
            sincos(r13.x, null, r13.x);
            r13.x = r13.x * l(43758.546875);
            r13.x = frac(r13.x);
            r11.w = dot2(r11.xwxx, l(12.989800, 78.233002, 0.000000, 0.000000));
            sincos(r11.w, null, r11.w);
            r11.w = r11.w * l(43758.546875);
            r11.w = frac(r11.w);
            r11.w = -r13.x + r11.w;
            r11.w = (r9.z * r11.w) + r13.x;
            r11.z = dot2(r11.zyzz, l(12.989800, 78.233002, 0.000000, 0.000000));
            sincos(r11.z, null, r11.z);
            r11.z = r11.z * l(43758.546875);
            r11.x = dot2(r11.xyxx, l(12.989800, 78.233002, 0.000000, 0.000000));
            sincos(r11.x, null, r11.x);
            r11.x = r11.x * l(43758.546875);
            r11.xz = frac(r11.xxzx);
            r11.x = -r11.z + r11.x;
            r9.z = (r9.z * r11.x) + r11.z;
            r9.z = -r11.w + r9.z;
            r9.z = (r9.w * r9.z) + r11.w;
            r9.z = r9.z * r9.z;
            // asm: mad_sat r7.x, r7.x, l(0.014286), l(-0.714286)
            r9.z = (r9.z * r9.z) + l(-1.000000);
            r7.x = (r7.x * r9.z) + l(1.000000);
            r12.x = r7.x * r7.z;
            r9.z = (r10.x < r12.x);
            r10.xyzw = (r9.zzzz) ? r12.xyzw : r10.xyzw;
            r7.w = (r7.z * r7.x) + r7.w;
            r9.y = r9.y + l(1);
        }
        r8.xyz = r10.yzwy;
        r5.z = r7.w;
        r5.w = r10.x;
        r9.x = r9.x + l(1);
    }
    // asm: mul_sat r8.w, r5.z, l(0.062500)
    r0.y = (l(0.000000) < r8.w);
    r1.xyzw = r8.xyzw & r0.yyyy;
    store_structured(u0.xyzw, r0.x, l(0), r1.xyzw);
    return;
    // asm: // Approximately 195 instruction slots used
}

