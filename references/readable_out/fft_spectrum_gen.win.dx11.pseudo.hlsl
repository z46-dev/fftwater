// Pseudo-HLSL generated from compiled shader bytecode.
// Source container: fft_spectrum_gen.win.dx11.fxo
//
// This is reconstructed for reading only.
// It is not original HLSL and should not be treated as recompilable source.

// -----------------------------------------------------------------------------
// Shader 0
// Profile: cs_5_0
// Byte offset: 19256
// Byte length: 9220
// -----------------------------------------------------------------------------

// Reflected buffer definitions
cbuffer $Globals
{
  bool g_isTAAEnabledBranch;         // Offset:    0 Size:     4 [unused]
     = 0xffffffff 
  float g_L;                         // Offset:    4 Size:     4
  float2 g_cutoffLowHigh;            // Offset:    8 Size:     8
  float g_dispMapSize;               // Offset:   16 Size:     4
  float g_gravity;                   // Offset:   20 Size:     4
  float g_depth;                     // Offset:   24 Size:     4
  float g_windSpeed;                 // Offset:   28 Size:     4
  float g_fetch;                     // Offset:   32 Size:     4
  float g_spectrumAmplitude;         // Offset:   36 Size:     4
  float g_peakEnhance;               // Offset:   40 Size:     4
  float g_windAngle;                 // Offset:   44 Size:     4
  float g_spreadBlend;               // Offset:   48 Size:     4
  float g_swell;                     // Offset:   52 Size:     4
  float g_windSpeedLargeWave;        // Offset:   56 Size:     4 [unused]
  float g_fetchLargeWave;            // Offset:   60 Size:     4 [unused]
  float g_spectrumAmplitudeLargeWave;// Offset:   64 Size:     4 [unused]
  float g_peakEnhanceLargeWave;      // Offset:   68 Size:     4 [unused]
  float g_windAngleLargeWave;        // Offset:   72 Size:     4 [unused]
  float g_spreadBlendLargeWave;      // Offset:   76 Size:     4 [unused]
  float g_swellLargeWave;            // Offset:   80 Size:     4 [unused]
  float g_currSimTime;               // Offset:   84 Size:     4 [unused]
}

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// g_h0OutTexture                        UAV  float2          2d             u0      1 
// g_omegaOutTexture                     UAV   float          2d             u1      1 
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
void cs_00_cs_5_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_globalFlags refactoringAllowed
    // dcl_constantbuffer CB0[4], immediateIndexed
    // dcl_uav_typed_texture2d (float,float,float,float) u0
    // dcl_uav_typed_texture2d (float,float,float,float) u1
    // dcl_input vThreadID.xy
    float4 r[4];
    // numthreads(16, 16, 1)
    r0.x = (int)cb0[1].x;
    r0.y = r0.x + l(1);
    r0.zw = (r0.yyyy < vThreadID.xxxy);
    r0.z = r0.w | r0.z;
    if (r0.z) {
        return;
    }
    r0.z = r0.x ^ l(2);
    // asm: imax r0.x, r0.x, -r0.x
    r0.x = r0.x >> l(1);
    // asm: ineg r0.w, r0.x
    r0.z = r0.z & l(0x80000000);
    r0.x = (r0.z) ? r0.w : r0.x;
    r0.xz = r0.xxxx + -vThreadID.yyxy;
    r0.xz = (float)r0.xxzx;
    r0.xz = r0.xxzx * l(6.283185, 0.000000, 6.283185, 0.000000);
    r0.xz = r0.xxzx / cb0[0].yyyy;
    r0.w = dot2(r0.xzxx, r0.xzxx);
    r1.x = sqrt(r0.w);
    r1.y = (r1.x >= cb0[0].z);
    r1.z = (cb0[0].w >= r1.x);
    r1.y = r1.z & r1.y;
    if (r1.y) {
        r1.yz = (r0.zzxz != l(0.000000, 0.000000, 0.000000, 0.000000));
        r1.y = r1.z | r1.y;
        if (r1.y) {
            r0.y = (vThreadID.y * r0.y) + vThreadID.x;
            r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
            r1.y = r0.y ^ l(61);
            r0.y = r0.y >> l(16);
            r0.y = r0.y ^ r1.y;
            null = r0.y * r0.y;
            r1.y = r0.y >> l(4);
            r0.y = r0.y ^ r1.y;
            null = r0.y * r0.y;
            r1.y = r0.y >> l(15);
            r0.y = r0.y ^ r1.y;
            r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
            r1.y = r0.y ^ l(61);
            r0.y = r0.y >> l(16);
            r0.y = r0.y ^ r1.y;
            null = r0.y * r0.y;
            r1.y = r0.y >> l(4);
            r0.y = r0.y ^ r1.y;
            null = r0.y * r0.y;
            r1.y = r0.y >> l(15);
            r0.y = r0.y ^ r1.y;
            r1.y = (float)r0.y;
            r1.z = r1.y * l(0.000000);
            r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
            r1.w = r0.y ^ l(61);
            r0.y = r0.y >> l(16);
            r0.y = r0.y ^ r1.w;
            null = r0.y * r0.y;
            r1.w = r0.y >> l(4);
            r0.y = r0.y ^ r1.w;
            null = r0.y * r0.y;
            r1.w = r0.y >> l(15);
            r0.y = r0.y ^ r1.w;
            r1.w = (float)r0.y;
            r1.y = (r1.y < l(4294.967285));
            r1.z = log2(r1.z);
            r1.z = r1.z * l(-1.386294);
            r1.z = sqrt(r1.z);
            r1.y = (r1.y) ? l(5.256522) : r1.z;
            r1.z = r1.w * l(0.000000);
            sincos(null, r1.z, r1.z);
            r2.x = r1.z * r1.y;
            r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
            r1.y = r0.y ^ l(61);
            r0.y = r0.y >> l(16);
            r0.y = r0.y ^ r1.y;
            null = r0.y * r0.y;
            r1.y = r0.y >> l(4);
            r0.y = r0.y ^ r1.y;
            null = r0.y * r0.y;
            r1.y = r0.y >> l(15);
            r0.y = r0.y ^ r1.y;
            r1.y = (float)r0.y;
            r1.z = r1.y * l(0.000000);
            r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
            r1.w = r0.y ^ l(61);
            r0.y = r0.y >> l(16);
            r0.y = r0.y ^ r1.w;
            null = r0.y * r0.y;
            r1.w = r0.y >> l(4);
            r0.y = r0.y ^ r1.w;
            null = r0.y * r0.y;
            r1.w = r0.y >> l(15);
            r0.y = r0.y ^ r1.w;
            r0.y = (float)r0.y;
            r1.y = (r1.y < l(4294.967285));
            r1.z = log2(r1.z);
            r1.z = r1.z * l(-1.386294);
            r1.z = sqrt(r1.z);
            r1.y = (r1.y) ? l(5.256522) : r1.z;
            r0.y = r0.y * l(0.000000);
            sincos(null, r0.y, r0.y);
            r2.y = r0.y * r1.y;
            r0.y = min(|r0.z|, |r0.x|);
            r1.y = max(|r0.z|, |r0.x|);
            r1.y = l(1.000000, 1.000000, 1.000000, 1.000000) / r1.y;
            r0.y = r0.y * r1.y;
            r1.y = r0.y * r0.y;
            r1.z = (r1.y * l(0.020835)) + l(-0.085133);
            r1.z = (r1.y * r1.z) + l(0.180141);
            r1.z = (r1.y * r1.z) + l(-0.330299);
            r1.y = (r1.y * r1.z) + l(0.999866);
            r1.z = r0.y * r1.y;
            r1.w = (|r0.z| < |r0.x|);
            r1.z = (r1.z * l(-2.000000)) + l(1.570796);
            r1.z = r1.w & r1.z;
            r0.y = (r0.y * r1.y) + r1.z;
            r1.y = (r0.z < -r0.z);
            r1.y = r1.y & l(0xc0490fdb);
            r0.y = r0.y + r1.y;
            r1.y = min(r0.z, r0.x);
            r0.x = max(r0.z, r0.x);
            r0.z = (r1.y < -r1.y);
            r0.x = (r0.x >= -r0.x);
            r0.x = r0.x & r0.z;
            r0.x = (r0.x) ? -r0.y : r0.y;
            r0.yz = r1.xxxx * cb0[1].yyzy;
            r1.y = min(r0.z, l(20.000000));
            r1.y = r1.y * l(1.442695);
            r1.z = exp2(r1.y);
            r1.y = exp2(-r1.y);
            r1.w = -r1.y + r1.z;
            r1.y = r1.y + r1.z;
            r1.y = l(1.000000, 1.000000, 1.000000, 1.000000) / r1.y;
            r1.z = r1.y * r1.w;
            r0.y = r0.y * r1.z;
            r0.y = sqrt(r0.y);
            r1.z = r0.z * l(1.442695);
            r2.z = exp2(r1.z);
            r1.z = exp2(-r1.z);
            r1.z = r1.z + r2.z;
            r1.z = r1.z * l(0.500000);
            r0.z = r0.z / r1.z;
            r0.z = r0.z / r1.z;
            r0.z = (r1.w * r1.y) + r0.z;
            r0.z = r0.z * cb0[1].y;
            r0.z = r0.z / r0.y;
            r1.yz = cb0[1].wwyw * cb0[2].xxxx;
            r1.yz = r1.yyzy / cb0[1].yywy;
            r1.yz = r1.yyzy / cb0[1].yywy;
            r1.yz = log2(r1.yyzy);
            r1.yz = r1.yyzy * l(0.000000, -0.330000, -0.220000, 0.000000);
            r1.yz = exp2(r1.yyzy);
            r1.zw = r1.yyyz * l(0.000000, 0.000000, 22.000000, 0.076000);
            r2.z = (r1.z >= r0.y);
            r2.z = (r2.z) ? l(0.070000) : l(0.090000);
            r1.y = (-r1.y * l(22.000000)) + r0.y;
            r1.y = r1.y * -r1.y;
            r1.y = r1.y * l(0.500000);
            r1.y = r1.y / r2.z;
            r1.y = r1.y / r2.z;
            r1.y = r1.y / r1.z;
            r1.y = r1.y / r1.z;
            r1.y = r1.y * l(1.442695);
            r1.y = exp2(r1.y);
            r2.z = l(1.000000, 1.000000, 1.000000, 1.000000) / r0.y;
            r2.w = r1.z / r0.y;
            r3.x = cb0[1].z / cb0[1].y;
            r3.x = sqrt(r3.x);
            r3.y = r0.y * r3.x;
            r3.z = r3.y * r3.y;
            r3.z = r3.z * l(0.500000);
            r3.w = (l(1.000000) < r3.y);
            r3.y = (r3.y < l(2.000000));
            r3.x = (-r0.y * r3.x) + l(2.000000);
            r3.x = r3.x * r3.x;
            r3.x = (-r3.x * l(0.500000)) + l(1.000000);
            r3.x = (r3.y) ? r3.x : l(1.000000);
            r3.x = (r3.w) ? r3.x : r3.z;
            r3.x = r3.x * cb0[2].y;
            r1.w = r1.w * r3.x;
            r3.x = cb0[1].y * cb0[1].y;
            r1.w = r1.w * r3.x;
            r3.x = r2.z * r2.z;
            r3.x = r3.x * r3.x;
            r1.w = r1.w * r3.x;
            r1.w = r2.z * r1.w;
            r2.z = r2.w * r2.w;
            r2.z = r2.z * r2.z;
            r2.z = r2.z * l(-1.803369);
            r2.z = exp2(r2.z);
            r1.w = r1.w * r2.z;
            r2.z = log2(|cb0[2].z|);
            r1.y = r1.y * r2.z;
            r1.y = exp2(r1.y);
            r1.y = r1.y * r1.w;
            r1.w = (r1.z < r0.y);
            r1.z = r0.y / r1.z;
            r2.z = log2(r1.z);
            r2.z = r2.z * l(-2.500000);
            r2.z = exp2(r2.z);
            r2.w = r1.z * r1.z;
            r2.w = r2.w * r2.w;
            r2.w = r1.z * r2.w;
            r2.zw = r2.zzzw * l(0.000000, 0.000000, 9.770000, 6.970000);
            r1.w = (r1.w) ? r2.z : r2.w;
            r1.z = min(r1.z, l(20.000000));
            r1.z = r1.z * l(1.442695);
            r2.z = exp2(r1.z);
            r1.z = exp2(-r1.z);
            r2.w = -r1.z + r2.z;
            r1.z = r1.z + r2.z;
            r1.z = l(1.000000, 1.000000, 1.000000, 1.000000) / r1.z;
            r1.z = r1.z * r2.w;
            r2.z = cb0[3].y * cb0[3].y;
            r1.z = r1.z * r2.z;
            r1.z = (r1.z * l(16.000000)) + r1.w;
            sincos(null, r1.w, r0.x);
            r1.w = r1.w * r1.w;
            r1.w = r1.w * l(0.636639);
            r0.x = r0.x + -cb0[2].w;
            r2.z = r1.z * r1.z;
            r2.w = r1.z * r2.z;
            r3.x = r1.z * r2.w;
            r3.y = (r1.z < l(5.000000));
            r3.zw = r2.wwww * l(0.000000, 0.000000, 0.007760, 0.000011);
            r3.xz = (r3.xxxx * l(-0.000564, 0.000000, -0.000000, 0.000000)) + r3.zzwz;
            r2.zw = (-r2.zzzz * l(0.000000, 0.000000, 0.044000, 0.000953)) + r3.xxxz;
            r2.zw = (r1.zzzz * l(0.000000, 0.000000, 0.192000, 0.059000)) + r2.zzzw;
            r2.zw = r2.zzzw + l(0.000000, 0.000000, 0.163000, 0.393000);
            r2.z = (r3.y) ? r2.z : r2.w;
            r0.xz = r0.xxzx * l(0.500000, 0.000000, 0.500000, 0.000000);
            sincos(null, r0.x, r0.x);
            r1.z = r1.z + r1.z;
            r0.x = log2(|r0.x|);
            r0.x = r0.x * r1.z;
            r0.x = exp2(r0.x);
            r0.x = (r2.z * r0.x) + -r1.w;
            r0.x = (cb0[3].x * r0.x) + r1.w;
            r0.x = r0.x * r1.y;
            r0.w = r0.w * l(-0.000144);
            r0.w = exp2(r0.w);
            r1.y = l(6.283185) / cb0[0].y;
            r0.x = dot2(r0.xxxx, r0.wwww);
            r0.x = |r0.z| * r0.x;
            r0.x = r0.x / r1.x;
            r0.z = r1.y * r1.y;
            r0.x = r0.x * r0.z;
            r0.x = sqrt(r0.x);
            r0.xz = r0.xxxx * r2.xxyx;
        else
            r0.xyz = l(0,0,0,0);
        }
    else
        r0.xyz = l(0,0,0,0);
    }
    store_uav_typed(u0.xyzw, vThreadID.xyyy, r0.xzxx);
    store_uav_typed(u1.xyzw, vThreadID.xyyy, r0.yyyy);
    return;
    // asm: // Approximately 255 instruction slots used
}

