// Pseudo-HLSL generated from compiled shader bytecode.
// Source container: reflection.win.dx11.fxo
//
// This is reconstructed for reading only.
// It is not original HLSL and should not be treated as recompilable source.

// -----------------------------------------------------------------------------
// Shader 0
// Profile: vs_4_0
// Byte offset: 18352
// Byte length: 3392
// -----------------------------------------------------------------------------

// Reflected buffer definitions
cbuffer $Globals
{
  bool g_isTAAEnabledBranch;         // Offset:    0 Size:     4 [unused]
     = 0xffffffff 
  float mipLevel;                    // Offset:    4 Size:     4 [unused]
     = 0x00000000 
  float seaLevel;                    // Offset:    8 Size:     4
     = 0x00000000 
  row_major float4x4 transformInverse;// Offset:   16 Size:    64
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
// g_depthTexSampler                 sampler      NA          NA             s0      1 
// colorSampler                      sampler      NA          NA             s1      1 
// g_depthTex                        texture  float4          2d             t0      1 
// colorTexture                      texture  float4          2d             t1      1 
// $Globals                          cbuffer      NA          NA            cb0      1 
// PerView                           cbuffer      NA          NA            cb1      1

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// POSITION                 0   xy          0     NONE   float   xy

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float   xyzw
// TEXCOORD                 0   xyzw        1     NONE   float   xyzw

void vs_00_vs_4_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_constantbuffer CB0[5], immediateIndexed
    // dcl_constantbuffer CB1[4], immediateIndexed
    // dcl_sampler s0, mode_default
    // dcl_sampler s1, mode_default
    // dcl_resource_texture2d (float,float,float,float) t0
    // dcl_resource_texture2d (float,float,float,float) t1
    // dcl_input v0.xy
    // dcl_output_siv o0.xyzw, position
    // dcl_output o1.xyzw
    float4 r[5];
    r0.xyzw = sample_l(v0.xyxx, t0.xyzw, s0, l(0.000000));
    r0.y = (v0.x * l(2.000000)) + l(-1.000000);
    r0.z = (-v0.y * l(2.000000)) + l(1.000000);
    r1.xyzw = r0.yyyy * cb0[1].xyzw;
    r2.xyzw = (r0.zzzz * cb0[2].xyzw) + r1.xyzw;
    r2.xyzw = (r0.xxxx * cb0[3].xyzw) + r2.xyzw;
    r2.xyzw = r2.xyzw + cb0[4].xyzw;
    r0.x = (l(0.000000) < r0.x);
    r0.y = r2.w * cb0[0].z;
    r0.y = (r0.y < r2.y);
    r0.x = r0.y & r0.x;
    r0.yz = v0.yyyy + l(0.000000, 0.500000, -0.500000, 0.000000);
    r0.w = (l(1.000000) < r0.y);
    r0.y = (r0.w) ? r0.z : r0.y;
    r3.x = (r0.x) ? v0.y : r0.y;
    if (!(r0.x)) {
        r3.y = v0.x;
        r4.xyzw = sample_l(r3.yxyy, t0.xyzw, s0, l(0.000000));
        r0.y = (-r3.x * l(2.000000)) + l(1.000000);
        r1.xyzw = (r0.yyyy * cb0[2].xyzw) + r1.xyzw;
        r1.xyzw = (r4.xxxx * cb0[3].xyzw) + r1.xyzw;
        r2.xyzw = r1.xyzw + cb0[4].xyzw;
        r0.y = (l(0.000000) < r4.x);
        r0.z = r2.w * cb0[0].z;
        r0.z = (r0.z < r2.y);
        r0.x = r0.z & r0.y;
        r0.yz = r3.xxxx + l(0.000000, 0.500000, -0.500000, 0.000000);
        r0.w = (l(1.000000) < r0.y);
        r0.y = (r0.w) ? r0.z : r0.y;
        r3.x = (r0.x) ? r3.x : r0.y;
    }
    if (!(r0.x)) {
        o0.xyzw = l(0,0,-1000.000000,1.000000);
        o1.xyzw = l(0,0,0,0);
        return;
    }
    r3.y = v0.x;
    r0.xyzw = sample_l(r3.yxyy, t1.xyzw, s1, l(0.000000));
    r1.xy = (r3.yxyy * l(2.000000, 2.000000, 0.000000, 0.000000)) + l(-1.000000, -1.000000, 0.000000, 0.000000);
    r1.xy = -|r1.xyxx| + l(1.000000, 1.000000, 0.000000, 0.000000);
    // asm: mul_sat r1.xy, r1.xyxx, l(25.000000, 25.000000, 0.000000, 0.000000)
    o1.w = min(r1.y, r1.x);
    r1.xyzw = r2.xyzw / r2.wwww;
    r2.xyzw = r1.yyyy * cb1[1].xyzw;
    r2.xyzw = (r1.xxxx * cb1[0].xyzw) + r2.xyzw;
    r2.xyzw = (r1.zzzz * cb1[2].xyzw) + r2.xyzw;
    r1.xyzw = (r1.wwww * cb1[3].xyzw) + r2.xyzw;
    o0.xyzw = r1.xyzw + l(0.000000, 0.000000, 0.001000, 0.000000);
    o1.xyz = r0.xyzx;
    return;
    // asm: // Approximately 50 instruction slots used
}

