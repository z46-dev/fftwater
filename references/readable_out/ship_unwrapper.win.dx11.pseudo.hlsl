// Pseudo-HLSL generated from compiled shader bytecode.
// Source container: ship_unwrapper.win.dx11.fxo
//
// This is reconstructed for reading only.
// It is not original HLSL and should not be treated as recompilable source.

// -----------------------------------------------------------------------------
// Shader 0
// Profile: vs_5_0
// Byte offset: 18486
// Byte length: 3056
// -----------------------------------------------------------------------------

// Reflected buffer definitions
cbuffer $Globals
{
  bool g_isTAAEnabledBranch;         // Offset:    0 Size:     4 [unused]
     = 0xffffffff 
  row_major float4x4 g_shipUnwrapperInvWorld;// Offset:   16 Size:    64
  float4 g_shipSize;                 // Offset:   80 Size:    16
  bool g_isSideUnwrap;               // Offset:   96 Size:     4
  bool g_isRightSide;                // Offset:  100 Size:     4
}

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// $Globals                          cbuffer      NA          NA            cb0      1

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// POSITION                 0   xyzw        0     NONE   float   xyzw
// NORMAL                   0   x           1     NONE    uint       
// TEXCOORD                 0   xy          2     NONE   float       
// TEXCOORD                 4   xyzw        3     NONE   float   xyz 
// TEXCOORD                 5   xyzw        4     NONE   float   xyz 
// TEXCOORD                 6   xyzw        5     NONE   float   xyz 
// TEXCOORD                 7   xyzw        6     NONE   float   xyz 
// TEXCOORD                 8   xyzw        7     NONE   float       
// TEXCOORD                 9   xyzw        8     NONE   float       
// TEXCOORD                10   xyzw        9     NONE   float       
// TEXCOORD                11   xyzw       10     NONE   float       
// SV_InstanceId            0   x          11   INSTID    uint

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float   xyzw
// TEXCOORD                 0   x           1     NONE   float   x   
// TEXCOORD                 1    y          1     NONE   float    y  
// TEXCOORD                 2   xyz         2     NONE   float   xyz

void vs_00_vs_5_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_globalFlags refactoringAllowed
    // dcl_constantbuffer CB0[7], immediateIndexed
    // dcl_input v0.xyzw
    // dcl_input v3.xyz
    // dcl_input v4.xyz
    // dcl_input v5.xyz
    // dcl_input v6.xyz
    // dcl_output_siv o0.xyzw, position
    // dcl_output o1.x
    // dcl_output o1.y
    // dcl_output o2.xyz
    float4 r[2];
    r0.x = v3.y;
    r0.y = v4.y;
    r0.z = v5.y;
    r0.w = v6.y;
    r0.x = dot(v0.xyzw, r0.xyzw);
    r0.xyz = r0.xxxx * cb0[2].xyzx;
    r1.x = v3.x;
    r1.y = v4.x;
    r1.z = v5.x;
    r1.w = v6.x;
    r0.w = dot(v0.xyzw, r1.xyzw);
    r0.xyz = (r0.wwww * cb0[1].xyzx) + r0.xyzx;
    r1.x = v3.z;
    r1.y = v4.z;
    r1.z = v5.z;
    r1.w = v6.z;
    r0.w = dot(v0.xyzw, r1.xyzw);
    r0.xyz = (r0.wwww * cb0[3].xyzx) + r0.xyzx;
    r0.xyz = r0.xyzx + cb0[4].xyzx;
    r1.x = (cb0[6].y) ? l(1.000000) : l(-1.000000);
    r0.w = r0.x * r1.x;
    r1.x = dot2(r0.zwzz, r0.zwzz);
    r1.x = sqrt(r1.x);
    r1.x = max(r1.x, l(0.000001));
    r1.xy = r0.zwzz / r1.xxxx;
    r0.w = r1.y + l(1.000000);
    r0.w = r1.x / r0.w;
    r0.w = max(r0.w, l(-1.000000));
    r0.w = min(r0.w, l(1.000000));
    r1.x = log2(|r0.w|);
    r0.w = (l(0.000000) < r0.w);
    r0.w = (r0.w) ? l(1.000000) : l(-1.000000);
    r1.x = r1.x * l(2.100000);
    r1.x = exp2(r1.x);
    r0.w = r0.w * r1.x;
    r1.x = (-r0.w * l(0.500000)) + l(0.500000);
    r0.w = (r0.w * l(0.500000)) + l(-0.500000);
    r1.x = (cb0[6].y) ? r1.x : r0.w;
    r0.w = r0.y + -cb0[5].x;
    // asm: div_sat r0.w, r0.w, cb0[5].y
    r1.y = (r0.w * l(2.000000)) + l(-1.000000);
    r1.zw = (-cb0[5].wwwz * l(0.000000, 0.000000, -0.500000, -0.500000)) + r0.zzzx;
    // asm: div_sat r1.zw, r1.zzzw, cb0[5].wwwz
    r1.zw = (r1.zzzw * l(0.000000, 0.000000, 2.000000, 2.000000)) + l(0.000000, 0.000000, -1.000000, -1.000000);
    o0.xy = (cb0[6].xxxx) ? r1.xyxx : r1.zwzz;
    o0.zw = l(0,0,1.000000,1.000000);
    r0.w = dot(r0.xyzx, r0.xyzx);
    r1.x = sqrt(r0.w);
    r0.w = max(r1.x, l(0.000001));
    r1.y = r0.x / r0.w;
    r0.w = r0.y + l(20.000000);
    o2.xyz = r0.xyzx;
    r0.x = max(r0.w, l(0.000000));
    r0.y = l(0);
    o1.xy = (cb0[6].xxxx) ? r1.xyxx : r0.xyxx;
    return;
    // asm: // Approximately 56 instruction slots used
}

