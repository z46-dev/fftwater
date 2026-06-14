// Pseudo-HLSL generated from compiled shader bytecode.
// Source container: dynamic_wetness.win.dx11.fxo
//
// This is reconstructed for reading only.
// It is not original HLSL and should not be treated as recompilable source.

// -----------------------------------------------------------------------------
// Shader 0
// Profile: cs_5_0
// Byte offset: 19608
// Byte length: 24360
// -----------------------------------------------------------------------------

// Reflected buffer definitions
cbuffer $Globals
{
  bool g_isTAAEnabledBranch;         // Offset:    0 Size:     4 [unused]
     = 0xffffffff 
  uint g_numRenderSets;              // Offset:    4 Size:     4 [unused]
  row_major float4x4 g_shipUnwrapperWorld;// Offset:   16 Size:    64
  row_major float4x4 g_shipWorldInv; // Offset:   80 Size:    64 [unused]
  float4 g_shipSize;                 // Offset:  144 Size:    16
  float g_shipSpeed;                 // Offset:  160 Size:     4
  float g_shipMovementForward;       // Offset:  164 Size:     4 [unused]
  float4 g_textureSize;              // Offset:  176 Size:    16
  float g_rainAmount;                // Offset:  192 Size:     4
  float g_shipFoamSpawnMinDistMult;  // Offset:  196 Size:     4 [unused]
  uint g_vfxIDShipRaindrop;          // Offset:  200 Size:     4 [unused]
  uint g_vfxIDShipFoam;              // Offset:  204 Size:     4 [unused]
  uint g_vfxIDShipTopWave;           // Offset:  208 Size:     4 [unused]
  uint g_vfxIDUnderwaterBubbles;     // Offset:  212 Size:     4
  bool g_isShipSubmarine;            // Offset:  216 Size:     4
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
  float g_deltaTime;                 // Offset: 2056 Size:     4
     = 0x00000000 
  float g_timeFromMapStart;          // Offset: 2060 Size:     4 [unused]
     = 0x00000000 
  uint g_frameIdx;                   // Offset: 2064 Size:     4
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
  bool g_gpuVfxAccessPong;           // Offset: 2104 Size:     4
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
Resource bind info for g_gpuVfxParticlesUAV
{
  struct GPUParticleData
  {
      float3 position;               // Offset:    0
      uint vfxHashID;                // Offset:   12
      float3 velocity;               // Offset:   16
      float linearAge;               // Offset:   28
  } $Element;                        // Offset:    0 Size:    32
}

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// g_bilinearClampSampler            sampler      NA          NA             s0      1 
// g_bilinearWrapSampler             sampler      NA          NA             s1      1 
// g_RTLinearSampler                 sampler      NA          NA             s2      1 
// g_RTPointSampler                  sampler      NA          NA             s3      1 
// g_normalsTexture                  texture  float4          2d             t0      1 
// g_gpuVfxPerVfxCountersSRV         texture    uint         buf             t1      1 
// g_wave0DispTexture                texture  float4          2d             t2      1 
// g_wave1DispTexture                texture  float4          2d             t3      1 
// g_variationTexture                texture  float4          2d             t4      1 
// g_spaceVariationTexture           texture  float4          2d             t5      1 
// g_waterDeformTexture              texture  float4          2d             t6      1 
// g_shipUnwrapperDepth              texture  float4          2d             t7      1 
// g_prevShipWetnessTexture          texture  float4          2d             t8      1 
// g_gpuVfxGlobalCountersUAV             UAV    uint         buf             u0      1 
// g_gpuVfxDeadIndirectionUAV            UAV    uint         buf             u1      1 
// g_gpuVfxParticlesUAV                  UAV  struct         r/w             u2      1 
// g_gpuVfxParticlesIndirectionUAV        UAV    uint         buf             u3      1 
// g_sideWetnessTextureUAV               UAV   float          2d             u4      1 
// $Globals                          cbuffer      NA          NA            cb0      1 
// PerFrame                          cbuffer      NA          NA            cb1      1 
// PerView                           cbuffer      NA          NA            cb2      1

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
    // dcl_constantbuffer CB0[14], immediateIndexed
    // dcl_constantbuffer CB1[132], immediateIndexed
    // dcl_constantbuffer CB2[37], immediateIndexed
    // dcl_sampler s0, mode_default
    // dcl_sampler s1, mode_default
    // dcl_sampler s2, mode_default
    // dcl_sampler s3, mode_default
    // dcl_resource_texture2d (float,float,float,float) t0
    // dcl_resource_buffer (uint,uint,uint,uint) t1
    // dcl_resource_texture2d (float,float,float,float) t2
    // dcl_resource_texture2d (float,float,float,float) t3
    // dcl_resource_texture2d (float,float,float,float) t4
    // dcl_resource_texture2d (float,float,float,float) t5
    // dcl_resource_texture2d (float,float,float,float) t6
    // dcl_resource_texture2d (float,float,float,float) t7
    // dcl_resource_texture2d (float,float,float,float) t8
    // dcl_uav_typed_buffer (uint,uint,uint,uint) u0
    // dcl_uav_typed_buffer (uint,uint,uint,uint) u1
    // dcl_uav_structured u2, 32
    // dcl_uav_typed_buffer (uint,uint,uint,uint) u3
    // dcl_uav_typed_texture2d (float,float,float,float) u4
    // dcl_input vThreadID.xy
    float4 r[7];
    // numthreads(16, 16, 1)
    r0.xy = vThreadID.xyxx;
    r0.zw = l(0,0,0,0);
    // asm: ld_indexable(texture2d)(float,float,float,float) r1.xyzw, r0.xyww, t7.xyzw
    r1.w = (r1.w < l(0.000010));
    if (r1.w) {
        return;
    }
    r2.xy = (uint)cb0[11].xyxx;
    r3.xyz = r1.yyyy * cb0[2].xyzx;
    r3.xyz = (r1.xxxx * cb0[1].xyzx) + r3.xyzx;
    r3.xyz = (r1.zzzz * cb0[3].xyzx) + r3.xyzx;
    r3.xyz = r3.xyzx + cb0[4].xyzx;
    // asm: mad_sat r1.w, cb1[131].y, l(2.000000), l(-1.000000)
    r2.z = -cb1[58].z + cb2[36].y;
    r2.w = (-cb1[61].x * cb1[61].w) + cb1[61].x;
    r2.w = l(1.000000, 1.000000, 1.000000, 1.000000) / r2.w;
    // asm: mad_sat r2.z, |r2.z|, l(0.003333), l(-0.100000)
    r4.x = -cb1[60].w + l(1.000000);
    r4.yz = r3.xxzx;
    r4.w = l(0);
    while (true) {
        r5.x = (r4.w >= l(2));
        if (r5.x) { break; }
        r5.xy = -r4.yzyy + cb2[36].xzxx;
        r5.x = dot2(r5.xyxx, r5.xyxx);
        r5.x = sqrt(r5.x);
        r5.yz = r4.yyzy * cb1[61].yyyy;
        r5.yz = r5.yyzy * l(0.000000, 0.001000, 0.001000, 0.000000);
        // asm: sample_l_indexable(texture2d)(float,float,float,float) r5.y, r5.yzyy, t4.yxzw, s1, l(1.000000)
        // asm: add_sat r5.y, r5.y, cb1[59].w
        r5.z = (-cb1[61].x * cb1[61].w) + r5.y;
        // asm: mul_sat r5.z, r2.w, r5.z
        r5.w = (r5.z * l(-2.000000)) + l(3.000000);
        r5.z = r5.z * r5.z;
        r5.z = (r5.w * r5.z) + r2.z;
        // asm: mad_sat r5.x, r5.x, l(0.005000), l(-2.000000)
        r5.x = (r1.w * r5.x) + r5.z;
        r5.x = min(r5.x, l(1.000000));
        r5.x = (r5.x * r4.x) + cb1[60].w;
        r5.y = log2(r5.y);
        r5.x = r5.y * r5.x;
        r5.x = exp2(r5.x);
        r5.yz = (r4.yyzy * cb1[124].xxyx) + cb1[124].zzwz;
        r6.xy = (r5.yzyy >= l(0.000000, 0.000000, 0.000000, 0.000000));
        r6.zw = (l(0.000000, 0.000000, 1.000000, 1.000000) >= r5.yyyz);
        r5.w = r6.z & r6.x;
        r5.w = r6.y & r5.w;
        r5.w = r6.w & r5.w;
        if (r5.w) {
            // asm: sample_l_indexable(texture2d)(float,float,float,float) r5.y, r5.yzyy, t5.yxzw, s0, l(0.000000)
        else
            r5.y = l(1.000000);
        }
        r5.x = r5.y * r5.x;
        r6.xyzw = (r4.yzyz * cb1[59].xxyy) + cb1[60].xxyy;
        // asm: sample_l_indexable(texture2d)(float,float,float,float) r5.yz, r6.xyxx, t2.xyzw, s1, l(1.000000)
        r5.x = r5.x * l(0.066667);
        // asm: sample_l_indexable(texture2d)(float,float,float,float) r6.xy, r6.zwzz, t3.yzxw, s1, l(1.000000)
        r6.xy = r5.xxxx * r6.xyxx;
        r5.xy = (r5.yzyy * r5.xxxx) + r6.xyxx;
        r5.xy = r4.yzyy + r5.xyxx;
        r5.xy = -r3.xzxx + r5.xyxx;
        r4.yz = r4.yyzy + -r5.xxyx;
        r4.w = r4.w + l(1);
    }
    r5.xyzw = r4.yzyz;
    r4.yz = -r5.zzwz + cb2[36].xxzx;
    r4.y = dot2(r4.yzyy, r4.yzyy);
    r4.y = sqrt(r4.y);
    r4.zw = r5.zzzw * cb1[61].yyyy;
    r4.zw = r4.zzzw * l(0.000000, 0.000000, 0.001000, 0.001000);
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r4.z, r4.zwzz, t4.yzxw, s1, l(1.000000)
    // asm: add_sat r4.z, r4.z, cb1[59].w
    r4.w = (-cb1[61].x * cb1[61].w) + r4.z;
    // asm: mul_sat r2.w, r2.w, r4.w
    r4.w = (r2.w * l(-2.000000)) + l(3.000000);
    r2.w = r2.w * r2.w;
    r2.z = (r4.w * r2.w) + r2.z;
    // asm: mad_sat r2.w, r4.y, l(0.005000), l(-2.000000)
    r1.w = (r1.w * r2.w) + r2.z;
    r1.w = min(r1.w, l(1.000000));
    r1.w = (r1.w * r4.x) + cb1[60].w;
    r2.z = log2(r4.z);
    r1.w = r1.w * r2.z;
    r1.w = exp2(r1.w);
    r2.zw = (r5.zzzw * cb1[124].xxxy) + cb1[124].zzzw;
    r4.xy = (r2.zwzz >= l(0.000000, 0.000000, 0.000000, 0.000000));
    r4.zw = (l(0.000000, 0.000000, 1.000000, 1.000000) >= r2.zzzw);
    r4.x = r4.z & r4.x;
    r4.x = r4.y & r4.x;
    r4.x = r4.w & r4.x;
    if (r4.x) {
        // asm: sample_l_indexable(texture2d)(float,float,float,float) r2.z, r2.zwzz, t5.yzxw, s0, l(0.000000)
    else
        r2.z = l(1.000000);
    }
    r1.w = r1.w * r2.z;
    r4.xyzw = (r5.xyzw * cb1[59].xxyy) + cb1[60].xxyy;
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r2.z, r4.xyxx, t2.yzxw, s1, l(1.000000)
    r1.w = r1.w * l(0.066667);
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r2.w, r4.zwzz, t3.yzwx, s1, l(1.000000)
    r2.w = r1.w * r2.w;
    r1.w = (r2.z * r1.w) + r2.w;
    r4.xyz = cb1[58].zzzz * cb2[1].xywx;
    r4.xyz = (r3.xxxx * cb2[0].xywx) + r4.xyzx;
    r4.xyz = (r3.zzzz * cb2[2].xywx) + r4.xyzx;
    r4.xyz = r4.xyzx + cb2[3].xywx;
    r2.zw = r4.xxxy / r4.zzzz;
    r2.zw = (r2.zzzw * l(0.000000, 0.000000, 0.400000, -0.400000)) + l(0.000000, 0.000000, 0.500000, 0.500000);
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r2.z, r2.zwzz, t6.xzyw, s2, l(0.000000)
    r1.w = (r2.z * cb1[62].x) + r1.w;
    r4.y = vThreadID.y + l(-1);
    r4.x = vThreadID.x;
    // asm: umin r4.xy, r2.xyxx, r4.xyxx
    r2.z = min(cb1[128].z, l(0.040000));
    // asm: ld_indexable(texture2d)(float,float,float,float) r0.x, r0.xyzw, t8.xyzw
    r4.zw = l(0,0,0,0);
    // asm: ld_indexable(texture2d)(float,float,float,float) r0.y, r4.xyww, t8.yxzw
    // asm: ld_indexable(texture2d)(float,float,float,float) r4.xyzw, r4.xyzw, t7.xyzw
    r0.z = r4.y * cb0[2].y;
    r0.z = (r4.x * cb0[1].y) + r0.z;
    r0.z = (r4.z * cb0[3].y) + r0.z;
    r0.z = r0.z + cb0[4].y;
    r4.xy = r1.xzxx * l(100.000000, 100.000000, 0.000000, 0.000000);
    r5.zw = floor(r4.xxxy);
    r6.xy = (r1.xzxx * l(100.000000, 100.000000, 0.000000, 0.000000)) + l(1.000000, 1.000000, 0.000000, 0.000000);
    r5.xy = floor(r6.xyxx);
    r4.xy = frac(r4.xyxx);
    r6.xy = r4.xyxx * r4.xyxx;
    r4.xy = (-r4.xyxx * l(2.000000, 2.000000, 0.000000, 0.000000)) + l(3.000000, 3.000000, 0.000000, 0.000000);
    r4.xy = r4.xyxx * r6.xyxx;
    r0.w = dot2(r5.zwzz, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r0.w, null, r0.w);
    r0.w = r0.w * l(43758.546875);
    r0.w = frac(r0.w);
    r2.w = dot2(r5.xwxx, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r2.w, null, r2.w);
    r2.w = r2.w * l(43758.546875);
    r2.w = frac(r2.w);
    r2.w = -r0.w + r2.w;
    r0.w = (r4.x * r2.w) + r0.w;
    r2.w = dot2(r5.zyzz, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r2.w, null, r2.w);
    r2.w = r2.w * l(43758.546875);
    r2.w = frac(r2.w);
    r4.z = dot2(r5.xyxx, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r4.z, null, r4.z);
    r4.z = r4.z * l(43758.546875);
    r4.z = frac(r4.z);
    r4.z = -r2.w + r4.z;
    r2.w = (r4.x * r4.z) + r2.w;
    r2.w = -r0.w + r2.w;
    r0.w = (r4.y * r2.w) + r0.w;
    r0.w = r0.w * r0.w;
    r0.z = -r3.y + r0.z;
    r4.xy = (r0.wwww * l(60.000000, 3.000000, 0.000000, 0.000000)) + l(100.000000, 2.500000, 0.000000, 0.000000);
    r0.z = |r0.z| * r4.x;
    r4.xz = r0.xxxx + l(-0.050000, 0.000000, -0.200000, 0.000000);
    // asm: mul_sat r4.xz, r4.xxzx, l(1.333333, 0.000000, 1.666667, 0.000000)
    r5.xy = (r4.xzxx * l(-2.000000, -2.000000, 0.000000, 0.000000)) + l(3.000000, 3.000000, 0.000000, 0.000000);
    r4.xz = r4.xxzx * r4.xxzx;
    r4.xz = r4.xxzx * r5.xxyx;
    r5.xy = (r4.xzxx * l(4.000000, 1.500000, 0.000000, 0.000000)) + l(1.000000, 0.500000, 0.000000, 0.000000);
    r2.w = r2.z * r5.x;
    r0.z = (-r2.w * r0.z) + l(1.000000);
    r2.w = -r0.z + l(1.000000);
    r0.y = r0.y * r2.w;
    r2.w = (l(0.001000) < r4.w);
    r2.w = r2.w & l(0x3f800000);
    r0.y = r0.y * r2.w;
    r0.y = (r0.x * r0.z) + r0.y;
    r0.x = (l(0.000000) < r0.x);
    r0.z = max(r0.y, l(0.080000));
    r0.x = (r0.x) ? r0.z : r0.y;
    r0.y = r2.z * r4.z;
    r0.y = r0.y * l(0.500000);
    r0.z = (r0.w * r5.y) + l(1.000000);
    r0.y = (-r0.y * r0.z) + l(1.000000);
    r0.y = max(r0.y, l(0.000000));
    r0.z = r3.y + l(-0.004000);
    r0.z = (r1.w < r0.z);
    r2.z = (-r2.z * r4.y) + l(1.000000);
    r0.z = (r0.z) ? l(0) : r2.z;
    // asm: mad_sat r0.x, r0.x, r0.y, r0.z
    store_uav_typed(u4.xyzw, vThreadID.xyyy, r0.xxxx);
    r0.x = min(r0.w, l(1.000000));
    r0.y = (vThreadID.y * r2.x) + vThreadID.x;
    null = r0.z * r2.y;
    r0.w = cb1[129].x & l(63);
    r0.y = (r0.z * r0.w) + r0.y;
    r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
    r0.z = r0.y ^ l(61);
    r0.y = r0.y >> l(16);
    r0.y = r0.y ^ r0.z;
    null = r0.y * r0.y;
    r0.z = r0.y >> l(4);
    r0.y = r0.z ^ r0.y;
    null = r0.y * r0.y;
    r0.z = r0.y >> l(15);
    r0.y = r0.z ^ r0.y;
    r0.z = cb0[9].w * cb0[9].z;
    // asm: mul_sat r0.w, r0.z, l(0.108069)
    r0.z = (l(27.759930) < r0.z);
    // asm: bfi r0.z, l(1), l(1), r0.z, l(0)
    r0.z = r0.z + l(6);
    r0.z = (float)r0.z;
    r0.x = log2(r0.x);
    r0.z = r0.x * r0.z;
    r0.z = exp2(r0.z);
    // asm: mad_sat r2.x, cb0[10].x, l(0.142857), l(-0.142857)
    r2.x = (r2.x * l(0.020000)) + l(0.024000);
    r2.y = -r1.w + r3.y;
    r2.x = (|r2.y| < r2.x);
    r2.y = (l(0.000000) < cb0[12].x);
    r2.y = (r2.y) ? l(0.200000) : l(100.199997);
    r2.y = (r2.y < |r1.w|);
    r2.x = r2.x | r2.y;
    r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
    r2.y = r0.y ^ l(61);
    r0.y = r0.y >> l(16);
    r0.y = r0.y ^ r2.y;
    null = r0.y * r0.y;
    r2.y = r0.y >> l(4);
    r0.y = r0.y ^ r2.y;
    null = r0.y * r0.y;
    r2.y = r0.y >> l(15);
    r0.y = r0.y ^ r2.y;
    r2.y = (float)r0.y;
    r2.y = r2.y * l(0.000000);
    r0.z = r0.w * r0.z;
    r0.z = (r2.y < r0.z);
    r0.z = r0.z & r2.x;
    r2.x = r1.w + l(0.020000);
    r2.x = (r3.y < r2.x);
    r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
    r2.y = r0.y ^ l(61);
    r0.y = r0.y >> l(16);
    r0.y = r0.y ^ r2.y;
    null = r0.y * r0.y;
    r2.y = r0.y >> l(4);
    r0.y = r0.y ^ r2.y;
    null = r0.y * r0.y;
    r2.y = r0.y >> l(15);
    r0.y = r0.y ^ r2.y;
    r2.y = (float)r0.y;
    r2.y = r2.y * l(0.000000);
    r0.w = (r2.y < r0.w);
    r0.w = r0.w & r2.x;
    r1.w = (cb0[9].y * l(0.900000)) + r1.w;
    r1.w = (r3.y < r1.w);
    r0.z = r0.w | r0.z;
    r0.z = r0.z & r1.w;
    if (r0.z) {
        r0.z = (cb0[13].z != l(0));
        r0.w = (l(-0.100000) < r1.y);
        r0.z = r0.w & r0.z;
        if (r0.z) {
            r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
            r0.z = r0.y ^ l(61);
            r0.y = r0.y >> l(16);
            r0.y = r0.y ^ r0.z;
            null = r0.y * r0.y;
            r0.z = r0.y >> l(4);
            r0.y = r0.z ^ r0.y;
            null = r0.y * r0.y;
            r0.z = r0.y >> l(15);
            r0.y = r0.z ^ r0.y;
            r2.y = (cb0[13].z) ? l(0.000100) : l(0.010000);
            r2.xz = l(0,0,0,0);
            r2.xyz = r1.xyzx + r2.xyzx;
            r4.xyz = r2.yyyy * cb0[2].xyzx;
            r2.xyw = (r2.xxxx * cb0[1].xyxz) + r4.xyxz;
            r2.xyz = (r2.zzzz * cb0[3].xyzx) + r2.xywx;
            r2.xyz = r2.xyzx + cb0[4].xyzx;
            r4.xyz = r2.yyyy * cb2[1].xywx;
            r2.xyw = (r2.xxxx * cb2[0].xyxw) + r4.xyxz;
            r2.xyz = (r2.zzzz * cb2[2].xywx) + r2.xywx;
            r2.xyz = r2.xyzx + cb2[3].xywx;
            r0.zw = r2.xxxy / r2.zzzz;
            r2.xy = (r0.zwzz * l(0.500000, 0.500000, 0.000000, 0.000000)) + l(0.500000, 0.500000, 0.000000, 0.000000);
            r2.z = -r2.y + l(1.000000);
            // asm: sample_l_indexable(texture2d)(float,float,float,float) r0.zw, r2.xzxx, t0.zwxy, s3, l(0.000000)
            r0.zw = (r0.zzzw * l(0.000000, 0.000000, 2.000000, 2.000000)) + l(0.000000, 0.000000, -1.000000, -1.000000);
            r2.xyz = -|r0.zwzz| + l(1.000000, 1.000000, 1.000000, 0.000000);
            r4.z = -|r0.w| + r2.x;
            r1.y = (r4.z >= l(0.000000));
            r2.xw = (r0.zzzw >= l(0.000000, 0.000000, 0.000000, 0.000000));
            r2.xw = (r2.xxxw) ? l(1.000000,0,0,1.000000) : l(-1.000000,0,0,-1.000000);
            r2.xy = r2.xwxx * r2.yzyy;
            r4.xy = (r1.yyyy) ? r0.zwzz : r2.xyxx;
            r0.z = dot(r4.xyzx, r4.xyzx);
            r0.z = rsqrt(r0.z);
            r2.xyz = r0.zzzz * r4.xyzx;
            r0.x = r0.x * l(64.000000);
            r0.x = exp2(r0.x);
            r0.z = (uint)cb1[128].x;
            r1.xy = r1.xzxx * l(10.310000, 10.310000, 0.000000, 0.000000);
            r1.xy = frac(r1.xyxx);
            r4.xyz = r1.yxxy + l(33.330002, 33.330002, 33.330002, 0.000000);
            r0.w = dot(r1.xyxx, r4.xyzx);
            r1.xy = r0.wwww + r1.xyxx;
            r0.w = r1.y + r1.x;
            r0.w = r1.x * r0.w;
            r0.w = frac(r0.w);
            r0.w = r0.w * l(10.000000);
            r0.w = (uint)r0.w;
            r0.w = r0.w + l(10);
            // asm: udiv null, r0.z, r0.z, r0.w
            // asm: mad_sat r0.w, cb0[10].x, l(0.166667), l(-1.333333)
            r0.w = -r0.w + l(1.000000);
            r0.x = r0.w * r0.x;
            // asm: mad_sat r0.w, |r2.y|, l(3.333333), l(-1.666667)
            // asm: ld_indexable(buffer)(uint,uint,uint,uint) r1.x, cb0[13].yyyy, t1.xyzw
            r1.x = (r1.x < l(5000));
            r1.x = r1.x & l(0x3f800000);
            r0.w = r0.w * r1.x;
            r0.x = r0.w * r0.x;
            r0.x = (r0.z) ? l(0) : r0.x;
            r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
            r0.z = r0.y ^ l(61);
            r0.y = r0.y >> l(16);
            r0.y = r0.y ^ r0.z;
            null = r0.y * r0.y;
            r0.z = r0.y >> l(4);
            r0.y = r0.z ^ r0.y;
            null = r0.y * r0.y;
            r0.z = r0.y >> l(15);
            r0.y = r0.z ^ r0.y;
            r0.z = (float)r0.y;
            r0.z = r0.z * l(0.000000);
            r0.x = (r0.z < r0.x);
            if (r0.x) {
                // asm: imm_atomic_iadd r1.x, u0, l(1), l(1)
                r0.x = (r1.x >= l(0x00080000));
                if (r0.x) {
                    // asm: imm_atomic_iadd r1.x, u0, l(1), l(-1)
                }
                if (!(r0.x)) {
                    r0.x = dot(cb0[3].xyzx, cb0[3].xyzx);
                    r0.x = rsqrt(r0.x);
                    r0.xzw = r0.xxxx * cb0[3].xxyz;
                    r0.xzw = r0.xxzw * cb0[10].xxxx;
                    r0.xzw = r0.xxzw * l(0.066667, 0.000000, 0.066667, 0.066667);
                    r2.xyz = (r2.xyzx * l(0.070000, 0.070000, 0.070000, 0.000000)) + r0.xzwx;
                    // asm: imm_atomic_iadd r4.x, u1, l(0), l(-1)
                    // asm: ld_uav_typed_indexable(buffer)(uint,uint,uint,uint) r0.x, r4.xxxx, u1.xyzw
                    r0.z = r1.x + l(0x00080000);
                    r0.z = (cb1[131].z) ? r1.x : r0.z;
                    store_uav_typed(u3.xyzw, r0.zzzz, r0.xxxx);
                    // asm: bfi r3.w, l(11), l(0), cb0[13].y, r0.y
                    store_structured(u2.xyzw, r0.x, l(0), r3.xyzw);
                    r2.w = l(1.000000);
                    store_structured(u2.xyzw, r0.x, l(16), r2.xyzw);
                }
            }
        }
    }
    return;
    // asm: // Approximately 358 instruction slots used
}