// -----------------------------------------------------------------------------
// Shader 1
// Profile: cs_5_0
// Byte offset: 28592
// Byte length: 11672
// -----------------------------------------------------------------------------

// Reflected buffer definitions
cbuffer $Globals
{
  bool g_isTAAEnabledBranch;         // Offset:    0 Size:     4 [unused]
     = 0xffffffff 
  float g_L;                         // Offset:    4 Size:     4
  float2 g_cutoffLowHigh;            // Offset:    8 Size:     8
  float g_dispMapSize;               // Offset:   16 Size:     4
  float g_gravity;                   // Offset:   20 Size:     4
  float g_depth;                     // Offset:   24 Size:     4
  float g_windSpeed;                 // Offset:   28 Size:     4
  float g_fetch;                     // Offset:   32 Size:     4
  float g_spectrumAmplitude;         // Offset:   36 Size:     4
  float g_peakEnhance;               // Offset:   40 Size:     4
  float g_windAngle;                 // Offset:   44 Size:     4
  float g_spreadBlend;               // Offset:   48 Size:     4
  float g_swell;                     // Offset:   52 Size:     4
  float g_windSpeedLargeWave;        // Offset:   56 Size:     4
  float g_fetchLargeWave;            // Offset:   60 Size:     4
  float g_spectrumAmplitudeLargeWave;// Offset:   64 Size:     4
  float g_peakEnhanceLargeWave;      // Offset:   68 Size:     4
  float g_windAngleLargeWave;        // Offset:   72 Size:     4
  float g_spreadBlendLargeWave;      // Offset:   76 Size:     4
  float g_swellLargeWave;            // Offset:   80 Size:     4
  float g_currSimTime;               // Offset:   84 Size:     4 [unused]
}

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// g_h0OutTexture                        UAV  float2          2d             u0      1 
// g_omegaOutTexture                     UAV   float          2d             u1      1 
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
    // dcl_constantbuffer CB0[6], immediateIndexed
    // dcl_uav_typed_texture2d (float,float,float,float) u0
    // dcl_uav_typed_texture2d (float,float,float,float) u1
    // dcl_input vThreadID.xy
    float4 r[6];
    // numthreads(16, 16, 1)
    r0.x = (int)cb0[1].x;
    r0.y = r0.x + l(1);
    r0.zw = (r0.yyyy < vThreadID.xxxy);
    r0.z = r0.w | r0.z;
    if (r0.z) {
        return;
    }
    r0.z = r0.x ^ l(2);
    // asm: imax r0.x, r0.x, -r0.x
    r0.x = r0.x >> l(1);
    // asm: ineg r0.w, r0.x
    r0.z = r0.z & l(0x80000000);
    r0.x = (r0.z) ? r0.w : r0.x;
    r0.xz = r0.xxxx + -vThreadID.yyxy;
    r0.xz = (float)r0.xxzx;
    r0.xz = r0.xxzx * l(6.283185, 0.000000, 6.283185, 0.000000);
    r0.xz = r0.xxzx / cb0[0].yyyy;
    r0.w = dot2(r0.xzxx, r0.xzxx);
    r1.x = sqrt(r0.w);
    r1.y = (r1.x >= cb0[0].z);
    r1.z = (cb0[0].w >= r1.x);
    r1.y = r1.z & r1.y;
    if (r1.y) {
        r1.yz = (r0.zzxz != l(0.000000, 0.000000, 0.000000, 0.000000));
        r1.y = r1.z | r1.y;
        if (r1.y) {
            r0.y = (vThreadID.y * r0.y) + vThreadID.x;
            r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
            r1.y = r0.y ^ l(61);
            r0.y = r0.y >> l(16);
            r0.y = r0.y ^ r1.y;
            null = r0.y * r0.y;
            r1.y = r0.y >> l(4);
            r0.y = r0.y ^ r1.y;
            null = r0.y * r0.y;
            r1.y = r0.y >> l(15);
            r0.y = r0.y ^ r1.y;
            r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
            r1.y = r0.y ^ l(61);
            r0.y = r0.y >> l(16);
            r0.y = r0.y ^ r1.y;
            null = r0.y * r0.y;
            r1.y = r0.y >> l(4);
            r0.y = r0.y ^ r1.y;
            null = r0.y * r0.y;
            r1.y = r0.y >> l(15);
            r0.y = r0.y ^ r1.y;
            r1.y = (float)r0.y;
            r1.z = r1.y * l(0.000000);
            r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
            r1.w = r0.y ^ l(61);
            r0.y = r0.y >> l(16);
            r0.y = r0.y ^ r1.w;
            null = r0.y * r0.y;
            r1.w = r0.y >> l(4);
            r0.y = r0.y ^ r1.w;
            null = r0.y * r0.y;
            r1.w = r0.y >> l(15);
            r0.y = r0.y ^ r1.w;
            r1.w = (float)r0.y;
            r1.y = (r1.y < l(4294.967285));
            r1.z = log2(r1.z);
            r1.z = r1.z * l(-1.386294);
            r1.z = sqrt(r1.z);
            r1.y = (r1.y) ? l(5.256522) : r1.z;
            r1.z = r1.w * l(0.000000);
            sincos(null, r1.z, r1.z);
            r2.x = r1.z * r1.y;
            r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
            r1.y = r0.y ^ l(61);
            r0.y = r0.y >> l(16);
            r0.y = r0.y ^ r1.y;
            null = r0.y * r0.y;
            r1.y = r0.y >> l(4);
            r0.y = r0.y ^ r1.y;
            null = r0.y * r0.y;
            r1.y = r0.y >> l(15);
            r0.y = r0.y ^ r1.y;
            r1.y = (float)r0.y;
            r1.z = r1.y * l(0.000000);
            r0.y = (l(0x0019660d) * r0.y) + l(0x3c6ef35f);
            r1.w = r0.y ^ l(61);
            r0.y = r0.y >> l(16);
            r0.y = r0.y ^ r1.w;
            null = r0.y * r0.y;
            r1.w = r0.y >> l(4);
            r0.y = r0.y ^ r1.w;
            null = r0.y * r0.y;
            r1.w = r0.y >> l(15);
            r0.y = r0.y ^ r1.w;
            r0.y = (float)r0.y;
            r1.y = (r1.y < l(4294.967285));
            r1.z = log2(r1.z);
            r1.z = r1.z * l(-1.386294);
            r1.z = sqrt(r1.z);
            r1.y = (r1.y) ? l(5.256522) : r1.z;
            r0.y = r0.y * l(0.000000);
            sincos(null, r0.y, r0.y);
            r2.y = r0.y * r1.y;
            r0.y = min(|r0.z|, |r0.x|);
            r1.y = max(|r0.z|, |r0.x|);
            r1.y = l(1.000000, 1.000000, 1.000000, 1.000000) / r1.y;
            r0.y = r0.y * r1.y;
            r1.y = r0.y * r0.y;
            r1.z = (r1.y * l(0.020835)) + l(-0.085133);
            r1.z = (r1.y * r1.z) + l(0.180141);
            r1.z = (r1.y * r1.z) + l(-0.330299);
            r1.y = (r1.y * r1.z) + l(0.999866);
            r1.z = r0.y * r1.y;
            r1.w = (|r0.z| < |r0.x|);
            r1.z = (r1.z * l(-2.000000)) + l(1.570796);
            r1.z = r1.w & r1.z;
            r0.y = (r0.y * r1.y) + r1.z;
            r1.y = (r0.z < -r0.z);
            r1.y = r1.y & l(0xc0490fdb);
            r0.y = r0.y + r1.y;
            r1.y = min(r0.z, r0.x);
            r0.x = max(r0.z, r0.x);
            r0.z = (r1.y < -r1.y);
            r0.x = (r0.x >= -r0.x);
            r0.x = r0.x & r0.z;
            r0.x = (r0.x) ? -r0.y : r0.y;
            r0.yz = r1.xxxx * cb0[1].yyzy;
            r1.y = min(r0.z, l(20.000000));
            r1.y = r1.y * l(1.442695);
            r1.z = exp2(r1.y);
            r1.y = exp2(-r1.y);
            r1.w = -r1.y + r1.z;
            r1.y = r1.y + r1.z;
            r1.y = l(1.000000, 1.000000, 1.000000, 1.000000) / r1.y;
            r1.z = r1.y * r1.w;
            r0.y = r0.y * r1.z;
            r0.y = sqrt(r0.y);
            r1.z = r0.z * l(1.442695);
            r2.z = exp2(r1.z);
            r1.z = exp2(-r1.z);
            r1.z = r1.z + r2.z;
            r1.z = r1.z * l(0.500000);
            r0.z = r0.z / r1.z;
            r0.z = r0.z / r1.z;
            r0.z = (r1.w * r1.y) + r0.z;
            r0.z = r0.z * cb0[1].y;
            r0.z = r0.z / r0.y;
            r1.yz = cb0[1].wwyw * cb0[2].xxxx;
            r1.yz = r1.yyzy / cb0[1].yywy;
            r1.yz = r1.yyzy / cb0[1].yywy;
            r1.yz = log2(r1.yyzy);
            r1.yz = r1.yyzy * l(0.000000, -0.330000, -0.220000, 0.000000);
            r1.yz = exp2(r1.yyzy);
            r1.zw = r1.yyyz * l(0.000000, 0.000000, 22.000000, 0.076000);
            r2.z = (r1.z >= r0.y);
            r2.z = (r2.z) ? l(0.070000) : l(0.090000);
            r1.y = (-r1.y * l(22.000000)) + r0.y;
            r1.y = r1.y * -r1.y;
            r1.y = r1.y * l(0.500000);
            r1.y = r1.y / r2.z;
            r1.y = r1.y / r2.z;
            r1.y = r1.y / r1.z;
            r1.y = r1.y / r1.z;
            r1.y = r1.y * l(1.442695);
            r1.y = exp2(r1.y);
            r2.z = l(1.000000, 1.000000, 1.000000, 1.000000) / r0.y;
            r2.w = r1.z / r0.y;
            r3.x = cb0[1].z / cb0[1].y;
            r3.x = sqrt(r3.x);
            r3.y = r0.y * r3.x;
            r3.z = r3.y * r3.y;
            r3.z = r3.z * l(0.500000);
            r3.w = (l(1.000000) < r3.y);
            r3.y = (r3.y < l(2.000000));
            r3.x = (-r0.y * r3.x) + l(2.000000);
            r3.x = r3.x * r3.x;
            r3.x = (-r3.x * l(0.500000)) + l(1.000000);
            r3.x = (r3.y) ? r3.x : l(1.000000);
            r3.x = (r3.w) ? r3.x : r3.z;
            r3.y = r3.x * cb0[2].y;
            r1.w = r1.w * r3.y;
            r3.y = cb0[1].y * cb0[1].y;
            r1.w = r1.w * r3.y;
            r3.z = r2.z * r2.z;
            r3.z = r3.z * r3.z;
            r1.w = r1.w * r3.z;
            r1.w = r2.z * r1.w;
            r2.w = r2.w * r2.w;
            r2.w = r2.w * r2.w;
            r2.w = r2.w * l(-1.803369);
            r2.w = exp2(r2.w);
            r1.w = r1.w * r2.w;
            r2.w = log2(|cb0[2].z|);
            r1.y = r1.y * r2.w;
            r1.y = exp2(r1.y);
            r1.y = r1.y * r1.w;
            r1.w = (r1.z < r0.y);
            r1.z = r0.y / r1.z;
            r2.w = log2(r1.z);
            r2.w = r2.w * l(-2.500000);
            r2.w = exp2(r2.w);
            r2.w = r2.w * l(9.770000);
            r3.w = r1.z * r1.z;
            r3.w = r3.w * r3.w;
            r3.w = r1.z * r3.w;
            r3.w = r3.w * l(6.970000);
            r1.w = (r1.w) ? r2.w : r3.w;
            r1.z = min(r1.z, l(20.000000));
            r1.z = r1.z * l(1.442695);
            r2.w = exp2(r1.z);
            r1.z = exp2(-r1.z);
            r3.w = -r1.z + r2.w;
            r1.z = r1.z + r2.w;
            r1.z = l(1.000000, 1.000000, 1.000000, 1.000000) / r1.z;
            r1.z = r1.z * r3.w;
            r4.xy = cb0[3].ywyy * cb0[3].yzyy;
            r1.z = r1.z * r4.x;
            r1.z = (r1.z * l(16.000000)) + r1.w;
            sincos(null, r1.w, r0.x);
            r1.w = r1.w * r1.w;
            r1.w = r1.w * l(0.636639);
            r2.w = r0.x + -cb0[2].w;
            r3.w = r1.z * r1.z;
            r4.x = r1.z * r3.w;
            r4.z = r1.z * r4.x;
            r4.w = (r1.z < l(5.000000));
            r5.xy = r4.xxxx * l(0.007760, 0.000011, 0.000000, 0.000000);
            r4.xz = (r4.zzzz * l(-0.000564, 0.000000, -0.000000, 0.000000)) + r5.xxyx;
            r4.xz = (-r3.wwww * l(0.044000, 0.000000, 0.000953, 0.000000)) + r4.xxzx;
            r4.xz = (r1.zzzz * l(0.192000, 0.000000, 0.059000, 0.000000)) + r4.xxzx;
            r4.xz = r4.xxzx + l(0.163000, 0.000000, 0.393000, 0.000000);
            r3.w = (r4.w) ? r4.x : r4.z;
            r2.w = r2.w * l(0.500000);
            sincos(null, r2.w, r2.w);
            r1.z = r1.z + r1.z;
            r2.w = log2(|r2.w|);
            r1.z = r1.z * r2.w;
            r1.z = exp2(r1.z);
            r1.z = (r3.w * r1.z) + -r1.w;
            r1.z = (cb0[3].x * r1.z) + r1.w;
            r1.y = r1.z * r1.y;
            r0.w = r0.w * l(-0.000144);
            r0.w = exp2(r0.w);
            r1.z = r4.y / cb0[1].y;
            r1.z = r1.z / cb0[1].y;
            r1.z = log2(r1.z);
            r1.z = r1.z * l(-0.330000);
            r1.z = exp2(r1.z);
            r2.w = r1.z * l(22.000000);
            r3.w = cb0[1].y * cb0[3].w;
            r3.w = r3.w / cb0[3].z;
            r3.w = r3.w / cb0[3].z;
            r3.w = log2(r3.w);
            r3.w = r3.w * l(-0.220000);
            r3.w = exp2(r3.w);
            r3.w = r3.w * l(0.076000);
            r4.x = (r2.w >= r0.y);
            r4.x = (r4.x) ? l(0.070000) : l(0.090000);
            r1.z = (-r1.z * l(22.000000)) + r0.y;
            r1.z = r1.z * -r1.z;
            r1.z = r1.z * l(0.500000);
            r1.z = r1.z / r4.x;
            r1.z = r1.z / r4.x;
            r1.z = r1.z / r2.w;
            r1.z = r1.z / r2.w;
            r1.z = r1.z * l(1.442695);
            r1.z = exp2(r1.z);
            r4.x = r2.w / r0.y;
            r3.x = r3.x * cb0[4].x;
            r3.x = r3.w * r3.x;
            r3.x = r3.x * r3.y;
            r3.x = r3.z * r3.x;
            r2.z = r2.z * r3.x;
            r3.x = r4.x * r4.x;
            r3.x = r3.x * r3.x;
            r3.x = r3.x * l(-1.803369);
            r3.x = exp2(r3.x);
            r2.z = r2.z * r3.x;
            r3.x = log2(|cb0[4].y|);
            r1.z = r1.z * r3.x;
            r1.z = exp2(r1.z);
            r1.z = r1.z * r2.z;
            r2.z = (r2.w < r0.y);
            r2.w = r0.y / r2.w;
            r3.x = log2(r2.w);
            r3.x = r3.x * l(-2.500000);
            r3.x = exp2(r3.x);
            r3.y = r2.w * r2.w;
            r3.y = r3.y * r3.y;
            r3.y = r2.w * r3.y;
            r3.xy = r3.xyxx * l(9.770000, 6.970000, 0.000000, 0.000000);
            r2.z = (r2.z) ? r3.x : r3.y;
            r2.w = min(r2.w, l(20.000000));
            r2.w = r2.w * l(1.442695);
            r3.x = exp2(r2.w);
            r2.w = exp2(-r2.w);
            r3.y = -r2.w + r3.x;
            r2.w = r2.w + r3.x;
            r2.w = l(1.000000, 1.000000, 1.000000, 1.000000) / r2.w;
            r2.w = r2.w * r3.y;
            r3.x = cb0[5].x * cb0[5].x;
            r2.w = r2.w * r3.x;
            r2.z = (r2.w * l(16.000000)) + r2.z;
            r0.x = r0.x + -cb0[4].z;
            r2.w = r2.z * r2.z;
            r3.x = r2.z * r2.w;
            r3.y = r2.z * r3.x;
            r3.z = (r2.z < l(5.000000));
            r3.xw = r3.xxxx * l(0.007760, 0.000000, 0.000000, 0.000011);
            r3.xy = (r3.yyyy * l(-0.000564, -0.000000, 0.000000, 0.000000)) + r3.xwxx;
            r3.xy = (-r2.wwww * l(0.044000, 0.000953, 0.000000, 0.000000)) + r3.xyxx;
            r3.xy = (r2.zzzz * l(0.192000, 0.059000, 0.000000, 0.000000)) + r3.xyxx;
            r3.xy = r3.xyxx + l(0.163000, 0.393000, 0.000000, 0.000000);
            r2.w = (r3.z) ? r3.x : r3.y;
            r0.xz = r0.xxzx * l(0.500000, 0.000000, 0.500000, 0.000000);
            sincos(null, r0.x, r0.x);
            r2.z = r2.z + r2.z;
            r0.x = log2(|r0.x|);
            r0.x = r0.x * r2.z;
            r0.x = exp2(r0.x);
            r0.x = (r2.w * r0.x) + -r1.w;
            r0.x = (cb0[4].w * r0.x) + r1.w;
            r0.x = r0.x * r1.z;
            r0.x = r0.w * r0.x;
            r0.x = (r1.y * r0.w) + r0.x;
            r0.w = l(6.283185) / cb0[0].y;
            r0.x = r0.x + r0.x;
            r0.x = |r0.z| * r0.x;
            r0.x = r0.x / r1.x;
            r0.z = r0.w * r0.w;
            r0.x = r0.x * r0.z;
            r0.x = sqrt(r0.x);
            r0.xz = r0.xxxx * r2.xxyx;
        else
            r0.xyz = l(0,0,0,0);
        }
    else
        r0.xyz = l(0,0,0,0);
    }
    store_uav_typed(u0.xyzw, vThreadID.xyyy, r0.xzxx);
    store_uav_typed(u1.xyzw, vThreadID.xyyy, r0.yyyy);
    return;
    // asm: // Approximately 338 instruction slots used
}