// -----------------------------------------------------------------------------
// Shader 1
// Profile: ps_5_0
// Byte offset: 21882
// Byte length: 1508
// -----------------------------------------------------------------------------

// Reflected buffer definitions
cbuffer $Globals
{
  bool g_isTAAEnabledBranch;         // Offset:    0 Size:     4 [unused]
     = 0xffffffff 
  row_major float4x4 g_shipUnwrapperInvWorld;// Offset:   16 Size:    64 [unused]
  float4 g_shipSize;                 // Offset:   80 Size:    16
  bool g_isSideUnwrap;               // Offset:   96 Size:     4
  bool g_isRightSide;                // Offset:  100 Size:     4
}

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// $Globals                          cbuffer      NA          NA            cb0      1

// Input signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float       
// TEXCOORD                 0   x           1     NONE   float   x   
// TEXCOORD                 1    y          1     NONE   float    y  
// TEXCOORD                 2   xyz         2     NONE   float   xyz

// Output signature
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Target                0   xyzw        0   TARGET   float   xyzw
// SV_Depth                 0    N/A   oDepth    DEPTH   float    YES

void ps_01_ps_5_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_globalFlags refactoringAllowed
    // dcl_constantbuffer CB0[7], immediateIndexed
    // dcl_input_ps linear v1.x
    // dcl_input_ps linear v1.y
    // dcl_input_ps linear v2.xyz
    // dcl_output o0.xyzw
    // dcl_output oDepth
    float4 r[1];
    r0.xy = (cb0[6].xyxx != l(0, 0, 0, 0));
    // asm: not r0.z, r0.y
    r0.y = r0.y & r0.x;
    r0.w = (v1.y < l(0.000000));
    r0.xy = r0.zwzz & r0.xyxx;
    // asm: discard_nz r0.y
    r0.y = (v1.y >= l(0.000000));
    r0.x = r0.y & r0.x;
    // asm: discard_nz r0.x
    r0.x = v1.x / cb0[5].w;
    r0.y = v1.x * l(0.025000);
    oDepth = (cb0[6].x) ? r0.x : r0.y;
    o0.xyz = v2.xyzx;
    o0.w = v1.x;
    return;
    // asm: // Approximately 15 instruction slots used
}

