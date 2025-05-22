Shader "Custom/DrawToSnow"
{
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Pass
        {
ZTest Always

ZWrite Off

Cull Off

Blend One

One // <-- sobrescribe

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
#include "UnityCG.cginc"

float4 _DrawPosition; // XY = UV
float _Radius;
float _Strength; // de 0 a 1

struct v2f
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
};

v2f vert(uint id : SV_VertexID)
{
    float2 quad[6] =
    {
        float2(-1, -1), float2(1, -1), float2(1, 1),
                    float2(-1, -1), float2(1, 1), float2(-1, 1)
    };
    v2f o;
    o.pos = float4(quad[id], 0, 1);
    o.uv = (quad[id] + 1.0) * 0.5;
    return o;
}

float4 frag(v2f i) : SV_Target
{
    float dist = distance(i.uv, _DrawPosition.xy);
    float falloff = smoothstep(_Radius, 0, dist);
    float value = 1 - (_Strength * falloff); // invertir
    
    return float4(value, 0, 0, 1);
}
            ENDCG
        }
    }
}