// -----------------------------------------------------------------------------
// Shader 2
// Profile: cs_5_0
// Byte offset: 40380
// Byte length: 3108
// -----------------------------------------------------------------------------

// Reflected buffer definitions
cbuffer $Globals
{
  bool g_isTAAEnabledBranch;         // Offset:    0 Size:     4 [unused]
     = 0xffffffff 
  float g_L;                         // Offset:    4 Size:     4 [unused]
  float2 g_cutoffLowHigh;            // Offset:    8 Size:     8 [unused]
  float g_dispMapSize;               // Offset:   16 Size:     4
  float g_gravity;                   // Offset:   20 Size:     4 [unused]
  float g_depth;                     // Offset:   24 Size:     4 [unused]
  float g_windSpeed;                 // Offset:   28 Size:     4 [unused]
  float g_fetch;                     // Offset:   32 Size:     4 [unused]
  float g_spectrumAmplitude;         // Offset:   36 Size:     4 [unused]
  float g_peakEnhance;               // Offset:   40 Size:     4 [unused]
  float g_windAngle;                 // Offset:   44 Size:     4 [unused]
  float g_spreadBlend;               // Offset:   48 Size:     4 [unused]
  float g_swell;                     // Offset:   52 Size:     4 [unused]
  float g_windSpeedLargeWave;        // Offset:   56 Size:     4 [unused]
  float g_fetchLargeWave;            // Offset:   60 Size:     4 [unused]
  float g_spectrumAmplitudeLargeWave;// Offset:   64 Size:     4 [unused]
  float g_peakEnhanceLargeWave;      // Offset:   68 Size:     4 [unused]
  float g_windAngleLargeWave;        // Offset:   72 Size:     4 [unused]
  float g_spreadBlendLargeWave;      // Offset:   76 Size:     4 [unused]
  float g_swellLargeWave;            // Offset:   80 Size:     4 [unused]
  float g_currSimTime;               // Offset:   84 Size:     4
}