// -----------------------------------------------------------------------------
// Shader 1
// Profile: ps_4_0
// Byte offset: 21956
// Byte length: 516
// -----------------------------------------------------------------------------

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float       
// TEXCOORD                 0   xyzw        1     NONE   float   xyzw

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Target                0   xyzw        0   TARGET   float   xyzw

void ps_01_ps_4_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_input_ps linear v1.xyzw
    // dcl_output o0.xyzw
    float4 r[1];
    r0.x = (v1.w < l(0.001000));
    // asm: discard_nz r0.x
    o0.xyzw = v1.xyzw;
    return;
    // asm: // Approximately 4 instruction slots used
}

// -----------------------------------------------------------------------------
// Shader 2
// Profile: vs_4_0
// Byte offset: 22588
// Byte length: 568
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

void vs_02_vs_4_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

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
// Shader 3
// Profile: ps_4_0
// Byte offset: 23288
// Byte length: 888
// -----------------------------------------------------------------------------

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// g_pointClampSampler               sampler      NA          NA             s0      1 
// colorTexture                      texture  float4          2d             t0      1 
// depthTexture                      texture   float          2d             t1      1

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float       
// TEXCOORD                 0   xy          1     NONE   float   xy

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Target                0   xyzw        0   TARGET   float   xyzw

void ps_03_ps_4_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_sampler s0, mode_default
    // dcl_resource_texture2d (float,float,float,float) t0
    // dcl_resource_texture2d (float,float,float,float) t1
    // dcl_input_ps linear v1.xy
    // dcl_output o0.xyzw
    float4 r[1];
    r0.xyzw = sample_l(v1.xyxx, t0.xyzw, s0, l(0.000000));
    r0.w = dot(r0.xyzx, l(0.212500, 0.715400, 0.072100, 0.000000));
    r0.w = r0.w + l(1.000000);
    o0.xyz = r0.xyzx / r0.wwww;
    r0.xyzw = sample_l(v1.xyxx, t1.xyzw, s0, l(0.000000));
    r0.x = (r0.x == l(0.000000));
    o0.w = (r0.x) ? l(0) : l(1.000000);
    return;
    // asm: // Approximately 8 instruction slots used
}

// -----------------------------------------------------------------------------
// Shader 4
// Profile: ps_4_0
// Byte offset: 24340
// Byte length: 1336
// -----------------------------------------------------------------------------

// Reflected buffer definitions
cbuffer $Globals
{
  bool g_isTAAEnabledBranch;         // Offset:    0 Size:     4 [unused]
     = 0xffffffff 
  float mipLevel;                    // Offset:    4 Size:     4
     = 0x00000000 
  float seaLevel;                    // Offset:    8 Size:     4 [unused]
     = 0x00000000 
  row_major float4x4 transformInverse;// Offset:   16 Size:    64 [unused]
}
cbuffer PerScreen
{
  float4 g_screen;                   // Offset:    0 Size:    16
     = 0x00000000 0x00000000 0x00000000 0x00000000 
}

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// mipSamplerLinear                  sampler      NA          NA             s0      1 
// mipTexture                        texture  float4          2d             t0      1 
// $Globals                          cbuffer      NA          NA            cb0      1 
// PerScreen                         cbuffer      NA          NA            cb1      1

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float       
// TEXCOORD                 0   xy          1     NONE   float   xy

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Target                0   xyzw        0   TARGET   float   xyzw

void ps_04_ps_4_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_constantbuffer CB0[1], immediateIndexed
    // dcl_constantbuffer CB1[1], immediateIndexed
    // dcl_sampler s0, mode_default
    // dcl_resource_texture2d (float,float,float,float) t0
    // dcl_input_ps linear v1.xy
    // dcl_output o0.xyzw
    float4 r[2];
    r0.xy = (cb1[0].zwzz * l(0.500000, 0.000000, 0.000000, 0.000000)) + v1.xyxx;
    r0.xyzw = sample_l(r0.xyxx, t0.xyzw, s0, cb0[0].y);
    r1.xy = (-cb1[0].zwzz * l(0.500000, 0.000000, 0.000000, 0.000000)) + v1.xyxx;
    r1.xyzw = sample_l(r1.xyxx, t0.xyzw, s0, cb0[0].y);
    r0.xyzw = r0.xyzw + r1.xyzw;
    r0.xyzw = r0.xyzw * l(0.500000, 0.500000, 0.500000, 0.500000);
    o0.xyzw = max(r0.xyzw, l(0.000000, 0.000000, 0.000000, 0.000000));
    return;
    // asm: // Approximately 8 instruction slots used
}