// -----------------------------------------------------------------------------
// Shader 1
// Profile: cs_5_0
// Byte offset: 44372
// Byte length: 41928
// -----------------------------------------------------------------------------

// Reflected buffer definitions
cbuffer $Globals
{
  bool g_isTAAEnabledBranch;         // Offset:    0 Size:     4 [unused]
     = 0xffffffff 
  uint g_numRenderSets;              // Offset:    4 Size:     4 [unused]
  row_major float4x4 g_shipUnwrapperWorld;// Offset:   16 Size:    64
  row_major float4x4 g_shipWorldInv; // Offset:   80 Size:    64 [unused]
  float4 g_shipSize;                 // Offset:  144 Size:    16
  float g_shipSpeed;                 // Offset:  160 Size:     4
  float g_shipMovementForward;       // Offset:  164 Size:     4
  float4 g_textureSize;              // Offset:  176 Size:    16
  float g_rainAmount;                // Offset:  192 Size:     4
  float g_shipFoamSpawnMinDistMult;  // Offset:  196 Size:     4
  uint g_vfxIDShipRaindrop;          // Offset:  200 Size:     4
  uint g_vfxIDShipFoam;              // Offset:  204 Size:     4
  uint g_vfxIDShipTopWave;           // Offset:  208 Size:     4 [unused]
  uint g_vfxIDUnderwaterBubbles;     // Offset:  212 Size:     4 [unused]
  bool g_isShipSubmarine;            // Offset:  216 Size:     4
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
  float g_time;                      // Offset: 2048 Size:     4 [unused]
     = 0x00000000 
  float g_timePrev;                  // Offset: 2052 Size:     4 [unused]
     = 0x00000000 
  float g_deltaTime;                 // Offset: 2056 Size:     4
     = 0x00000000 
  float g_timeFromMapStart;          // Offset: 2060 Size:     4 [unused]
     = 0x00000000 
  uint g_frameIdx;                   // Offset: 2064 Size:     4
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
  bool g_gpuVfxAccessPong;           // Offset: 2104 Size:     4
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
  row_major float4x4 g_invView;      // Offset:  320 Size:    64
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
  row_major float4x4 g_cameraDirs;   // Offset:  512 Size:    64 [unused]
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
Resource bind info for g_gpuVfxParticlesUAV
{
  struct GPUParticleData
  {
      float3 position;               // Offset:    0
      uint vfxHashID;                // Offset:   12
      float3 velocity;               // Offset:   16
      float linearAge;               // Offset:   28
  } $Element;                        // Offset:    0 Size:    32
}

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// g_bilinearClampSampler            sampler      NA          NA             s0      1 
// g_bilinearWrapSampler             sampler      NA          NA             s1      1 
// g_RTLinearSampler                 sampler      NA          NA             s2      1 
// g_RTPointSampler                  sampler      NA          NA             s3      1 
// g_depthTexSampler                 sampler      NA          NA             s4      1 
// g_depthTex                        texture  float4          2d             t0      1 
// g_normalsTexture                  texture  float4          2d             t1      1 
// g_gpuVfxPerVfxCountersSRV         texture    uint         buf             t2      1 
// g_wave0DispTexture                texture  float4          2d             t3      1 
// g_wave1DispTexture                texture  float4          2d             t4      1 
// g_variationTexture                texture  float4          2d             t5      1 
// g_spaceVariationTexture           texture  float4          2d             t6      1 
// g_waterDeformTexture              texture  float4          2d             t7      1 
// g_shipUnwrapperDepth              texture  float4          2d             t8      1 
// g_prevShipWetnessTexture          texture  float4          2d             t9      1 
// g_gpuVfxGlobalCountersUAV             UAV    uint         buf             u0      1 
// g_gpuVfxDeadIndirectionUAV            UAV    uint         buf             u1      1 
// g_gpuVfxParticlesUAV                  UAV  struct         r/w             u2      1 
// g_gpuVfxParticlesIndirectionUAV        UAV    uint         buf             u3      1 
// g_sideWetnessTextureUAV               UAV   float          2d             u4      1 
// $Globals                          cbuffer      NA          NA            cb0      1 
// PerFrame                          cbuffer      NA          NA            cb1      1 
// PerView                           cbuffer      NA          NA            cb2      1

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
    // dcl_constantbuffer CB0[14], immediateIndexed
    // dcl_constantbuffer CB1[132], immediateIndexed
    // dcl_constantbuffer CB2[37], immediateIndexed
    // dcl_sampler s0, mode_default
    // dcl_sampler s1, mode_default
    // dcl_sampler s2, mode_default
    // dcl_sampler s3, mode_default
    // dcl_sampler s4, mode_default
    // dcl_resource_texture2d (float,float,float,float) t0
    // dcl_resource_texture2d (float,float,float,float) t1
    // dcl_resource_buffer (uint,uint,uint,uint) t2
    // dcl_resource_texture2d (float,float,float,float) t3
    // dcl_resource_texture2d (float,float,float,float) t4
    // dcl_resource_texture2d (float,float,float,float) t5
    // dcl_resource_texture2d (float,float,float,float) t6
    // dcl_resource_texture2d (float,float,float,float) t7
    // dcl_resource_texture2d (float,float,float,float) t8
    // dcl_resource_texture2d (float,float,float,float) t9
    // dcl_uav_typed_buffer (uint,uint,uint,uint) u0
    // dcl_uav_typed_buffer (uint,uint,uint,uint) u1
    // dcl_uav_structured u2, 32
    // dcl_uav_typed_buffer (uint,uint,uint,uint) u3
    // dcl_uav_typed_texture2d (float,float,float,float) u4
    // dcl_input vThreadID.xy
    float4 r[10];
    // numthreads(16, 16, 1)
    r0.xy = vThreadID.xyxx;
    r0.zw = l(0,0,0,0);
    // asm: ld_indexable(texture2d)(float,float,float,float) r1.xyzw, r0.xyww, t8.xyzw
    r1.w = (r1.w < l(0.000010));
    if (r1.w) {
        return;
    }
    r2.xy = (uint)cb0[11].xyxx;
    r3.xyz = r1.yyyy * cb0[2].xzyx;
    r3.xyz = (r1.xxxx * cb0[1].xzyx) + r3.xyzx;
    r3.xyz = (r1.zzzz * cb0[3].xzyx) + r3.xyzx;
    r3.xyz = r3.xyzx + cb0[4].xzyx;
    // asm: mad_sat r1.w, cb1[131].y, l(2.000000), l(-1.000000)
    r2.z = -cb1[58].z + cb2[36].y;
    r2.w = (-cb1[61].x * cb1[61].w) + cb1[61].x;
    r2.w = l(1.000000, 1.000000, 1.000000, 1.000000) / r2.w;
    // asm: mad_sat r2.z, |r2.z|, l(0.003333), l(-0.100000)
    r3.w = -cb1[60].w + l(1.000000);
    r4.xy = r3.xyxx;
    r4.z = l(0);
    while (true) {
        r4.w = (r4.z >= l(2));
        if (r4.w) { break; }
        r5.xy = -r4.xyxx + cb2[36].xzxx;
        r4.w = dot2(r5.xyxx, r5.xyxx);
        r4.w = sqrt(r4.w);
        r5.xy = r4.xyxx * cb1[61].yyyy;
        r5.xy = r5.xyxx * l(0.001000, 0.001000, 0.000000, 0.000000);
        // asm: sample_l_indexable(texture2d)(float,float,float,float) r5.x, r5.xyxx, t5.xyzw, s1, l(1.000000)
        // asm: add_sat r5.x, r5.x, cb1[59].w
        r5.y = (-cb1[61].x * cb1[61].w) + r5.x;
        // asm: mul_sat r5.y, r2.w, r5.y
        r5.z = (r5.y * l(-2.000000)) + l(3.000000);
        r5.y = r5.y * r5.y;
        r5.y = (r5.z * r5.y) + r2.z;
        // asm: mad_sat r4.w, r4.w, l(0.005000), l(-2.000000)
        r4.w = (r1.w * r4.w) + r5.y;
        r4.w = min(r4.w, l(1.000000));
        r4.w = (r4.w * r3.w) + cb1[60].w;
        r5.x = log2(r5.x);
        r4.w = r4.w * r5.x;
        r4.w = exp2(r4.w);
        r5.xy = (r4.xyxx * cb1[124].xyxx) + cb1[124].zwzz;
        r5.zw = (r5.xxxy >= l(0.000000, 0.000000, 0.000000, 0.000000));
        r6.xy = (l(1.000000, 1.000000, 0.000000, 0.000000) >= r5.xyxx);
        r5.z = r5.z & r6.x;
        r5.z = r5.w & r5.z;
        r5.z = r6.y & r5.z;
        if (r5.z) {
            // asm: sample_l_indexable(texture2d)(float,float,float,float) r5.x, r5.xyxx, t6.xyzw, s0, l(0.000000)
        else
            r5.x = l(1.000000);
        }
        r4.w = r4.w * r5.x;
        r5.xyzw = (r4.xyxy * cb1[59].xxyy) + cb1[60].xxyy;
        // asm: sample_l_indexable(texture2d)(float,float,float,float) r5.xy, r5.xyxx, t3.yzxw, s1, l(1.000000)
        r4.w = r4.w * l(0.066667);
        // asm: sample_l_indexable(texture2d)(float,float,float,float) r5.zw, r5.zwzz, t4.xwyz, s1, l(1.000000)
        r5.zw = r4.wwww * r5.zzzw;
        r5.xy = (r5.xyxx * r4.wwww) + r5.zwzz;
        r5.xy = r4.xyxx + r5.xyxx;
        r5.xy = -r3.xyxx + r5.xyxx;
        r4.xy = r4.xyxx + -r5.xyxx;
        r4.z = r4.z + l(1);
    }
    r4.xyzw = r4.xyxy;
    r5.xy = -r4.zwzz + cb2[36].xzxx;
    r5.x = dot2(r5.xyxx, r5.xyxx);
    r5.x = sqrt(r5.x);
    r5.yz = r4.zzwz * cb1[61].yyyy;
    r5.yz = r5.yyzy * l(0.000000, 0.001000, 0.001000, 0.000000);
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r5.y, r5.yzyy, t5.yxzw, s1, l(1.000000)
    // asm: add_sat r5.y, r5.y, cb1[59].w
    r5.z = (-cb1[61].x * cb1[61].w) + r5.y;
    // asm: mul_sat r2.w, r2.w, r5.z
    r5.z = (r2.w * l(-2.000000)) + l(3.000000);
    r2.w = r2.w * r2.w;
    r2.z = (r5.z * r2.w) + r2.z;
    // asm: mad_sat r2.w, r5.x, l(0.005000), l(-2.000000)
    r1.w = (r1.w * r2.w) + r2.z;
    r1.w = min(r1.w, l(1.000000));
    r1.w = (r1.w * r3.w) + cb1[60].w;
    r2.z = log2(r5.y);
    r1.w = r1.w * r2.z;
    r1.w = exp2(r1.w);
    r2.zw = (r4.zzzw * cb1[124].xxxy) + cb1[124].zzzw;
    r5.xy = (r2.zwzz >= l(0.000000, 0.000000, 0.000000, 0.000000));
    r5.zw = (l(0.000000, 0.000000, 1.000000, 1.000000) >= r2.zzzw);
    r3.w = r5.z & r5.x;
    r3.w = r5.y & r3.w;
    r3.w = r5.w & r3.w;
    if (r3.w) {
        // asm: sample_l_indexable(texture2d)(float,float,float,float) r2.z, r2.zwzz, t6.yzxw, s0, l(0.000000)
    else
        r2.z = l(1.000000);
    }
    r1.w = r1.w * r2.z;
    r4.xyzw = (r4.xyzw * cb1[59].xxyy) + cb1[60].xxyy;
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r2.z, r4.xyxx, t3.yzxw, s1, l(1.000000)
    r1.w = r1.w * l(0.066667);
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r2.w, r4.zwzz, t4.yzwx, s1, l(1.000000)
    r2.w = r1.w * r2.w;
    r1.w = (r2.z * r1.w) + r2.w;
    r4.xyz = cb1[58].zzzz * cb2[1].xywx;
    r4.xyz = (r3.xxxx * cb2[0].xywx) + r4.xyzx;
    r3.xyw = (r3.yyyy * cb2[2].xyxw) + r4.xyxz;
    r3.xyw = r3.xyxw + cb2[3].xyxw;
    r2.zw = r3.xxxy / r3.wwww;
    r2.zw = (r2.zzzw * l(0.000000, 0.000000, 0.400000, -0.400000)) + l(0.000000, 0.000000, 0.500000, 0.500000);
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r2.z, r2.zwzz, t7.xzyw, s2, l(0.000000)
    r1.w = (r2.z * cb1[62].x) + r1.w;
    r3.y = vThreadID.y + l(-1);
    r3.x = vThreadID.x;
    // asm: umin r4.xy, r2.xyxx, r3.xyxx
    r2.z = min(cb1[128].z, l(0.040000));
    // asm: ld_indexable(texture2d)(float,float,float,float) r0.x, r0.xyzw, t9.xyzw
    r4.zw = l(0,0,0,0);
    // asm: ld_indexable(texture2d)(float,float,float,float) r0.y, r4.xyww, t9.yxzw
    // asm: ld_indexable(texture2d)(float,float,float,float) r4.xyzw, r4.xyzw, t8.xyzw
    r0.z = r4.y * cb0[2].y;
    r0.z = (r4.x * cb0[1].y) + r0.z;
    r0.z = (r4.z * cb0[3].y) + r0.z;
    r0.z = r0.z + cb0[4].y;
    r3.xy = r1.xzxx * l(100.000000, 100.000000, 0.000000, 0.000000);
    r5.zw = floor(r3.xxxy);
    r4.xy = (r1.xzxx * l(100.000000, 100.000000, 0.000000, 0.000000)) + l(1.000000, 1.000000, 0.000000, 0.000000);
    r5.xy = floor(r4.xyxx);
    r3.xy = frac(r3.xyxx);
    r4.xy = r3.xyxx * r3.xyxx;
    r3.xy = (-r3.xyxx * l(2.000000, 2.000000, 0.000000, 0.000000)) + l(3.000000, 3.000000, 0.000000, 0.000000);
    r3.xy = r3.xyxx * r4.xyxx;
    r0.w = dot2(r5.zwzz, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r0.w, null, r0.w);
    r0.w = r0.w * l(43758.546875);
    r0.w = frac(r0.w);
    r2.w = dot2(r5.xwxx, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r2.w, null, r2.w);
    r2.w = r2.w * l(43758.546875);
    r2.w = frac(r2.w);
    r2.w = -r0.w + r2.w;
    r0.w = (r3.x * r2.w) + r0.w;
    r2.w = dot2(r5.zyzz, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r2.w, null, r2.w);
    r2.w = r2.w * l(43758.546875);
    r2.w = frac(r2.w);
    r3.w = dot2(r5.xyxx, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r3.w, null, r3.w);
    r3.w = r3.w * l(43758.546875);
    r3.w = frac(r3.w);
    r3.w = -r2.w + r3.w;
    r2.w = (r3.x * r3.w) + r2.w;
    r2.w = -r0.w + r2.w;
    r0.w = (r3.y * r2.w) + r0.w;
    r0.w = r0.w * r0.w;
    r0.z = -r3.z + r0.z;
    r3.xy = (r0.wwww * l(60.000000, 3.000000, 0.000000, 0.000000)) + l(100.000000, 2.500000, 0.000000, 0.000000);
    r0.z = |r0.z| * r3.x;
    r3.xw = r0.xxxx + l(-0.050000, 0.000000, 0.000000, -0.200000);
    // asm: mul_sat r3.xw, r3.xxxw, l(1.333333, 0.000000, 0.000000, 1.666667)
    r4.xy = (r3.xwxx * l(-2.000000, -2.000000, 0.000000, 0.000000)) + l(3.000000, 3.000000, 0.000000, 0.000000);
    r3.xw = r3.xxxw * r3.xxxw;
    r3.xw = r3.xxxw * r4.xxxy;
    r4.xy = (r3.xwxx * l(4.000000, 1.500000, 0.000000, 0.000000)) + l(1.000000, 0.500000, 0.000000, 0.000000);
    r2.w = r2.z * r4.x;
    r0.z = (-r2.w * r0.z) + l(1.000000);
    r2.w = -r0.z + l(1.000000);
    r0.y = r0.y * r2.w;
    r2.w = (l(0.001000) < r4.w);
    r2.w = r2.w & l(0x3f800000);
    r0.y = r0.y * r2.w;
    r0.y = (r0.x * r0.z) + r0.y;
    r0.x = (l(0.000000) < r0.x);
    r0.z = max(r0.y, l(0.080000));
    r0.x = (r0.x) ? r0.z : r0.y;
    r0.y = r2.z * r3.w;
    r0.y = r0.y * l(0.500000);
    r0.z = (r0.w * r4.y) + l(1.000000);
    r0.y = (-r0.y * r0.z) + l(1.000000);
    r0.y = max(r0.y, l(0.000000));
    r0.z = r3.z + l(-0.004000);
    r0.z = (r1.w < r0.z);
    r2.z = (-r2.z * r3.y) + l(1.000000);
    r0.z = (r0.z) ? l(0) : r2.z;
    // asm: mad_sat r0.x, r0.x, r0.y, r0.z
    store_uav_typed(u4.xyzw, vThreadID.xyyy, r0.xxxx);
    r0.x = min(r0.w, l(1.000000));
    r0.y = (vThreadID.y * r2.x) + vThreadID.x;
    null = r0.z * r2.y;
    r0.w = cb1[129].x & l(63);
    r0.y = (r0.z * r0.w) + r0.y;
    r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
    r0.z = r0.y ^ l(61);
    r0.y = r0.y >> l(16);
    r0.y = r0.y ^ r0.z;
    null = r0.y * r0.y;
    r0.z = r0.y >> l(4);
    r0.y = r0.z ^ r0.y;
    null = r0.y * r0.y;
    r0.z = r0.y >> l(15);
    r0.y = r0.z ^ r0.y;
    r0.z = cb0[9].w * cb0[9].z;
    r0.w = r0.z * l(0.108069);
    r0.z = (l(27.759930) < r0.z);
    // asm: bfi r0.z, l(1), l(1), r0.z, l(0)
    r0.z = r0.z + l(6);
    r0.z = (float)r0.z;
    r0.x = log2(r0.x);
    r0.x = r0.x * r0.z;
    r0.x = exp2(r0.x);
    // asm: mad_sat r0.z, cb0[10].x, l(0.142857), l(-0.142857)
    r0.z = (r0.z * l(0.020000)) + l(0.024000);
    r2.x = -r1.w + r3.z;
    r0.z = (|r2.x| < r0.z);
    r2.x = (l(0.000000) < cb0[12].x);
    r2.x = (r2.x) ? l(0.200000) : l(100.199997);
    r2.x = (r2.x < |r1.w|);
    r0.z = r0.z | r2.x;
    r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
    r2.x = r0.y ^ l(61);
    r0.y = r0.y >> l(16);
    r0.y = r0.y ^ r2.x;
    null = r0.y * r0.y;
    r2.x = r0.y >> l(4);
    r0.y = r0.y ^ r2.x;
    null = r0.y * r0.y;
    r2.x = r0.y >> l(15);
    r0.y = r0.y ^ r2.x;
    r2.x = (float)r0.y;
    r2.x = r2.x * l(0.000000);
    // asm: mov_sat r2.y, r0.w
    r0.x = r0.x * r2.y;
    r0.x = (r2.x < r0.x);
    r0.x = r0.x & r0.z;
    r0.z = r1.w + l(0.020000);
    r0.z = (r3.z < r0.z);
    r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
    r2.x = r0.y ^ l(61);
    r0.y = r0.y >> l(16);
    r0.y = r0.y ^ r2.x;
    null = r0.y * r0.y;
    r2.x = r0.y >> l(4);
    r0.y = r0.y ^ r2.x;
    null = r0.y * r0.y;
    r2.x = r0.y >> l(15);
    r0.y = r0.y ^ r2.x;
    r2.x = (float)r0.y;
    r2.x = r2.x * l(0.000000);
    r2.x = (r2.x < r2.y);
    r0.z = r0.z & r2.x;
    r2.x = (cb0[9].y * l(0.900000)) + r1.w;
    r2.x = (r3.z < r2.x);
    r2.y = r0.z | r0.x;
    r2.x = r2.y & r2.x;
    if (r2.x) {
        r2.xy = cb0[9].wwww * l(0.500000, 0.980000, 0.000000, 0.000000);
        r2.x = r1.z / r2.x;
        // asm: mad_sat r2.x, r2.x, l(0.500000), l(0.500000)
        r2.zw = cb0[9].zzzw * cb0[11].zzzw;
        r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
        r3.x = r0.y ^ l(61);
        r0.y = r0.y >> l(16);
        r0.y = r0.y ^ r3.x;
        null = r0.y * r0.y;
        r3.x = r0.y >> l(4);
        r0.y = r0.y ^ r3.x;
        null = r0.y * r0.y;
        r3.x = r0.y >> l(15);
        r0.y = r0.y ^ r3.x;
        r3.xy = (cb0[13].zzzz) ? l(0.000100,0.700000,0,0) : l(0.010000,0.800000,0,0);
        r3.z = l(0);
        r3.xzw = r1.xxyz + r3.zzxz;
        r4.xyz = r3.zzzz * cb0[2].xyzx;
        r4.xyz = (r3.xxxx * cb0[1].xyzx) + r4.xyzx;
        r4.xyz = (r3.wwww * cb0[3].xyzx) + r4.xyzx;
        r4.xyz = r4.xyzx + cb0[4].xyzx;
        r5.xyz = r4.yyyy * cb2[1].xywx;
        r4.xyw = (r4.xxxx * cb2[0].xyxw) + r5.xyxz;
        r4.xyz = (r4.zzzz * cb2[2].xywx) + r4.xywx;
        r4.xyz = r4.xyzx + cb2[3].xywx;
        r1.yz = r4.xxyx / r4.zzzz;
        r5.xy = (r1.yzyy * l(0.500000, 0.500000, 0.000000, 0.000000)) + l(0.500000, 0.500000, 0.000000, 0.000000);
        r5.z = -r5.y + l(1.000000);
        // asm: sample_l_indexable(texture2d)(float,float,float,float) r1.y, r5.xzxx, t0.yxzw, s4, l(0.000000)
        r1.y = r1.y + -cb2[26].z;
        r1.y = cb2[27].z / r1.y;
        r1.y = -r1.y + r4.z;
        r1.yz = (l(0.000000, 0.200000, 0.010000, 0.000000) < |r1.yyyy|);
        // asm: sample_l_indexable(texture2d)(float,float,float,float) r4.xy, r5.xzxx, t1.xyzw, s3, l(0.000000)
        r4.xy = (r4.xyxx * l(2.000000, 2.000000, 0.000000, 0.000000)) + l(-1.000000, -1.000000, 0.000000, 0.000000);
        r5.xyz = -|r4.xyxx| + l(1.000000, 1.000000, 1.000000, 0.000000);
        r6.z = -|r4.y| + r5.x;
        r4.z = (r6.z >= l(0.000000));
        r5.xw = (r4.xxxy >= l(0.000000, 0.000000, 0.000000, 0.000000));
        r5.xw = (r5.xxxw) ? l(1.000000,0,0,1.000000) : l(-1.000000,0,0,-1.000000);
        r5.xy = r5.xwxx * r5.yzyy;
        r6.xy = (r4.zzzz) ? r4.xyxx : r5.xyxx;
        r4.x = dot(r6.xyzx, r6.xyzx);
        r4.x = rsqrt(r4.x);
        r4.x = r4.x * r6.y;
        // asm: mad_sat r4.x, r4.x, l(3.333333), l(-1.000000)
        r4.x = r4.x * l(0.400000);
        r1.y = (r1.y) ? l(0) : r4.x;
        r4.x = dot(cb0[3].xyzx, cb0[3].xyzx);
        r4.x = rsqrt(r4.x);
        r4.xyz = r4.xxxx * cb0[3].xyzx;
        r4.w = r4.y * cb0[9].w;
        r4.w = (r4.w * l(0.500000)) + cb0[4].y;
        r5.x = r4.w + cb0[9].x;
        r5.x = (cb0[9].y * l(0.500000)) + r5.x;
        r5.y = max(r0.w, l(0.700000));
        r5.y = min(r5.y, l(1.000000));
        r5.z = cb0[10].x + l(-1.000000);
        // asm: mul_sat r5.z, r5.z, l(0.058824)
        r5.w = (r5.z * l(-2.000000)) + l(3.000000);
        r5.z = r5.z * r5.z;
        r5.z = r5.z * r5.w;
        r5.w = (l(0.000000) < cb0[10].y);
        r5.w = r5.w & l(0x3f800000);
        r5.z = r5.w * r5.z;
        r5.w = (l(0.001000) >= cb0[12].y);
        r3.y = (-r3.y * cb0[9].w) + r2.y;
        r3.y = min(r3.y, l(2.500000));
        r3.y = (cb0[9].w * l(0.980000)) + -r3.y;
        r6.x = r2.x * cb0[9].w;
        r6.y = (cb0[9].w * l(0.980000)) + -r3.y;
        r6.z = (r2.x * cb0[9].w) + -r3.y;
        r6.y = l(1.000000, 1.000000, 1.000000, 1.000000) / r6.y;
        // asm: mul_sat r6.y, r6.y, r6.z
        r6.z = (r6.y * l(-2.000000)) + l(3.000000);
        r6.y = r6.y * r6.y;
        r7.y = r6.y * r6.z;
        r3.y = (r3.y < r6.x);
        r3.y = r3.y & l(0x3f800000);
        r2.y = (r6.x < r2.y);
        r2.y = r2.y & l(0x3f800000);
        r2.y = r2.y * r3.y;
        r7.x = r2.y * r5.y;
        r6.xyz = r2.xxxx + l(0.300000, -0.900000, -0.930000, 0.000000);
        r6.xyz = r6.yzxy * l(49.999897, 50.000050, 0.781250, 0.000000);
        r2.y = min(r6.z, l(1.000000));
        r3.y = (r2.y * l(-2.000000)) + l(3.000000);
        r2.y = r2.y * r2.y;
        r8.y = r2.y * r3.y;
        r2.x = (r2.x < l(0.980000));
        r2.x = r2.x & l(0x3f800000);
        r8.x = r2.x * r5.y;
        r2.xy = (r5.wwww) ? r8.xyxx : r7.xyxx;
        r3.y = (r2.y * l(0.200000)) + l(0.100000);
        // asm: mov_sat r6.xy, r6.xyxx
        r6.zw = (r6.xxxy * l(0.000000, 0.000000, -2.000000, -2.000000)) + l(0.000000, 0.000000, 3.000000, 3.000000);
        r6.xy = r6.xyxx * r6.xyxx;
        r5.y = r6.x * r6.z;
        r5.y = r5.y * l(0.700000);
        r6.x = (-r6.w * r6.y) + l(1.000000);
        r3.y = (r5.y * r6.x) + r3.y;
        r2.x = r2.x * r3.y;
        r3.y = r5.z * r5.z;
        r2.x = r2.x * r3.y;
        r3.y = (r2.y * l(-0.025000)) + r4.w;
        r3.y = r3.y + l(0.015000);
        r3.y = r1.w + -r3.y;
        r4.w = (cb0[9].y * l(0.090000)) + l(-0.001000);
        r4.w = l(1.000000, 1.000000, 1.000000, 1.000000) / r4.w;
        r5.y = r4.w * l(-0.001000);
        // asm: mad_sat r3.y, r3.y, r4.w, r5.y
        r2.x = r2.x * r3.y;
        r4.w = (r1.z) ? l(0.400000) : l(1.000000);
        r2.x = r2.x * r4.w;
        r4.w = (cb0[13].z != l(0));
        r5.x = -r1.w + r5.x;
        r5.x = (r5.x < l(-0.005000));
        r4.w = r4.w & r5.x;
        r2.x = (r4.w) ? l(0) : r2.x;
        // asm: ld_indexable(buffer)(uint,uint,uint,uint) r4.w, cb0[12].zzzz, t2.yzwx
        r5.x = (r5.w) ? l(5000) : l(0x00007530);
        r4.w = (r4.w < r5.x);
        r0.x = r0.x & r4.w;
        r4.w = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
        r5.x = r4.w ^ l(61);
        r4.w = r4.w >> l(16);
        r4.w = r4.w ^ r5.x;
        null = r4.w * r4.w;
        r5.x = r4.w >> l(4);
        r4.w = r4.w ^ r5.x;
        null = r4.w * r4.w;
        r5.x = r4.w >> l(15);
        r4.w = r4.w ^ r5.x;
        r5.x = (float)r4.w;
        r5.x = r5.x * l(0.000000);
        r1.y = (r5.x < r1.y);
        r0.x = r0.x & r1.y;
        if (r0.x) {
            r0.x = (uint)r0.w;
            // asm: umax r0.x, r0.x, l(1)
            // asm: umin r0.x, r0.x, l(8)
            r0.y = (float)r0.y;
            r0.w = r0.y * l(-0.000000);
            r5.xy = (r0.yyyy < l(1717986944.000000, 2147483648.000000, 0.000000, 0.000000));
            r5.xy = r5.xyxx & l(0x3f800000, 0x3f800000, 0, 0);
            r6.y = (r0.w * r5.x) + l(-0.050000);
            // asm: mov_sat r0.y, r1.w
            r0.yw = r0.yyyy * cb1[58].xxxy;
            r6.xz = r5.yyyy * r0.yywy;
            if (r0.x) {
                r0.y = (l(0x0019660d) * r4.w) + l(0x3c6ef35f);
                r0.w = r0.y ^ l(61);
                r0.y = r0.y >> l(16);
                r0.y = r0.y ^ r0.w;
                null = r0.y * r0.y;
                r0.w = r0.y >> l(4);
                r0.y = r0.w ^ r0.y;
                null = r0.y * r0.y;
                r0.w = r0.y >> l(15);
                r0.y = r0.w ^ r0.y;
                r0.w = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
                r1.y = r0.w ^ l(61);
                r0.w = r0.w >> l(16);
                r0.w = r0.w ^ r1.y;
                null = r0.w * r0.w;
                r1.y = r0.w >> l(4);
                r0.w = r0.w ^ r1.y;
                null = r0.w * r0.w;
                r1.y = r0.w >> l(15);
                r4.w = r0.w ^ r1.y;
                // asm: imm_atomic_iadd r7.x, u0, l(1), l(1)
                r0.w = (r7.x >= l(0x00080000));
                if (r0.w) {
                    // asm: imm_atomic_iadd r7.x, u0, l(1), l(-1)
                }
                if (!(r0.w)) {
                    r7.y = (float)r0.y;
                    r7.z = (float)r4.w;
                    r0.yw = (r7.yyyz * l(0.000000, 0.000000, 0.000000, 0.000000)) + l(0.000000, -1.000000, 0.000000, -1.000000);
                    r8.yz = r2.zzwz * r0.yywy;
                    r0.y = min(|r8.y|, l(0.080000));
                    r0.w = (r8.y < l(0.000000));
                    r0.w = (r0.w) ? l(-1.000000) : l(1.000000);
                    r8.x = r0.w * r0.y;
                    r8.w = l(0);
                    r7.yzw = r3.xxzw + r8.xxwz;
                    r8.xyz = r7.zzzz * cb0[2].xyzx;
                    r8.xyz = (r7.yyyy * cb0[1].xyzx) + r8.xyzx;
                    r7.yzw = (r7.wwww * cb0[3].xxyz) + r8.xxyz;
                    r8.xyz = r7.yzwy + cb0[4].xyzx;
                    // asm: imm_atomic_iadd r9.x, u1, l(0), l(-1)
                    // asm: ld_uav_typed_indexable(buffer)(uint,uint,uint,uint) r0.y, r9.xxxx, u1.yxzw
                    r0.w = r7.x + l(0x00080000);
                    r0.w = (cb1[131].z) ? r7.x : r0.w;
                    store_uav_typed(u3.xyzw, r0.wwww, r0.yyyy);
                    // asm: bfi r8.w, l(11), l(0), cb0[12].z, r4.w
                    store_structured(u2.xyzw, r0.y, l(0), r8.xyzw);
                    r6.w = l(1.000000);
                    store_structured(u2.xyzw, r0.y, l(16), r6.xyzw);
                }
                r0.y = l(1);
            else
                r0.y = l(0);
            }
            r0.w = (r0.y < r0.x);
            if (r0.w) {
                r1.y = (l(0x0019660d) * r4.w) + l(0x3c6ef35f);
                r5.x = r1.y ^ l(61);
                r1.y = r1.y >> l(16);
                r1.y = r1.y ^ r5.x;
                null = r1.y * r1.y;
                r5.x = r1.y >> l(4);
                r1.y = r1.y ^ r5.x;
                null = r1.y * r1.y;
                r5.x = r1.y >> l(15);
                r1.y = r1.y ^ r5.x;
                r5.x = (l(0x0019660d) * r1.y) + l(0x3c6ef35f);
                r5.y = r5.x ^ l(61);
                r5.x = r5.x >> l(16);
                r5.x = r5.x ^ r5.y;
                null = r5.x * r5.x;
                r5.y = r5.x >> l(4);
                r5.x = r5.y ^ r5.x;
                null = r5.x * r5.x;
                r5.y = r5.x >> l(15);
                r4.w = r5.y ^ r5.x;
                // asm: imm_atomic_iadd r7.x, u0, l(1), l(1)
                r5.x = (r7.x >= l(0x00080000));
                if (r5.x) {
                    // asm: imm_atomic_iadd r7.x, u0, l(1), l(-1)
                }
                if (!(r5.x)) {
                    r7.y = (float)r1.y;
                    r7.z = (float)r4.w;
                    r5.xy = (r7.yzyy * l(0.000000, 0.000000, 0.000000, 0.000000)) + l(-1.000000, -1.000000, 0.000000, 0.000000);
                    r8.yz = r2.zzwz * r5.xxyx;
                    r1.y = min(|r8.y|, l(0.080000));
                    r5.x = (r8.y < l(0.000000));
                    r5.x = (r5.x) ? l(-1.000000) : l(1.000000);
                    r8.x = r1.y * r5.x;
                    r8.w = l(0);
                    r7.yzw = r3.xxzw + r8.xxwz;
                    r8.xyz = r7.zzzz * cb0[2].xyzx;
                    r8.xyz = (r7.yyyy * cb0[1].xyzx) + r8.xyzx;
                    r7.yzw = (r7.wwww * cb0[3].xxyz) + r8.xxyz;
                    r8.xyz = r7.yzwy + cb0[4].xyzx;
                    // asm: imm_atomic_iadd r9.x, u1, l(0), l(-1)
                    // asm: ld_uav_typed_indexable(buffer)(uint,uint,uint,uint) r1.y, r9.xxxx, u1.yxzw
                    r5.x = r7.x + l(0x00080000);
                    r5.x = (cb1[131].z) ? r7.x : r5.x;
                    store_uav_typed(u3.xyzw, r5.xxxx, r1.yyyy);
                    // asm: bfi r8.w, l(11), l(0), cb0[12].z, r4.w
                    store_structured(u2.xyzw, r1.y, l(0), r8.xyzw);
                    r6.w = l(1.000000);
                    store_structured(u2.xyzw, r1.y, l(16), r6.xyzw);
                }
                r0.y = l(2);
            }
            r1.y = (r0.y < r0.x);
            r0.w = r0.w & r1.y;
            if (r0.w) {
                r1.y = (l(0x0019660d) * r4.w) + l(0x3c6ef35f);
                r5.x = r1.y ^ l(61);
                r1.y = r1.y >> l(16);
                r1.y = r1.y ^ r5.x;
                null = r1.y * r1.y;
                r5.x = r1.y >> l(4);
                r1.y = r1.y ^ r5.x;
                null = r1.y * r1.y;
                r5.x = r1.y >> l(15);
                r1.y = r1.y ^ r5.x;
                r5.x = (l(0x0019660d) * r1.y) + l(0x3c6ef35f);
                r5.y = r5.x ^ l(61);
                r5.x = r5.x >> l(16);
                r5.x = r5.x ^ r5.y;
                null = r5.x * r5.x;
                r5.y = r5.x >> l(4);
                r5.x = r5.y ^ r5.x;
                null = r5.x * r5.x;
                r5.y = r5.x >> l(15);
                r4.w = r5.y ^ r5.x;
                // asm: imm_atomic_iadd r7.x, u0, l(1), l(1)
                r5.x = (r7.x >= l(0x00080000));
                if (r5.x) {
                    // asm: imm_atomic_iadd r7.x, u0, l(1), l(-1)
                }
                if (!(r5.x)) {
                    r7.y = (float)r1.y;
                    r7.z = (float)r4.w;
                    r5.xy = (r7.yzyy * l(0.000000, 0.000000, 0.000000, 0.000000)) + l(-1.000000, -1.000000, 0.000000, 0.000000);
                    r8.yz = r2.zzwz * r5.xxyx;
                    r1.y = min(|r8.y|, l(0.080000));
                    r5.x = (r8.y < l(0.000000));
                    r5.x = (r5.x) ? l(-1.000000) : l(1.000000);
                    r8.x = r1.y * r5.x;
                    r8.w = l(0);
                    r7.yzw = r3.xxzw + r8.xxwz;
                    r8.xyz = r7.zzzz * cb0[2].xyzx;
                    r8.xyz = (r7.yyyy * cb0[1].xyzx) + r8.xyzx;
                    r7.yzw = (r7.wwww * cb0[3].xxyz) + r8.xxyz;
                    r8.xyz = r7.yzwy + cb0[4].xyzx;
                    // asm: imm_atomic_iadd r9.x, u1, l(0), l(-1)
                    // asm: ld_uav_typed_indexable(buffer)(uint,uint,uint,uint) r1.y, r9.xxxx, u1.yxzw
                    r5.x = r7.x + l(0x00080000);
                    r5.x = (cb1[131].z) ? r7.x : r5.x;
                    store_uav_typed(u3.xyzw, r5.xxxx, r1.yyyy);
                    // asm: bfi r8.w, l(11), l(0), cb0[12].z, r4.w
                    store_structured(u2.xyzw, r1.y, l(0), r8.xyzw);
                    r6.w = l(1.000000);
                    store_structured(u2.xyzw, r1.y, l(16), r6.xyzw);
                }
                r0.y = l(3);
            }
            r1.y = (r0.y < r0.x);
            r0.w = r0.w & r1.y;
            if (r0.w) {
                r1.y = (l(0x0019660d) * r4.w) + l(0x3c6ef35f);
                r5.x = r1.y ^ l(61);
                r1.y = r1.y >> l(16);
                r1.y = r1.y ^ r5.x;
                null = r1.y * r1.y;
                r5.x = r1.y >> l(4);
                r1.y = r1.y ^ r5.x;
                null = r1.y * r1.y;
                r5.x = r1.y >> l(15);
                r1.y = r1.y ^ r5.x;
                r5.x = (l(0x0019660d) * r1.y) + l(0x3c6ef35f);
                r5.y = r5.x ^ l(61);
                r5.x = r5.x >> l(16);
                r5.x = r5.x ^ r5.y;
                null = r5.x * r5.x;
                r5.y = r5.x >> l(4);
                r5.x = r5.y ^ r5.x;
                null = r5.x * r5.x;
                r5.y = r5.x >> l(15);
                r4.w = r5.y ^ r5.x;
                // asm: imm_atomic_iadd r7.x, u0, l(1), l(1)
                r5.x = (r7.x >= l(0x00080000));
                if (r5.x) {
                    // asm: imm_atomic_iadd r7.x, u0, l(1), l(-1)
                }
                if (!(r5.x)) {
                    r7.y = (float)r1.y;
                    r7.z = (float)r4.w;
                    r5.xy = (r7.yzyy * l(0.000000, 0.000000, 0.000000, 0.000000)) + l(-1.000000, -1.000000, 0.000000, 0.000000);
                    r8.yz = r2.zzwz * r5.xxyx;
                    r1.y = min(|r8.y|, l(0.080000));
                    r5.x = (r8.y < l(0.000000));
                    r5.x = (r5.x) ? l(-1.000000) : l(1.000000);
                    r8.x = r1.y * r5.x;
                    r8.w = l(0);
                    r7.yzw = r3.xxzw + r8.xxwz;
                    r8.xyz = r7.zzzz * cb0[2].xyzx;
                    r8.xyz = (r7.yyyy * cb0[1].xyzx) + r8.xyzx;
                    r7.yzw = (r7.wwww * cb0[3].xxyz) + r8.xxyz;
                    r8.xyz = r7.yzwy + cb0[4].xyzx;
                    // asm: imm_atomic_iadd r9.x, u1, l(0), l(-1)
                    // asm: ld_uav_typed_indexable(buffer)(uint,uint,uint,uint) r1.y, r9.xxxx, u1.yxzw
                    r5.x = r7.x + l(0x00080000);
                    r5.x = (cb1[131].z) ? r7.x : r5.x;
                    store_uav_typed(u3.xyzw, r5.xxxx, r1.yyyy);
                    // asm: bfi r8.w, l(11), l(0), cb0[12].z, r4.w
                    store_structured(u2.xyzw, r1.y, l(0), r8.xyzw);
                    r6.w = l(1.000000);
                    store_structured(u2.xyzw, r1.y, l(16), r6.xyzw);
                }
                r0.y = l(4);
            }
            r1.y = (r0.y < r0.x);
            r0.w = r0.w & r1.y;
            if (r0.w) {
                r1.y = (l(0x0019660d) * r4.w) + l(0x3c6ef35f);
                r5.x = r1.y ^ l(61);
                r1.y = r1.y >> l(16);
                r1.y = r1.y ^ r5.x;
                null = r1.y * r1.y;
                r5.x = r1.y >> l(4);
                r1.y = r1.y ^ r5.x;
                null = r1.y * r1.y;
                r5.x = r1.y >> l(15);
                r1.y = r1.y ^ r5.x;
                r5.x = (l(0x0019660d) * r1.y) + l(0x3c6ef35f);
                r5.y = r5.x ^ l(61);
                r5.x = r5.x >> l(16);
                r5.x = r5.x ^ r5.y;
                null = r5.x * r5.x;
                r5.y = r5.x >> l(4);
                r5.x = r5.y ^ r5.x;
                null = r5.x * r5.x;
                r5.y = r5.x >> l(15);
                r4.w = r5.y ^ r5.x;
                // asm: imm_atomic_iadd r7.x, u0, l(1), l(1)
                r5.x = (r7.x >= l(0x00080000));
                if (r5.x) {
                    // asm: imm_atomic_iadd r7.x, u0, l(1), l(-1)
                }
                if (!(r5.x)) {
                    r7.y = (float)r1.y;
                    r7.z = (float)r4.w;
                    r5.xy = (r7.yzyy * l(0.000000, 0.000000, 0.000000, 0.000000)) + l(-1.000000, -1.000000, 0.000000, 0.000000);
                    r8.yz = r2.zzwz * r5.xxyx;
                    r1.y = min(|r8.y|, l(0.080000));
                    r5.x = (r8.y < l(0.000000));
                    r5.x = (r5.x) ? l(-1.000000) : l(1.000000);
                    r8.x = r1.y * r5.x;
                    r8.w = l(0);
                    r7.yzw = r3.xxzw + r8.xxwz;
                    r8.xyz = r7.zzzz * cb0[2].xyzx;
                    r8.xyz = (r7.yyyy * cb0[1].xyzx) + r8.xyzx;
                    r7.yzw = (r7.wwww * cb0[3].xxyz) + r8.xxyz;
                    r8.xyz = r7.yzwy + cb0[4].xyzx;
                    // asm: imm_atomic_iadd r9.x, u1, l(0), l(-1)
                    // asm: ld_uav_typed_indexable(buffer)(uint,uint,uint,uint) r1.y, r9.xxxx, u1.yxzw
                    r5.x = r7.x + l(0x00080000);
                    r5.x = (cb1[131].z) ? r7.x : r5.x;
                    store_uav_typed(u3.xyzw, r5.xxxx, r1.yyyy);
                    // asm: bfi r8.w, l(11), l(0), cb0[12].z, r4.w
                    store_structured(u2.xyzw, r1.y, l(0), r8.xyzw);
                    r6.w = l(1.000000);
                    store_structured(u2.xyzw, r1.y, l(16), r6.xyzw);
                }
                r0.y = l(5);
            }
            r1.y = (r0.y < r0.x);
            r0.w = r0.w & r1.y;
            if (r0.w) {
                r1.y = (l(0x0019660d) * r4.w) + l(0x3c6ef35f);
                r5.x = r1.y ^ l(61);
                r1.y = r1.y >> l(16);
                r1.y = r1.y ^ r5.x;
                null = r1.y * r1.y;
                r5.x = r1.y >> l(4);
                r1.y = r1.y ^ r5.x;
                null = r1.y * r1.y;
                r5.x = r1.y >> l(15);
                r1.y = r1.y ^ r5.x;
                r5.x = (l(0x0019660d) * r1.y) + l(0x3c6ef35f);
                r5.y = r5.x ^ l(61);
                r5.x = r5.x >> l(16);
                r5.x = r5.x ^ r5.y;
                null = r5.x * r5.x;
                r5.y = r5.x >> l(4);
                r5.x = r5.y ^ r5.x;
                null = r5.x * r5.x;
                r5.y = r5.x >> l(15);
                r4.w = r5.y ^ r5.x;
                // asm: imm_atomic_iadd r7.x, u0, l(1), l(1)
                r5.x = (r7.x >= l(0x00080000));
                if (r5.x) {
                    // asm: imm_atomic_iadd r7.x, u0, l(1), l(-1)
                }
                if (!(r5.x)) {
                    r7.y = (float)r1.y;
                    r7.z = (float)r4.w;
                    r5.xy = (r7.yzyy * l(0.000000, 0.000000, 0.000000, 0.000000)) + l(-1.000000, -1.000000, 0.000000, 0.000000);
                    r8.yz = r2.zzwz * r5.xxyx;
                    r1.y = min(|r8.y|, l(0.080000));
                    r5.x = (r8.y < l(0.000000));
                    r5.x = (r5.x) ? l(-1.000000) : l(1.000000);
                    r8.x = r1.y * r5.x;
                    r8.w = l(0);
                    r7.yzw = r3.xxzw + r8.xxwz;
                    r8.xyz = r7.zzzz * cb0[2].xyzx;
                    r8.xyz = (r7.yyyy * cb0[1].xyzx) + r8.xyzx;
                    r7.yzw = (r7.wwww * cb0[3].xxyz) + r8.xxyz;
                    r8.xyz = r7.yzwy + cb0[4].xyzx;
                    // asm: imm_atomic_iadd r9.x, u1, l(0), l(-1)
                    // asm: ld_uav_typed_indexable(buffer)(uint,uint,uint,uint) r1.y, r9.xxxx, u1.yxzw
                    r5.x = r7.x + l(0x00080000);
                    r5.x = (cb1[131].z) ? r7.x : r5.x;
                    store_uav_typed(u3.xyzw, r5.xxxx, r1.yyyy);
                    // asm: bfi r8.w, l(11), l(0), cb0[12].z, r4.w
                    store_structured(u2.xyzw, r1.y, l(0), r8.xyzw);
                    r6.w = l(1.000000);
                    store_structured(u2.xyzw, r1.y, l(16), r6.xyzw);
                }
                r0.y = l(6);
            }
            r1.y = (r0.y < r0.x);
            r0.w = r0.w & r1.y;
            if (r0.w) {
                r1.y = (l(0x0019660d) * r4.w) + l(0x3c6ef35f);
                r5.x = r1.y ^ l(61);
                r1.y = r1.y >> l(16);
                r1.y = r1.y ^ r5.x;
                null = r1.y * r1.y;
                r5.x = r1.y >> l(4);
                r1.y = r1.y ^ r5.x;
                null = r1.y * r1.y;
                r5.x = r1.y >> l(15);
                r1.y = r1.y ^ r5.x;
                r5.x = (l(0x0019660d) * r1.y) + l(0x3c6ef35f);
                r5.y = r5.x ^ l(61);
                r5.x = r5.x >> l(16);
                r5.x = r5.x ^ r5.y;
                null = r5.x * r5.x;
                r5.y = r5.x >> l(4);
                r5.x = r5.y ^ r5.x;
                null = r5.x * r5.x;
                r5.y = r5.x >> l(15);
                r4.w = r5.y ^ r5.x;
                // asm: imm_atomic_iadd r7.x, u0, l(1), l(1)
                r5.x = (r7.x >= l(0x00080000));
                if (r5.x) {
                    // asm: imm_atomic_iadd r7.x, u0, l(1), l(-1)
                }
                if (!(r5.x)) {
                    r7.y = (float)r1.y;
                    r7.z = (float)r4.w;
                    r5.xy = (r7.yzyy * l(0.000000, 0.000000, 0.000000, 0.000000)) + l(-1.000000, -1.000000, 0.000000, 0.000000);
                    r8.yz = r2.zzwz * r5.xxyx;
                    r1.y = min(|r8.y|, l(0.080000));
                    r5.x = (r8.y < l(0.000000));
                    r5.x = (r5.x) ? l(-1.000000) : l(1.000000);
                    r8.x = r1.y * r5.x;
                    r8.w = l(0);
                    r7.yzw = r3.xxzw + r8.xxwz;
                    r8.xyz = r7.zzzz * cb0[2].xyzx;
                    r8.xyz = (r7.yyyy * cb0[1].xyzx) + r8.xyzx;
                    r7.yzw = (r7.wwww * cb0[3].xxyz) + r8.xxyz;
                    r8.xyz = r7.yzwy + cb0[4].xyzx;
                    // asm: imm_atomic_iadd r9.x, u1, l(0), l(-1)
                    // asm: ld_uav_typed_indexable(buffer)(uint,uint,uint,uint) r1.y, r9.xxxx, u1.yxzw
                    r5.x = r7.x + l(0x00080000);
                    r5.x = (cb1[131].z) ? r7.x : r5.x;
                    store_uav_typed(u3.xyzw, r5.xxxx, r1.yyyy);
                    // asm: bfi r8.w, l(11), l(0), cb0[12].z, r4.w
                    store_structured(u2.xyzw, r1.y, l(0), r8.xyzw);
                    r6.w = l(1.000000);
                    store_structured(u2.xyzw, r1.y, l(16), r6.xyzw);
                }
                r0.y = l(7);
            }
            r0.x = (r0.y < r0.x);
            r0.x = r0.x & r0.w;
            if (r0.x) {
                r0.x = (l(0x0019660d) * r4.w) + l(0x3c6ef35f);
                r0.y = r0.x ^ l(61);
                r0.x = r0.x >> l(16);
                r0.x = r0.x ^ r0.y;
                null = r0.x * r0.x;
                r0.y = r0.x >> l(4);
                r0.x = r0.y ^ r0.x;
                null = r0.x * r0.x;
                r0.y = r0.x >> l(15);
                r0.x = r0.y ^ r0.x;
                r0.y = (l(0x0019660d) * r0.x) + l(0x3c6ef35f);
                r0.w = r0.y ^ l(61);
                r0.y = r0.y >> l(16);
                r0.y = r0.y ^ r0.w;
                null = r0.y * r0.y;
                r0.w = r0.y >> l(4);
                r0.y = r0.w ^ r0.y;
                null = r0.y * r0.y;
                r0.w = r0.y >> l(15);
                r4.w = r0.w ^ r0.y;
                // asm: imm_atomic_iadd r7.x, u0, l(1), l(1)
                r0.y = (r7.x >= l(0x00080000));
                if (r0.y) {
                    // asm: imm_atomic_iadd r7.x, u0, l(1), l(-1)
                }
                if (!(r0.y)) {
                    r7.y = (float)r0.x;
                    r7.z = (float)r4.w;
                    r0.xy = (r7.yzyy * l(0.000000, 0.000000, 0.000000, 0.000000)) + l(-1.000000, -1.000000, 0.000000, 0.000000);
                    r8.yz = r2.zzwz * r0.xxyx;
                    r0.x = min(|r8.y|, l(0.080000));
                    r0.y = (r8.y < l(0.000000));
                    r0.y = (r0.y) ? l(-1.000000) : l(1.000000);
                    r8.x = r0.y * r0.x;
                    r8.w = l(0);
                    r0.xyw = r3.xzxw + r8.xwxz;
                    r7.yzw = r0.yyyy * cb0[2].xxyz;
                    r7.yzw = (r0.xxxx * cb0[1].xxyz) + r7.yyzw;
                    r0.xyw = (r0.wwww * cb0[3].xyxz) + r7.yzyw;
                    r8.xyz = r0.xywx + cb0[4].xyzx;
                    // asm: imm_atomic_iadd r9.x, u1, l(0), l(-1)
                    // asm: ld_uav_typed_indexable(buffer)(uint,uint,uint,uint) r0.x, r9.xxxx, u1.xyzw
                    r0.y = r7.x + l(0x00080000);
                    r0.y = (cb1[131].z) ? r7.x : r0.y;
                    store_uav_typed(u3.xyzw, r0.yyyy, r0.xxxx);
                    // asm: bfi r8.w, l(11), l(0), cb0[12].z, r4.w
                    store_structured(u2.xyzw, r0.x, l(0), r8.xyzw);
                    r6.w = l(1.000000);
                    store_structured(u2.xyzw, r0.x, l(16), r6.xyzw);
                }
            }
        }
        // asm: ld_indexable(buffer)(uint,uint,uint,uint) r0.x, cb0[12].wwww, t2.xyzw
        r0.y = (l(1.500000) < cb0[9].z);
        r0.y = (r0.y) ? l(0x0000cb20) : l(0x00009c40);
        r0.y = (r5.w) ? l(0x00002ee0) : r0.y;
        r0.x = (r0.x < r0.y);
        r0.y = (l(0x0019660d) * r4.w) + l(0x3c6ef35f);
        r0.w = r0.y ^ l(61);
        r0.y = r0.y >> l(16);
        r0.y = r0.y ^ r0.w;
        null = r0.y * r0.y;
        r0.w = r0.y >> l(4);
        r0.y = r0.w ^ r0.y;
        null = r0.y * r0.y;
        r0.w = r0.y >> l(15);
        r0.y = r0.w ^ r0.y;
        r0.w = (float)r0.y;
        r0.w = r0.w * l(0.000000);
        r0.w = (r0.w < r2.x);
        r0.x = r0.w & r0.x;
        r0.x = r0.z & r0.x;
        if (r0.x) {
            // asm: imm_atomic_iadd r6.x, u0, l(1), l(1)
            r0.x = (r6.x >= l(0x00080000));
            if (r0.x) {
                // asm: imm_atomic_iadd r6.x, u0, l(1), l(-1)
            }
            if (!(r0.x)) {
                r0.x = cb0[9].z * l(0.500000);
                r0.z = dot(cb2[22].xyzx, cb2[22].xyzx);
                r0.z = rsqrt(r0.z);
                r6.yzw = r0.zzzz * cb2[22].xxyz;
                r0.z = (l(0.000000) < r1.x);
                r0.z = (r0.z) ? l(1.000000) : l(-1.000000);
                r0.x = r0.z * r0.x;
                r0.z = dot(r4.xyzx, r6.yzwy);
                r0.z = (l(0.800000) < |r0.z|);
                r0.z = (r0.z) ? l(0.900000) : l(0.200000);
                r0.z = (r1.z) ? r0.z : l(0.200000);
                r0.x = r0.z * r0.x;
                r0.x = max(r0.x, l(-0.500000));
                r0.x = min(r0.x, l(0.500000));
                r0.z = (r5.w) ? l(0.050000) : l(1.000000);
                r0.z = r0.z * r5.z;
                r0.x = r0.z * r0.x;
                r4.xz = r0.xxxx * cb0[1].xxzx;
                r0.x = (l(0.999900) < r3.y);
                r0.z = (r1.z) ? l(0.250000) : l(0.100000);
                r0.w = (r2.y * l(0.300000)) + l(0.150000);
                r0.z = (r0.w * r3.y) + r0.z;
                // asm: mad_sat r1.yz, cb0[9].zzzz, l(0.000000, 1.111111, 6.666665, 0.000000), l(0.000000, -1.666667, -2.999999, 0.000000)
                r0.w = (l(1.200000) < cb0[9].z);
                r0.xw = (r0.xxxw) ? l(1.150000,0,0,1.100000) : l(0.400000,0,0,1.000000);
                r0.x = (r1.y * r0.x) + r0.w;
                r0.x = r0.x * r0.z;
                r0.z = (r1.z * l(0.100000)) + l(0.500000);
                r0.z = (cb0[13].z) ? r0.z : l(1.000000);
                r0.x = r0.z * r0.x;
                r4.y = min(r0.x, l(1.000000));
                r0.x = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
                r0.y = r0.x ^ l(61);
                r0.x = r0.x >> l(16);
                r0.x = r0.x ^ r0.y;
                null = r0.x * r0.x;
                r0.y = r0.x >> l(4);
                r0.x = r0.y ^ r0.x;
                null = r0.x * r0.x;
                r0.y = r0.x >> l(15);
                r0.x = r0.y ^ r0.x;
                r0.y = (float)r0.x;
                r0.y = r0.y * l(0.000000);
                r0.x = (l(0x0019660d) * r0.x) + l(0x3c6ef35f);
                r0.z = r0.x ^ l(61);
                r0.x = r0.x >> l(16);
                r0.x = r0.x ^ r0.z;
                null = r0.x * r0.x;
                r0.z = r0.x >> l(4);
                r0.x = r0.z ^ r0.x;
                null = r0.x * r0.x;
                r0.z = r0.x >> l(15);
                r0.x = r0.z ^ r0.x;
                r0.z = (float)r0.x;
                r0.w = (r1.x >= l(0.000000));
                r0.w = (r0.w) ? l(1.000000) : l(-1.000000);
                r0.w = r2.z * r0.w;
                r0.w = (r0.w * l(0.080000)) + r3.x;
                r1.x = max(r2.w, r2.z);
                r0.y = dot2(r0.yyyy, r1.xxxx);
                r0.z = (r0.z * l(0.000000)) + l(-1.000000);
                r0.z = dot2(r0.zzzz, r2.wwww);
                r0.yz = r0.yyzy + r3.zzwz;
                r1.xyz = r0.yyyy * cb0[2].xyzx;
                r1.xyz = (r0.wwww * cb0[1].xyzx) + r1.xyzx;
                r0.yzw = (r0.zzzz * cb0[3].xxyz) + r1.xxyz;
                r2.xyz = r0.yzwy + cb0[4].xyzx;
                r0.y = max(r1.w, r2.y);
                r2.y = r0.y + l(0.030000);
                // asm: imm_atomic_iadd r1.x, u1, l(0), l(-1)
                // asm: ld_uav_typed_indexable(buffer)(uint,uint,uint,uint) r0.y, r1.xxxx, u1.yxzw
                r0.z = r6.x + l(0x00080000);
                r0.z = (cb1[131].z) ? r6.x : r0.z;
                store_uav_typed(u3.xyzw, r0.zzzz, r0.yyyy);
                // asm: bfi r2.w, l(11), l(0), cb0[12].w, r0.x
                store_structured(u2.xyzw, r0.y, l(0), r2.xyzw);
                r4.w = l(1.000000);
                store_structured(u2.xyzw, r0.y, l(16), r4.xyzw);
            }
        }
    }
    return;
    // asm: // Approximately 951 instruction slots used
}