// Reflected resource bindings
// Name                                 Type  Format         Dim      HLSL Bind  Count
// ------------------------------ ---------- ------- ----------- -------------- ------
// g_h0Texture                       texture  float2          2d             t0      1 
// g_omegaTexture                    texture   float          2d             t1      1 
// g_tildeHOutTexture                    UAV  float2          2d             u0      1 
// g_tildeDOutTexture                    UAV  float2          2d             u1      1 
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
void cs_02_cs_5_0()
{
    // Decompiled from DXBC instructions.
    // Declarations and operations below are approximations.

    // dcl_globalFlags refactoringAllowed
    // dcl_constantbuffer CB0[6], immediateIndexed
    // dcl_resource_texture2d (float,float,float,float) t0
    // dcl_resource_texture2d (float,float,float,float) t1
    // dcl_uav_typed_texture2d (float,float,float,float) u0
    // dcl_uav_typed_texture2d (float,float,float,float) u1
    // dcl_input vThreadID.xy
    float4 r[5];
    // numthreads(16, 16, 1)
    r0.x = (int)cb0[1].x;
    r0.yz = (r0.xxxx < vThreadID.xxyx);
    r0.y = r0.z | r0.y;
    if (r0.y) {
        return;
    }
    r1.xy = r0.xxxx + -vThreadID.xyxx;
    r2.xy = vThreadID.xyxx;
    r2.zw = l(0,0,0,0);
    // asm: ld_indexable(texture2d)(float,float,float,float) r0.yz, r2.xyww, t0.zxyw
    r1.zw = l(0,0,0,0);
    // asm: ld_indexable(texture2d)(float,float,float,float) r1.xy, r1.xyzw, t0.xyzw
    // asm: ld_indexable(texture2d)(float,float,float,float) r0.w, r2.xyzw, t1.yzwx
    r0.w = r0.w * cb0[5].y;
    sincos(r2.x, r3.x, r0.w);
    r1.zw = r0.yyyz + r1.xxxy;
    r0.w = r1.w * r2.x;
    r4.xzw = (r3.xxxx * r1.zzzz) + -r0.wwww;
    r0.yz = r0.zzyz + -r1.yyxy;
    r0.z = r0.z * r2.x;
    r4.y = (r3.x * r0.y) + r0.z;
    r0.y = r0.x ^ l(2);
    // asm: imax r0.x, r0.x, -r0.x
    r0.x = r0.x >> l(1);
    // asm: ineg r0.z, r0.x
    r0.y = r0.y & l(0x80000000);
    r0.x = (r0.y) ? r0.z : r0.x;
    r0.xy = r0.xxxx + -vThreadID.xyxx;
    r0.xy = (float)r0.xyxx;
    r0.z = dot2(r0.xyxx, r0.xyxx);
    r0.w = (l(0.000000) < r0.z);
    r0.z = rsqrt(r0.z);
    r0.xy = r0.zzzz * r0.xyxx;
    r0.xy = r0.xyxx & r0.wwww;
    r1.w = r0.x * -r4.w;
    r1.xyz = r0.yxyy * r4.wyyw;
    store_uav_typed(u0.xyzw, vThreadID.xyyy, r4.xyzw);
    r0.xyzw = r1.xzxx + r1.ywyy;
    store_uav_typed(u1.xyzw, vThreadID.xyyy, r0.xyzw);
    return;
    // asm: // Approximately 40 instruction slots used
}