// -----------------------------------------------------------------------------
// Shader 2
// Profile: cs_5_0
// Byte offset: 86736
// Byte length: 39932
// -----------------------------------------------------------------------------

// Reflected buffer definitions
cbuffer $Globals
{
  bool g_isTAAEnabledBranch;         // Offset:    0 Size:     4 [unused]
     = 0xffffffff 
  uint g_numRenderSets;              // Offset:    4 Size:     4 [unused]
  row_major float4x4 g_shipUnwrapperWorld;// Offset:   16 Size:    64
  row_major float4x4 g_shipWorldInv; // Offset:   80 Size:    64 [unused]
  float4 g_shipSize;                 // Offset:  144 Size:    16
  float g_shipSpeed;                 // Offset:  160 Size:     4
  float g_shipMovementForward;       // Offset:  164 Size:     4 [unused]
  float4 g_textureSize;              // Offset:  176 Size:    16
  float g_rainAmount;                // Offset:  192 Size:     4
  float g_shipFoamSpawnMinDistMult;  // Offset:  196 Size:     4
  uint g_vfxIDShipRaindrop;          // Offset:  200 Size:     4
  uint g_vfxIDShipFoam;              // Offset:  204 Size:     4 [unused]
  uint g_vfxIDShipTopWave;           // Offset:  208 Size:     4
  uint g_vfxIDUnderwaterBubbles;     // Offset:  212 Size:     4 [unused]
  bool g_isShipSubmarine;            // Offset:  216 Size:     4
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
  float g_time;                      // Offset: 2048 Size:     4 [unused]
     = 0x00000000 
  float g_timePrev;                  // Offset: 2052 Size:     4 [unused]
     = 0x00000000 
  float g_deltaTime;                 // Offset: 2056 Size:     4
     = 0x00000000 
  float g_timeFromMapStart;          // Offset: 2060 Size:     4 [unused]
     = 0x00000000 
  uint g_frameIdx;                   // Offset: 2064 Size:     4
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
  bool g_gpuVfxAccessPong;           // Offset: 2104 Size:     4
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
  row_major float4x4 g_cameraDirs;   // Offset:  512 Size:    64 [unused]
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
Resource bind info for g_gpuVfxParticlesUAV
{
  struct GPUParticleData
  {
      float3 position;               // Offset:    0
      uint vfxHashID;                // Offset:   12
      float3 velocity;               // Offset:   16
      float linearAge;               // Offset:   28
  } $Element;                        // Offset:    0 Size:    32
}

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// g_bilinearClampSampler            sampler      NA          NA             s0      1 
// g_bilinearWrapSampler             sampler      NA          NA             s1      1 
// g_RTLinearSampler                 sampler      NA          NA             s2      1 
// g_depthTexSampler                 sampler      NA          NA             s3      1 
// g_depthTex                        texture  float4          2d             t0      1 
// g_gpuVfxPerVfxCountersSRV         texture    uint         buf             t1      1 
// g_wave0DispTexture                texture  float4          2d             t2      1 
// g_wave1DispTexture                texture  float4          2d             t3      1 
// g_variationTexture                texture  float4          2d             t4      1 
// g_spaceVariationTexture           texture  float4          2d             t5      1 
// g_waterDeformTexture              texture  float4          2d             t6      1 
// g_shipUnwrapperDepth              texture  float4          2d             t7      1 
// g_prevShipWetnessTexture          texture  float4          2d             t8      1 
// g_gpuVfxGlobalCountersUAV             UAV    uint         buf             u0      1 
// g_gpuVfxDeadIndirectionUAV            UAV    uint         buf             u1      1 
// g_gpuVfxParticlesUAV                  UAV  struct         r/w             u2      1 
// g_gpuVfxParticlesIndirectionUAV        UAV    uint         buf             u3      1 
// g_topWetnessTextureUAV                UAV   float          2d             u4      1 
// $Globals                          cbuffer      NA          NA            cb0      1 
// PerFrame                          cbuffer      NA          NA            cb1      1 
// PerView                           cbuffer      NA          NA            cb2      1

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
    // dcl_constantbuffer CB0[14], immediateIndexed
    // dcl_constantbuffer CB1[132], immediateIndexed
    // dcl_constantbuffer CB2[37], immediateIndexed
    // dcl_sampler s0, mode_default
    // dcl_sampler s1, mode_default
    // dcl_sampler s2, mode_default
    // dcl_sampler s3, mode_default
    // dcl_resource_texture2d (float,float,float,float) t0
    // dcl_resource_buffer (uint,uint,uint,uint) t1
    // dcl_resource_texture2d (float,float,float,float) t2
    // dcl_resource_texture2d (float,float,float,float) t3
    // dcl_resource_texture2d (float,float,float,float) t4
    // dcl_resource_texture2d (float,float,float,float) t5
    // dcl_resource_texture2d (float,float,float,float) t6
    // dcl_resource_texture2d (float,float,float,float) t7
    // dcl_resource_texture2d (float,float,float,float) t8
    // dcl_uav_typed_buffer (uint,uint,uint,uint) u0
    // dcl_uav_typed_buffer (uint,uint,uint,uint) u1
    // dcl_uav_structured u2, 32
    // dcl_uav_typed_buffer (uint,uint,uint,uint) u3
    // dcl_uav_typed_texture2d (float,float,float,float) u4
    // dcl_input vThreadIDInGroup.xy
    // dcl_input vThreadID.xy
    float4 r[9];
    // dcl_tgsm_raw g0, 4
    // numthreads(16, 16, 1)
    r0.xy = (vThreadIDInGroup.xyxx == l(0, 0, 0, 0));
    r0.x = r0.y & r0.x;
    if (r0.x) {
        // asm: store_raw g0.x, l(0), l(0)
    }
    // asm: sync_g_t
    // asm: imm_atomic_iadd r0.x, g0, l(0), l(1)
    r1.xy = vThreadID.xyxx;
    r1.zw = l(0,0,0,0);
    // asm: ld_indexable(texture2d)(float,float,float,float) r2.xyzw, r1.xyww, t7.xyzw
    r0.y = (r2.w < l(0.000010));
    if (r0.y) {
        return;
    }
    r0.yz = (uint)cb0[11].xxyx;
    r3.xyz = r2.yyyy * cb0[2].xyzx;
    r3.xyz = (r2.xxxx * cb0[1].xyzx) + r3.xyzx;
    r3.xyz = (r2.zzzz * cb0[3].xyzx) + r3.xyzx;
    r3.xyz = r3.xyzx + cb0[4].xyzx;
    // asm: mad_sat r0.w, cb1[131].y, l(2.000000), l(-1.000000)
    r3.w = -cb1[58].z + cb2[36].y;
    r4.x = (-cb1[61].x * cb1[61].w) + cb1[61].x;
    r4.x = l(1.000000, 1.000000, 1.000000, 1.000000) / r4.x;
    // asm: mad_sat r3.w, |r3.w|, l(0.003333), l(-0.100000)
    r4.y = -cb1[60].w + l(1.000000);
    r4.zw = r3.xxxz;
    r5.x = l(0);
    while (true) {
        r5.y = (r5.x >= l(2));
        if (r5.y) { break; }
        r5.yz = -r4.zzwz + cb2[36].xxzx;
        r5.y = dot2(r5.yzyy, r5.yzyy);
        r5.y = sqrt(r5.y);
        r5.zw = r4.zzzw * cb1[61].yyyy;
        r5.zw = r5.zzzw * l(0.000000, 0.000000, 0.001000, 0.001000);
        // asm: sample_l_indexable(texture2d)(float,float,float,float) r5.z, r5.zwzz, t4.yzxw, s1, l(1.000000)
        // asm: add_sat r5.z, r5.z, cb1[59].w
        r5.w = (-cb1[61].x * cb1[61].w) + r5.z;
        // asm: mul_sat r5.w, r4.x, r5.w
        r6.x = (r5.w * l(-2.000000)) + l(3.000000);
        r5.w = r5.w * r5.w;
        r5.w = (r6.x * r5.w) + r3.w;
        // asm: mad_sat r5.y, r5.y, l(0.005000), l(-2.000000)
        r5.y = (r0.w * r5.y) + r5.w;
        r5.y = min(r5.y, l(1.000000));
        r5.y = (r5.y * r4.y) + cb1[60].w;
        r5.z = log2(r5.z);
        r5.y = r5.z * r5.y;
        r5.y = exp2(r5.y);
        r5.zw = (r4.zzzw * cb1[124].xxxy) + cb1[124].zzzw;
        r6.xy = (r5.zwzz >= l(0.000000, 0.000000, 0.000000, 0.000000));
        r6.zw = (l(0.000000, 0.000000, 1.000000, 1.000000) >= r5.zzzw);
        r6.x = r6.z & r6.x;
        r6.x = r6.y & r6.x;
        r6.x = r6.w & r6.x;
        if (r6.x) {
            // asm: sample_l_indexable(texture2d)(float,float,float,float) r5.z, r5.zwzz, t5.yzxw, s0, l(0.000000)
        else
            r5.z = l(1.000000);
        }
        r5.y = r5.z * r5.y;
        r6.xyzw = (r4.zwzw * cb1[59].xxyy) + cb1[60].xxyy;
        // asm: sample_l_indexable(texture2d)(float,float,float,float) r5.zw, r6.xyxx, t2.xwyz, s1, l(1.000000)
        r5.y = r5.y * l(0.066667);
        // asm: sample_l_indexable(texture2d)(float,float,float,float) r6.xy, r6.zwzz, t3.yzxw, s1, l(1.000000)
        r6.xy = r5.yyyy * r6.xyxx;
        r5.yz = (r5.zzwz * r5.yyyy) + r6.xxyx;
        r5.yz = r4.zzwz + r5.yyzy;
        r5.yz = -r3.xxzx + r5.yyzy;
        r4.zw = r4.zzzw + -r5.yyyz;
        r5.x = r5.x + l(1);
    }
    r5.xyzw = r4.zwzw;
    r4.zw = -r5.zzzw + cb2[36].xxxz;
    r4.z = dot2(r4.zwzz, r4.zwzz);
    r4.z = sqrt(r4.z);
    r6.xy = r5.zwzz * cb1[61].yyyy;
    r6.xy = r6.xyxx * l(0.001000, 0.001000, 0.000000, 0.000000);
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r4.w, r6.xyxx, t4.yzwx, s1, l(1.000000)
    // asm: add_sat r4.w, r4.w, cb1[59].w
    r6.x = (-cb1[61].x * cb1[61].w) + r4.w;
    // asm: mul_sat r4.x, r4.x, r6.x
    r6.x = (r4.x * l(-2.000000)) + l(3.000000);
    r4.x = r4.x * r4.x;
    r3.w = (r6.x * r4.x) + r3.w;
    // asm: mad_sat r4.x, r4.z, l(0.005000), l(-2.000000)
    r0.w = (r0.w * r4.x) + r3.w;
    r0.w = min(r0.w, l(1.000000));
    r0.w = (r0.w * r4.y) + cb1[60].w;
    r3.w = log2(r4.w);
    r0.w = r0.w * r3.w;
    r0.w = exp2(r0.w);
    r4.xy = (r5.zwzz * cb1[124].xyxx) + cb1[124].zwzz;
    r4.zw = (r4.xxxy >= l(0.000000, 0.000000, 0.000000, 0.000000));
    r6.xy = (l(1.000000, 1.000000, 0.000000, 0.000000) >= r4.xyxx);
    r3.w = r4.z & r6.x;
    r3.w = r4.w & r3.w;
    r3.w = r6.y & r3.w;
    if (r3.w) {
        // asm: sample_l_indexable(texture2d)(float,float,float,float) r3.w, r4.xyxx, t5.yzwx, s0, l(0.000000)
    else
        r3.w = l(1.000000);
    }
    r0.w = r0.w * r3.w;
    r4.xyzw = (r5.xyzw * cb1[59].xxyy) + cb1[60].xxyy;
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r3.w, r4.xyxx, t2.yzwx, s1, l(1.000000)
    r0.w = r0.w * l(0.066667);
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r4.x, r4.zwzz, t3.xyzw, s1, l(1.000000)
    r4.x = r0.w * r4.x;
    r0.w = (r3.w * r0.w) + r4.x;
    r4.xyz = cb1[58].zzzz * cb2[1].xywx;
    r4.xyz = (r3.xxxx * cb2[0].xywx) + r4.xyzx;
    r4.xyz = (r3.zzzz * cb2[2].xywx) + r4.xyzx;
    r4.xyz = r4.xyzx + cb2[3].xywx;
    r4.xy = r4.xyxx / r4.zzzz;
    r4.xy = (r4.xyxx * l(0.400000, -0.400000, 0.000000, 0.000000)) + l(0.500000, 0.500000, 0.000000, 0.000000);
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r3.w, r4.xyxx, t6.xzwy, s2, l(0.000000)
    r0.w = (r3.w * cb1[62].x) + r0.w;
    r4.xyzw = vThreadID.xyxy + l(-1, 1, 1, -1);
    r5.xz = r4.xxzx;
    r5.yw = vThreadID.yyyy;
    // asm: umin r6.xy, r0.yzyy, r5.xyxx
    // asm: umin r5.xy, r0.yzyy, r5.zwzz
    r4.xz = vThreadID.xxxx;
    // asm: umin r7.xy, r0.yzyy, r4.xyxx
    // asm: umin r4.xy, r0.yzyy, r4.zwzz
    r3.w = min(cb1[128].z, l(0.040000));
    // asm: ld_indexable(texture2d)(float,float,float,float) r1.x, r1.xyzw, t8.xyzw
    r6.zw = l(0,0,0,0);
    // asm: ld_indexable(texture2d)(float,float,float,float) r1.y, r6.xyww, t8.yxzw
    r5.zw = l(0,0,0,0);
    // asm: ld_indexable(texture2d)(float,float,float,float) r1.z, r5.xyww, t8.yzxw
    r7.zw = l(0,0,0,0);
    // asm: ld_indexable(texture2d)(float,float,float,float) r1.w, r7.xyww, t8.yzwx
    r4.zw = l(0,0,0,0);
    // asm: ld_indexable(texture2d)(float,float,float,float) r8.x, r4.xyww, t8.xyzw
    // asm: ld_indexable(texture2d)(float,float,float,float) r6.xyzw, r6.xyzw, t7.xyzw
    // asm: ld_indexable(texture2d)(float,float,float,float) r5.xyzw, r5.xyzw, t7.xyzw
    // asm: ld_indexable(texture2d)(float,float,float,float) r7.xyzw, r7.xyzw, t7.xyzw
    // asm: ld_indexable(texture2d)(float,float,float,float) r4.xyzw, r4.xyzw, t7.xyzw
    r6.y = r6.y * cb0[2].y;
    r6.x = (r6.x * cb0[1].y) + r6.y;
    r6.x = (r6.z * cb0[3].y) + r6.x;
    r6.x = r6.x + cb0[4].y;
    r5.y = r5.y * cb0[2].y;
    r5.x = (r5.x * cb0[1].y) + r5.y;
    r5.x = (r5.z * cb0[3].y) + r5.x;
    r5.y = r7.y * cb0[2].y;
    r5.y = (r7.x * cb0[1].y) + r5.y;
    r5.y = (r7.z * cb0[3].y) + r5.y;
    r5.xy = r5.xyxx + cb0[4].yyyy;
    r4.y = r4.y * cb0[2].y;
    r4.x = (r4.x * cb0[1].y) + r4.y;
    r4.x = (r4.z * cb0[3].y) + r4.x;
    r4.x = r4.x + cb0[4].y;
    r4.y = (l(0.001000) < r6.w);
    r4.z = -r2.w + r6.w;
    r4.z = (|r4.z| < l(0.010000));
    r4.y = r4.z & r4.y;
    r4.z = (l(0.001000) < r5.w);
    r5.z = -r2.w + r5.w;
    r5.z = (|r5.z| < l(0.010000));
    r4.z = r4.z & r5.z;
    r5.z = (l(0.001000) < r7.w);
    r5.w = -r2.w + r7.w;
    r5.w = (|r5.w| < l(0.010000));
    r5.z = r5.w & r5.z;
    r5.w = (l(0.001000) < r4.w);
    r2.w = -r2.w + r4.w;
    r2.w = (|r2.w| < l(0.010000));
    r2.w = r2.w & r5.w;
    r4.w = -r3.y + r6.x;
    r5.xy = -r3.yyyy + r5.xyxx;
    r4.x = -r3.y + r4.x;
    r6.xy = r2.xzxx * l(12.000000, 12.000000, 0.000000, 0.000000);
    r6.zw = (r2.xxxz * l(0.000000, 0.000000, 12.000000, 12.000000)) + l(0.000000, 0.000000, 1.000000, 1.000000);
    r7.xyzw = floor(r6.zwxy);
    r6.xy = frac(r6.xyxx);
    r6.zw = r6.xxxy * r6.xxxy;
    r6.xy = (-r6.xyxx * l(2.000000, 2.000000, 0.000000, 0.000000)) + l(3.000000, 3.000000, 0.000000, 0.000000);
    r6.xy = r6.xyxx * r6.zwzz;
    r5.w = dot2(r7.zwzz, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r5.w, null, r5.w);
    r5.w = r5.w * l(43758.546875);
    r5.w = frac(r5.w);
    r6.z = dot2(r7.xwxx, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r6.z, null, r6.z);
    r6.z = r6.z * l(43758.546875);
    r6.z = frac(r6.z);
    r6.z = -r5.w + r6.z;
    r5.w = (r6.x * r6.z) + r5.w;
    r6.z = dot2(r7.zyzz, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r6.z, null, r6.z);
    r6.z = r6.z * l(43758.546875);
    r6.w = dot2(r7.xyxx, l(12.989800, 78.233002, 0.000000, 0.000000));
    sincos(r6.w, null, r6.w);
    r6.w = r6.w * l(43758.546875);
    r6.zw = frac(r6.zzzw);
    r6.w = -r6.z + r6.w;
    r6.x = (r6.x * r6.w) + r6.z;
    r6.x = -r5.w + r6.x;
    r5.w = (r6.y * r6.x) + r5.w;
    r6.x = r5.w * l(0.400000);
    r6.x = max(r6.x, l(0.100000));
    r6.y = r1.x + l(-0.050000);
    // asm: mul_sat r6.y, r6.y, l(2.857143)
    r6.z = (r6.y * l(-2.000000)) + l(3.000000);
    r6.y = r6.y * r6.y;
    r6.y = r6.y * r6.z;
    r6.z = (r6.y * l(4800.000000)) + l(200.000000);
    r6.w = (r4.y) ? l(-0.000000) : l(-10000.000000);
    r6.w = r4.w + r6.w;
    r6.w = min(r6.w, l(0.000000));
    r7.x = (r4.z) ? l(-0.000000) : l(-10000.000000);
    r7.x = r5.x + r7.x;
    r7.x = min(r7.x, l(0.000000));
    r7.x = r6.z * r7.x;
    r6.w = (r6.w * r6.z) + r7.x;
    r7.x = (r5.z) ? l(-0.000000) : l(-10000.000000);
    r7.x = r5.y + r7.x;
    r7.x = min(r7.x, l(0.000000));
    r6.w = (r7.x * r6.z) + r6.w;
    r7.x = (r2.w) ? l(-0.000000) : l(-10000.000000);
    r7.x = r4.x + r7.x;
    r7.x = min(r7.x, l(0.000000));
    r6.w = (r7.x * r6.z) + r6.w;
    r6.x = -r6.x + r6.w;
    // asm: mad_sat r6.x, r3.w, r6.x, l(1.000000)
    r4.yz = r4.yyzy & l(0, 0x3f800000, 0x3f800000, 0);
    r4.yz = r3.wwww * r4.yyzy;
    r4.xw = max(r4.xxxw, l(0.000000, 0.000000, 0.000000, 0.000000));
    r4.y = r4.w * r4.y;
    r4.w = max(r5.x, l(0.000000));
    r4.z = r4.w * r4.z;
    r4.w = r5.z & l(0x3f800000);
    r4.w = r3.w * r4.w;
    r5.x = max(r5.y, l(0.000000));
    r4.w = r4.w * r5.x;
    // asm: mul_sat r4.yzw, r6.zzzz, r4.yyzw
    r2.w = r2.w & l(0x3f800000);
    r2.w = r3.w * r2.w;
    r2.w = r4.x * r2.w;
    // asm: mul_sat r2.w, r6.z, r2.w
    r1.y = r1.y * r4.y;
    r1.y = (r1.x * r6.x) + r1.y;
    r1.y = (r1.z * r4.z) + r1.y;
    r1.y = (r1.w * r4.w) + r1.y;
    r1.y = (r8.x * r2.w) + r1.y;
    r1.x = (l(0.000000) < r1.x);
    r1.z = max(r1.y, l(0.080000));
    r1.x = (r1.x) ? r1.z : r1.y;
    r1.y = cb0[10].x + l(-20.000000);
    // asm: mul_sat r1.y, r1.y, l(0.333333)
    r1.z = (r1.y * l(-2.000000)) + l(3.000000);
    r1.y = r1.y * r1.y;
    r1.y = r1.y * r1.z;
    r1.z = cb0[9].w * l(0.500000);
    r1.w = (-cb0[9].z * l(-0.500000)) + r2.x;
    // asm: div_sat r1.w, r1.w, cb0[9].z
    r1.w = r1.w + l(-0.500000);
    r1.w = |r1.w| + l(0.150000);
    r1.w = r1.w * l(2.500000);
    r1.w = min(r1.w, l(1.000000));
    r2.w = (r1.w * l(-2.000000)) + l(3.000000);
    r1.w = r1.w * r1.w;
    r1.w = r1.w * r2.w;
    r2.w = -r5.w + l(1.000000);
    r2.w = (r6.y * r2.w) + r5.w;
    r1.w = r1.w * r2.w;
    r1.y = r1.w * r1.y;
    r1.z = r2.z / r1.z;
    // asm: mad_sat r1.z, r1.z, l(0.500000), l(0.500000)
    r1.y = r1.y * l(0.160000);
    r1.z = (r1.z * l(2.000000)) + l(-1.000000);
    r1.z = max(r1.z, l(0.000000));
    r1.yz = (r1.yyyy * r1.zzzz) + l(0.000000, 0.009000, 0.029000, 0.000000);
    r1.y = -r1.y + r3.y;
    r1.y = (r0.w < r1.y);
    r1.w = (-r3.w * l(5.000000)) + l(1.000000);
    r1.y = (r1.y) ? l(0) : r1.w;
    // asm: add_sat r1.x, r1.y, r1.x
    store_uav_typed(u4.xyzw, vThreadID.xyyy, r1.xxxx);
    // asm: mov_sat r5.w, r5.w
    r1.x = (vThreadID.y * r0.y) + vThreadID.x;
    null = r0.y * r0.z;
    r0.z = cb1[129].x & l(63);
    r0.y = (r0.y * r0.z) + r1.x;
    r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
    r0.z = r0.y ^ l(61);
    r0.y = r0.y >> l(16);
    r0.y = r0.y ^ r0.z;
    null = r0.y * r0.y;
    r0.z = r0.y >> l(4);
    r0.y = r0.z ^ r0.y;
    null = r0.y * r0.y;
    r0.z = r0.y >> l(15);
    r0.y = r0.z ^ r0.y;
    r0.z = (cb0[9].z * l(0.500000)) + r2.x;
    // asm: div_sat r0.z, r0.z, cb0[9].z
    r0.z = r0.z + l(-0.500000);
    // asm: mad_sat r0.z, |r0.z|, l(4.000000), l(-0.200000)
    r1.x = cb0[9].w * cb0[9].z;
    r1.w = r1.x * l(0.108069);
    r1.x = (l(27.759930) < r1.x);
    // asm: bfi r1.x, l(1), l(1), r1.x, l(0)
    r1.x = r1.x + l(6);
    r1.x = (float)r1.x;
    r2.w = log2(r5.w);
    r1.x = r1.x * r2.w;
    r1.x = exp2(r1.x);
    r1.x = r0.z * r1.x;
    // asm: mad_sat r2.w, cb0[10].x, l(0.142857), l(-0.142857)
    r1.z = (r2.w * l(0.020000)) + r1.z;
    r2.w = -r0.w + r3.y;
    r1.z = (|r2.w| < r1.z);
    r3.w = (-cb0[12].x * l(0.030000)) + l(0.070000);
    r4.x = (l(0.000000) < cb0[12].x);
    r4.x = (r4.x) ? l(0) : l(100.000000);
    r3.w = r3.w + r4.x;
    r3.w = (r3.w < |r0.w|);
    r1.z = r1.z | r3.w;
    r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
    r3.w = r0.y ^ l(61);
    r0.y = r0.y >> l(16);
    r0.y = r0.y ^ r3.w;
    null = r0.y * r0.y;
    r3.w = r0.y >> l(4);
    r0.y = r0.y ^ r3.w;
    null = r0.y * r0.y;
    r3.w = r0.y >> l(15);
    r0.y = r0.y ^ r3.w;
    r3.w = (float)r0.y;
    r3.w = r3.w * l(0.000000);
    // asm: mov_sat r4.x, r1.w
    r1.x = r1.x * r4.x;
    r1.x = (r3.w < r1.x);
    r1.x = r1.x & r1.z;
    r1.z = r0.w + l(0.020000);
    r1.z = (r3.y < r1.z);
    r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
    r3.w = r0.y ^ l(61);
    r0.y = r0.y >> l(16);
    r0.y = r0.y ^ r3.w;
    null = r0.y * r0.y;
    r3.w = r0.y >> l(4);
    r0.y = r0.y ^ r3.w;
    null = r0.y * r0.y;
    r3.w = r0.y >> l(15);
    r0.y = r0.y ^ r3.w;
    r3.w = (float)r0.y;
    r3.w = r3.w * l(0.000000);
    r0.z = r0.z * r4.x;
    r0.z = (r3.w < r0.z);
    r0.z = r0.z & r1.z;
    r1.z = (cb0[9].y * l(0.900000)) + r0.w;
    r1.z = (r3.y < r1.z);
    r0.z = r0.z | r1.x;
    r0.z = r0.z & r1.z;
    if (r0.z) {
        r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
        r0.z = r0.y ^ l(61);
        r0.y = r0.y >> l(16);
        r0.y = r0.y ^ r0.z;
        null = r0.y * r0.y;
        r0.z = r0.y >> l(4);
        r0.y = r0.z ^ r0.y;
        null = r0.y * r0.y;
        r0.z = r0.y >> l(15);
        r0.y = r0.z ^ r0.y;
        r4.y = (cb0[13].z) ? l(0.000100) : l(0.010000);
        r4.xz = l(0,0,0,0);
        r2.xyz = r2.xyzx + r4.xyzx;
        r4.xyz = r2.yyyy * cb0[2].xyzx;
        r4.xyz = (r2.xxxx * cb0[1].xyzx) + r4.xyzx;
        r4.xyz = (r2.zzzz * cb0[3].xyzx) + r4.xyzx;
        r4.xyz = r4.xyzx + cb0[4].xyzx;
        r5.xyz = r4.yyyy * cb2[1].xywx;
        r4.xyw = (r4.xxxx * cb2[0].xyxw) + r5.xyxz;
        r4.xyz = (r4.zzzz * cb2[2].xywx) + r4.xywx;
        r4.xyz = r4.xyzx + cb2[3].xywx;
        r4.xy = r4.xyxx / r4.zzzz;
        r5.xy = (r4.xyxx * l(0.500000, 0.500000, 0.000000, 0.000000)) + l(0.500000, 0.500000, 0.000000, 0.000000);
        r5.z = -r5.y + l(1.000000);
        // asm: sample_l_indexable(texture2d)(float,float,float,float) r0.z, r5.xzxx, t0.yzxw, s3, l(0.000000)
        r0.z = r0.z + -cb2[26].z;
        r0.z = cb2[27].z / r0.z;
        r0.z = -r0.z + r4.z;
        r0.z = (l(0.200000) < |r0.z|);
        r4.xy = (r0.zzzz) ? l(0,0,0,0) : l(0.400000,0.320000,0,0);
        r0.z = (l(0.001000) >= cb0[12].y);
        // asm: ld_indexable(buffer)(uint,uint,uint,uint) r1.z, cb0[12].zzzz, t1.yzxw
        r0.z = (r0.z) ? l(5000) : l(0x00007530);
        r0.z = (r1.z < r0.z);
        r0.z = r0.z & r1.x;
        r1.z = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
        r3.w = r1.z ^ l(61);
        r1.z = r1.z >> l(16);
        r1.z = r1.z ^ r3.w;
        null = r1.z * r1.z;
        r3.w = r1.z >> l(4);
        r1.z = r1.z ^ r3.w;
        null = r1.z * r1.z;
        r3.w = r1.z >> l(15);
        r1.z = r1.z ^ r3.w;
        r3.w = (float)r1.z;
        r3.w = r3.w * l(0.000000);
        r3.w = (r3.w < r4.x);
        r0.z = r0.z & r3.w;
        if (r0.z) {
            r0.z = (uint)r1.w;
            // asm: umax r0.z, r0.z, l(1)
            // asm: umin r0.z, r0.z, l(8)
            r4.xz = cb0[9].zzwz * cb0[11].zzwz;
            r0.y = (float)r0.y;
            r1.w = r0.y * l(-0.000000);
            r5.xy = (r0.yyyy < l(1717986944.000000, 2147483648.000000, 0.000000, 0.000000));
            r5.xy = r5.xyxx & l(0x3f800000, 0x3f800000, 0, 0);
            r6.y = (r1.w * r5.x) + l(-0.050000);
            // asm: mov_sat r0.w, r0.w
            r0.yw = r0.wwww * cb1[58].xxxy;
            r6.xz = r5.yyyy * r0.yywy;
            if (r0.z) {
                r0.y = (l(0x0019660d) * r1.z) + l(0x3c6ef35f);
                r0.w = r0.y ^ l(61);
                r0.y = r0.y >> l(16);
                r0.y = r0.y ^ r0.w;
                null = r0.y * r0.y;
                r0.w = r0.y >> l(4);
                r0.y = r0.w ^ r0.y;
                null = r0.y * r0.y;
                r0.w = r0.y >> l(15);
                r0.y = r0.w ^ r0.y;
                r0.w = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
                r1.w = r0.w ^ l(61);
                r0.w = r0.w >> l(16);
                r0.w = r0.w ^ r1.w;
                null = r0.w * r0.w;
                r1.w = r0.w >> l(4);
                r0.w = r0.w ^ r1.w;
                null = r0.w * r0.w;
                r1.w = r0.w >> l(15);
                r1.z = r0.w ^ r1.w;
                // asm: imm_atomic_iadd r5.x, u0, l(1), l(1)
                r0.w = (r5.x >= l(0x00080000));
                if (r0.w) {
                    // asm: imm_atomic_iadd r5.x, u0, l(1), l(-1)
                }
                if (!(r0.w)) {
                    r5.y = (float)r0.y;
                    r5.z = (float)r1.z;
                    r0.yw = (r5.yyyz * l(0.000000, 0.000000, 0.000000, 0.000000)) + l(0.000000, -1.000000, 0.000000, -1.000000);
                    r7.yz = r4.xxzx * r0.yywy;
                    r0.y = min(|r7.y|, l(0.080000));
                    r0.w = (r7.y < l(0.000000));
                    r0.w = (r0.w) ? l(-1.000000) : l(1.000000);
                    r7.x = r0.w * r0.y;
                    r7.w = l(0);
                    r5.yzw = r2.xxyz + r7.xxwz;
                    r7.xyz = r5.zzzz * cb0[2].xyzx;
                    r7.xyz = (r5.yyyy * cb0[1].xyzx) + r7.xyzx;
                    r5.yzw = (r5.wwww * cb0[3].xxyz) + r7.xxyz;
                    r7.xyz = r5.yzwy + cb0[4].xyzx;
                    // asm: imm_atomic_iadd r8.x, u1, l(0), l(-1)
                    // asm: ld_uav_typed_indexable(buffer)(uint,uint,uint,uint) r0.y, r8.xxxx, u1.yxzw
                    r0.w = r5.x + l(0x00080000);
                    r0.w = (cb1[131].z) ? r5.x : r0.w;
                    store_uav_typed(u3.xyzw, r0.wwww, r0.yyyy);
                    // asm: bfi r7.w, l(11), l(0), cb0[12].z, r1.z
                    store_structured(u2.xyzw, r0.y, l(0), r7.xyzw);
                    r6.w = l(1.000000);
                    store_structured(u2.xyzw, r0.y, l(16), r6.xyzw);
                }
                r0.y = l(1);
            else
                r0.y = l(0);
            }
            r0.w = (r0.y < r0.z);
            if (r0.w) {
                r1.w = (l(0x0019660d) * r1.z) + l(0x3c6ef35f);
                r3.w = r1.w ^ l(61);
                r1.w = r1.w >> l(16);
                r1.w = r1.w ^ r3.w;
                null = r1.w * r1.w;
                r3.w = r1.w >> l(4);
                r1.w = r1.w ^ r3.w;
                null = r1.w * r1.w;
                r3.w = r1.w >> l(15);
                r1.w = r1.w ^ r3.w;
                r3.w = (l(0x0019660d) * r1.w) + l(0x3c6ef35f);
                r4.w = r3.w ^ l(61);
                r3.w = r3.w >> l(16);
                r3.w = r3.w ^ r4.w;
                null = r3.w * r3.w;
                r4.w = r3.w >> l(4);
                r3.w = r3.w ^ r4.w;
                null = r3.w * r3.w;
                r4.w = r3.w >> l(15);
                r1.z = r3.w ^ r4.w;
                // asm: imm_atomic_iadd r5.x, u0, l(1), l(1)
                r3.w = (r5.x >= l(0x00080000));
                if (r3.w) {
                    // asm: imm_atomic_iadd r5.x, u0, l(1), l(-1)
                }
                if (!(r3.w)) {
                    r5.yz = (float)r1.wwzw;
                    r5.yz = (r5.yyzy * l(0.000000, 0.000000, 0.000000, 0.000000)) + l(0.000000, -1.000000, -1.000000, 0.000000);
                    r7.yz = r4.xxzx * r5.yyzy;
                    r1.w = min(|r7.y|, l(0.080000));
                    r3.w = (r7.y < l(0.000000));
                    r3.w = (r3.w) ? l(-1.000000) : l(1.000000);
                    r7.x = r1.w * r3.w;
                    r7.w = l(0);
                    r5.yzw = r2.xxyz + r7.xxwz;
                    r7.xyz = r5.zzzz * cb0[2].xyzx;
                    r7.xyz = (r5.yyyy * cb0[1].xyzx) + r7.xyzx;
                    r5.yzw = (r5.wwww * cb0[3].xxyz) + r7.xxyz;
                    r7.xyz = r5.yzwy + cb0[4].xyzx;
                    // asm: imm_atomic_iadd r8.x, u1, l(0), l(-1)
                    // asm: ld_uav_typed_indexable(buffer)(uint,uint,uint,uint) r1.w, r8.xxxx, u1.yzwx
                    r3.w = r5.x + l(0x00080000);
                    r3.w = (cb1[131].z) ? r5.x : r3.w;
                    store_uav_typed(u3.xyzw, r3.wwww, r1.wwww);
                    // asm: bfi r7.w, l(11), l(0), cb0[12].z, r1.z
                    store_structured(u2.xyzw, r1.w, l(0), r7.xyzw);
                    r6.w = l(1.000000);
                    store_structured(u2.xyzw, r1.w, l(16), r6.xyzw);
                }
                r0.y = l(2);
            }
            r1.w = (r0.y < r0.z);
            r0.w = r0.w & r1.w;
            if (r0.w) {
                r1.w = (l(0x0019660d) * r1.z) + l(0x3c6ef35f);
                r3.w = r1.w ^ l(61);
                r1.w = r1.w >> l(16);
                r1.w = r1.w ^ r3.w;
                null = r1.w * r1.w;
                r3.w = r1.w >> l(4);
                r1.w = r1.w ^ r3.w;
                null = r1.w * r1.w;
                r3.w = r1.w >> l(15);
                r1.w = r1.w ^ r3.w;
                r3.w = (l(0x0019660d) * r1.w) + l(0x3c6ef35f);
                r4.w = r3.w ^ l(61);
                r3.w = r3.w >> l(16);
                r3.w = r3.w ^ r4.w;
                null = r3.w * r3.w;
                r4.w = r3.w >> l(4);
                r3.w = r3.w ^ r4.w;
                null = r3.w * r3.w;
                r4.w = r3.w >> l(15);
                r1.z = r3.w ^ r4.w;
                // asm: imm_atomic_iadd r5.x, u0, l(1), l(1)
                r3.w = (r5.x >= l(0x00080000));
                if (r3.w) {
                    // asm: imm_atomic_iadd r5.x, u0, l(1), l(-1)
                }
                if (!(r3.w)) {
                    r5.yz = (float)r1.wwzw;
                    r5.yz = (r5.yyzy * l(0.000000, 0.000000, 0.000000, 0.000000)) + l(0.000000, -1.000000, -1.000000, 0.000000);
                    r7.yz = r4.xxzx * r5.yyzy;
                    r1.w = min(|r7.y|, l(0.080000));
                    r3.w = (r7.y < l(0.000000));
                    r3.w = (r3.w) ? l(-1.000000) : l(1.000000);
                    r7.x = r1.w * r3.w;
                    r7.w = l(0);
                    r5.yzw = r2.xxyz + r7.xxwz;
                    r7.xyz = r5.zzzz * cb0[2].xyzx;
                    r7.xyz = (r5.yyyy * cb0[1].xyzx) + r7.xyzx;
                    r5.yzw = (r5.wwww * cb0[3].xxyz) + r7.xxyz;
                    r7.xyz = r5.yzwy + cb0[4].xyzx;
                    // asm: imm_atomic_iadd r8.x, u1, l(0), l(-1)
                    // asm: ld_uav_typed_indexable(buffer)(uint,uint,uint,uint) r1.w, r8.xxxx, u1.yzwx
                    r3.w = r5.x + l(0x00080000);
                    r3.w = (cb1[131].z) ? r5.x : r3.w;
                    store_uav_typed(u3.xyzw, r3.wwww, r1.wwww);
                    // asm: bfi r7.w, l(11), l(0), cb0[12].z, r1.z
                    store_structured(u2.xyzw, r1.w, l(0), r7.xyzw);
                    r6.w = l(1.000000);
                    store_structured(u2.xyzw, r1.w, l(16), r6.xyzw);
                }
                r0.y = l(3);
            }
            r1.w = (r0.y < r0.z);
            r0.w = r0.w & r1.w;
            if (r0.w) {
                r1.w = (l(0x0019660d) * r1.z) + l(0x3c6ef35f);
                r3.w = r1.w ^ l(61);
                r1.w = r1.w >> l(16);
                r1.w = r1.w ^ r3.w;
                null = r1.w * r1.w;
                r3.w = r1.w >> l(4);
                r1.w = r1.w ^ r3.w;
                null = r1.w * r1.w;
                r3.w = r1.w >> l(15);
                r1.w = r1.w ^ r3.w;
                r3.w = (l(0x0019660d) * r1.w) + l(0x3c6ef35f);
                r4.w = r3.w ^ l(61);
                r3.w = r3.w >> l(16);
                r3.w = r3.w ^ r4.w;
                null = r3.w * r3.w;
                r4.w = r3.w >> l(4);
                r3.w = r3.w ^ r4.w;
                null = r3.w * r3.w;
                r4.w = r3.w >> l(15);
                r1.z = r3.w ^ r4.w;
                // asm: imm_atomic_iadd r5.x, u0, l(1), l(1)
                r3.w = (r5.x >= l(0x00080000));
                if (r3.w) {
                    // asm: imm_atomic_iadd r5.x, u0, l(1), l(-1)
                }
                if (!(r3.w)) {
                    r5.yz = (float)r1.wwzw;
                    r5.yz = (r5.yyzy * l(0.000000, 0.000000, 0.000000, 0.000000)) + l(0.000000, -1.000000, -1.000000, 0.000000);
                    r7.yz = r4.xxzx * r5.yyzy;
                    r1.w = min(|r7.y|, l(0.080000));
                    r3.w = (r7.y < l(0.000000));
                    r3.w = (r3.w) ? l(-1.000000) : l(1.000000);
                    r7.x = r1.w * r3.w;
                    r7.w = l(0);
                    r5.yzw = r2.xxyz + r7.xxwz;
                    r7.xyz = r5.zzzz * cb0[2].xyzx;
                    r7.xyz = (r5.yyyy * cb0[1].xyzx) + r7.xyzx;
                    r5.yzw = (r5.wwww * cb0[3].xxyz) + r7.xxyz;
                    r7.xyz = r5.yzwy + cb0[4].xyzx;
                    // asm: imm_atomic_iadd r8.x, u1, l(0), l(-1)
                    // asm: ld_uav_typed_indexable(buffer)(uint,uint,uint,uint) r1.w, r8.xxxx, u1.yzwx
                    r3.w = r5.x + l(0x00080000);
                    r3.w = (cb1[131].z) ? r5.x : r3.w;
                    store_uav_typed(u3.xyzw, r3.wwww, r1.wwww);
                    // asm: bfi r7.w, l(11), l(0), cb0[12].z, r1.z
                    store_structured(u2.xyzw, r1.w, l(0), r7.xyzw);
                    r6.w = l(1.000000);
                    store_structured(u2.xyzw, r1.w, l(16), r6.xyzw);
                }
                r0.y = l(4);
            }
            r1.w = (r0.y < r0.z);
            r0.w = r0.w & r1.w;
            if (r0.w) {
                r1.w = (l(0x0019660d) * r1.z) + l(0x3c6ef35f);
                r3.w = r1.w ^ l(61);
                r1.w = r1.w >> l(16);
                r1.w = r1.w ^ r3.w;
                null = r1.w * r1.w;
                r3.w = r1.w >> l(4);
                r1.w = r1.w ^ r3.w;
                null = r1.w * r1.w;
                r3.w = r1.w >> l(15);
                r1.w = r1.w ^ r3.w;
                r3.w = (l(0x0019660d) * r1.w) + l(0x3c6ef35f);
                r4.w = r3.w ^ l(61);
                r3.w = r3.w >> l(16);
                r3.w = r3.w ^ r4.w;
                null = r3.w * r3.w;
                r4.w = r3.w >> l(4);
                r3.w = r3.w ^ r4.w;
                null = r3.w * r3.w;
                r4.w = r3.w >> l(15);
                r1.z = r3.w ^ r4.w;
                // asm: imm_atomic_iadd r5.x, u0, l(1), l(1)
                r3.w = (r5.x >= l(0x00080000));
                if (r3.w) {
                    // asm: imm_atomic_iadd r5.x, u0, l(1), l(-1)
                }
                if (!(r3.w)) {
                    r5.yz = (float)r1.wwzw;
                    r5.yz = (r5.yyzy * l(0.000000, 0.000000, 0.000000, 0.000000)) + l(0.000000, -1.000000, -1.000000, 0.000000);
                    r7.yz = r4.xxzx * r5.yyzy;
                    r1.w = min(|r7.y|, l(0.080000));
                    r3.w = (r7.y < l(0.000000));
                    r3.w = (r3.w) ? l(-1.000000) : l(1.000000);
                    r7.x = r1.w * r3.w;
                    r7.w = l(0);
                    r5.yzw = r2.xxyz + r7.xxwz;
                    r7.xyz = r5.zzzz * cb0[2].xyzx;
                    r7.xyz = (r5.yyyy * cb0[1].xyzx) + r7.xyzx;
                    r5.yzw = (r5.wwww * cb0[3].xxyz) + r7.xxyz;
                    r7.xyz = r5.yzwy + cb0[4].xyzx;
                    // asm: imm_atomic_iadd r8.x, u1, l(0), l(-1)
                    // asm: ld_uav_typed_indexable(buffer)(uint,uint,uint,uint) r1.w, r8.xxxx, u1.yzwx
                    r3.w = r5.x + l(0x00080000);
                    r3.w = (cb1[131].z) ? r5.x : r3.w;
                    store_uav_typed(u3.xyzw, r3.wwww, r1.wwww);
                    // asm: bfi r7.w, l(11), l(0), cb0[12].z, r1.z
                    store_structured(u2.xyzw, r1.w, l(0), r7.xyzw);
                    r6.w = l(1.000000);
                    store_structured(u2.xyzw, r1.w, l(16), r6.xyzw);
                }
                r0.y = l(5);
            }
            r1.w = (r0.y < r0.z);
            r0.w = r0.w & r1.w;
            if (r0.w) {
                r1.w = (l(0x0019660d) * r1.z) + l(0x3c6ef35f);
                r3.w = r1.w ^ l(61);
                r1.w = r1.w >> l(16);
                r1.w = r1.w ^ r3.w;
                null = r1.w * r1.w;
                r3.w = r1.w >> l(4);
                r1.w = r1.w ^ r3.w;
                null = r1.w * r1.w;
                r3.w = r1.w >> l(15);
                r1.w = r1.w ^ r3.w;
                r3.w = (l(0x0019660d) * r1.w) + l(0x3c6ef35f);
                r4.w = r3.w ^ l(61);
                r3.w = r3.w >> l(16);
                r3.w = r3.w ^ r4.w;
                null = r3.w * r3.w;
                r4.w = r3.w >> l(4);
                r3.w = r3.w ^ r4.w;
                null = r3.w * r3.w;
                r4.w = r3.w >> l(15);
                r1.z = r3.w ^ r4.w;
                // asm: imm_atomic_iadd r5.x, u0, l(1), l(1)
                r3.w = (r5.x >= l(0x00080000));
                if (r3.w) {
                    // asm: imm_atomic_iadd r5.x, u0, l(1), l(-1)
                }
                if (!(r3.w)) {
                    r5.yz = (float)r1.wwzw;
                    r5.yz = (r5.yyzy * l(0.000000, 0.000000, 0.000000, 0.000000)) + l(0.000000, -1.000000, -1.000000, 0.000000);
                    r7.yz = r4.xxzx * r5.yyzy;
                    r1.w = min(|r7.y|, l(0.080000));
                    r3.w = (r7.y < l(0.000000));
                    r3.w = (r3.w) ? l(-1.000000) : l(1.000000);
                    r7.x = r1.w * r3.w;
                    r7.w = l(0);
                    r5.yzw = r2.xxyz + r7.xxwz;
                    r7.xyz = r5.zzzz * cb0[2].xyzx;
                    r7.xyz = (r5.yyyy * cb0[1].xyzx) + r7.xyzx;
                    r5.yzw = (r5.wwww * cb0[3].xxyz) + r7.xxyz;
                    r7.xyz = r5.yzwy + cb0[4].xyzx;
                    // asm: imm_atomic_iadd r8.x, u1, l(0), l(-1)
                    // asm: ld_uav_typed_indexable(buffer)(uint,uint,uint,uint) r1.w, r8.xxxx, u1.yzwx
                    r3.w = r5.x + l(0x00080000);
                    r3.w = (cb1[131].z) ? r5.x : r3.w;
                    store_uav_typed(u3.xyzw, r3.wwww, r1.wwww);
                    // asm: bfi r7.w, l(11), l(0), cb0[12].z, r1.z
                    store_structured(u2.xyzw, r1.w, l(0), r7.xyzw);
                    r6.w = l(1.000000);
                    store_structured(u2.xyzw, r1.w, l(16), r6.xyzw);
                }
                r0.y = l(6);
            }
            r1.w = (r0.y < r0.z);
            r0.w = r0.w & r1.w;
            if (r0.w) {
                r1.w = (l(0x0019660d) * r1.z) + l(0x3c6ef35f);
                r3.w = r1.w ^ l(61);
                r1.w = r1.w >> l(16);
                r1.w = r1.w ^ r3.w;
                null = r1.w * r1.w;
                r3.w = r1.w >> l(4);
                r1.w = r1.w ^ r3.w;
                null = r1.w * r1.w;
                r3.w = r1.w >> l(15);
                r1.w = r1.w ^ r3.w;
                r3.w = (l(0x0019660d) * r1.w) + l(0x3c6ef35f);
                r4.w = r3.w ^ l(61);
                r3.w = r3.w >> l(16);
                r3.w = r3.w ^ r4.w;
                null = r3.w * r3.w;
                r4.w = r3.w >> l(4);
                r3.w = r3.w ^ r4.w;
                null = r3.w * r3.w;
                r4.w = r3.w >> l(15);
                r1.z = r3.w ^ r4.w;
                // asm: imm_atomic_iadd r5.x, u0, l(1), l(1)
                r3.w = (r5.x >= l(0x00080000));
                if (r3.w) {
                    // asm: imm_atomic_iadd r5.x, u0, l(1), l(-1)
                }
                if (!(r3.w)) {
                    r5.yz = (float)r1.wwzw;
                    r5.yz = (r5.yyzy * l(0.000000, 0.000000, 0.000000, 0.000000)) + l(0.000000, -1.000000, -1.000000, 0.000000);
                    r7.yz = r4.xxzx * r5.yyzy;
                    r1.w = min(|r7.y|, l(0.080000));
                    r3.w = (r7.y < l(0.000000));
                    r3.w = (r3.w) ? l(-1.000000) : l(1.000000);
                    r7.x = r1.w * r3.w;
                    r7.w = l(0);
                    r5.yzw = r2.xxyz + r7.xxwz;
                    r7.xyz = r5.zzzz * cb0[2].xyzx;
                    r7.xyz = (r5.yyyy * cb0[1].xyzx) + r7.xyzx;
                    r5.yzw = (r5.wwww * cb0[3].xxyz) + r7.xxyz;
                    r7.xyz = r5.yzwy + cb0[4].xyzx;
                    // asm: imm_atomic_iadd r8.x, u1, l(0), l(-1)
                    // asm: ld_uav_typed_indexable(buffer)(uint,uint,uint,uint) r1.w, r8.xxxx, u1.yzwx
                    r3.w = r5.x + l(0x00080000);
                    r3.w = (cb1[131].z) ? r5.x : r3.w;
                    store_uav_typed(u3.xyzw, r3.wwww, r1.wwww);
                    // asm: bfi r7.w, l(11), l(0), cb0[12].z, r1.z
                    store_structured(u2.xyzw, r1.w, l(0), r7.xyzw);
                    r6.w = l(1.000000);
                    store_structured(u2.xyzw, r1.w, l(16), r6.xyzw);
                }
                r0.y = l(7);
            }
            r0.y = (r0.y < r0.z);
            r0.y = r0.y & r0.w;
            if (r0.y) {
                r0.y = (l(0x0019660d) * r1.z) + l(0x3c6ef35f);
                r0.z = r0.y ^ l(61);
                r0.y = r0.y >> l(16);
                r0.y = r0.y ^ r0.z;
                null = r0.y * r0.y;
                r0.z = r0.y >> l(4);
                r0.y = r0.z ^ r0.y;
                null = r0.y * r0.y;
                r0.z = r0.y >> l(15);
                r0.y = r0.z ^ r0.y;
                r0.z = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
                r0.w = r0.z ^ l(61);
                r0.z = r0.z >> l(16);
                r0.z = r0.z ^ r0.w;
                null = r0.z * r0.z;
                r0.w = r0.z >> l(4);
                r0.z = r0.w ^ r0.z;
                null = r0.z * r0.z;
                r0.w = r0.z >> l(15);
                r1.z = r0.w ^ r0.z;
                // asm: imm_atomic_iadd r5.x, u0, l(1), l(1)
                r0.z = (r5.x >= l(0x00080000));
                if (r0.z) {
                    // asm: imm_atomic_iadd r5.x, u0, l(1), l(-1)
                }
                if (!(r0.z)) {
                    r0.y = (float)r0.y;
                    r0.z = (float)r1.z;
                    r0.yz = (r0.yyzy * l(0.000000, 0.000000, 0.000000, 0.000000)) + l(0.000000, -1.000000, -1.000000, 0.000000);
                    r7.yz = r4.xxzx * r0.yyzy;
                    r0.y = min(|r7.y|, l(0.080000));
                    r0.z = (r7.y < l(0.000000));
                    r0.z = (r0.z) ? l(-1.000000) : l(1.000000);
                    r7.x = r0.z * r0.y;
                    r7.w = l(0);
                    r0.yzw = r2.xxyz + r7.xxwz;
                    r2.xyz = r0.zzzz * cb0[2].xyzx;
                    r2.xyz = (r0.yyyy * cb0[1].xyzx) + r2.xyzx;
                    r0.yzw = (r0.wwww * cb0[3].xxyz) + r2.xxyz;
                    r7.xyz = r0.yzwy + cb0[4].xyzx;
                    // asm: imm_atomic_iadd r8.x, u1, l(0), l(-1)
                    // asm: ld_uav_typed_indexable(buffer)(uint,uint,uint,uint) r0.y, r8.xxxx, u1.yxzw
                    r0.z = r5.x + l(0x00080000);
                    r0.z = (cb1[131].z) ? r5.x : r0.z;
                    store_uav_typed(u3.xyzw, r0.zzzz, r0.yyyy);
                    // asm: bfi r7.w, l(11), l(0), cb0[12].z, r1.z
                    store_structured(u2.xyzw, r0.y, l(0), r7.xyzw);
                    r6.w = l(1.000000);
                    store_structured(u2.xyzw, r0.y, l(16), r6.xyzw);
                }
            }
        }
        // asm: ld_indexable(buffer)(uint,uint,uint,uint) r0.y, cb0[13].xxxx, t1.yxzw
        r0.x = (r0.x < l(1));
        r0.x = r0.x & r1.x;
        r0.z = (l(0.900000) < r1.y);
        r0.x = r0.z & r0.x;
        r0.z = (l(-0.005000) < r2.w);
        r0.x = r0.z & r0.x;
        r0.z = (l(0x0019660d) * r1.z) + l(0x3c6ef35f);
        r0.w = r0.z ^ l(61);
        r0.z = r0.z >> l(16);
        r0.z = r0.z ^ r0.w;
        null = r0.z * r0.z;
        r0.w = r0.z >> l(4);
        r0.z = r0.w ^ r0.z;
        null = r0.z * r0.z;
        r0.w = r0.z >> l(15);
        r0.z = r0.w ^ r0.z;
        r0.w = (float)r0.z;
        r0.w = r0.w * l(0.000000);
        r0.w = (r0.w < r4.y);
        r0.x = r0.w & r0.x;
        r0.y = (r0.y < l(10));
        r0.x = r0.y & r0.x;
        if (r0.x) {
            // asm: imm_atomic_iadd r1.x, u0, l(1), l(1)
            r0.x = (r1.x >= l(0x00080000));
            if (r0.x) {
                // asm: imm_atomic_iadd r1.x, u0, l(1), l(-1)
            }
            if (!(r0.x)) {
                r2.xyz = r3.xyzx + l(0.000000, 0.010000, 0.000000, 0.000000);
                // asm: imm_atomic_iadd r3.x, u1, l(0), l(-1)
                // asm: ld_uav_typed_indexable(buffer)(uint,uint,uint,uint) r0.x, r3.xxxx, u1.xyzw
                r0.y = r1.x + l(0x00080000);
                r0.y = (cb1[131].z) ? r1.x : r0.y;
                store_uav_typed(u3.xyzw, r0.yyyy, r0.xxxx);
                // asm: bfi r2.w, l(11), l(0), cb0[13].x, r0.z
                store_structured(u2.xyzw, r0.x, l(0), r2.xyzw);
                store_structured(u2.xyzw, r0.x, l(16), l(0,0,0,1.000000));
            }
        }
    }
    return;
    // asm: // Approximately 897 instruction slots used
}

// -----------------------------------------------------------------------------
// Shader 3
// Profile: cs_5_0
// Byte offset: 127072
// Byte length: 4760
// -----------------------------------------------------------------------------

// Reflected buffer definitions
cbuffer $Globals
{
  bool g_isTAAEnabledBranch;         // Offset:    0 Size:     4 [unused]
     = 0xffffffff 
  uint g_numRenderSets;              // Offset:    4 Size:     4 [unused]
  row_major float4x4 g_shipUnwrapperWorld;// Offset:   16 Size:    64 [unused]
  row_major float4x4 g_shipWorldInv; // Offset:   80 Size:    64 [unused]
  float4 g_shipSize;                 // Offset:  144 Size:    16 [unused]
  float g_shipSpeed;                 // Offset:  160 Size:     4 [unused]
  float g_shipMovementForward;       // Offset:  164 Size:     4 [unused]
  float4 g_textureSize;              // Offset:  176 Size:    16
  float g_rainAmount;                // Offset:  192 Size:     4 [unused]
  float g_shipFoamSpawnMinDistMult;  // Offset:  196 Size:     4 [unused]
  uint g_vfxIDShipRaindrop;          // Offset:  200 Size:     4 [unused]
  uint g_vfxIDShipFoam;              // Offset:  204 Size:     4 [unused]
  uint g_vfxIDShipTopWave;           // Offset:  208 Size:     4 [unused]
  uint g_vfxIDUnderwaterBubbles;     // Offset:  212 Size:     4 [unused]
  bool g_isShipSubmarine;            // Offset:  216 Size:     4 [unused]
}

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// g_bilinearWrapSampler             sampler      NA          NA             s0      1 
// g_sideWetnessTexture              texture  float4          2d             t0      1 
// g_topWetnessTexture               texture  float4          2d             t1      1 
// g_finalWetnessTextureUAV              UAV  float2          2d             u0      1 
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
void cs_03_cs_5_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_globalFlags refactoringAllowed
    // dcl_constantbuffer CB0[12], immediateIndexed
    // dcl_sampler s0, mode_default
    // dcl_resource_texture2d (float,float,float,float) t0
    // dcl_resource_texture2d (float,float,float,float) t1
    // dcl_uav_typed_texture2d (float,float,float,float) u0
    // dcl_input vThreadID.xy
    float4 r[5];
    // numthreads(16, 16, 1)
    r0.xy = (float)vThreadID.xyxx;
    r0.xy = r0.xyxx + l(0.500000, 0.500000, 0.000000, 0.000000);
    r0.xy = r0.xyxx * cb0[11].zwzz;
    // asm: resinfo_indexable(texture2d)(float,float,float,float) r0.zw, l(0), t0.zwxy
    r1.xy = (r0.xyxx * r0.zwzz) + l(0.500000, 0.500000, 0.000000, 0.000000);
    r0.zw = l(1.000000, 1.000000, 1.000000, 1.000000) / r0.zzzw;
    r1.zw = floor(r1.xxxy);
    r1.xy = frac(r1.xyxx);
    r2.xy = -r1.xyxx + l(3.000000, 3.000000, 0.000000, 0.000000);
    r2.xy = (r1.xyxx * r2.xyxx) + l(-3.000000, -3.000000, 0.000000, 0.000000);
    r2.xy = (r1.xyxx * r2.xyxx) + l(1.000000, 1.000000, 0.000000, 0.000000);
    r2.zw = r1.xxxy * r1.xxxy;
    r3.xyzw = (r1.xxyy * l(3.000000, -3.000000, 3.000000, -3.000000)) + l(-6.000000, 3.000000, -6.000000, 3.000000);
    r3.xz = (r2.zzwz * r3.xxzx) + l(4.000000, 0.000000, 4.000000, 0.000000);
    r2.zw = r1.xxxy * r2.zzzw;
    r2.zw = r2.zzzw * l(0.000000, 0.000000, 0.166667, 0.166667);
    r3.yw = (r1.xxxy * r3.yyyw) + l(0.000000, 3.000000, 0.000000, 3.000000);
    r1.xy = (r1.xyxx * r3.ywyy) + l(1.000000, 1.000000, 0.000000, 0.000000);
    r1.xy = (r1.xyxx * l(0.166667, 0.166667, 0.000000, 0.000000)) + r2.zwzz;
    r2.zw = r2.zzzw / r1.xxxy;
    r4.xy = r1.zwzz + r2.zwzz;
    r2.zw = r3.xxxz * l(0.000000, 0.000000, 0.166667, 0.166667);
    r2.xy = (r2.xyxx * l(0.166667, 0.166667, 0.000000, 0.000000)) + r2.zwzz;
    r2.zw = r2.zzzw / r2.xxxy;
    r4.zw = r1.zzzw + r2.zzzw;
    r3.xyzw = r4.zyxy + l(-1.500000, 0.500000, 0.500000, 0.500000);
    r4.xyzw = r4.zwxw + l(-1.500000, -1.500000, 0.500000, -1.500000);
    r4.xyzw = r0.zwzw * r4.xyzw;
    r3.xyzw = r0.zwzw * r3.xyzw;
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r0.z, r3.zwzz, t0.yzxw, s0, l(0.000000)
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r0.w, r3.xyxx, t0.yzwx, s0, l(0.000000)
    r0.z = r0.z * r1.x;
    r0.z = (r2.x * r0.w) + r0.z;
    r0.z = r0.z * r1.y;
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r0.w, r4.zwzz, t0.yzwx, s0, l(0.000000)
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r1.y, r4.xyxx, t0.yxzw, s0, l(0.000000)
    r0.w = r0.w * r1.x;
    r0.w = (r2.x * r1.y) + r0.w;
    r1.xzw = (r2.yyyy * r0.wwww) + r0.zzzz;
    // asm: resinfo_indexable(texture2d)(float,float,float,float) r0.zw, l(0), t1.zwxy
    r0.xy = (r0.xyxx * r0.zwzz) + l(0.500000, 0.500000, 0.000000, 0.000000);
    r0.zw = l(1.000000, 1.000000, 1.000000, 1.000000) / r0.zzzw;
    r2.xy = floor(r0.xyxx);
    r0.xy = frac(r0.xyxx);
    r2.zw = -r0.xxxy + l(0.000000, 0.000000, 3.000000, 3.000000);
    r2.zw = (r0.xxxy * r2.zzzw) + l(0.000000, 0.000000, -3.000000, -3.000000);
    r2.zw = (r0.xxxy * r2.zzzw) + l(0.000000, 0.000000, 1.000000, 1.000000);
    r3.xy = r0.xyxx * r0.xyxx;
    r4.xyzw = (r0.xxyy * l(3.000000, -3.000000, 3.000000, -3.000000)) + l(-6.000000, 3.000000, -6.000000, 3.000000);
    r3.zw = (r3.xxxy * r4.xxxz) + l(0.000000, 0.000000, 4.000000, 4.000000);
    r3.xy = r0.xyxx * r3.xyxx;
    r3.xy = r3.xyxx * l(0.166667, 0.166667, 0.000000, 0.000000);
    r4.xy = (r0.xyxx * r4.ywyy) + l(3.000000, 3.000000, 0.000000, 0.000000);
    r0.xy = (r0.xyxx * r4.xyxx) + l(1.000000, 1.000000, 0.000000, 0.000000);
    r0.xy = (r0.xyxx * l(0.166667, 0.166667, 0.000000, 0.000000)) + r3.xyxx;
    r3.xy = r3.xyxx / r0.xyxx;
    r4.xy = r2.xyxx + r3.xyxx;
    r3.xy = r3.zwzz * l(0.166667, 0.166667, 0.000000, 0.000000);
    r2.zw = (r2.zzzw * l(0.000000, 0.000000, 0.166667, 0.166667)) + r3.xxxy;
    r3.xy = r3.xyxx / r2.zwzz;
    r4.zw = r2.xxxy + r3.xxxy;
    r3.xyzw = r4.zyxy + l(-1.500000, 0.500000, 0.500000, 0.500000);
    r4.xyzw = r4.zwxw + l(-1.500000, -1.500000, 0.500000, -1.500000);
    r4.xyzw = r0.zwzw * r4.xyzw;
    r3.xyzw = r0.zwzw * r3.xyzw;
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r0.z, r3.zwzz, t1.yzxw, s0, l(0.000000)
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r0.w, r3.xyxx, t1.yzwx, s0, l(0.000000)
    r0.z = r0.z * r0.x;
    r0.z = (r2.z * r0.w) + r0.z;
    r0.y = r0.z * r0.y;
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r0.z, r4.zwzz, t1.yzxw, s0, l(0.000000)
    // asm: sample_l_indexable(texture2d)(float,float,float,float) r0.w, r4.xyxx, t1.yzwx, s0, l(0.000000)
    r0.x = r0.z * r0.x;
    r0.x = (r2.z * r0.w) + r0.x;
    r1.y = (r2.w * r0.x) + r0.y;
    store_uav_typed(u0.xyzw, vThreadID.xyyy, r1.xyzw);
    return;
    // asm: // Approximately 77 instruction slots used
}

